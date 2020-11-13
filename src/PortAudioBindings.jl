module PortAudioBindings
using Unitful
using Unitful: s

import Libdl

# Load in `deps.jl`, complaining if it does not exist

#const depsjl_path = joinpath(@__DIR__, "..", "deps", "deps.jl")
#if !isfile(depsjl_path)
#    error("PortAudioBindings was not build properly. Please run Pkg.build(\"PortAudioBindings\").")
#end
#include(depsjl_path)
## Module initialization function
#function __init__()
#    check_deps()
#end

using CEnum

include("ctypes.jl")
export Ctm, Ctime_t, Cclock_t
const libportaudio = "libportaudio"
include("libportaudio_manual.jl")
include("libportaudio_common.jl")
include("libportaudio_api.jl")

# export everything
foreach(names(@__MODULE__, all=true)) do s
    if startswith(string(s), "Pa") || startswith(string(s), "pa")
        @eval export $s
    end
end

using SampleArrays

export paerr, listdevices, device_id_by_name, device_id_default_in, device_id_default_out
export play, record, recordresponse

function paerr(err)
    if err != 0
        txt = unsafe_string(Pa_GetErrorText(err))
        @error "PortAudio Error ($err): $txt"
    end
    err
end

function listdevices()
    Pa_Initialize() |> paerr

    ndevices = Pa_GetDeviceCount()
    defin = Pa_GetDefaultInputDevice()
    defout = Pa_GetDefaultOutputDevice()
    devs = NamedTuple[]
    for i in 0:ndevices-1
        devinfo = unsafe_load(Pa_GetDeviceInfo(i))
        push!(devs, (
            name = unsafe_string(devinfo.name),
            nins = devinfo.maxInputChannels,
            nouts = devinfo.maxOutputChannels,

            rate = devinfo.defaultSampleRate * u"Hz",
            inlowlatency = devinfo.defaultLowInputLatency * u"s",
            outlowlatency = devinfo.defaultLowOutputLatency * u"s",
            inhighlatency = devinfo.defaultHighInputLatency * u"s",
            outhighlatency = devinfo.defaultHighOutputLatency * u"s",
            defaultin = i == defin,
            defaultout = i == defout,
        ))
        deviceName = unsafe_string(devinfo.name)
    end
    Pa_Terminate() |> paerr
    devs
end

function device_id_by_name(name::AbstractString)
    devs = listdevices()
    id = findfirst(e -> e.name == name, devs)
    if isnothing(id)
        error("PortAudio: unknown device: $name")
    end
    id
end

function device_id_default_in()
    err = Pa_Initialize() |> paerr
    if err != 0
        error("PortAudio failed!")
    end
    id = Pa_GetDefaultInputDevice()
    Pa_Terminate() |> paerr
    id
end

function device_id_default_out()
    err = Pa_Initialize() |> paerr
    if err != 0 
        error("PortAudio failed!")
    end
    id = Pa_GetDefaultOutputDevice()
    Pa_Terminate() |> paerr
    id
end

function play(x::SampleArray; bsize=512)
    nchannels_, nframes_, rate_ = nchannels(x), nframes(x), rate(x)
    
    err = Pa_Initialize()
    paerr(err)
    
    outid = Pa_GetDefaultOutputDevice()
    outinfo = unsafe_load(Pa_GetDeviceInfo(outid));
    @info "output: $(unsafe_string(outinfo.name)), #channels: $(nchannels_)"
    
    outParams = PaStreamParameters(outid, nchannels_, paFloat32, 
        outinfo.defaultHighInputLatency, C_NULL)
    
    stream = Ref(Ptr{PaStream}(C_NULL))    
    
    err = Pa_OpenStream(
        stream,
        C_NULL,
        Ref(outParams),
        rate_,
        bsize,
        paClipOff,
        C_NULL,
        C_NULL)
    paerr(err)

    samplebuf = zeros(Float32, nchannels_, bsize)
    
    err = Pa_StartStream(stream[])
    paerr(err)

    samples = data(x)'
    
    off = 1
    while off <= nframes_
        high = min(off + bsize -1, nframes_)
        highbuf = high-off+1
        samplebuf[:, 1:highbuf] .= samples[:, off:high]
        samplebuf[:, highbuf+1:end] .= 0
        err = Pa_WriteStream(stream[], pointer(samplebuf), bsize)
        paerr(err)
        off += bsize        
    end
    
    err = Pa_Terminate()
    paerr(err)
end

function record(; s=1.0, rate=44100.0, bsize=512)
    error("FIX!")
    nblocks = ceil(Int, s*rate/bsize)
    @show nblocks
    
    err = Pa_Initialize() |> paerr
    
    indev = Pa_GetDefaultInputDevice()
    ininfo = unsafe_load(Pa_GetDeviceInfo(indev))
    
    numchannels = 1
    inparams = PaStreamParameters(indev, numchannels, paFloat32, 
        ininfo.defaultHighInputLatency, C_NULL)
    
    stream = Ref(Ptr{PaStream}(C_NULL))    
    
    err = Pa_OpenStream(
        stream,
        Ref(inparams),
        C_NULL,
        rate,
        bsize,
        paClipOff,
        C_NULL,
        C_NULL)
    paerr(err)

    samplebuf = zeros(Float32, numchannels, bsize)
    samples = zeros(Float32, numchannels, nblocks * bsize)
    
    err = Pa_StartStream(stream[]) |> paerr
    
    off = 1
    for i in 1:nblocks
        err = Pa_ReadStream(stream[], pointer(samplebuf), bsize) |> paerr
        samples[:, off:off+bsize-1] .= samplebuf
        off += bsize
    end
    
    err = Pa_Terminate() |> paerr
    return samples
end

function recordresponse(x::SampleArray; indev=nothing, outdev=nothing, post::Time=1.0s, bsize=512)
    err = Pa_Initialize() |> paerr
    post = tos(post)
    
    noutchannels, nframes_, rate_ = nchannels(x), nframes(x), rate(x)
    
    indev = isnothing(indev) ? Pa_GetDefaultInputDevice() : indev
    ininfo = unsafe_load(Pa_GetDeviceInfo(indev));
    ninchannels = 2
    inparams = PaStreamParameters(indev, ninchannels, paFloat32, ininfo.defaultHighInputLatency, C_NULL)
    @debug "input: $(unsafe_string(ininfo.name)), #channels: $(ninchannels)"
    
    outdev = isnothing(outdev) ? Pa_GetDefaultOutputDevice() : outdev
    outinfo = unsafe_load(Pa_GetDeviceInfo(outdev)); 
    outparams = PaStreamParameters(outdev, noutchannels, paFloat32, outinfo.defaultHighInputLatency, C_NULL)
    @debug "output: $(unsafe_string(outinfo.name)), #channels: $(noutchannels)"
    
    stream = Ref(Ptr{PaStream}(C_NULL))    
    
    err = Pa_OpenStream(
        stream,
        Ref(inparams),
        Ref(outparams),
        rate_,
        bsize,
        paClipOff,
        C_NULL,
        C_NULL) |> paerr

    nframesrec = nframes_ + ceil(Int, post * rate_)
    @debug "input signal frames: $nframes_, frames to record: $nframesrec"
    sampleinbuf = zeros(Float32, ninchannels, bsize)
    sampleoutbuf = zeros(Float32, noutchannels, bsize)
    y = similar(x, nframesrec, ninchannels)
    samples = data(y)'
    samples .= 0
    
    err = Pa_StartStream(stream[]) |> paerr

    insignal = data(x)'
    
    off = 1
    while off <= nframes_
        high = min(off + bsize -1, nframes_)
        highbuf = high-off+1
        sampleoutbuf[:, 1:highbuf] .= insignal[:, off:high]
        sampleoutbuf[:, highbuf+1:end] .= 0
        err = Pa_WriteStream(stream[], pointer(sampleoutbuf), bsize) |> paerr
        err = Pa_ReadStream(stream[], pointer(sampleinbuf), bsize) |> paerr
        samples[:, off:off+bsize-1] .= sampleinbuf
        
        off += bsize
    end
    
    while off <= nframesrec
        err = Pa_ReadStream(stream[], pointer(sampleinbuf), bsize) |> paerr
        high = min(off + bsize -1, nframesrec)
        highbuf = high-off+1
        samples[:, off:high] .= sampleinbuf[:, 1:highbuf]
        
        off += bsize
    end
    
    err = Pa_Terminate() |> paerr
    y
end

end # module

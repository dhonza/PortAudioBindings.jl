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

export paerr, PortAudio, listdevices, device_id_by_name, device_id_default_in, device_id_default_out
export play, record, recordresponse

function paerr(err)
    if err != 0
        txt = unsafe_string(Pa_GetErrorText(err))
        @error "PortAudio Error ($err): $txt"
    end
    err
end

mutable struct PortAudio
    # TODO add some state variables, e.g., default devices, channels, sample rate?
    function PortAudio()
        err = Pa_Initialize() |> paerr
        if err != 0
            error("failed to initialize PortAudio!")
        end
        pa = new()

        function f(pa_)
            @async println("finalizing PortAudio")
            err = Pa_Terminate() |> paerr
            if err != 0
                error("failed to initialize PortAudio!")
            end
        end

        finalizer(f, pa)
    end
end

function listdevices(::PortAudio)
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
    devs
end

function device_id_by_name(pa::PortAudio, name::AbstractString)
    devs = listdevices(pa)
    id = findfirst(e -> e.name == name, devs)
    if isnothing(id)
        error("PortAudio: unknown device: $name")
    end
    id-1
end

function device_id_default_in(::PortAudio)
    Pa_GetDefaultInputDevice()
end

function device_id_default_out(::PortAudio)
    Pa_GetDefaultOutputDevice()
end

function play(::PortAudio, x::SampleArray; outdev=nothing, bsize=512)
    nchannels_, nframes_, rate_ = nchannels(x), nframes(x), rate(x)
    
    outdev = isnothing(outdev) ? Pa_GetDefaultOutputDevice() : outdev
    outinfo = unsafe_load(Pa_GetDeviceInfo(outdev));

    @debug "output: $(unsafe_string(outinfo.name)), #channels: $(nchannels_)"
    
    outParams = PaStreamParameters(outdev, nchannels_, paFloat32, 
        outinfo.defaultHighOutputLatency, C_NULL)
    
    stream = Ref(Ptr{PaStream}(C_NULL))    
    
    Pa_OpenStream(
        stream,
        C_NULL,
        Ref(outParams),
        rate_,
        bsize,
        paClipOff,
        C_NULL,
        C_NULL) |> paerr

    samplebuf = zeros(Float32, nchannels_, bsize)
    
    Pa_StartStream(stream[]) |> paerr

    samples = data(x)'
    
    off = 1
    while off <= nframes_
        high = min(off + bsize -1, nframes_)
        highbuf = high-off+1
        samplebuf[:, 1:highbuf] .= samples[:, off:high]
        samplebuf[:, highbuf+1:end] .= 0
        Pa_WriteStream(stream[], pointer(samplebuf), bsize) |> paerr
        off += bsize        
    end

    Pa_StopStream(stream[]) |> paerr
    Pa_CloseStream(stream[]) |> paerr
end

function record(::PortAudio; s=1.0, rate=44100.0, indev=nothing, nins=nothing, bsize=512)
    nblocks = ceil(Int, s*rate/bsize)
        
    indev = isnothing(indev) ? Pa_GetDefaultInputDevice() : indev
    ininfo = unsafe_load(Pa_GetDeviceInfo(indev))
    nins = isnothing(nins) ? ininfo.maxInputChannels : nins
    
    inparams = PaStreamParameters(indev, nins, paFloat32, 
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
        C_NULL) |> paerr
    
    if err != 0
        return
    end

    samplebuf = zeros(Float32, nins, bsize)
    samples = zeros(Float32, nins, nblocks * bsize)
    
    err = Pa_StartStream(stream[]) |> paerr
    
    off = 1
    for i in 1:nblocks
        Pa_ReadStream(stream[], pointer(samplebuf), bsize) |> paerr
        samples[:, off:off+bsize-1] .= samplebuf
        off += bsize
    end

    Pa_StopStream(stream[]) |> paerr
    Pa_CloseStream(stream[]) |> paerr

    return SampleArray(samples', rate)
end

function recordresponse(::PortAudio, x::SampleArray; indev=nothing, outdev=nothing, nins=nothing, post::Time=1.0s, bsize=512)
    post = tos(post)
    
    nouts, nframes_, rate_ = nchannels(x), nframes(x), rate(x)
    
    indev = isnothing(indev) ? Pa_GetDefaultInputDevice() : indev
    ininfo = unsafe_load(Pa_GetDeviceInfo(indev));
    outdev = isnothing(outdev) ? Pa_GetDefaultOutputDevice() : outdev
    outinfo = unsafe_load(Pa_GetDeviceInfo(outdev)); 
    nins = isnothing(nins) ? ininfo.maxInputChannels : nins

    inparams = PaStreamParameters(indev, nins, paFloat32, ininfo.defaultHighInputLatency, C_NULL)
    @debug "input: $(unsafe_string(ininfo.name)), #channels: $(nins)"
    
    outparams = PaStreamParameters(outdev, nouts, paFloat32, ininfo.defaultHighOutputLatency, C_NULL)
    @debug "output: $(unsafe_string(outinfo.name)), #channels: $(nouts)"
    
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
    
    if err != 0
        return
    end

    nframesrec = nframes_ + ceil(Int, post * rate_)
    @debug "input signal frames: $nframes_, frames to record: $nframesrec"
    sampleinbuf = zeros(Float32, nins, bsize)
    sampleoutbuf = zeros(Float32, nouts, bsize)
    y = similar(x, nframesrec, nins)
    samples = data(y)'
    samples .= 0
    
    Pa_StartStream(stream[]) |> paerr

    insignal = data(x)'
    
    off = 1
    werr = 0
    woffs = []
    rerr = 0
    while off <= nframes_
        high = min(off + bsize -1, nframes_)
        highbuf = high-off+1
        sampleoutbuf[:, 1:highbuf] .= insignal[:, off:high]
        sampleoutbuf[:, highbuf+1:end] .= 0
        # @show high
        # @show highbuf
        # @show off
        # @show 1:highbuf, off:high
        
        err = Pa_WriteStream(stream[], pointer(sampleoutbuf), bsize)
        if err != 0
            werr = err
            push!(woffs, off)
        end

        err = Pa_ReadStream(stream[], pointer(sampleinbuf), bsize)
        if err != 0
            rerr = err
        end

        samples[:, off:off+bsize-1] .= sampleinbuf
        # if off > 1024
            # break
        # end
        off += bsize
    end
    
    while off <= nframesrec
        err = Pa_ReadStream(stream[], pointer(sampleinbuf), bsize)
        if err != 0
            rerr = err
        end
        high = min(off + bsize -1, nframesrec)
        highbuf = high-off+1
        samples[:, off:high] .= sampleinbuf[:, 1:highbuf]
        
        off += bsize
    end
    
    paerr(werr)
    @error "offsets: $woffs"
    paerr(rerr)
    
    Pa_StopStream(stream[]) |> paerr
    i = 1
    while true
        err = Pa_IsStreamActive(stream[])
        if err != 1
            break
        end
        @show i, err
        Pa_Sleep(1000);
        i += 1
    end
    
    # Pa_AbortStream(stream[]) |> paerr
    Pa_CloseStream(stream[]) |> paerr

    y
end

end # module

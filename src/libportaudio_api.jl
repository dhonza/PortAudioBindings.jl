# Julia wrapper for header: portaudio.h
# Automatically generated using Clang.jl


function Pa_GetVersion()
    ccall((:Pa_GetVersion, libportaudio), Cint, ())
end

function Pa_GetVersionText()
    ccall((:Pa_GetVersionText, libportaudio), Cstring, ())
end

function Pa_GetVersionInfo()
    ccall((:Pa_GetVersionInfo, libportaudio), Ptr{PaVersionInfo}, ())
end

function Pa_GetErrorText(errorCode)
    ccall((:Pa_GetErrorText, libportaudio), Cstring, (PaError,), errorCode)
end

function Pa_Initialize()
    ccall((:Pa_Initialize, libportaudio), PaError, ())
end

function Pa_Terminate()
    ccall((:Pa_Terminate, libportaudio), PaError, ())
end

function Pa_GetHostApiCount()
    ccall((:Pa_GetHostApiCount, libportaudio), PaHostApiIndex, ())
end

function Pa_GetDefaultHostApi()
    ccall((:Pa_GetDefaultHostApi, libportaudio), PaHostApiIndex, ())
end

function Pa_GetHostApiInfo(hostApi)
    ccall((:Pa_GetHostApiInfo, libportaudio), Ptr{PaHostApiInfo}, (PaHostApiIndex,), hostApi)
end

function Pa_HostApiTypeIdToHostApiIndex(type)
    ccall((:Pa_HostApiTypeIdToHostApiIndex, libportaudio), PaHostApiIndex, (PaHostApiTypeId,), type)
end

function Pa_HostApiDeviceIndexToDeviceIndex(hostApi, hostApiDeviceIndex)
    ccall((:Pa_HostApiDeviceIndexToDeviceIndex, libportaudio), PaDeviceIndex, (PaHostApiIndex, Cint), hostApi, hostApiDeviceIndex)
end

function Pa_GetLastHostErrorInfo()
    ccall((:Pa_GetLastHostErrorInfo, libportaudio), Ptr{PaHostErrorInfo}, ())
end

function Pa_GetDeviceCount()
    ccall((:Pa_GetDeviceCount, libportaudio), PaDeviceIndex, ())
end

function Pa_GetDefaultInputDevice()
    ccall((:Pa_GetDefaultInputDevice, libportaudio), PaDeviceIndex, ())
end

function Pa_GetDefaultOutputDevice()
    ccall((:Pa_GetDefaultOutputDevice, libportaudio), PaDeviceIndex, ())
end

function Pa_GetDeviceInfo(device)
    ccall((:Pa_GetDeviceInfo, libportaudio), Ptr{PaDeviceInfo}, (PaDeviceIndex,), device)
end

function Pa_IsFormatSupported(inputParameters, outputParameters, sampleRate)
    ccall((:Pa_IsFormatSupported, libportaudio), PaError, (Ptr{PaStreamParameters}, Ptr{PaStreamParameters}, Cdouble), inputParameters, outputParameters, sampleRate)
end

function Pa_OpenStream(stream, inputParameters, outputParameters, sampleRate, framesPerBuffer, streamFlags, streamCallback, userData)
    ccall((:Pa_OpenStream, libportaudio), PaError, (Ptr{Ptr{PaStream}}, Ptr{PaStreamParameters}, Ptr{PaStreamParameters}, Cdouble, Culong, PaStreamFlags, Ptr{PaStreamCallback}, Ptr{Cvoid}), stream, inputParameters, outputParameters, sampleRate, framesPerBuffer, streamFlags, streamCallback, userData)
end

function Pa_OpenDefaultStream(stream, numInputChannels, numOutputChannels, sampleFormat, sampleRate, framesPerBuffer, streamCallback, userData)
    ccall((:Pa_OpenDefaultStream, libportaudio), PaError, (Ptr{Ptr{PaStream}}, Cint, Cint, PaSampleFormat, Cdouble, Culong, Ptr{PaStreamCallback}, Ptr{Cvoid}), stream, numInputChannels, numOutputChannels, sampleFormat, sampleRate, framesPerBuffer, streamCallback, userData)
end

function Pa_CloseStream(stream)
    ccall((:Pa_CloseStream, libportaudio), PaError, (Ptr{PaStream},), stream)
end

function Pa_SetStreamFinishedCallback(stream, streamFinishedCallback)
    ccall((:Pa_SetStreamFinishedCallback, libportaudio), PaError, (Ptr{PaStream}, Ptr{PaStreamFinishedCallback}), stream, streamFinishedCallback)
end

function Pa_StartStream(stream)
    ccall((:Pa_StartStream, libportaudio), PaError, (Ptr{PaStream},), stream)
end

function Pa_StopStream(stream)
    ccall((:Pa_StopStream, libportaudio), PaError, (Ptr{PaStream},), stream)
end

function Pa_AbortStream(stream)
    ccall((:Pa_AbortStream, libportaudio), PaError, (Ptr{PaStream},), stream)
end

function Pa_IsStreamStopped(stream)
    ccall((:Pa_IsStreamStopped, libportaudio), PaError, (Ptr{PaStream},), stream)
end

function Pa_IsStreamActive(stream)
    ccall((:Pa_IsStreamActive, libportaudio), PaError, (Ptr{PaStream},), stream)
end

function Pa_GetStreamInfo(stream)
    ccall((:Pa_GetStreamInfo, libportaudio), Ptr{PaStreamInfo}, (Ptr{PaStream},), stream)
end

function Pa_GetStreamTime(stream)
    ccall((:Pa_GetStreamTime, libportaudio), PaTime, (Ptr{PaStream},), stream)
end

function Pa_GetStreamCpuLoad(stream)
    ccall((:Pa_GetStreamCpuLoad, libportaudio), Cdouble, (Ptr{PaStream},), stream)
end

function Pa_ReadStream(stream, buffer, frames)
    ccall((:Pa_ReadStream, libportaudio), PaError, (Ptr{PaStream}, Ptr{Cvoid}, Culong), stream, buffer, frames)
end

function Pa_WriteStream(stream, buffer, frames)
    ccall((:Pa_WriteStream, libportaudio), PaError, (Ptr{PaStream}, Ptr{Cvoid}, Culong), stream, buffer, frames)
end

function Pa_GetStreamReadAvailable(stream)
    ccall((:Pa_GetStreamReadAvailable, libportaudio), Clong, (Ptr{PaStream},), stream)
end

function Pa_GetStreamWriteAvailable(stream)
    ccall((:Pa_GetStreamWriteAvailable, libportaudio), Clong, (Ptr{PaStream},), stream)
end

function Pa_GetSampleSize(format)
    ccall((:Pa_GetSampleSize, libportaudio), PaError, (PaSampleFormat,), format)
end

function Pa_Sleep(msec)
    ccall((:Pa_Sleep, libportaudio), Cvoid, (Clong,), msec)
end

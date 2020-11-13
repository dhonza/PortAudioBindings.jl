# Automatically generated using Clang.jl


# Skipping MacroDefinition: paMakeVersionNumber ( major , minor , subminor ) ( ( ( major ) & 0xFF ) << 16 | ( ( minor ) & 0xFF ) << 8 | ( ( subminor ) & 0xFF ) )
# Skipping MacroDefinition: paNoDevice ( ( PaDeviceIndex ) - 1 )
# Skipping MacroDefinition: paUseHostApiSpecificDeviceSpecification ( ( PaDeviceIndex ) - 2 )
# Skipping MacroDefinition: paFloat32 ( ( PaSampleFormat ) 0x00000001 )
# Skipping MacroDefinition: paInt32 ( ( PaSampleFormat ) 0x00000002 )
# Skipping MacroDefinition: paInt24 ( ( PaSampleFormat ) 0x00000004 )
# Skipping MacroDefinition: paInt16 ( ( PaSampleFormat ) 0x00000008 )
# Skipping MacroDefinition: paInt8 ( ( PaSampleFormat ) 0x00000010 )
# Skipping MacroDefinition: paUInt8 ( ( PaSampleFormat ) 0x00000020 )
# Skipping MacroDefinition: paCustomFormat ( ( PaSampleFormat ) 0x00010000 )
# Skipping MacroDefinition: paNonInterleaved ( ( PaSampleFormat ) 0x80000000 )

const paFormatIsSupported = 0
const paFramesPerBufferUnspecified = 0

# Skipping MacroDefinition: paNoFlag ( ( PaStreamFlags ) 0 )
# Skipping MacroDefinition: paClipOff ( ( PaStreamFlags ) 0x00000001 )
# Skipping MacroDefinition: paDitherOff ( ( PaStreamFlags ) 0x00000002 )
# Skipping MacroDefinition: paNeverDropInput ( ( PaStreamFlags ) 0x00000004 )
# Skipping MacroDefinition: paPrimeOutputBuffersUsingStreamCallback ( ( PaStreamFlags ) 0x00000008 )
# Skipping MacroDefinition: paPlatformSpecificFlags ( ( PaStreamFlags ) 0xFFFF0000 )
# Skipping MacroDefinition: paInputUnderflow ( ( PaStreamCallbackFlags ) 0x00000001 )
# Skipping MacroDefinition: paInputOverflow ( ( PaStreamCallbackFlags ) 0x00000002 )
# Skipping MacroDefinition: paOutputUnderflow ( ( PaStreamCallbackFlags ) 0x00000004 )
# Skipping MacroDefinition: paOutputOverflow ( ( PaStreamCallbackFlags ) 0x00000008 )
# Skipping MacroDefinition: paPrimingOutput ( ( PaStreamCallbackFlags ) 0x00000010 )

struct PaVersionInfo
    versionMajor::Cint
    versionMinor::Cint
    versionSubMinor::Cint
    versionControlRevision::Cstring
    versionText::Cstring
end

const PaError = Cint

@cenum PaErrorCode::Int32 begin
    paNoError = 0
    paNotInitialized = -10000
    paUnanticipatedHostError = -9999
    paInvalidChannelCount = -9998
    paInvalidSampleRate = -9997
    paInvalidDevice = -9996
    paInvalidFlag = -9995
    paSampleFormatNotSupported = -9994
    paBadIODeviceCombination = -9993
    paInsufficientMemory = -9992
    paBufferTooBig = -9991
    paBufferTooSmall = -9990
    paNullCallback = -9989
    paBadStreamPtr = -9988
    paTimedOut = -9987
    paInternalError = -9986
    paDeviceUnavailable = -9985
    paIncompatibleHostApiSpecificStreamInfo = -9984
    paStreamIsStopped = -9983
    paStreamIsNotStopped = -9982
    paInputOverflowed = -9981
    paOutputUnderflowed = -9980
    paHostApiNotFound = -9979
    paInvalidHostApi = -9978
    paCanNotReadFromACallbackStream = -9977
    paCanNotWriteToACallbackStream = -9976
    paCanNotReadFromAnOutputOnlyStream = -9975
    paCanNotWriteToAnInputOnlyStream = -9974
    paIncompatibleStreamHostApi = -9973
    paBadBufferPtr = -9972
end


const PaDeviceIndex = Cint
const PaHostApiIndex = Cint

@cenum PaHostApiTypeId::UInt32 begin
    paInDevelopment = 0
    paDirectSound = 1
    paMME = 2
    paASIO = 3
    paSoundManager = 4
    paCoreAudio = 5
    paOSS = 7
    paALSA = 8
    paAL = 9
    paBeOS = 10
    paWDMKS = 11
    paJACK = 12
    paWASAPI = 13
    paAudioScienceHPI = 14
end


struct PaHostApiInfo
    structVersion::Cint
    type::PaHostApiTypeId
    name::Cstring
    deviceCount::Cint
    defaultInputDevice::PaDeviceIndex
    defaultOutputDevice::PaDeviceIndex
end

struct PaHostErrorInfo
    hostApiType::PaHostApiTypeId
    errorCode::Clong
    errorText::Cstring
end

const PaTime = Cdouble
const PaSampleFormat = Culong

struct PaDeviceInfo
    structVersion::Cint
    name::Cstring
    hostApi::PaHostApiIndex
    maxInputChannels::Cint
    maxOutputChannels::Cint
    defaultLowInputLatency::PaTime
    defaultLowOutputLatency::PaTime
    defaultHighInputLatency::PaTime
    defaultHighOutputLatency::PaTime
    defaultSampleRate::Cdouble
end

struct PaStreamParameters
    device::PaDeviceIndex
    channelCount::Cint
    sampleFormat::PaSampleFormat
    suggestedLatency::PaTime
    hostApiSpecificStreamInfo::Ptr{Cvoid}
end

const PaStream = Cvoid
const PaStreamFlags = Culong

struct PaStreamCallbackTimeInfo
    inputBufferAdcTime::PaTime
    currentTime::PaTime
    outputBufferDacTime::PaTime
end

const PaStreamCallbackFlags = Culong

@cenum PaStreamCallbackResult::UInt32 begin
    paContinue = 0
    paComplete = 1
    paAbort = 2
end


# Skipping Typedef: CXType_FunctionProto PaStreamCallback
# Skipping Typedef: CXType_FunctionProto PaStreamFinishedCallback

struct PaStreamInfo
    structVersion::Cint
    inputLatency::PaTime
    outputLatency::PaTime
    sampleRate::Cdouble
end

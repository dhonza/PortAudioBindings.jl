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
const paFloat32 = 0x00000001
const paNonInterleaved = 0x80000000

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

const paClipOff = 0x00000001

# Skipping Typedef: CXType_FunctionProto PaStreamCallback
const PaStreamCallback = Cvoid
# Skipping Typedef: CXType_FunctionProto PaStreamFinishedCallback
const PaStreamFinishedCallback = Cvoid
# PortAudioBindings.jl
Julia bindings for PortAudio 

Note thate PortAudio library must be in the search path. For MacOS with Homebrew use: 
```bash
brew install portaudio

export LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH"
```
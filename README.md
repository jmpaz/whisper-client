# whisper-transcribe
Written after months of meaning to transcribe years' worth of voice memos 

## About
- Runs a hardcoded command (currently `whisper_cli -m large --lang en`) over files in an input directory; leaves output .txt and .vtt in a target directory while maintaining subfolder structure

## Usage
`whisper-transcribe -s "path/to/input" -d "/path/to/output"`

## To Do
- Run whisper itself
- Delete empty folders after transcription
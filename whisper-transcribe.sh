#!/usr/bin/env bash

# Check if the command is available
if ! [ -x "$(command -v whisper_cli)" ]; then
  echo 'Error: whisper_cli is not installed or not in the PATH.' >&2
  exit 1
fi

# Parse command-line arguments
while getopts ":s:d:" opt; do
  case $opt in
    s|--source)
      source_dir="$OPTARG"
      ;;
    d|--destination)
      dest_dir="$OPTARG"
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

# Check if the source directory exists and is accessible
if [ ! -d "$source_dir" ]; then
    echo "Error: source directory $source_dir does not exist or is not accessible"
    exit 1
fi

# Check if the destination directory exists and is accessible
if [ ! -d "$dest_dir" ]; then
    echo "Error: destination directory $dest_dir does not exist or is not accessible"
    exit 1
fi

# The command we will run is defined below (defaults to whisper_cli -m large --lang en). We'll append to this command the file we're currently processing.
cmd="whisper_cli -m large --lang en"

# Counter variable to keep track of the number of files processed
counter=0

# Function to process a single file
function process_file() {
    file="$1"
    echo "Processing file: $file"
    $cmd "$file"
    IFS=$'\n' # set the internal field separator to a newline so that we can iterate over the output of the command
    if [ $? -eq 0 ]; then
        # move associated files to the destination directory if the command succeeded
        filename=$(basename "$file")
        filename="${filename%.*}"
        mkdir -p "$dest_dir/$(dirname $file | sed -e "s|$source_dir||g")" # create the destination directory if it doesn't exist
        processed_dir="$dest_dir/$(dirname $file | sed -e "s|$source_dir||g")"
        mkdir -p "$processed_dir"
        mv -n "$file" "$processed_dir"
        mv -n "$file.txt" "$processed_dir"
        mv -n "$file.vtt" "$processed_dir"

        rm "$file.srt" # remove the redundant .srt file
        echo "Successfully processed file: $file"
        ((counter++))
    else
        # if the command failed, log the error
        echo "Error processing file: $file"
        echo "Error code: $?"
    fi
    IFS=$' ' # reset the internal field separator to a space
}

# run the command recursively on all files in a directory
function process_directory() {
    for file in "$1"/*; do
        if [ -d "$file" ]; then
            process_directory "$file" # if the file is a directory, recursively call the function on that directory
            elif [ -f "$file" ]; then
            # if the file is a regular file, process it
            process_file "$file"
        fi
    done

}


# call the function to start the recursive command execution
process_directory "$source_dir"
clean_empty_subdirs "$source_dir"

echo "All files in $source_dir have been processed and moved to $dest_dir"
echo "$counter files processed successfully"

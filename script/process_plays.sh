#!/bin/bash

# Set the input directory
input_dir="/path/to/input_dir"

# Set the output directory
output_dir="/path/to/output_dir"

# Check if input_dir and output_dir are the same
if [ "$input_dir" -ef "$output_dir" ]; then
  echo "Error: input_dir and output_dir cannot be the same directory"
  exit 1
fi

# Initialise the loop counter
counter=1

# Loop over all files in the input directory
for file in "$input_dir"/*.xml
do
  # Check if the file is a regular file
  if [[ -f "$file" ]]; then
    # Extract the file name without the extension
    filename=$(basename "$file" .xml)

    # Remove control and newline characters from the file using tr command
    tr -dc '[:print:]' < "$file" > "$output_dir/$filename.csv.tmp"
    
    # Remove XML declaration and DOCTYPE declaration from the file using sed command
    sed -e '1s/<?xml version="1.0"?>//' -e '1s/<!DOCTYPE PLAY SYSTEM "play.dtd">//'< "$output_dir/$filename.csv.tmp" > "$output_dir/$filename.csv"
    
    # Add the loop counter at the beginning of the output file
    sed -i "1s/^/$counter|/" "$output_dir/$filename.csv"
    
    # Remove the temporary file
    rm "$output_dir/$filename.csv.tmp"
    
    # Increment the loop counter
    counter=$((counter+1))
  fi
done

# Concatenate all output files into a single file
for file in "$output_dir"/*.csv
do
  if [[ -f "$file" ]] && [[ "$file" != "$output_dir/all_plays.csv" ]]; then
    cat "$file" >> "$output_dir/all_plays.csv"
    echo >> "$output_dir/all_plays.csv"
    rm "$file"
  fi
done

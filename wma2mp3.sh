#!/bin/bash

usage="./$(basename "$0") [-h] [-d] [-f] [-o] [-e] -- convert wav files to mp3 using ffmpeg

options:
	-h show this help message
	-d look for files in this directory
	-f convert these files
	-o write output to this location
	-e file extension to look for"


if [ $# -lt 2 ]; then
	echo "$usage"
	exit
fi

output_directory="."
file_extension="*"

while getopts :hd:f:o:e: option; do
	case "$option" in
		h)	echo "$usage"
			exit
			;;
		d)	input_directories+=("$OPTARG")
			;;
		f)	files+=("$OPTARG")
			;;
		o)	output_directory="$OPTARG"
			;;
		e)	file_extension="*$OPTARG"
			;;
	esac
done

# set intenal field separator to newline to handle filenames with whitespace correctly
IFS=$'\n'

for directory in ${input_directories[@]}; do
	for file in $(find "$directory" -name "$file_extension"); do
		basename="${file##*/}"
		ffmpeg -i $file -codec:a libmp3lame -qscale:a 2 $output_directory/"${basename::-4}".mp3
	done
done

if [[ ! -z $files ]]; then
	for file in ${files[@]}; do
		basename="${file##*/}"
		ffmpeg -i $f -codec:a libmp3lame -qscale:a 2 $output_directory/"${basename::-4}".mp3
	done
fi

echo "\nAll done!"

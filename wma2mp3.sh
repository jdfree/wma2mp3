#!/bin/bash

usage="./$(basename "$0") [-h] [-d] [-f] [-o] [-e] -- convert wma files to mp3 using ffmpeg
options:
	-h show this help message
	-d look for files in this directory
	-f convert these files
	-o write output to this location
	-e file extension to look for
	-n new file extension
	-p preserve directory structure in output"


if [ $# -lt 2 ]; then
	echo "$usage"
	exit
fi

output_directory="."
file_extension="*"
new_file_extension="mp3"

while getopts :hd:f:o:e:n:p option; do
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
		n)	new_file_extension="$OPTARG"
			;;
		p)	preserve_structure=true
			;;
	esac
done

if [ $preserve_structure ]; then
	echo "Preserving directory structure"
fi

# set intenal field separator to newline to handle filenames with whitespace correctly
IFS=$'\n'

mkdir -p $output_directory

convert_file()
{
	directory=$1
	file=$2
	path=$(dirname "${file}")
        basename=$(echo "${file##*/}" | cut -f 1 -d '.')
	newfile=$output_directory/$basename.$new_file_extension
	if [ $preserve_structure ]; then
		newfile=$output_directory${path#$directory}/$basename.$new_file_extension
        	mkdir -p $output_directory${path#$directory}
	fi
	echo "Transcribing $file to $newfile"
        ffmpeg -y -i $file -codec:a libmp3lame -qscale:a 2 -loglevel warning $newfile
}

for directory in ${input_directories[@]}; do
	for file in $(find "$directory" -name "$file_extension"); do
		convert_file $directory $file
	done
done

if [[ ! -z $files ]]; then
	for file in ${files[@]}; do
		convert_file $directory $file
	done
fi

echo "All done!"


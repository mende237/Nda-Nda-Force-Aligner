#!/bin/bash

calling_script_path=$(pwd)
# Get the path to the script
script_path="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
cd "$script_path" || exit 1

source ../utils.sh


if [ $# -ne 1 ]; then
    print_info "Usage: $0 <data folder path>"
    exit 1
fi

data_folder_path="$1"


find "$data_folder_path" -type f -iname "*.TextGrid" | while read -r textgrid_file; do
    ctm_file="${textgrid_file%.TextGrid}.ctm"
    python "./convert_textgrid_to_ctm.py" "$textgrid_file" "$ctm_file"
done



cd "$calling_script_path" || exit 1
#!/bin/bash

calling_script_path=$(pwd)

script_path="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
cd "$script_path" || exit 1
source "./utils.sh"


if [ $# -ne 2 ]; then
    print_info "Usage: $0 <project name> <data folder root>" 
    exit 1
fi

project_name=$1
data_folder_root=$2

lexicon_file=$KALDI_INSTALLATION_PATH/egs/$project_name/data/local/lang/lexicon.txt


if ! is_file_exist $lexicon_file; then
    print_error "File doesn't exist : $lexicon_file"
    exit 1
fi

python triphone_count.py $lexicon_file $data_folder_root/utterance.txt

# python word_count_occurence.py $data_folder_root/utterance.txt


cd $calling_script_path || exit 1
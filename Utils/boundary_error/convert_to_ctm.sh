#!/bin/bash

calling_script_path=$(pwd)
# Get the path to the script
script_path="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
cd "$script_path" || exit 1

source ../utils.sh


if [ $# -ne 3 ]; then
    print_info "Usage: $0 <project name> <model folder> <align folder>"
    exit 1
fi

project_name=$1
model_folder_path="$KALDI_INSTALLATION_PATH/egs/$project_name/exp/$2"
align_folder_path="$KALDI_INSTALLATION_PATH/egs/$project_name/exp/$3"

project_setup_verification "$project_name"

cd "$align_folder_path" || exit 1
print_info "The current directory is: $align_folder_path"

for i in ali.*.gz; do
    "../../src/bin/ali-to-phones" --ctm-output "$model_folder_path/final.mdl" "ark:gunzip -c $i |" "${i%.gz}.ctm"
done

cat *.ctm > merged_alignment.ctm

cd "$calling_script_path" || exit 1
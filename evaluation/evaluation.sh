#!/bin/bash 

calling_script_path=$(pwd)
# Get the path to the script
script_path="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
cd "$script_path" || exit 1
source ../Utils/utils.sh

if [ $# -ne 2 ] && [ $# -ne 3 ]; then
    print_error "Please provide a project name."
    print_info "Usage: $0 <project name> <data folder name> <model folder name> <lang dir|graph dir> <decode folder name>"
    exit 1
fi

project_name=$1
data_folder_name=$2
model_folder_name=$3
lang_dir=$4
decode_folder_name=$5

project_setup_verification $project_name

cmd_file_path="$KALDI_INSTALLATION_PATH/egs/$project_name/cmd.sh"
if ! is_file_exist $cmd_file_path; then
    print_warning "File doesn't exist : $cmd_file_path"
    train_cmd="run.pl"
    ((nbr_warning++))
else
    print_info "Add execution right to $KALDI_INSTALLATION_PATH/egs/$project_name/cmd.sh file"
    chmod +x "$KALDI_INSTALLATION_PATH/egs/$project_name/cmd.sh"
    print_info "Execution of file cmd.sh which is in $KALDI_INSTALLATION_PATH/egs/$project_name"
    . $KALDI_INSTALLATION_PATH/egs/$project_name/cmd.sh
fi



cd "$KALDI_INSTALLATION_PATH/egs/$project_name" || exit 1;
print_info "Inside the directory $KALDI_INSTALLATION_PATH/egs/$project_name"






steps/score_kaldi.sh --cmd "$train_cmd" $data_dir $lang_dir $decode_dir



cd "$calling_script_path" || exit 1

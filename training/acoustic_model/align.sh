#!/bin/bash 

calling_script_path=$(pwd)
# Get the path to the script
script_path="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
cd "$script_path" || exit 1
source ../../Utils/utils.sh


nbr_warning=0
nbr_error=0


# Check the number of arguments
if [ $# -ne 4 ] && [ $# -ne 5 ]; then
    print_info "Usage: $0 [option] <project name> <model folder name> <output alignment folder name> <configuration file name>"    
    exit 1
fi

model_folder_name=
output_alignment_folder_name=
configuration_file_name=
align_option=
project_name=

if [ $# -eq 5 ]; then
    align_option=$1
    if $align_option == "--sat"; then
        print_error "$align_option invalid option"
        exit 1
    fi
    project_name=$2
    model_folder_name=$3
    output_alignment_folder_name=$4
    configuration_file_name=$5
else
    project_name=$1
    model_folder_name=$2
    output_alignment_folder_name=$3
    configuration_file_name=$4
fi


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
current_directory=$(pwd)
print_info "The current directory is: $current_directory"

config_option=

if ! is_folder_exist exp/$model_folder_name; then
    print_error "The folder exp/$model_folder_name doesn't exist"
    exit 1
fi



if ! is_file_exist conf/$configuration_file_name; then
    print_warning "The config file $configuration_file_name doesn't exist inside conf folder. The default configurations will be applied"
    ((nbr_warning++))
else
    config_option="--config conf/$configuration_file_name"
fi


if is_folder_exist exp/$output_alignment_folder_name; then
    ((nbr_warning++))
    print_warning "The folder exp/$output_alignment_folder_name already exist, the content will be deleted"
    rm -rf exp/$output_alignment_folder_name/*
fi

if [[ $align_option ]]; then
    steps/align_fmllr.sh $config_option --cmd "$train_cmd" data/train data/lang exp/$model_folder_name exp/$output_alignment_folder_name
else
    steps/align_si.sh $config_option --cmd "$train_cmd" data/train data/lang exp/$model_folder_name exp/$output_alignment_folder_name
fi

status=$?
if [ $status -eq 1 ]; then
    print_error "During Alignement"
    ((nbr_error++))
    exit 1
fi



cd "$calling_script_path" || exit 1
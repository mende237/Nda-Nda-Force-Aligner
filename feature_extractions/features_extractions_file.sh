#!/bin/bash

calling_script_path=$(pwd)
# Get the path to the script
script_path="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
cd "$script_path"
source ../Utils/utils.sh

# Check the number of arguments
if [ $# -ne 2 ] && [ $# -ne 3 ]; then
    print_error "Please provide a project name."
    print_info "Usage: ./script.sh --pitch | --mfcc <project name> <nbr_job> (optional)"
    exit 1
fi

nbr_warning=0
nbr_error=0
project_name=$2

if [ "$1" != "--mfcc" ] && [ "$1" != "--pitch" ]; then
    print_info "Usage: ./script.sh --pitch | --mfcc <project name> <nbr_job> (optional)"
    exit 1
fi

feature_type=$1
nbr_job=0


if [ $# -eq 3 ]; then
    string_to_int "$3"
    nbr_job=$?
fi

project_setup_verification $project_name

cmd_file_path="$KALDI_INSTALLATION_PATH/egs/$project_name/cmd.sh"

# Check if the file already exists
if ! is_file_exist $cmd_file_path; then
    print_warning "File already exists: $cmd_file_path"
    print_info "Creating and configuring the cmd.sh file in the $KALDI_INSTALLATION_PATH/egs/$project_name directory "
    echo "train_cmd=\"run.pl\"" > "$cmd_file_path"
    echo "decode_cmd=\"run.pl\"" >> "$cmd_file_path"
    ((nbr_warning++))
fi



print_info "Add execution right to $KALDI_INSTALLATION_PATH/egs/$project_name/cmd.sh file"
chmod +x "$KALDI_INSTALLATION_PATH/egs/$project_name/cmd.sh"
print_info "Execution of file cmd.sh which is in $KALDI_INSTALLATION_PATH/egs/$project_name"
. $KALDI_INSTALLATION_PATH/egs/$project_name/cmd.sh



cd "$KALDI_INSTALLATION_PATH/egs/$project_name"
print_info "Inside the directory $KALDI_INSTALLATION_PATH/egs/$project_name"


mfcc_conf_file_path=$KALDI_INSTALLATION_PATH/egs/$project_name/conf/mfcc.conf
if ! is_file_exist $mfcc_conf_file_path; then
    print_warning "File doesn't exist : $mfcc_conf_file_path"
    print_info "Creating and configuring the mfcc.conf file in the $KALDI_INSTALLATION_PATH/egs/$project_name/conf directory "
    echo "--use-energy=false" > "$mfcc_conf_file_path"
    echo "--sample-frequency=44100" >> "$mfcc_conf_file_path"
    ((nbr_warning++))
fi

nbr_job=$((nbr_job == 0 ? 1 : nbr_job))
feature_folder=
x=data/train 
log_folder_name=
pitch_conf_file_path=$KALDI_INSTALLATION_PATH/egs/$project_name/conf/pitch.conf
if [ "$feature_type" == "--pitch" ]; then
    feature_folder="mfcc_pitch"
    log_folder_name="log_mfcc_pitch"
    if is_folder_exist exp/$log_folder_name; then
        print_warning "Delete the contents of the exp/log_mfcc folder"
        rm -rf the exp/$log_folder_name/*
        ((nbr_warning++))
    fi

    if is_folder_exist $feature_folder; then
        print_warning "Delete the contents of the $feature_folder folder"
        rm -rf $feature_folder/*
        ((nbr_warning++))
    fi

    if ! is_file_exist $pitch_conf_file_path; then
        print_warning "File doesn't exist : $pitch_conf_file_path"
        print_info "Creating and configuring the pitch.conf file in the $KALDI_INSTALLATION_PATH/egs/$project_name/conf directory"
        echo "--sample-frequency=44100" >> "$pitch_conf_file_path"
        ((nbr_warning++))
    fi
else
    feature_folder="mfcc"
    log_folder_name="log_mfcc"
    if is_folder_exist exp/$log_folder_name; then
        print_warning "Delete the contents of the exp/log_mfcc folder"
        rm -rf the exp/$log_folder_name/*
        ((nbr_warning++))
    fi

    if is_folder_exist $feature_folder; then
        print_warning "Delete the contents of the $feature_folder folder"
        rm -rf $feature_folder/*
        ((nbr_warning++))
    fi

    print_info "Extraction of MFCC characteristics with job number equal to $nbr_job the result will be stored in the $mfccdir directory"
    steps/make_mfcc.sh --cmd "$train_cmd" --nj "$nbr_job" $x exp/log_mfcc/$x $feature_folder  
fi

status=$?
if [ $status -eq 1 ]; then
    print_error "An error occured during feature extraction"
    ((nbr_error++))
    exit 1
fi

print_info "Features normalisation ..."
steps/compute_cmvn_stats.sh $x exp/$log_folder_name/$x $feature_folder             


status=$?
if [ $status -eq 1 ]; then
    print_error "An error occured during feature normalisation"
    ((nbr_error++))
    exit 1
fi



cd "$calling_script_path"

print_info "End of characteristics extraction. \033[1;33m Warning Number = $nbr_warning \033[0m  \033[1;31m Error Number = $nbr_error \033[0m"

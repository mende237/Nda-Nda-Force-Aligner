#!/bin/bash

source ../Utils/utils.sh

# Check the number of arguments
if [ $# -lt 1 ]; then
    print_error "Please provide a project name."
    print_info "Usage: ./script.sh <project name> <nbr_job> (optional)"
    exit 1
fi

nbr_warning=0
nbr_error=0
project_name=$1
nbr_job=0



if [ $# -eq 2 ]; then
    string_to_int "$2"
    nbr_job=$?
fi

project_setup_verification $project_name

cmd_file_path="$KALDI_INSTALLATION_PATH/egs/$project_name/cmd.sh"

# Check if the file already exists
if is_file_exist $cmd_file_path ; then
    print_warning "File already exists: $cmd_file_path"
    ((nbr_warning++))
fi

print_info "Creating and configuring the cmd.sh file in the $KALDI_INSTALLATION_PATH/egs/$project_name directory "
echo "train_cmd=\"run.pl\"" > "$cmd_file_path"
echo "decode_cmd=\"run.pl\"" >> "$cmd_file_path"


print_info "Add execution right to $KALDI_INSTALLATION_PATH/egs/$project_name/cmd.sh file"
chmod +x "$KALDI_INSTALLATION_PATH/egs/$project_name/cmd.sh"
print_info "Execution of file cmd.sh which is in $KALDI_INSTALLATION_PATH/egs/$project_name"
. $KALDI_INSTALLATION_PATH/egs/$project_name/cmd.sh


mfcc_conf_file_path=$KALDI_INSTALLATION_PATH/egs/$project_name/conf/mfcc.conf
# Check if the file already exists
if is_file_exist $mfcc_conf_file_path; then
    print_warning "File already exists: $mfcc_conf_file_path"
    ((nbr_warning++))
fi

print_info "Creating and configuring the mfcc.conf file in the $KALDI_INSTALLATION_PATH/egs/$project_name/conf directory "
echo "--use-energy=false" > "$mfcc_conf_file_path"
echo "--sample-frequency=44100" >> "$mfcc_conf_file_path"

nbr_job=$((nbr_job == 0 ? 1 : nbr_job))
mfccdir=mfcc  


cd "$KALDI_INSTALLATION_PATH/egs/$project_name"
if is_folder_exist data/lang/exp/make_mfcc; then
    print_info "Delete the contents of the make_mfcc folder"
    rm -rf exp/make_mfcc/*
    ((nbr_warning++))
fi

if is_folder_exist mfcc; then
    print_info "Delete the contents of the make_mfcc folder"
    rm -rf mfcc/*
    ((nbr_warning++))
fi

print_info "Inside the directory $KALDI_INSTALLATION_PATH/egs/$project_name"
print_info "Extraction of MFCC characteristics with job number equal to $nbr_job the result will be stored in the $mfccdir directory"
x=data/train   
steps/make_mfcc.sh --cmd "$train_cmd" --nj "$nbr_job" $x exp/make_mfcc/$x $mfccdir  
steps/compute_cmvn_stats.sh $x exp/make_mfcc/$x $mfccdir

status=$?
if [ $status -eq 1 ]; then
    print_error "An error occured during feature extraction"
    ((nbr_error++))
    exit 1
fi


print_info "End of characteristics extraction. \033[1;33m Warning Number = $nbr_warning \033[0m  \033[1;31m Error Number = $nbr_error \033[0m"

#!/bin/bash 
calling_script_path=$(pwd)
# Get the path to the script
script_path="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
cd "$script_path" || exit 1
source ../Utils/utils.sh

option=
error=false

if [ $# -ne 6 ] && [ $# -ne 7 ]; then
   error=true
fi

case $1 in
    "--delta")
        option=$1
        ;;
    "--lda")
        option=$1
        ;;
    "--sat")
        option=$1
        ;;
    *)
        error=true
        ;;
esac

if $error; then
    print_error "During providing parameters"
    print_info "Usage: $0 [option] <project name> <nbr leaves> <nbr gaussian> <align folder> <dest folder> <config file name>"    
    print_info "[option] = --delta | --lda | --sat"
    exit 1
fi


project_name=$2

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

cd "$KALDI_INSTALLATION_PATH/egs/$project_name" || exit 1
current_directory=$(pwd)
print_info "The current directory is: $current_directory"



nbr_leaves=$(string_to_int $3)
nbr_gauss=$(string_to_int $4)
align_folder=$5
dest_folder=$6
conf_option=
conf_file_name=

if [ $# -eq 7 ]; then
    conf_file_name=$7
    if ! is_file_exist conf/$conf_file_name; then
        print_error "The file $conf_file_name doesn't exist under conf folder"
        exit 1
    fi
    conf_option="--config conf/$conf_file_name"
fi

echo "nbr leaves $nbr_leaves"
echo "nbr gauss $nbr_gauss"

if [ $nbr_leaves -ge $nbr_gauss ]; then
    print_error "The number of leaves must be less than the number of gaussian"
    exit 1
fi


if is_folder_exist exp/$dest_folder; then
    ((nbr_warning++))
    print_warning "The folder exp/$dest_folder already exist, the content will be deleted"
    rm -rf exp/$dest_folder/*
fi

if ! is_folder_exist exp/$align_folder; then
    print_error "The folder $align_folder doesn't exist under exp folder"
    exit 1
fi



case $option in
    "--delta")
        steps/train_deltas.sh $confi_option --cmd "$train_cmd" $nbr_leaves $nbr_gauss data/train data/lang exp/$align_folder exp/$dest_folder
        ;;
    "--lda")
        steps/train_lda_mllt.sh $conf_option --cmd "$train_cmd" $nbr_gauss $nbr_leaves data/train data/lang exp/$align_folder exp/$dest_folder
        ;;
    "--sat")
        steps/train_sat.sh  $conf_option --cmd "$train_cmd" $nbr_gauss $nbr_leaves data/train data/lang exp/$align_folder exp/$dest_folder
        ;;
esac





status=$?
if [ $status -eq 1 ]; then
    print_error "During delta trainning"
    ((nbr_error++))
    exit 1
fi

cd "$calling_script_path" || exit 1
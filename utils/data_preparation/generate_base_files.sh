#!/bin/bash

calling_script_path=$(pwd)
script_path="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
cd "$script_path" || exit 1
source "../utils.sh"


nbr_warning=0
nbr_error=0

train=true
verbose=false
lm_data_path=
data_folder=

while [[ $# -gt 0 ]]; do
    case $1 in
        --test)
            train=false
            shift
            ;;
        --verbose)
            verbose=true
            shift
            ;;
        --lm)
            shift
            lm_data_path=$1
            shift
            ;;
        *)
            break
            ;;
    esac
done

# Check the number of arguments
if [ $# -ne 2 ]; then
    print_info "Usage: $0 [option] <project name> <data path folder root>"
    print_info "--test if you want to prepare files for a test"
    print_info "--lm if you want to prepare data for language model"
    print_info "--verbose if you want to have information about script execution"
    exit 1
fi

project_name=$1
data_root=$2
config=

if $train; then
    data_folder=train
else
    data_folder=test
    config="$config --test"
fi


if [[ $lm_data_path ]]; then
    config="$config --lm $lm_data_path"
fi

print_info "text file generation in $KALDI_INSTALLATION_PATH/egs/$project_name/data/$data_folder"
if  is_file_exist $KALDI_INSTALLATION_PATH/egs/$project_name/data/$data_folder; then
    ((nbr_warning++))
    print_warning "The file text already exist and the data it contains will be overwritten"
fi 
python generate_text_file.py $config $data_root $KALDI_INSTALLATION_PATH/egs/$project_name/data/$data_folder/text
status=$?
if [ $status -eq 1 ]; then
    ((nbr_error++))
    print_error "Error when creating a text file"
fi

print_info "wav.scp file generation in $KALDI_INSTALLATION_PATH/egs/$project_name/data/$data_folder"
if  is_file_exist $KALDI_INSTALLATION_PATH/egs/$project_name/data/$data_folder/wav.scp; then
    ((nbr_warning++))
    print_warning "The file wav.scp already exist and the data it contains will be overwritten"
fi 
python generate_wav_scp_file.py $KALDI_INSTALLATION_PATH/egs/$project_name/data/$data_folder/text $KALDI_INSTALLATION_PATH/egs/$project_name/data/$data_folder/wav.scp $data_root/$data_folder
status=$?
if [ $status -eq 1 ]; then
    ((nbr_error++))
    print_error "Error when creating a wav.scp file"
fi

print_info "segments file generation in $KALDI_INSTALLATION_PATH/egs/$project_name/data/$data_folder"
if  is_file_exist $KALDI_INSTALLATION_PATH/egs/$project_name/data/$data_folder/segments; then
    ((nbr_warning++))
    print_warning "The file segments already exist and the data it contains will be overwritten"
fi 
python generate_segment_file.py $KALDI_INSTALLATION_PATH/egs/$project_name/data/$data_folder/wav.scp $KALDI_INSTALLATION_PATH/egs/$project_name/data/$data_folder/segments

status=$?
if [ $status -eq 1 ]; then
    ((nbr_error++))
    print_error "Error when creating a segments file"
fi


print_info "utt2spk file generation in $KALDI_INSTALLATION_PATH/egs/$project_name/data/$data_folder"
if  is_file_exist $KALDI_INSTALLATION_PATH/egs/$project_name/data/$data_folder/utt2spk; then
    ((nbr_warning++))
    print_warning "The file utt2spk already exist and the data it contains will be overwritten"
fi 
python generate_utterance_to_speaker_file.py $KALDI_INSTALLATION_PATH/egs/$project_name/data/$data_folder/text $KALDI_INSTALLATION_PATH/egs/$project_name/data/$data_folder

status=$?
if [ $status -eq 1 ]; then
    ((nbr_error++))
    print_error "Error when creating utt2spk file"
fi

current_script_path=$(pwd)

cd "$KALDI_INSTALLATION_PATH/egs/$project_name" || exit 1
print_info "The current directory is: $KALDI_INSTALLATION_PATH/egs/$project_name"
print_info "spk2utt file generation in data/$data_folder"
if  is_file_exist spk2utt; then
    ((nbr_warning++))
    print_warning "The file spk2utt already exist and the data it contains will be overwritten"
fi 

utils/fix_data_dir.sh data/$data_folder
cd "$calling_script_path" || exit 1
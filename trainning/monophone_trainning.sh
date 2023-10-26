#!/bin/bash 

calling_script_path=$(pwd)
# Get the path to the script
script_path="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
cd "$script_path" || exit 1
source ../Utils/utils.sh

nbr_warning=0
nbr_error=0
shortest=false
perspk=false
speakers=false
first_opt=
spk_list=
utt_list=
numutt=
config_file_name=


expect_args=4
case $1 in
  --first|--last) first_opt=$1; shift ;;
  --per-spk)  perspk=true; shift ;;
  --shortest) shortest=true; shift ;;
  --speakers) speakers=true; shift ;;
  --spk-list) shift; spk_list=$1; shift; expect_args=3 ;;
  --utt-list) shift; utt_list=$1; shift; expect_args=3 ;;
  --*) print_error "$0: invalid option '$1'"; exit 1
esac


message="Usage:
    \tmonophone_trainning.sh [--speakers|--shortest|--first|--last|--per-spk] <project name> <num-utt> <destdir> <config file name>
    \tmonophone_trainning.sh [--spk-list <speaker-list-file>] <project name>  <destdir> <config file name>
    \tmonophone_trainning.sh [--utt-list <utt-list-file>] <project name> <destdir> <config file name>
    \tBy default, randomly selects <num-utt> utterances from the data directory.
    \tWith --speakers, randomly selects enough speakers that we have <num-utt> utterances
    \tWith --per-spk, selects <num-utt> utterances per speaker, if available.
    \tWith --first, selects the first <num-utt> utterances
    \tWith --last, selects the last <num-utt> utterances
    \tWith --shortest, selects the shortest <num-utt> utterances.
    \tWith --spk-list, reads the speakers to keep from <speaker-list-file>
    \tWith --utt-list, reads the utterances to keep from <utt-list-file>"

if [ $# != $expect_args ]; then
    print_error "During providing parameters"
    print_info "$message"
    exit 1;
fi

project_name=$1
project_setup_verification $project_name
if [[ $spk_list || $utt_list ]]; then
  numutt=
  destdir=$2
  config_file_name=$3
else
  numutt=$2
  destdir=$3
  config_file_name=$4
fi


cd "$KALDI_INSTALLATION_PATH/egs/$project_name" || exit 1
current_directory=$(pwd)
print_info "The current directory is: $current_directory"

if is_folder_exist data/$destdir; then
    ((nbr_warning++))
    print_warning "The folder data/$destdir already exist, the content will be deleted"
    rm -rf data/$destdir/*
fi

if ! is_folder_exist data/train; then
    print_error "The folder data/train doesn't exist"
    exit 1
fi

if [[ $first_opt ]]; then
    utils/subset_data_dir.sh $first_opt data/train $numutt data/$destdir
elif $perspk; then
    utils/subset_data_dir.sh --per-spk  data/train $numutt data/$destdir
elif $shortest; then 
    utils/subset_data_dir.sh --shortest data/train $numutt data/$destdir
elif $speakers; then
    utils/subset_data_dir.sh --speakers data/train $numutt data/$destdir 
elif [[ $spk_list || $utt_list ]]; then
    if [[ $spk_list ]]; then
        utils/subset_data_dir.sh --spk-list data/train $numutt data/$destdir 
    else
        utils/subset_data_dir.sh --utt-list data/train $numutt data/$destdir 
    fi
fi

status=$?
if [ $status -eq 1 ]; then
    print_error "When spliting the data"
    exit 1
fi

if is_folder_exist exp/$destdir; then
    ((nbr_warning++))
    print_warning "The folder exp/$destdir already exist, the content will be deleted"
    rm -rf exp/$destdir/*
fi

if ! is_file_exist conf/$config_file_name; then
    print_warning "The config trainning file doesn't exist inside conf folder. The default configurations will be applied"
    ((nbr_warning++))
    steps/train_mono.sh data/$destdir data/lang exp/$destdir
else
    steps/train_mono.sh --config conf/$config_file_name data/$destdir data/lang exp/$destdir
fi


status=$?
if [ $status -eq 1 ]; then
    print_error "During monophone trainning"
    ((nbr_error++))
    exit 1
fi


cd "$calling_script_path" || exit 1

print_info "End of monophone trainning. \033[1;33m Warning Number = $nbr_warning \033[0m  \033[1;31m Error Number = $nbr_error \033[0m"



#!/bin/bash 

calling_script_path=$(pwd)
# Get the path to the script
script_path="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
cd "$script_path"
source ../Utils/utils.sh

nbr_warning=0
shortest=false
perspk=false
speakers=false
first_opt=
spk_list=
utt_list=
numutt=

expect_args=4
case $1 in
  --first|--last) first_opt=$1; shift ;;
  --per-spk)  perspk=true; shift ;;
  --shortest) shortest=true; shift ;;
  --speakers) speakers=true; shift ;;
  --spk-list) shift; spk_list=$1; shift; expect_args=3 ;;
  --utt-list) shift; utt_list=$1; shift; expect_args=3 ;;
  --*) echo "$0: invalid option '$1'"; exit 1
esac


message="Usage:
    \tmonophone_trainning.sh [--speakers|--shortest|--first|--last|--per-spk] <project name> <srcdir> <num-utt> <destdir>
    \tmonophone_trainning.sh [--spk-list <speaker-list-file>] <project name> <srcdir> <destdir>
    \tmonophone_trainning.sh [--utt-list <utt-list-file>] <project name> <srcdir> <destdir>
    \tBy default, randomly selects <num-utt> utterances from the data directory.
    \tWith --speakers, randomly selects enough speakers that we have <num-utt> utterances
    \tWith --per-spk, selects <num-utt> utterances per speaker, if available.
    \tWith --first, selects the first <num-utt> utterances
    \tWith --last, selects the last <num-utt> utterances
    \tWith --shortest, selects the shortest <num-utt> utterances.
    \tWith --spk-list, reads the speakers to keep from <speaker-list-file>
    \tWith --utt-list, reads the utterances to keep from <utt-list-file>"

if [ $# != $expect_args ]; then
    print_error "Please during providing parameters"
    print_info "$message"
    exit 1;
fi

project_name=$1
project_setup_verification $project_name

srcdir=$2
if [[ $spk_list || $utt_list ]]; then
  numutt=
  destdir=$3
else
  numutt=$3
  destdir=$4
fi


cd "$KALDI_INSTALLATION_PATH/egs/$project_name"
current_directory=$(pwd)
print_info "The current directory is: $current_directory"

if is_folder_exist data/$destdir; then
    ((nbr_warning++))
    print_warning "The folder $destdir already exist, the content will be deleted"
    rm -rf data/$destdir/*
fi

if [[ $first_opt ]]; then
    utils/subset_data_dir.sh $first_opt data/$project_name data/train $numutt data/$destdir
elif $perspk; then
    utils/subset_data_dir.sh --per-spk data/$project_name data/train $numutt data/$destdir
elif $shortest; then 
    utils/subset_data_dir.sh --shortest data/$project_name data/train $numutt data/$destdir
elif $speakers; then
    utils/subset_data_dir.sh --speakers data/$project_name data/train $numutt data/$destdir 
elif [[ $spk_list || $utt_list ]]

fi




# utils/monophone_trainning.sh $option data/train 10000 data/$





cd "$calling_script_path"


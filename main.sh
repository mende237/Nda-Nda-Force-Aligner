#!/bin/bash 

calling_script_path=$(pwd)
script_path="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
cd "$script_path" || exit 1
source "Utils/utils.sh"


data_root="/home/dimitri/Documents/memoire/data/mono"
project_name="test_question"
add_question=true
add_pitch_feature=true
nbr_job_feature_extraction=8
nbr_job_trainning=4

trainning_type=1 #1 = monophone trainning 2 = triphone trainnig

question_option=

if $add_question; then
    question_option="--question"
fi

if $add_pitch_feature; then
    pitch_option="--pitch"
fi

print_info "******************************************* Data preparation *********************************************"
./Utils/data_preparation/main_data_preparation.sh $question_option $project_name $data_root

print_info "******************************************* Feature extraction *******************************************"
print_info "                                            Trainning features                                            "
./feature_extractions/feature_extractions.sh $pitch_option --nb-job $nbr_job_feature_extraction $project_name

print_info "                                            Testing features                                              "
./feature_extractions/feature_extractions.sh --test $pitch_option --nb-job $nbr_job_feature_extraction $project_name


cd "$calling_script_path" || exit 1
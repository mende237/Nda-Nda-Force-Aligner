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
monophone_model_folder_name="train_mono_50_per_spk"
triphone_delta_model_folder_name="train_tri_delta_50_per_spk"
triphone_delta_delta_model_folder_name="train_tri_delta_delta_50_per_spk"
monophone_align_folder="align_mono_50_per_spk"
triphone_delta_align_folder="align_tri_delta_50_per_spk"
train_mono_conf_file_name="train.conf"
train_tri_conf_file_name="train_tri.conf"
align_conf_file_name="align.conf"
decode_folder_name="decode"
test_data_folder_name="test"
nbr_leaves=4
nbr_gauss=70



trainning_type=3 #1 = monophone trainning 2 = triphone delta trainnig 3 = triphone delta-delta trainnig

question_option=
pitch_option=


if $add_question; then
    question_option="--question"
fi

if $add_pitch_feature; then
    pitch_option="--pitch"
fi

# print_info "******************************************* Data preparation *********************************************"
# ./Utils/data_preparation/main_data_preparation.sh $question_option $project_name $data_root

# print_info "******************************************* Feature extraction *******************************************"
# print_info "                                            Trainning features                                            "
# ./feature_extractions/features_extractions.sh $pitch_option --nbr-job $nbr_job_feature_extraction $project_name

# print_info "                                            Testing features                                              "
# ./feature_extractions/features_extractions.sh --test $pitch_option --nbr-job $nbr_job_feature_extraction  $project_name


# print_info "******************************************* Monophone Trainning *******************************************"
# ./training/acoustic_model/monophone_trainning.sh --per-spk $project_name 50 $monophone_model_folder_name $train_mono_conf_file_name

# if [[ $trainning_type -ge 1 ]]; then
#     print_info "******************************************** Graph construction ********************************************"
#     ./evaluation/make_graph.sh $project_name $monophone_model_folder_name
#     print_info "******************************************* Monophone evaluation *******************************************"
#     ./evaluation/evaluation.sh $project_name $test_data_folder_name $monophone_model_folder_name $decode_folder_name
#     if [[ $trainning_type -eq 1 ]]; then
#         exit 1
#     fi
# fi


# print_info "******************************************* Monophone Alignement *******************************************"
# ./training/acoustic_model/align.sh $project_name $monophone_model_folder_name $monophone_align_folder $align_conf_file_name

# print_info "******************************************* Triphone delta Training *******************************************"
# ./training/acoustic_model/triphone_training.sh $project_name $nbr_leaves $nbr_gauss $monophone_align_folder $triphone_delta_model_folder_name $train_tri_conf_file_name

# if [[ $trainning_type -ge 2 ]]; then
#     print_info "******************************************** Graph construction ********************************************"
#     ./evaluation/make_graph.sh $project_name $triphone_delta_model_folder_name
#     print_info "******************************************* Triphone delta evaluation *******************************************"
#     ./evaluation/evaluation.sh $project_name $test_data_folder_name $triphone_delta_model_folder_name $decode_folder_name
#     if [[ $trainning_type -eq 2 ]]; then
#         exit 1
#     fi
# fi

nbr_leaves=4
nbr_gauss=120

print_info "******************************************* Triphone delta Alignement *******************************************"
./training/acoustic_model/align.sh $project_name $triphone_delta_model_folder_name $triphone_delta_align_folder $align_conf_file_name

print_info "******************************************* Triphone delta delta Training *******************************************"
./training/acoustic_model/triphone_training.sh $project_name $nbr_leaves $nbr_gauss $triphone_delta_align_folder $triphone_delta_delta_model_folder_name $train_tri_conf_file_name


if [[ $trainning_type -ge 3 ]]; then
    print_info "******************************************** Graph construction ********************************************"
    ./evaluation/make_graph.sh $project_name $triphone_delta_delta_model_folder_name
    print_info "******************************************* Triphone delta delta evaluation *******************************************"
    ./evaluation/evaluation.sh $project_name $test_data_folder_name $triphone_delta_delta_model_folder_name $decode_folder_name
    if [[ $trainning_type -eq 3 ]]; then
        exit 1
    fi
fi
cd "$calling_script_path" || exit 1
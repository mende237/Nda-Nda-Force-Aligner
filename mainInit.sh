#!/bin/bash 

calling_script_path=$(pwd)
script_path="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
cd "$script_path" || exit 1
source "Utils/utils.sh"


data_root="/home/dimitri/Documents/memoire/data/mono"
project_name="test_1_2_8"
add_question=false
add_pitch_feature=true
nbr_job_feature_extraction=8
nbr_job_trainning=4
monophone_model_folder_name="train_mono_50_per_spk"
triphone_delta_model_folder_name="train_tri_delta_50_per_spk"
triphone_delta_delta_model_folder_name="train_tri_delta_delta_50_per_spk"
triphone_lda_mllt_model_folder_name="train_tri_lda_mllt_50_per_spk"
triphone_sat_model_folder_name="train_tri_sat_50_per_spk"
monophone_align_folder="align_mono_50_per_spk"
triphone_delta_align_folder="align_tri_delta_50_per_spk"
triphone_delta_delta_align_folder="align_tri_delta_delta_50_per_spk"
triphone_lda_mllt_align_folder="align_tri_lda_mllt_50_per_spk"
train_mono_conf_file_name="train.conf"
train_tri_conf_file_name="train_tri.conf"
align_conf_file_name="align.conf"
decode_folder_name="decode"
test_data_folder_name="test"
nbr_leaves=4
nbr_gauss=190



trainning_type=5 #1 = monophone trainning 2 = triphone delta trainnig 3 = triphone delta-delta trainnig 4 = triphone LDA-MLLT trainnig 5 =  triphone SAT trainnig

question_option=
pitch_option=


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
./feature_extractions/features_extractions.sh $pitch_option --nbr-job $nbr_job_feature_extraction $project_name

print_info "                                            Testing features                                              "
./feature_extractions/features_extractions.sh --test $pitch_option --nbr-job $nbr_job_feature_extraction  $project_name


print_info "******************************************* Monophone Trainning *******************************************"
./training/acoustic_model/monophone_trainning.sh --per-spk $project_name 50 $monophone_model_folder_name $train_mono_conf_file_name

if [[ $trainning_type -ge 1 ]]; then
    print_info "******************************************** Graph construction ********************************************"
    ./evaluation/make_graph.sh $project_name $monophone_model_folder_name
    print_info "******************************************* Monophone evaluation *******************************************"
    ./evaluation/evaluation.sh $project_name $test_data_folder_name $monophone_model_folder_name $decode_folder_name
    if [[ $trainning_type -eq 1 ]]; then
        exit 1
    fi
fi


print_info "******************************************* Monophone Alignement *******************************************"
./training/acoustic_model/align.sh $project_name $monophone_model_folder_name $monophone_align_folder $align_conf_file_name

print_info "******************************************* Triphone delta Training *******************************************"
./training/acoustic_model/triphone_training.sh $project_name $nbr_leaves $nbr_gauss $monophone_align_folder $triphone_delta_model_folder_name $train_tri_conf_file_name

if [[ $trainning_type -ge 2 ]]; then
    print_info "******************************************** Graph construction ********************************************"
    ./evaluation/make_graph.sh $project_name $triphone_delta_model_folder_name
    print_info "******************************************* Triphone delta evaluation *******************************************"
    ./evaluation/evaluation.sh $project_name $test_data_folder_name $triphone_delta_model_folder_name $decode_folder_name
    if [[ $trainning_type -eq 2 ]]; then
        exit 1
    fi
fi

nbr_leaves=4
nbr_gauss=194

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

nbr_leaves=4
nbr_gauss=190

print_info "******************************************* Triphone delta delta Alignement *******************************************"
./training/acoustic_model/align.sh --use-graphs true $project_name $triphone_delta_delta_model_folder_name $triphone_delta_delta_align_folder $align_conf_file_name

status=$?
if [ $status -eq 1 ]; then
    exit 1
fi

print_info "******************************************* Triphone LDA-MLLT Training *******************************************"
./training/acoustic_model/triphone_training.sh --lda $project_name $nbr_leaves $nbr_gauss $triphone_delta_delta_align_folder $triphone_lda_mllt_model_folder_name $train_tri_conf_file_name

status=$?
if [ $status -eq 1 ]; then
    exit 1
fi

if [[ $trainning_type -ge 4 ]]; then
    print_info "******************************************** Graph construction ********************************************"
    ./evaluation/make_graph.sh $project_name $triphone_lda_mllt_model_folder_name
    print_info "******************************************* Triphone LDA-MLLT evaluation *******************************************"
    ./evaluation/evaluation.sh $project_name $test_data_folder_name $triphone_lda_mllt_model_folder_name $decode_folder_name
    if [[ $trainning_type -eq 4 ]]; then
        exit 1
    fi
fi

print_info "******************************************* Triphone LDA-MLLT Alignement *******************************************"
./training/acoustic_model/align.sh $project_name $triphone_lda_mllt_model_folder_name $triphone_lda_mllt_align_folder $align_conf_file_name


nbr_leaves=4
nbr_gauss=190


print_info "******************************************* Triphone SAT Training *******************************************"
./training/acoustic_model/triphone_training.sh --sat $project_name $nbr_leaves $nbr_gauss $triphone_lda_mllt_align_folder $triphone_sat_model_folder_name $train_tri_conf_file_name


if [[ $trainning_type -ge 5 ]]; then
    print_info "******************************************** Graph construction ********************************************"
    ./evaluation/make_graph.sh $project_name $triphone_sat_model_folder_name
    print_info "******************************************* Triphone SAT evaluation *******************************************"
    ./evaluation/evaluation.sh $project_name $test_data_folder_name $triphone_sat_model_folder_name $decode_folder_name
    if [[ $trainning_type -eq 4 ]]; then
        exit 1
    fi
fi

cd "$calling_script_path" || exit 1

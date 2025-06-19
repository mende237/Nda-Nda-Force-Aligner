#!/bin/bash 

calling_script_path=$(pwd)
script_path="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
cd "$script_path" || exit 1
# shellcheck disable=SC1091
source "utils/utils.sh"


data_root="/home/dimitri/Downloads/mono-20250606T112759Z-1-001/mono"
# project_name="test_MFCC_1_2"
project_name="test_MFCC_pitch_1_2"
# project_name="test_MFCC_pitch_tone_1_2"
exp_folder_path="$KALDI_INSTALLATION_PATH/egs/$project_name/exp"
add_question=false
add_pitch_feature=true
nbr_job_feature_extraction=8
nbr_job_trainning=4
nb_job_alignment=2
monophone_model_folder_name="train_mono_50_per_spk"
triphone_delta_model_folder_name="train_tri_delta_50_per_spk"
triphone_delta_delta_model_folder_name="train_tri_delta_delta_50_per_spk"
triphone_lda_mllt_model_folder_name="train_tri_lda_mllt_50_per_spk"
triphone_sat_model_folder_name="train_tri_sat_50_per_spk"
hybrid_model_folder_name="train_hybrid_50_per_spk"
test_data_align_folder_name="test_align"
monophone_align_folder="align_mono_50_per_spk"
triphone_delta_align_folder="align_tri_delta_50_per_spk"
triphone_delta_delta_align_folder="align_tri_delta_delta_50_per_spk"
triphone_lda_mllt_align_folder="align_tri_lda_mllt_50_per_spk"
triphone_sat_align_folder="align_tri_sat_50_per_spk"
hybrid_align_folder="align_hybrid_50_per_spk"
train_mono_conf_file_name="train.conf"
train_tri_conf_file_name="train_tri.conf"
align_conf_file_name="align.conf"
decode_folder_name="decode"
test_data_folder_name="test"
train_data_folder_name="test"
nbr_leaves=10
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
./utils/data_preparation/nda_nda/main_data_preparation.sh $question_option $project_name $data_root

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
    print_info "******************************************* Monophone WER evaluation *******************************************"
    ./evaluation/evaluation.sh $project_name $test_data_folder_name $monophone_model_folder_name $decode_folder_name
    if [[ $trainning_type -eq 1 ]]; then
        exit 1
    fi
fi


print_info "******************************************* Monophone Alignement *******************************************"
./training/acoustic_model/align.sh --nj $nbr_job_trainning $project_name $monophone_model_folder_name $monophone_align_folder $align_conf_file_name



print_info "******************************************* Monophone Alignement Test Data *******************************************"
./training/acoustic_model/align.sh --nj $nb_job_alignment --test $project_name $monophone_model_folder_name $monophone_align_folder/$test_data_align_folder_name $align_conf_file_name


print_info "******************************************* Monophone Boundary error evaluation *******************************************"
./utils/boundary_error/compute_boundary_error.sh --convert-textgrid-to-ctm \
                                                --score-file-path "$exp_folder_path/$monophone_model_folder_name/decode/scoring_kaldi/boundary_error" \
                                                $project_name $monophone_model_folder_name \
                                                "$exp_folder_path/$monophone_align_folder/$test_data_align_folder_name" $data_root/test




print_info "******************************************* Triphone delta Training *******************************************"
./training/acoustic_model/triphone_training.sh $project_name $nbr_leaves $nbr_gauss $monophone_align_folder $triphone_delta_model_folder_name $train_tri_conf_file_name

if [[ $trainning_type -ge 2 ]]; then
    print_info "******************************************** Graph construction ********************************************"
    ./evaluation/make_graph.sh $project_name $triphone_delta_model_folder_name
    print_info "******************************************* Triphone delta WER evaluation *******************************************"
    ./evaluation/evaluation.sh $project_name $test_data_folder_name $triphone_delta_model_folder_name $decode_folder_name
    if [[ $trainning_type -eq 2 ]]; then
        exit 1
    fi
fi

print_info "******************************************* Triphone delta Alignement *******************************************"
./training/acoustic_model/align.sh $project_name $triphone_delta_model_folder_name $triphone_delta_align_folder $align_conf_file_name


print_info "******************************************* Triphone delta Alignement Test Data *******************************************"
./training/acoustic_model/align.sh --nj $nb_job_alignment --test $project_name $triphone_delta_model_folder_name $triphone_delta_align_folder/$test_data_align_folder_name $align_conf_file_name


print_info "******************************************* Triphone delta Boundary error evaluation *******************************************"
./utils/boundary_error/compute_boundary_error.sh --score-file-path "$exp_folder_path/$triphone_delta_model_folder_name/decode/scoring_kaldi/boundary_error" \
                                                $project_name $triphone_delta_model_folder_name \
                                                "$exp_folder_path/$triphone_delta_align_folder/$test_data_align_folder_name" $data_root/test


# nbr_leaves=4
# nbr_gauss=194


print_info "******************************************* Triphone delta-delta Training *******************************************"
./training/acoustic_model/triphone_training.sh $project_name $nbr_leaves $nbr_gauss $triphone_delta_align_folder $triphone_delta_delta_model_folder_name $train_tri_conf_file_name


if [[ $trainning_type -ge 3 ]]; then
    print_info "******************************************** Graph construction ********************************************"
    ./evaluation/make_graph.sh $project_name $triphone_delta_delta_model_folder_name
    print_info "******************************************* Triphone delta-delta WER evaluation *******************************************"
    ./evaluation/evaluation.sh $project_name $test_data_folder_name $triphone_delta_delta_model_folder_name $decode_folder_name
    if [[ $trainning_type -eq 3 ]]; then
        exit 1
    fi
fi


print_info "******************************************* Triphone delta-delta Alignement *******************************************"
./training/acoustic_model/align.sh $project_name $triphone_delta_delta_model_folder_name $triphone_delta_delta_align_folder $align_conf_file_name


print_info "******************************************* Triphone delta-delta  Alignement Test Data *******************************************"
./training/acoustic_model/align.sh --nj $nb_job_alignment --test $project_name $triphone_delta_delta_model_folder_name $triphone_delta_delta_align_folder/$test_data_align_folder_name $align_conf_file_name


print_info "******************************************* Triphone delta-delta Boundary error evaluation *******************************************"
./utils/boundary_error/compute_boundary_error.sh --score-file-path "$exp_folder_path/$triphone_delta_delta_model_folder_name/decode/scoring_kaldi/boundary_error" \
                                                $project_name $triphone_delta_delta_model_folder_name \
                                                "$exp_folder_path/$triphone_delta_delta_align_folder/$test_data_align_folder_name" $data_root/test

# nbr_leaves=4
# nbr_gauss=194


print_info "******************************************* Triphone LDA-MLLT Training *******************************************"
./training/acoustic_model/triphone_training.sh --lda $project_name $nbr_leaves $nbr_gauss $triphone_delta_delta_align_folder $triphone_lda_mllt_model_folder_name $train_tri_conf_file_name

status=$?
if [ $status -eq 1 ]; then
    exit 1
fi

if [[ $trainning_type -ge 4 ]]; then
    print_info "******************************************** Graph construction ********************************************"
    ./evaluation/make_graph.sh $project_name $triphone_lda_mllt_model_folder_name
    print_info "******************************************* Triphone LDA-MLLT WER evaluation *******************************************"
    ./evaluation/evaluation.sh $project_name $test_data_folder_name $triphone_lda_mllt_model_folder_name $decode_folder_name
    if [[ $trainning_type -eq 4 ]]; then
        exit 1
    fi
fi

print_info "******************************************* Triphone LDA-MLLT Alignement *******************************************"
./training/acoustic_model/align.sh  $project_name $triphone_lda_mllt_model_folder_name $triphone_lda_mllt_align_folder $align_conf_file_name


print_info "******************************************* Triphone LDA-MLLT  Alignement Test Data *******************************************"
./training/acoustic_model/align.sh --nj $nb_job_alignment --test $project_name $triphone_lda_mllt_model_folder_name $triphone_lda_mllt_align_folder/$test_data_align_folder_name $align_conf_file_name


print_info "******************************************* Triphone LDA-MLLT Boundary error evaluation *******************************************"
./utils/boundary_error/compute_boundary_error.sh --score-file-path "$exp_folder_path/$triphone_lda_mllt_model_folder_name/decode/scoring_kaldi/boundary_error" \
                                                $project_name $triphone_lda_mllt_model_folder_name \
                                                "$exp_folder_path/$triphone_lda_mllt_align_folder/$test_data_align_folder_name" $data_root/test

# nbr_leaves=4
# nbr_gauss=190


print_info "******************************************* Triphone SAT Training *******************************************"
./training/acoustic_model/triphone_training.sh --sat $project_name $nbr_leaves $nbr_gauss $triphone_lda_mllt_align_folder $triphone_sat_model_folder_name $train_tri_conf_file_name


if [[ $trainning_type -ge 5 ]]; then
    print_info "******************************************** Graph construction ********************************************"
    ./evaluation/make_graph.sh $project_name $triphone_sat_model_folder_name
    print_info "******************************************* Triphone SAT WER evaluation *******************************************"
    # ./evaluation/evaluation.sh --transform-dir /home/dimitri/kaldi/egs/test_MFCC_pitch_tone_1_2/exp/train_tri_lda_mllt_50_per_spk $project_name $test_data_folder_name $triphone_sat_model_folder_name $decode_folder_name
    ./evaluation/evaluation.sh $project_name $train_data_folder_name $triphone_sat_model_folder_name $decode_folder_name

    if [[ $trainning_type -eq 4 ]]; then
        exit 1
    fi
fi


print_info "******************************************* Triphone SAT Alignement *******************************************"
./training/acoustic_model/align.sh $project_name $triphone_sat_model_folder_name $triphone_sat_align_folder $align_conf_file_name


print_info "******************************************* Triphone SAT  Alignement Test Data *******************************************"
./training/acoustic_model/align.sh --nj $nb_job_alignment --test $project_name $triphone_sat_model_folder_name $triphone_sat_align_folder/$test_data_align_folder_name $align_conf_file_name


print_info "******************************************* Triphone SAT Boundary error evaluation *******************************************"
./utils/boundary_error/compute_boundary_error.sh --score-file-path "$exp_folder_path/$triphone_sat_model_folder_name/decode/scoring_kaldi/boundary_error" \
                                                $project_name $triphone_sat_model_folder_name \
                                                "$exp_folder_path/$triphone_sat_align_folder/$test_data_align_folder_name" $data_root/test

cd "$KALDI_INSTALLATION_PATH/egs/$project_name" || exit 1
print_info "The current directory is: $(pwd)"

print_info "******************************************* Hybrid Model Training *******************************************"

steps/nnet2/train_tanh.sh  --initial-learning-rate 0.015 --final-learning-rate 0.002 \
                            --num-hidden-layers 1  --num-jobs-nnet "$nbr_job_trainning" \
                            data/train data/lang exp/$triphone_delta_delta_model_folder_name exp/$hybrid_model_folder_name


steps/nnet2/decode.sh --nj 2 exp/$triphone_delta_delta_model_folder_name/graph \
                        data/test exp/$hybrid_model_folder_name/decode | tee exp/$hybrid_model_folder_name/decode/decode.log


cd "$calling_script_path" || exit 1
print_info "The current directory is: $calling_script_path"
print_info "******************************************* Hybrid Model Alignement *******************************************"
./training/acoustic_model/align.sh --hybrid --nj $nb_job_alignment --test $project_name $hybrid_model_folder_name \
                                    $hybrid_align_folder $align_conf_file_name

print_info "******************************************* Hybrid Boundary error evaluation *******************************************"
./utils/boundary_error/compute_boundary_error.sh --score-file-path "$exp_folder_path/$hybrid_model_folder_name/decode/scoring_kaldi/boundary_error" \
                                                $project_name $hybrid_model_folder_name \
                                                "$exp_folder_path/$hybrid_align_folder" $data_root/test

cd "$calling_script_path" || exit 1

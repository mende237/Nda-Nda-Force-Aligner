#!/bin/bash

calling_script_path=$(pwd)
# Get the path to the script
script_path="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
cd "$script_path" || exit 1
source ../Utils/utils.sh


pitch=false
train=true
nbr_job=1
nbr_warning=0
nbr_error=0
data_folder=

while [[ $# -gt 0 ]]; do
    case $1 in
        --test)
            train=false
            shift
            ;;
        --pitch)
            pitch=true
            shift
            ;;
        --nbr-job)
            shift
            nbr_job=$(string_to_int "$1")
            shift
            ;;
        *)
            break
            ;;
    esac
done

# Check the number of arguments
if [ $# -ne 1 ]; then
    print_info "Usage: $0 [options] <project name>"
    print_info "--test if you want to extract features for testing data"
    print_info "--pitch if you want to extract pitch features"
    print_info "--nbr-job is the number of job you want for feature extractions"
    exit 1
fi

project_name=$1

project_setup_verification $project_name


if $train; then
    data_folder=train
else
    data_folder=test
fi

cmd_file_path="$KALDI_INSTALLATION_PATH/egs/$project_name/cmd.sh"

# Check if the file already exists
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
print_info "Inside the directory $KALDI_INSTALLATION_PATH/egs/$project_name"


feature_folder="features/$data_folder"
x=data/$data_folder
log_folder_name="features/$data_folder"
pitch_conf_file_path="$KALDI_INSTALLATION_PATH/egs/$project_name/conf/pitch.conf"
mfcc_conf_file_path="$KALDI_INSTALLATION_PATH/egs/$project_name/conf/mfcc.conf"
if $pitch; then
    feature_folder="$feature_folder/mfcc_pitch"
    log_folder_name="$feature_folder/log_mfcc_pitch"
    if is_folder_exist exp/$log_folder_name; then
        print_warning "Delete the contents of the exp/$log_folder_name folder"
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

        echo "--frame-length=25.0" >> "$pitch_conf_file_path"
        echo "--frame-shift=10.0" >> "$pitch_conf_file_path"
        echo "--snip-edges=true" >> "$pitch_conf_file_path"
        echo "--min-f0=50" >> "$pitch_conf_file_path"
        echo "--max-f0=400" >> "$pitch_conf_file_path"
        echo "--soft-min-f0=10.0" >> "$pitch_conf_file_path"
        echo "--penalty-factor=0.1" >> "$pitch_conf_file_path"
        echo "--delta-pitch=0.005" >> "$pitch_conf_file_path"
        ((nbr_warning++))
    fi

    if ! is_file_exist $mfcc_conf_file_path; then
        print_warning "File doesn't exist : $mfcc_conf_file_path"
        print_info "Creating and configuring the mfcc.conf file in the $KALDI_INSTALLATION_PATH/egs/$project_name/conf directory "
        echo "--use-energy=false" >> "$mfcc_conf_file_path"
        echo "--sample-frequency=44100" >> "$mfcc_conf_file_path"

        echo "--frame-length=25.0" >> "$mfcc_conf_file_path"
        echo "--frame-shift=10.0" >> "$mfcc_conf_file_path"
        echo "--num-mel-bins=23" >> "$mfcc_conf_file_path"
        echo "--num-ceps=10" >> "$mfcc_conf_file_path"
        echo "--low-freq=20" >> "$mfcc_conf_file_path"
        echo "--high-freq=-400" >> "$mfcc_conf_file_path"

        ((nbr_warning++))
    fi
    print_info "Extraction of MFCC pitch characteristics"
    steps/make_mfcc_pitch.sh --cmd "$train_cmd" --nj "$nbr_job" $x exp/$log_folder_name/$x $feature_folder
else
    
    feature_folder="$feature_folder/mfcc"
    log_folder_name="$log_folder_name/log_mfcc"
    if is_folder_exist exp/$log_folder_name; then
        print_warning "Delete the contents of the exp/$log_folder_name folder"
        rm -rf the exp/$log_folder_name/*
        ((nbr_warning++))
    fi

    if is_folder_exist $feature_folder; then
        print_warning "Delete the contents of the $feature_folder folder"
        rm -rf $feature_folder/*
        ((nbr_warning++))
    fi

    if ! is_file_exist $mfcc_conf_file_path; then
        print_warning "File doesn't exist : $mfcc_conf_file_path"
        print_info "Creating and configuring the mfcc.conf file in the $KALDI_INSTALLATION_PATH/egs/$project_name/conf directory "
        echo "--use-energy=false" > "$mfcc_conf_file_path"
        echo "--sample-frequency=44100" >> "$mfcc_conf_file_path"
        ((nbr_warning++))
    fi
    # print_info "Extraction of MFCC characteristics with job number equal to $nbr_job the result will be stored in the $mfccdir directory"
    print_info "Extraction of MFCC characteristics"
    steps/make_mfcc.sh --cmd "$train_cmd" --nj "$nbr_job" $x exp/$log_folder_name/$x $feature_folder  
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



cd "$calling_script_path" || exit 1

print_info "End of characteristics extraction. \033[1;33m Warning Number = $nbr_warning \033[0m  \033[1;31m Error Number = $nbr_error \033[0m"

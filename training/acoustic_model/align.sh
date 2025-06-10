#!/bin/bash 

calling_script_path=$(pwd)
# Get the path to the script
script_path="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
cd "$script_path" || exit 1
source ../../utils/utils.sh

options=
sat_align=false
hybrid_align=false
test=false
nj="--nj 1"

while [[ $# -gt 0 ]]; do
    case $1 in
        --nj)
            nj="--nj $2"
            shift
            shift
            ;;
        --test)
            test=true
            shift
            ;;
        --sat)
            sat_align=true
            shift
            ;;
        --hybrid)
            hybrid_align=true
            shift
            ;;
        --use-graphs)
            options=$1 $2
            shift
            shift
            ;;
        *)
            break
            ;;
    esac
done


nbr_warning=0
nbr_error=0


# Check the number of arguments
if [ $# -ne 4 ]; then
    print_info "Usage: $0 [option] <project name> <model folder name> <output alignment folder name> <configuration file name>"   
    print_info "[option] = --nj <number of jobs> | --test | --sat | --use-graphs"
    print_info "Example: $0 --nj 4 my_project my_model_folder my_output_alignment_folder my_config_file.conf" 
    printf_info "--nj if you want to specify the number of jobs (default is 1)"
    print_info "--test if you want to align the test data"
    print_info "--sat if you want to use the SAT aligner"
    print_info "--use-graphs if you want to use the graphs in the alignment"
    exit 1
fi


project_name=$1
model_folder_name=$2
output_alignment_folder_name=$3
configuration_file_name=$4



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


cd "$KALDI_INSTALLATION_PATH/egs/$project_name" || exit 1;
current_directory=$(pwd)
print_info "The current directory is: $current_directory"

config_option=

if ! is_folder_exist exp/$model_folder_name; then
    print_error "The folder exp/$model_folder_name doesn't exist"
    exit 1
fi



if ! is_file_exist conf/$configuration_file_name; then
    print_warning "The config file $configuration_file_name doesn't exist inside conf folder. The default configurations will be applied"
    ((nbr_warning++))
else
    config_option="--config conf/$configuration_file_name"
fi


if is_folder_exist exp/$output_alignment_folder_name; then
    ((nbr_warning++))
    print_warning "The folder exp/$output_alignment_folder_name already exist, the content will be deleted"
    rm -rf exp/$output_alignment_folder_name/*
fi

data_path=data/train
if $test; then
    if ! is_folder_exist data/test; then
        print_error "The folder data/test doesn't exist"
         ((nbr_error++))
        exit 1
    fi
    data_path=data/test
fi

if $sat_align; then
    steps/align_fmllr.sh $config_option $nj --cmd "$train_cmd" $data_path data/lang exp/$model_folder_name exp/$output_alignment_folder_name
elif $hybrid_align; then
    steps/nnet2/align.sh $config_option $nj --cmd "$train_cmd" $data_path data/lang exp/$model_folder_name exp/$output_alignment_folder_name
else 
    steps/align_si.sh $options $config_option $nj --cmd "$train_cmd" $data_path data/lang exp/$model_folder_name exp/$output_alignment_folder_name
fi

status=$?
if [ $status -eq 1 ]; then
    print_error "During Alignement"
    ((nbr_error++))
    exit 1
fi

print_info "End of alignment. \033[1;33m Warning Number = $nbr_warning \033[0m  \033[1;31m Error Number = $nbr_error \033[0m"

cd "$calling_script_path" || exit 1
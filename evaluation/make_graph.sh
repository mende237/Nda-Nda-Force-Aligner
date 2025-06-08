#!/bin/bash

calling_script_path=$(pwd)
# Get the path to the script
script_path="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
cd "$script_path" || exit 1

source ../utils/utils.sh

nbr_warning=0
nbr_error=0

remove_oov=false
transition_scale=
self_loop_scale=

project_name=""
model=""
graph="graph"


while [[ $# -gt 0 ]]; do
    case $1 in
        --remove-oov)
            remove_oov=true
            shift
            ;;
        --transition-scale)
            shift
            if [[ $# -gt 0 ]]; then
                transition_scale=$1
                shift
            else
                print_error "Missing value for --transition-scale option"
                exit 1
            fi
            ;;
        --self-loop-scale)
            shift
            if [[ $# -gt 0 ]]; then
                self_loop_scale=$1
                shift
            else
                print_error "Missing value for --self-loop-scale option"
                exit 1
            fi
            ;;
        *)
            break
            ;;
    esac
done


if [[ $# -ne 2 ]]; then
    print_info "Usage: $0 [options] <project-name> <model-folder-name>"
    print_info "Options:"
    print_info "  --remove-oov          Remove OOV (Out-of-Vocabulary) words"
    print_info "  --transition-scale    Transition scale value"
    print_info "  --self-loop-scale     Self loop scale value"
    exit 1
fi

project_name=$1
model=$2


project_setup_verification $project_name

cd "$KALDI_INSTALLATION_PATH/egs/$project_name" || exit 1;
print_info "Inside the directory $KALDI_INSTALLATION_PATH/egs/$project_name"

option=

if ! $remove_oov; then
    option="--remove-oov"
fi

if [[ $transition_scale ]]; then
    option="$option --transition-scale $transition_scale"
fi

if [[ $self_loop_scale ]]; then
    option="$option --self-loop-scale $self_loop_scale"
fi

if ! is_folder_exist exp/$model; then
    print_error "The folder exp/$model doesn't exist"
    exit 1
fi


if is_folder_exist exp/$model/$graph; then
    print_warning "The folder exp/$model/$graph already exist and its contents will be overwritten"
    ((nbr_warning++))
else
    mkdir -p exp/$model/$graph
fi


utils/mkgraph.sh $option data/lang exp/$model exp/$model/graph

status=$?
if [ $status -eq 1 ]; then
    print_error "During delta Graph creation"
    ((nbr_error++))
    exit 1
fi

print_info "End of graph generation. \033[1;33m Warning Number = $nbr_warning \033[0m  \033[1;31m Error Number = $nbr_error \033[0m"

cd "$calling_script_path" || exit 1



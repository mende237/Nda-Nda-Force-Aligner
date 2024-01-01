#!/bin/bash 

# calling_script_path=$(pwd)
# script_path="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
# cd "$script_path" || exit 1

source ../../utils.sh


delete_in_lang_local_auto_generated_file() {
    if [ $# -ne 1 ]; then
        print_error "The function delete_in_lang_local_auto_generated_file takes one parameter the project name <project name>"
        exit 1
    fi

    local project_name=$1
    local nbr_warning=0

    previous_directory=$(pwd)

    project_setup_verification $project_name
    cd "$KALDI_INSTALLATION_PATH/egs/$project_name" || exit 1
    current_directory=$(pwd)
    print_info "The current directory is $current_directory"
    print_info "Delete all containt which are in data/lang"
    if is_folder_exist data/lang; then
        rm -rf data/lang/*
    else
        ((nbr_warning++))
    fi
    print_info "Delete file align_lexicon.txt, lexiconp.txt, lexiconp_disambig.txt, lex_ndisambig and phone_map.txt which are in data/local"
    delete_file data/local/align_lexicon.txt 1
    delete_file data/local/lexiconp.txt 1
    delete_file data/local/lexiconp_disambig.txt 1
    delete_file data/local/lex_ndisambig 1
    delete_file data/local/phone_map.txt 1
    print_info "Delete file lexiconp.txt which is data/local/lang"
    delete_file data/local/lang/lexiconp.txt 1

    cd "$previous_directory" || exit 1
}



# cd "$calling_script_path" || exit 1





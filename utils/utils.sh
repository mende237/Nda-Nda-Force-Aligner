#!/bin/bash

is_folder_exist() {
    if [ $# -ne 1 ]; then
        print_error "The function is_folder_exist take one parameter <folder_path>"
        exit 1
    fi

    local folder_path=$1
    if [  -d "$folder_path" ]; then
        return 0
    else
        return 1
    fi
}

is_file_exist(){
    if [ $# -ne 1 ]; then
        print_error "The function is_file_exist take one parameter <file_path>"
        exit 1
    fi

    local file_path=$1
    if [  -f "$file_path" ]; then
        return 0
    else
        return 1
    fi
}

print_warning() {
    if [ $# -ne 1 ]; then
        print_error "The function print_warning take one parameter <message>"
        exit 1
    fi
    local message="$1"
    echo -e "\033[1;33m[Warning]:\033[0m $message"
}


print_error() {
    if [ $# -ne 1 ]; then
        echo -e "\033[1;31m[Error]:\033[0m The function print_error take one parameter <message>"
        exit 1
    fi

    local message="$1"
    echo -e "\033[1;31m[Error]:\033[0m $message"
}


print_info() {
    if [ $# -ne 1 ]; then
        print_error "The function print_info take one parameter <message>"
        exit 1
    fi

    local message="$1"
    echo -e "\033[1;32m[Info]:\033[0m $message"
}


project_setup_verification(){
    if [ $# -ne 1 ]; then
        print_error "The function project_setup_verification take one parameter <message>"
        exit 1
    fi

    local project_name=$1
    if ! is_folder_exist "$KALDI_INSTALLATION_PATH"; then
        print_error "The Kaldi installation root folder not exist, if you are already install please configure it in the Config.json under the configs folder and run the export.sh script"
        exit 1
    fi

    if ! is_folder_exist "$KALDI_INSTALLATION_PATH/egs/$project_name"; then
        print_error "The projet with name $project_name doesn't exist in kaldi installation root please run the initialize.sh script to create projet"
        exit 1
    fi


    if ! is_folder_exist "$KALDI_INSTALLATION_PATH/egs/$project_name/data/train"; then
        print_error "The folder data/train not exit in $project_name. Please run the initialize.sh script to create projet"
        exit 1
    fi

     if ! is_folder_exist "$KALDI_INSTALLATION_PATH/egs/$project_name/data/test"; then
        print_error "The folder data/test not exit in $project_name. Please run the initialize.sh script to create projet"
        exit 1
    fi

    if ! is_folder_exist "$KALDI_INSTALLATION_PATH/egs/$project_name/data/lang"; then
        print_error "The folder data/lang not exit in $project_name. Please run the initialize.sh script to create projet"
        exit 1
    fi

    if ! is_folder_exist "$KALDI_INSTALLATION_PATH/egs/$project_name/data/local"; then
        print_error "The folder data/local not exit in $project_name. Please run the initialize.sh script to create projet"
        exit 1
    fi

    if ! is_folder_exist "$KALDI_INSTALLATION_PATH/egs/$project_name/data/local/local_lm/data"; then
        print_error "The folder data/local/local_lm/data not exit in $project_name. Please run the initialize.sh script to create projet"
        exit 1
    fi

    if ! is_folder_exist "$KALDI_INSTALLATION_PATH/egs/$project_name/data/local/lang"; then
        print_error "The folder data/local/lang not exit in $project_name. Please run the initialize.sh script to create projet"
        exit 1
    fi

    if ! is_folder_exist "$KALDI_INSTALLATION_PATH/egs/$project_name/exp"; then
        print_error "The folder exp not exit in $project_name. Please run the initialize.sh script to create projet"
        exit 1
    fi

    if ! is_folder_exist "$KALDI_INSTALLATION_PATH/egs/$project_name/steps"; then
        print_error "The folder steps not exit in $project_name. Please run the initialize.sh script to create projet"
        exit 1
    fi

    if ! is_folder_exist "$KALDI_INSTALLATION_PATH/egs/$project_name/utils"; then
        print_error "The folder utils not exit in $project_name. Please run the initialize.sh script to create projet"
        exit 1
    fi

    if ! is_folder_exist "$KALDI_INSTALLATION_PATH/egs/$project_name/src"; then
        print_error "The folder src not exit in $project_name. Please run the initialize.sh script to create projet"
        exit 1
    fi
}


string_to_int(){
    if [ $# -ne 1 ]; then
        print_error "The function string_to_int take one parameter <string>"
        exit 1
    fi
    local string=$1

    if [[ ! "$string" =~ ^[0-9]+$ ]]; then
        print_error "Invalid input $string. The input must be a numeric string."
        exit 1
    fi

    echo "$((string))"
}


delete_file(){
    if [ $# -ne 2 ]; then
        print_error "The function delete_file take two parameter <file_path> and <verbose>"
        exit 1
    fi

    local file_path=$1
    # string_to_int "$2"
    local verbose=$(string_to_int $2)
    

    if ! is_file_exist $file_path; then
        if [ $verbose -eq 0 ]; then
            print_warning "File $file_path doesn't exit"
        fi
        return 1
    else
        rm -f $file_path
        return 0
    fi
}


delete_all(){
    if [ $# -ne 2 ]; then
        print_error "The function delete_file take two parameter <folder_path> and <verbose>"
        exit 1
    fi

    local folder_path=$1
    local verbose=$(string_to_int $2)
    if ! is_folder_exist $folder_path; then
        if $verbose; then
            print_warning "File $file_path doesn't exit"
        fi
        return 1
    else
        return 0
    fi
}


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



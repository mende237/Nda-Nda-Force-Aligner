#!/bin/bash -i

calling_script_path=$(pwd)
# Get the path to the script
script_path="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
cd "$script_path" || exit 1

source ../utils.sh


# Check the number of arguments
if [ $# -ne 1 ]; then
    print_error "Please provide a project name."
    print_info "Usage: ./$0 <project name>"
    exit 1
fi

nbr_warning=0
projet_name=$1
config_file="../../configs/Config.json"

if [[ -z "${KALDI_INSTALLATION_PATH}" ]]; then
    print_warning "Variable KALDI_INSTALLATION_PATH does not exist or is empty"
    kaldi_installation_path=$(jq -r '.kaldi_installation_path' "$config_file")
    echo "export KALDI_INSTALLATION_PATH=\"$kaldi_installation_path\"" >> ~/.bashrc
    if [[ ":$PATH:" != *":$kaldi_installation_path:"* ]]; then
        echo "export PATH=\""\$"PATH:$kaldi_installation_path\"" >> ~/.bashrc
        print_info "Path folder $kaldi_installation_path added successfully in PATH."
    else
        print_warning "Path folder $kaldi_installation_path already exists in PATH."
        ((nbr_warning++))
    fi
    source ~/.bashrc
    print_info "Variable exported: $KALDI_INSTALLATION_PATH"
else
    print_info "Kaldi installation path exists and has a value: $KALDI_INSTALLATION_PATH"
fi


if ! is_folder_exist "$KALDI_INSTALLATION_PATH"; then
    print_error "The Kaldi installation root folder not exist if you are already install please configure it in the Config.json under the configs folder and run the export.sh script"
    exit 1
fi


cd "$KALDI_INSTALLATION_PATH/egs" || exit 1

current_directory=$(pwd)
print_info "The current directory is: $current_directory"

if [ ! -d "$projet_name" ]; then
    mkdir -p "$projet_name"
    print_info "Folder created: $projet_name"
else
    print_error "Folder already exists: $projet_name"
    ((nbr_error++))
    exit 1
fi

cd "$projet_name" || exit 1

current_directory=$(pwd)
print_info "The current directory is: $current_directory"

if [ ! -d "$KALDI_INSTALLATION_PATH/egs/$projet_name/steps" ]; then
    ln -s ../wsj/s5/steps .
    print_info "creation of symbolic link from folder  $KALDI_INSTALLATION_PATH/egs/wjs/s5/steps to $projet_name"
else
    print_warning "Folder already exists: steps"
    ((nbr_warning++))
fi



if [ ! -d "$KALDI_INSTALLATION_PATH/egs/$projet_name/utils" ]; then
    ln -s ../wsj/s5/utils .
    print_info "creation of symbolic link from folder $KALDI_INSTALLATION_PATH/egs/wjs/s5/utils to $projet_name"
else
    print_warning "Folder already exists: utils"
    ((nbr_warning++))
fi


if [ ! -d "$KALDI_INSTALLATION_PATH/egs/$projet_name/src" ]; then
    ln -s ../../src .
    print_info "creation of symbolic link from folder  $KALDI_INSTALLATION_PATH/src to $projet_name"
else
    print_warning "Folder already exists: src"
    ((nbr_warning++))
fi


print_info "Copy file $KALDI_INSTALLATION_PATH/egs/wjs/s5/path.sh to $projet_name "
cp ../wsj/s5/path.sh .

print_info "Change the path to the kaldi root inside the path.sh file to $KALDI_INSTALLATION_PATH "

mapfile -t lines < path.sh
# Modify the first line
lines[0]="export KALDI_ROOT=$KALDI_INSTALLATION_PATH"
# Write the modified contents back to the file
printf '%s\n' "${lines[@]}" > path.sh

if [ ! -d "exp" ]; then
    mkdir -p "exp"
    print_info "Folder created: exp"
else
    print_warning "Folder already exists: exp"
    ((nbr_warning++))
fi

if [ ! -d "conf" ]; then
    mkdir -p "conf"
    print_info "Folder created: conf"
else
    print_warning "Folder already exists: conf"
    ((nbr_warning++))
    exit 1
fi

if [ ! -d "data" ]; then
    mkdir -p "data"
    print_info "Folder created: data"
else
    print_warning "Folder already exists: data"
    ((nbr_warning++))
fi

cd "data" || exit 1

current_directory=$(pwd)
print_info "The current directory is: $current_directory"

if [ ! -d "train" ]; then
    mkdir -p "train"
    print_info "Folder created: train"
else
    print_warning "Folder already exists: train"
    ((nbr_warning++))
fi


if [ ! -d "lang" ]; then
    mkdir -p "lang"
    print_info "Folder created: lang"
else
    print_warning "Folder already exists: lang"
    ((nbr_warning++))
fi

if [ ! -d "local" ]; then
    mkdir -p "local"
    print_info "Folder created: local"
else
    print_warning "Folder already exists: local"
    ((nbr_warning++))
fi

cd "local" || exit 1
current_directory=$(pwd)
print_info "The current directory is: $current_directory"

if [ ! -d "lang" ]; then
    mkdir -p "lang"
    print_info "Folder created: lang"
else
    print_warning "Folder already exists: lang"
    ((nbr_warning++))
fi

if [ ! -d "local_lm" ]; then
    mkdir -p "local_lm"
    print_info "Folder created: local_lm"
else
    print_warning "Folder already exists: local_lm"
    ((nbr_warning++))
fi

cd "local_lm" || exit 1

if [ ! -d "data" ]; then
    mkdir -p "data"
    print_info "Folder created: data"
else
    print_warning "Folder already exists: data"
    ((nbr_warning++))
fi

if [ ! -d "nda'nda'" ]; then
    mkdir -p "nda'nda'"
    print_info "Folder created: nda'nda'"
else
    print_warning "Folder already exists: nda'nda'"
    ((nbr_warning++))
fi

print_info "End of initialization of project named $projet_name. \033[1;33m Warning Number = $nbr_warning \033[0m"



cd "$calling_script_path" || exit 1



#!/bin/bash -i

# Check the number of arguments
if [ $# -ne 1 ]; then
    echo "Error: Please provide a project name."
    echo "Usage: ./script.sh <project name>"
    exit 1
fi

projet_name=$1

config_file="../../configs/ConfigKaldi.json"

if [[ -z "${KALDI_INSTALATION_PATH}" ]]; then
    echo "Variable does not exist or is empty"
    kaldi_installation_path=$(jq -r '.kaldi_installation_path' "$config_file")
    echo "export KALDI_INSTALATION_PATH=\"$kaldi_installation_path\"" >> ~/.bashrc
    if [[ ":$PATH:" != *":$kaldi_installation_path:"* ]]; then
        echo "export PATH=\""\$"PATH:$kaldi_installation_path\"" >> ~/.bashrc
        echo "Path folder added successfully."
    else
        echo "Path folder $kaldi_installation_path already exists in PATH."
    fi
    source ~/.bashrc
    echo "Variable exported: $KALDI_INSTALATION_PATH"
else
    echo "kaldi installation path exists and has a value: $KALDI_INSTALATION_PATH"
fi



cd "$KALDI_INSTALATION_PATH/egs"

echo -n "The current directory is: "
pwd

if [ ! -d "$projet_name" ]; then
    mkdir -p "$projet_name"
    echo "Folder created: $projet_name"
else
    echo "Folder already exists: $projet_name"
    exit 1
fi

cd "$projet_name"

echo -n "The current directory is: "
pwd

echo "creation of symbolic link from folder steps to $projet_name"
ln -s ../wsj/s5/steps .
echo "creation of symbolic link from folder utils to $projet_name"
ln -s ../wsj/s5/utils .
echo "creation of symbolic link from folder src to $projet_name"
ln -s ../../src .
echo "creation of symbolic link from file path.sh to $projet_name"
cp ../wsj/s5/path.sh .

echo "Change the path to the kaldi root inside the path.sh file to $KALDI_INSTALATION_PATH"
mapfile -t lines < path.sh
# Modify the first line
lines[0]="export KALDI_ROOT=$KALDI_INSTALATION_PATH"
# Write the modified contents back to the file
printf '%s\n' "${lines[@]}" > path.sh

if [ ! -d "exp" ]; then
    mkdir -p "exp"
    echo "Folder created: exp"
else
    echo "Folder already exists: exp"
    exit 1
fi

if [ ! -d "conf" ]; then
    mkdir -p "exp"
    echo "Folder created: conf"
else
    echo "Folder already exists: conf"
    exit 1
fi

if [ ! -d "data" ]; then
    mkdir -p "data"
    echo "Folder created: data"
else
    echo "Folder already exists: data"
    exit 1
fi








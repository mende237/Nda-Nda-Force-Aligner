#!/bin/bash 

# Check the number of arguments
if [ $# -ne 1 ]; then
    echo "Error: Please provide a project name."
    echo "Usage: ./script.sh <project name>"
    exit 1
fi


project_name=$1
$project_name/utils/fix_data_dir.sh data/train
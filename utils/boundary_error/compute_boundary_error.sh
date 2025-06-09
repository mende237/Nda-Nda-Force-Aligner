#!/bin/bash

calling_script_path=$(pwd)
# Get the path to the script
script_path="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
cd "$script_path" || exit 1

source ../utils.sh

convert_textgrid_to_ctm=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --convert-textgrid-to-ctm)
            convert_textgrid_to_ctm=true
            shift
            ;;
        *)
            break
            ;;
    esac
done

if [ $# -ne 4 ]; then
    print_info "Usage: $0 <project name> <model folder> <align folder path> <test data path>"
    print_info "Example: $0 my_project model_folder align_folder test_data"
    exit 1
fi

project_name=$1
model_folder="$KALDI_INSTALLATION_PATH/egs/$project_name/exp/$2"
align_folder_path=$3
test_data_path=$4

project_setup_verification "$project_name"
nbr_warning=0
nbr_error=0

cd "$align_folder_path" || exit 1
print_info "The current directory is: $align_folder_path"

for i in ali.*.gz; do
    "$KALDI_INSTALLATION_PATH/src/bin/ali-to-phones" --ctm-output "$model_folder/final.mdl" "ark:gunzip -c $i |" "${i%.gz}.ctm"
done


status=$?
if [ $status -eq 1 ]; then
    ((nbr_error++))
    print_error "Error during the conversion of alignments to CTM format."
    exit 1
fi

if is_file_exist "merged_alignment.ctm"; then
    ((nbr_warning++))
    print_info "merged_alignment.ctm already exists. It will be overwritten."
    rm -f merged_alignment.ctm
fi


cat *.ctm > merged_alignment.ctm


status=$?
if [ $status -eq 1 ]; then
    ((nbr_error++))
    print_error "Error during the merging of CTM files."
    exit 1
fi


if $convert_textgrid_to_ctm; then
    cd "$script_path" || exit 1
    printf_info "The current directory is: $script_path"

    print_info "Conversion of textgrid files to CTM format started."

    find "$test_data_path" -type f -iname "*.TextGrid" | while read -r textgrid_file; do
        ctm_file="${textgrid_file%.TextGrid}.ctm"
        python "./convert_textgrid_to_ctm.py" "$textgrid_file" "$ctm_file"
    done

    status=$?
    if [ $status -eq 1 ]; then
        ((nbr_error++))
        print_error "Error during the conversion of TextGrid files to CTM format."
        exit 1
    fi
    print_info "Conversion of textgrid files to CTM format completed successfully."
fi


cd "$script_path" || exit 1
print_info "The current directory is: $script_path"

print_info "Computing boundary error started."

python ./compute_boundary_error.py $test_data_path $align_folder_path
status=$?
if [ $status -eq 1 ]; then
    ((nbr_error++))
    print_error "Error during the computation of boundary error."
    exit 1
fi

print_info "Computing boundary error completed successfully."


cd "$calling_script_path" || exit 1
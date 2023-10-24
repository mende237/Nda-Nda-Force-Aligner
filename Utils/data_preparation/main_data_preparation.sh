#!/bin/bash 

calling_script_path=$(pwd)
script_path="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
cd "$script_path"
source "../utils.sh"
cd "$script_path/bash_scripts"
source "$script_path/bash_scripts/delete_file.sh"
cd "$script_path"



# Check the number of arguments
if [ $# -ne 3 ]; then
    print_error "Please provide a project name and the data path folder root and number of speakers"
    print_info "Usage: ./script.sh <project name> <data path folder root> <nbr_speaker>"
    exit 1
fi

project_name=$1
data_root=$2
nbr_speaker=$3
nbr_warning=0
nbr_error=0

config_file="../../configs/Config.json"

project_setup_verification $project_name


python_virtual_environement_path=$(jq -r '.python_virtual_environement_path' "$config_file")

if [[ "$python_virtual_environement_path" == "null" ]]; then
    print_error "Variable python_virtual_environement_path doesn't exist in Config.json file."
    exit 1
fi


if ! is_file_exist "$python_virtual_environement_path/bin/activate"; then
    print_error "Impossible to activate virtual environement $python_virtual_environement_path"
    exit 1
fi

print_info "Activating the virtual environment $python_virtual_environement_path"
source $python_virtual_environement_path/bin/activate

response=""
while [[ ! $response =~ ^[YyNn]$ ]]; do
    read -p "Would you like to install the python dependencies contained in the requirement.txt file? (y/n): " response

    if [[ $response =~ ^[Yy]$ ]]; then
        print_info "Dependency installation"
        pip install -r ../../requirements.txt
        print_info "End of dependency installation"
    elif [[ $response =~ ^[Nn]$ ]]; then
        print_info "Skip dependency installation"
    else
        echo "Invalid response. Please enter 'y' for yes or 'n' for no."
    fi
done



print_info "text file generation in $KALDI_INSTALLATION_PATH/egs/$project_name/data/train"
if  is_file_exist $KALDI_INSTALLATION_PATH/egs/$project_name/data/train/text; then
    ((nbr_warning++))
    # print_warning "The file text already exit and the data it contains will be overwritten"
fi 
python generate_text_file.py $data_root $KALDI_INSTALLATION_PATH/egs/$project_name/data/train $nbr_speaker
status=$?
if [ $status -eq 1 ]; then
    ((nbr_error++))
    print_error "Error when creating a text file"
fi

print_info "wav.scp file generation in $KALDI_INSTALLATION_PATH/egs/$project_name/data/train"
if  is_file_exist $KALDI_INSTALLATION_PATH/egs/$project_name/data/train/wav.scp; then
    ((nbr_warning++))
    # print_warning "The file wav.scp already exit and the data it contains will be overwritten"
fi 
python generate_wav_scp_file.py $KALDI_INSTALLATION_PATH/egs/$project_name/data/train/text $KALDI_INSTALLATION_PATH/egs/$project_name/data/train $data_root
status=$?
if [ $status -eq 1 ]; then
    ((nbr_error++))
    print_error "Error when creating a wav.scp file"
fi

print_info "segments file generation in $KALDI_INSTALLATION_PATH/egs/$project_name/data/train"
if  is_file_exist $KALDI_INSTALLATION_PATH/egs/$project_name/data/train/segments; then
    ((nbr_warning++))
    # print_warning "The file segments already exit and the data it contains will be overwritten"
fi 
python generate_segment_file.py $KALDI_INSTALLATION_PATH/egs/$project_name/data/train/wav.scp $KALDI_INSTALLATION_PATH/egs/$project_name/data/train

status=$?
if [ $status -eq 1 ]; then
    ((nbr_error++))
    print_error "Error when creating a segments file"
fi


print_info "utt2spk file generation in $KALDI_INSTALLATION_PATH/egs/$project_name/data/train"
if  is_file_exist $KALDI_INSTALLATION_PATH/egs/$project_name/data/train/utt2spk; then
    ((nbr_warning++))
    # print_warning "The file utt2spk already exit and the data it contains will be overwritten"
fi 
python generate_utterance_to_speaker_file.py $KALDI_INSTALLATION_PATH/egs/$project_name/data/train/text $KALDI_INSTALLATION_PATH/egs/$project_name/data/train

status=$?
if [ $status -eq 1 ]; then
    ((nbr_error++))
    print_error "Error when creating utt2spk file"
fi

current_script_path=$(pwd)

cd "$KALDI_INSTALLATION_PATH/egs/$project_name"
print_info "The current directory is: $KALDI_INSTALLATION_PATH/egs/$project_name"
print_info "spk2utt file generation in data/train"
if  is_file_exist spk2utt; then
    $((nbr_warning++))
    # print_warning "The file spk2utt already exit and the data it contains will be overwritten"
fi 

utils/fix_data_dir.sh data/train

cd "$current_script_path"
print_info "The current directory is: $current_script_path"

print_info "lexicon.txt file generation in $KALDI_INSTALLATION_PATH/egs/$project_name/data/local/lang"
python generate_lexicon_file.py $KALDI_INSTALLATION_PATH/egs/$project_name/data/train/text $KALDI_INSTALLATION_PATH/egs/$project_name/data/local/lang

print_info "nonsilence_phones.txt file generation in $KALDI_INSTALLATION_PATH/egs/$project_name/data/local/lang"
# cut -d ' ' -f 2- "$KALDI_INSTALLATION_PATH/egs/$project_name/data/local/lang/lexicon.txt" | sed 's/ /\n/g' | sort -u > "$KALDI_INSTALLATION_PATH/egs/$project_name/data/local/lang/nonsilence_phones.txt"
cut -d ' ' -f 2- "$KALDI_INSTALLATION_PATH/egs/$project_name/data/local/lang/lexicon.txt" | sed 's/ /\n/g' | sort -u | grep -vE '^(spn|sil)$' > "$KALDI_INSTALLATION_PATH/egs/$project_name/data/local/lang/nonsilence_phones.txt"

print_info "silence_phones.txt file generation in $KALDI_INSTALLATION_PATH/egs/$project_name/data/local/lang"
printf 'sil\nspn\n' > "$KALDI_INSTALLATION_PATH/egs/$project_name/data/local/lang/silence_phones.txt"

print_info "optional_silence.txt file generation in $KALDI_INSTALLATION_PATH/egs/$project_name/data/local/lang"
echo 'sil' > $KALDI_INSTALLATION_PATH/egs/$project_name/data/local/lang/optional_silence.txt


delete_in_lang_local_auto_generated_file "$project_name"

cd "$KALDI_INSTALLATION_PATH/egs/$project_name"

current_directory=$(pwd)
print_info "The current directory is: $current_directory"

print_info "Generation of other folders in data/lang and data/local folders"
utils/prepare_lang.sh data/local/lang 'oov' data/local data/lang


status=$?
if [ $status -eq 1 ]; then
    ((nbr_error++))
    print_error "When creating other files in data/local and data/lang folders "
fi

print_info "Deactivate virtual environment $python_virtual_environement_path"
deactivate

print_info "End of data preparation for project named $projet_name. \033[1;33m Warning Number = $nbr_warning \033[0m  \033[1;31m Error Number = $nbr_error \033[0m"

cd "$calling_script_path"
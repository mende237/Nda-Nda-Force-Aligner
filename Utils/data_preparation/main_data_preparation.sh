#!/bin/bash 

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

source "$SCRIPT_DIR/../utils.sh"
cd "$SCRIPT_DIR/bash_scripts"
source "$SCRIPT_DIR/bash_scripts/delete_file.sh"
cd "$SCRIPT_DIR"

# Check the number of arguments
if [ $# -ne 3 ]; then
    print_error "Please provide a project name and the data path folder root"
    print_info "Usage: ./script.sh <project name> <data path folder root> <nbr_speaker>"
    exit 1
fi

project_name=$1
data_root=$2
nbr_speaker=$3
nbr_warning=0

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
    print_warning "The file text already exit and the data it contains will be overwritten"
fi 
python generate_text_file.py $data_root $KALDI_INSTALLATION_PATH/egs/$project_name/data/train $nbr_speaker


print_info "wav.scp file generation in $KALDI_INSTALLATION_PATH/egs/$project_name/data/train"
if  is_file_exist $KALDI_INSTALLATION_PATH/egs/$project_name/data/train/wav.scp; then
    ((nbr_warning++))
    print_warning "The file wav.scp already exit and the data it contains will be overwritten"
fi 
python generate_wav_scp_file.py $KALDI_INSTALLATION_PATH/egs/$project_name/data/train/text $KALDI_INSTALLATION_PATH/egs/$project_name/data/train $data_root


print_info "segments file generation in $KALDI_INSTALLATION_PATH/egs/$project_name/data/train"
if  is_file_exist $KALDI_INSTALLATION_PATH/egs/$project_name/data/train/segments; then
    ((nbr_warning++))
    print_warning "The file segments already exit and the data it contains will be overwritten"
fi 
python generate_segment_file.py $KALDI_INSTALLATION_PATH/egs/$project_name/data/train/wav.scp $KALDI_INSTALLATION_PATH/egs/$project_name/data/train


print_info "utt2spk file generation in $KALDI_INSTALLATION_PATH/egs/$project_name/data/train"
if  is_file_exist $KALDI_INSTALLATION_PATH/egs/$project_name/data/train/utt2spk; then
    ((nbr_warning++))
    print_warning "The file utt2spk already exit and the data it contains will be overwritten"
fi 
python generate_utterance_to_speaker_file.py $KALDI_INSTALLATION_PATH/egs/$project_name/data/train/text $KALDI_INSTALLATION_PATH/egs/$project_name/data/train



current_script_path=$(pwd)

cd "$KALDI_INSTALLATION_PATH/egs/$project_name"
print_info "The current directory is: $KALDI_INSTALLATION_PATH/egs/$project_name"
print_info "spk2utt file generation in data/train"
if  is_file_exist spk2utt; then
    $((nbr_warning++))
    print_warning "The file spk2utt already exit and the data it contains will be overwritten"
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
utils/prepare_lang.sh data/local/lang 'spn' data/local data/lang

print_info "Deactivate virtual environment $python_virtual_environement_path"
deactivate


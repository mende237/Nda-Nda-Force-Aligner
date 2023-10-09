#!/bin/bash 

source ../utils.sh

# Check the number of arguments
if [ $# -ne 3 ]; then
    echo "Error: Please provide a project name and the data path folder root"
    echo "Usage: ./script.sh <project name> <data path folder root> <nbr_speaker>"
    exit 1
fi

project_name=$1
data_root=$2
nbr_speaker=$3

config_file="../../configs/Config.json"

if ! is_folder_exist "$KALDI_INSTALLATION_PATH"; then
    print_error "The Kaldi installation root folder not exist, if you are already install please configure it in the Config.json under the configs folder and run the export.sh script"
    exit 1
fi


if ! is_folder_exist "$KALDI_INSTALLATION_PATH/egs/$project_name"; then
    print_error "The projet with name $project_name doesn't exist in kaldi installation root please run the initialize.sh script to create projet"
    exit 1
fi


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
python generate_text_file.py $data_root $KALDI_INSTALLATION_PATH/egs/$project_name/data/train $nbr_speaker


print_info "wav.scp file generation in $KALDI_INSTALLATION_PATH/egs/$project_name/data/train"
python generate_wav_scp_file.py $KALDI_INSTALLATION_PATH/egs/$project_name/data/train/text $KALDI_INSTALLATION_PATH/egs/$project_name/data/train $data_root


# print_info "segments file generation in $KALDI_INSTALLATION_PATH/egs/$project_name/data/train"
# python generate_segment_file.py $KALDI_INSTALLATION_PATH/egs/$project_name/data/train/wav.scp $KALDI_INSTALLATION_PATH/egs/$project_name/data/train

print_info "utt2spk file generation in $KALDI_INSTALLATION_PATH/egs/$project_name/data/train"
python generate_utterance_to_speaker_file.py $KALDI_INSTALLATION_PATH/egs/$project_name/data/train/text $KALDI_INSTALLATION_PATH/egs/$project_name/data/train


print_info "lexicon.txt file generation in $KALDI_INSTALLATION_PATH/egs/$project_name/data/local/lang"
python generate_lexicon_file.py $KALDI_INSTALLATION_PATH/egs/$project_name/data/train/text $KALDI_INSTALLATION_PATH/egs/$project_name/data/local/lang

print_info "nonsilence_phones.txt file generation in $KALDI_INSTALLATION_PATH/egs/$project_name/data/local/lang"
cut -d ' ' -f 2- "$KALDI_INSTALLATION_PATH/egs/$project_name/data/local/lang/lexicon.txt" | sed 's/ /\n/g' | sort -u > "$KALDI_INSTALLATION_PATH/egs/$project_name/data/local/lang/nonsilence_phones.txt"

print_info "silence_phones.txt file generation in $KALDI_INSTALLATION_PATH/egs/$project_name/data/local/lang"
echo –e 'sil'\\n'oov' > $KALDI_INSTALLATION_PATH/egs/$project_name/data/local/lang/silence_phones.txt

print_info "optional_silence.txt file generation in $KALDI_INSTALLATION_PATH/egs/$project_name/data/local/lang"
echo 'sil' > $KALDI_INSTALLATION_PATH/egs/$project_name/data/local/lang/optional_silence.txt

cd "$KALDI_INSTALLATION_PATH/egs/$project_name"

current_directory=$(pwd)
print_info "The current directory is: $current_directory"

print_info "Generation of other folders in data/lang and data/local folders"
utils/prepare_lang.sh data/local/lang 'oov' data/local data/lang

print_info "Deactivate virtual environment $python_virtual_environement_path"
# deactivation of python virtual environement
deactivate


#!/bin/bash

calling_script_path=$(pwd)
script_path="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
cd "$script_path" || exit 1
source "../../utils.sh"
source "../bash_scripts/delete_file.sh"
cd "$script_path" || exit 1

add_question=false


while [[ $# -gt 0 ]]; do
    case $1 in
        --question)
            add_question=true
            shift
            ;;
        *)
            break
            ;;
    esac
done

# Check the number of arguments
if [ $# -ne 2 ]; then
    print_info "Usage: $0 [options] <project name> <data path folder root>"
    print_info "--question if you want to add extract question"
    exit 1
fi

project_name=$1
data_root=$2
nbr_speaker=$3
nbr_warning=0
nbr_error=0

config_file="../../../configs/Config.json"

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

text_file=data/train/text
lm_root_data=data/local/local_lm/data/nda\'nda\'
lm_data_file=data/local/local_lm/data/nda\'nda\'/train.tokens
lm_dir=data/local/local_lm
output_model_dir=$lm_dir/arpa
lm_model_name=nda\'nda\'
lm_model_order=3


print_info "*********************** train data preparation ****************************"
. ./generate_base_files.sh --lm $KALDI_INSTALLATION_PATH/egs/$project_name/$lm_data_file $project_name $data_root

print_info "*********************** test data preparation *****************************"
. ./generate_base_files.sh --test $project_name $data_root


cd "$current_script_path" || exit 1
print_info "The current directory is: $current_script_path"

loxicon_folder=data/local
wordlist_folder=data/local/local_lm/data


print_info "lexicon.txt and wordlist file generation in $KALDI_INSTALLATION_PATH/egs/$project_name/$loxicon_folder and $KALDI_INSTALLATION_PATH/egs/$project_name/$wordlist_folder"
python generate_lexicon_file.py $KALDI_INSTALLATION_PATH/egs/$project_name/data/train/text $KALDI_INSTALLATION_PATH/egs/$project_name/$loxicon_folder


print_info "nonsilence_phones.txt file generation in $KALDI_INSTALLATION_PATH/egs/$project_name/data/local/lang"
# cut -d ' ' -f 2- "$KALDI_INSTALLATION_PATH/egs/$project_name/data/local/lang/lexicon.txt" | sed 's/ /\n/g' | sort -u > "$KALDI_INSTALLATION_PATH/egs/$project_name/data/local/lang/nonsilence_phones.txt"
cut -d ' ' -f 2- "$KALDI_INSTALLATION_PATH/egs/$project_name/data/local/lang/lexicon.txt" | sed 's/ /\n/g' | sort -u | grep -vE '^(spn|sil)$' > "$KALDI_INSTALLATION_PATH/egs/$project_name/data/local/lang/nonsilence_phones.txt"

print_info "silence_phones.txt file generation in $KALDI_INSTALLATION_PATH/egs/$project_name/data/local/lang"
printf 'sil\nspn\n' > "$KALDI_INSTALLATION_PATH/egs/$project_name/data/local/lang/silence_phones.txt"

print_info "optional_silence.txt file generation in $KALDI_INSTALLATION_PATH/egs/$project_name/data/local/lang"
echo 'sil' > $KALDI_INSTALLATION_PATH/egs/$project_name/data/local/lang/optional_silence.txt


if $add_question; then
# m n ŋ nasales
# f s z fritives
    tone_questions="í é ɛ́ ə́ á ú ó ɔ́ ɨ́
ə̀ à ò ɔ̀ ɛ̀
î ɛ̂ ə̂ ɔ̂ â 
ɔ̌ ǔ
í î
é
ɛ́ ɛ̂ ɛ̀ 
ə́ ə̂ ə̀
á â à
ú ǔ
ó ò
ɔ́ ɔ̌ ɔ̀
ɨ́   
m n ŋ
f s z"

    print_info "extra_questions.txt file generation in $KALDI_INSTALLATION_PATH/egs/$project_name/data/local/lang"
    if  is_file_exist $KALDI_INSTALLATION_PATH/egs/$project_name/data/local/lang/extra_questions.txt; then
        ((nbr_warning++))
        print_warning "The file segments already exit and the data it contains will be overwritten"
        echo "$tone_questions" > "$KALDI_INSTALLATION_PATH/egs/$project_name/data/local/lang/extra_questions.txt"
    else
        echo "$tone_questions" > "$KALDI_INSTALLATION_PATH/egs/$project_name/data/local/lang/extra_questions.txt"
    fi 
fi

delete_in_lang_local_auto_generated_file "$project_name"

status=$?
if [ $status -eq 1 ]; then
    ((nbr_error++))
    print_error "When deleting auto generated files"
fi


cd "$KALDI_INSTALLATION_PATH/egs/$project_name" || exit 1

current_directory=$(pwd)
print_info "The current directory is: $current_directory"

print_info "Generation of other folders in data/lang and data/local folders"

utils/prepare_lang.sh data/local/lang 'oov' data/local data/lang

# utils/prepare_lang.sh --position-dependent-phones false data/local/dict "oov" data/local/lang data/lang

status=$?
if [ $status -eq 1 ]; then
    ((nbr_error++))
    print_error "When creating other files in data/local and data/lang folders "
fi

cd "$script_path" || exit 1
print_info "The current directory is: $script_path"

response=""
while [[ ! $response =~ ^[YyNn]$ ]]; do
    read -p "Would you like to train language model with data inside $KALDI_INSTALLATION_PATH/egs/$project_name/$text_file ? (y/n): " response
    if [[ $response =~ ^[Yy]$ ]]; then
        if [ ! -d "$KALDI_INSTALLATION_PATH/egs/$project_name/$lm_dir/out" ]; then
            mkdir -p "$KALDI_INSTALLATION_PATH/egs/$project_name/$lm_dir/out"
            print_info "Folder created: $KALDI_INSTALLATION_PATH/egs/$project_name/$lm_dir/out"
        else
            print_warning "Folder already exists: $KALDI_INSTALLATION_PATH/egs/$project_name/$lm_dir/out"
            ((nbr_warning++))
        fi
        cp $KALDI_INSTALLATION_PATH/egs/$project_name/$lm_data_file $KALDI_INSTALLATION_PATH/egs/$project_name/$lm_root_data/valid.tokens
        cp $KALDI_INSTALLATION_PATH/egs/$project_name/$lm_data_file $KALDI_INSTALLATION_PATH/egs/$project_name/$lm_root_data/test.tokens
        lm_model_order=3
        python ../../../training/language_model/lm/main.py --order $lm_model_order \
         --interpolate --save-arpa --name $lm_model_name \
         --data $KALDI_INSTALLATION_PATH/egs/$project_name/$lm_root_data \
         --out  $KALDI_INSTALLATION_PATH/egs/$project_name/$lm_dir/out \
         --output-model $KALDI_INSTALLATION_PATH/egs/$project_name/$output_model_dir

        gzip -f $KALDI_INSTALLATION_PATH/egs/$project_name/$output_model_dir/$lm_model_name"."$lm_model_order"gram.arpa"

        status=$?
        if [ $status -eq 1 ]; then
            ((nbr_error++))
            print_error "During language model training"
        else
            print_info "End of language model training check the output inside folders $KALDI_INSTALLATION_PATH/egs/$project_name/$output_model_dir and $KALDI_INSTALLATION_PATH/egs/$project_name/$lm_dir/out"
        fi

        cd "$KALDI_INSTALLATION_PATH/egs/$project_name" || exit 1
        current_directory=$(pwd)
        print_info "The current directory is: $current_directory"
        
        print_info "Conversion of the language model from arpa format to FST format"
        utils/format_lm.sh data/lang $output_model_dir/$lm_model_name"."$lm_model_order"gram.arpa.gz" data/local/lang/lexicon.txt data/lang

        if [ $status -eq 1 ]; then
            ((nbr_error++))
            print_error "During language model conversion"
        else
            print_info "End of conversion see result inside folder data/lang"
        fi
    elif [[ $response =~ ^[Nn]$ ]]; then
        print_info "Skip language model training"
    else
        echo "Invalid response. Please enter 'y' for yes or 'n' for no."
    fi
done


print_info "Deactivate virtual environment $python_virtual_environement_path"
deactivate

print_info "End of data preparation for project named $project_name. \033[1;33m Warning Number = $nbr_warning \033[0m  \033[1;31m Error Number = $nbr_error \033[0m"

cd "$calling_script_path" || exit 1
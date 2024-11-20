#!/bin/bash 

calling_script_path=$(pwd)
# Get the path to the script
script_path="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
cd "$script_path" || exit 1
source ../Utils/utils.sh


transform_dir=   # this option won't normally be used, but it can be used if you want to
                 # supply existing fMLLR transforms when decoding.
iter=
model= # You can specify the model to use (e.g. if you want to use the .alimdl)
stage=0
nj=1
cmd=run.pl
max_active=7000
beam=13.0
lattice_beam=6.0
acwt=0.083333 # note: only really affects pruning (scoring is on lattices).
num_threads=1 # if >1, will use gmm-latgen-faster-parallel
parallel_opts=  # ignored now.
scoring_opts=
# note: there are no more min-lmwt and max-lmwt options, instead use
# e.g. --scoring-opts "--min-lmwt 1 --max-lmwt 20"
skip_scoring=false
decode_extra_opts=
config_file=

config_options="--stage $stage --nj $nj --cmd $cmd --max-active $max_active --beam $beam --lattice-beam $lattice_beam --acwt $acwt --num-threads $num_threads --skip-scoring $skip_scoring"

 
cd "$KALDI_INSTALLATION_PATH/egs/wsj/s5" || exit 1;
print_info "Inside the directory $(pwd)"
. utils/parse_options.sh || exit 1;

if [ $# != 4 ]; then
    print_info "Usage: $0 [options] <project name> <data folder name> <model folder name> <decode folder name>"
    exit 1
fi

project_name=$1
data_folder_name=$2
model_folder_name=$3
decode_folder_name=$4

project_setup_verification $project_name


if [[ $transform_dir ]]; then
    config_options="$config_options --transform-dir $transform_dir"
fi

if [[ $iter ]]; then
    config_options="$config_options --iter $iter"
fi

if [[ $model ]]; then
    config_options="$config_options --model $model"
fi

if [[ $parallel_opts ]]; then
    config_options="$config_options --parallel-opts $parallel_opts"
fi

if [[ $scoring_opts ]]; then
    config_options="$config_options --scoring-opts $scoring_opts"
fi

if [[ $decode_extra_opts ]]; then
    config_options="$config_options --decode-extra-opts $decode_extra_opts"
fi




cd "$KALDI_INSTALLATION_PATH/egs/$project_name" || exit 1;
print_info "Inside the directory $(pwd)"
steps/decode.sh $config_options --model exp/$model_folder_name/final.mdl exp/$model_folder_name/graph data/$data_folder_name exp/$model_folder_name/$decode_folder_name


# steps/scoring/score_kaldi_wer.sh $config_options exp/$model_folder_name/final.mdl exp/$model_folder_name/graph data/$data_folder_name exp/$model_folder_name/$decode_folder_name
cd "$calling_script_path" || exit 1

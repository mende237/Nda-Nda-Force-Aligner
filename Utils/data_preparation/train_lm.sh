#!/usr/bin/env bash

calling_script_path=$(pwd)
script_path="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
cd "$script_path" || exit 1
source ../utils.sh


if [ $# -ne 1 ]; then
    print_error "Please provide a project name."
    print_info "Usage: ./$0 <project name>"
    exit 1
fi

project_name=$1

stage=1


dir=data/local/local_lm
lm_dir=${dir}/data

print_info "Creation of language model folder $dir"
mkdir -p $dir

cd "$KALDI_INSTALLATION_PATH/egs/$project_name"

. ./path.sh || exit 1; # for KALDI_ROOT

export PATH=$KALDI_ROOT/tools/pocolm/scripts:$PATH
( # First make sure the pocolm toolkit is installed.
 cd $KALDI_ROOT/tools || exit 1;
 if [ -d pocolm ]; then
   echo Not installing the pocolm toolkit since it is already there.
 else
   echo "$0: Please install the PocoLM toolkit with: "
   echo " cd $KALDI_INSTALLATION_PATH/tools; extras/install_pocolm.sh; cd -"
   exit 1;
 fi
) || exit 1;

num_dev_sentences=10000

#bypass_metaparam_optim_opt=
# If you want to bypass the metaparameter optimization steps with specific metaparameters
# un-comment the following line, and change the numbers to some appropriate values.
# You can find the values from output log of train_lm.py.
# These example numbers of metaparameters is for 4-gram model (with min-counts)
# running with train_lm.py.
# The dev perplexity should be close to the non-bypassed model.
bypass_metaparam_optim_opt="--bypass-metaparameter-optimization=0.854,0.0722,0.5808,0.338,0.166,0.015,0.999,0.6228,0.340,0.172,0.999,0.788,0.501,0.406"
# Note: to use these example parameters, you may need to remove the .done files
# to make sure the make_lm_dir.py be called and tain only 3-gram model
#for order in 3; do
#rm -f ${lm_dir}/${num_word}_${order}.pocolm/.done



order=4

if [ $stage -le 1 ]; then
  # decide on the vocabulary.
  # Note: you'd use --wordlist if you had a previously determined word-list
  # that you wanted to use.
  # Note: if you have more than one order, use a certain amount of words as the
  # vocab and want to restrict max memory for 'sort',
  echo "$0: training the unpruned LM"
  min_counts='train=2 ted=1'
  wordlist=${dir}/data/wordlist

  lm_name="`basename ${wordlist}`_${order}"
  if [ -n "${min_counts}" ]; then
    lm_name+="_`echo ${min_counts} | tr -s "[:blank:]" "_" | tr "=" "-"`"
  fi
  unpruned_lm_dir=${lm_dir}/${lm_name}.pocolm
  train_lm.py  --wordlist=${wordlist} --num-splits=10 --warm-start-ratio=20  \
               --limit-unk-history=true \
               --fold-dev-into=ted ${bypass_metaparam_optim_opt} \
               --min-counts="${min_counts}" \
               ${dir}/data/text ${order} ${lm_dir}/work ${unpruned_lm_dir}

  get_data_prob.py ${dir}/data/real_dev_set.txt ${unpruned_lm_dir} 2>&1 | grep -F '[perplexity'
  #[perplexity = 157.87] over 18290.0 words
fi

if [ $stage -le 2 ]; then
  echo "$0: pruning the LM (to larger size)"
  # Using 10 million n-grams for a big LM for rescoring purposes.
  size=10000000
  prune_lm_dir.py --target-num-ngrams=$size --initial-threshold=0.02 ${unpruned_lm_dir} ${dir}/data/lm_${order}_prune_big

  get_data_prob.py ${dir}/data/real_dev_set.txt ${dir}/data/lm_${order}_prune_big 2>&1 | grep -F '[perplexity'

  # current results, after adding --limit-unk-history=true:
  # get_data_prob.py: log-prob of data/local/local_lm/data/real_dev_set.txt given model data/local/local_lm/data/lm_4_prune_big was -5.16562818753 per word [perplexity = 175.147449465] over 18290.0 words.


  mkdir -p ${dir}/data/arpa
  format_arpa_lm.py ${dir}/data/lm_${order}_prune_big | gzip -c > ${dir}/data/arpa/${order}gram_big.arpa.gz
fi

# if [ $stage -le 3 ]; then
#   echo "$0: pruning the LM (to smaller size)"
#   # Using 2 million n-grams for a smaller LM for graph building.  Prune from the
#   # bigger-pruned LM, it'll be faster.
#   size=2000000
#   prune_lm_dir.py --target-num-ngrams=$size ${dir}/data/lm_${order}_prune_big ${dir}/data/lm_${order}_prune_small

#   get_data_prob.py ${dir}/data/real_dev_set.txt ${dir}/data/lm_${order}_prune_small 2>&1 | grep -F '[perplexity'

#   # current results, after adding --limit-unk-history=true (needed for modeling OOVs and not blowing up LG.fst):
#   # get_data_prob.py: log-prob of data/local/local_lm/data/real_dev_set.txt given model data/local/local_lm/data/lm_4_prune_small was -5.29432352378 per word [perplexity = 199.202824404 over 18290.0 words.


#   format_arpa_lm.py ${dir}/data/lm_${order}_prune_small | gzip -c > ${dir}/data/arpa/${order}gram_small.arpa.gz
# fi
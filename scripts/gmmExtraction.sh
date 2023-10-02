FINAL_MODEL_PATH=/home/dimitri/kaldi/egs/mycorpus/exp/mono_10/final.mdl 

SCRIPT_PATH=$(dirname "$0")

CONFIG_PATH=$SCRIPT_PATH/configs/pre-trainedModel

mkdir -p $CONFIG_PATH

gmm-info $FINAL_MODEL_PATH > "$CONFIG_PATH/info.txt"



# for i in $(seq 1 num_states); do 
#     gmm-copy --binary=false --print-args=false --print-covars=false --print-weights=false final.mdl - | awk '{if ($1 == "mu") {print $2}}' > state_${i}_means.txt; 
# done
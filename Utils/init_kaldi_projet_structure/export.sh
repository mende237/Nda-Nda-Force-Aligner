#!/bin/bash -i

config_file="../../configs/Config.json"

# if [[ -z "${KALDI_INSTALLATION_PATH}" ]]; then
#     echo "Variable does not exist or is empty"
#     kaldi_installation_path=$(jq -r '.kaldi_installation_path' "$config_file")
#     echo "export KALDI_INSTALLATION_PATH=\"$kaldi_installation_path\"" >> ~/.bashrc
#     if [[ ":$PATH:" != *":$kaldi_installation_path:"* ]]; then
          echo "export PATH=\"\$PATH:$kaldi_installation_path\"" >> ~/.bashrc
#         echo "Path folder added successfully."
#     else
#         echo "Path folder $kaldi_installation_path already exists in PATH."
#     fi
#     source ~/.bashrc
#     echo "Variable exported: $KALDI_INSTALLATION_PATH"
# else
#     new_kaldi_installation_path=$(jq -r '.kaldi_installation_path' "$config_file")
#     if [ "$new_kaldi_installation_path" == "$KALDI_INSTALLATION_PATH" ]; then
#         echo "kaldi installation path exists and has a value: $KALDI_INSTALLATION_PATH"
#     else
#         old_kaldi_installation_path=$KALDI_INSTALATION_PATH
#         echo "Updating KALDI_INSTALLATION_PATH to: $new_kaldi_installation_path"
#         sed -i "s|\(export KALDI_INSTALLATION_PATH=\).*|\1\"$new_kaldi_installation_path\"|" ~/.bashrc

#         if [[ ":$PATH:" != *":$new_kaldi_installation_path:"* ]]; then
#             echo "Updating PATH to: \$PATH:$new_kaldi_installation_path"
#             echo "Path folder updated successfully."
#             export PATH=$(echo "$PATH" | grep -v "$old_kaldi_installation_path" | sed 's/:$//')
#         else
#             echo "Path folder $new_kaldi_installation_path already exists in PATH."
#         fi
#         source ~/.bashrc
#         echo "Variable exported: $KALDI_INSTALLATION_PATH"
#     fi
# fi

# old_kaldi_installation_path="/home/dimitri/kaldir"
# export PATH=$(echo "$PATH" | grep -v "$old_kaldi_installation_path" | sed 's/:$//')

# old_kaldi_installation_path="/home/dimitri/kaldit"
# export PATH=$(echo "$PATH" | grep -v "$old_kaldi_installation_path" | sed 's/:$//')

# old_kaldi_installation_path="/home/dimitri/kaldi"
# export PATH=$(echo "$PATH" | grep -v "$old_kaldi_installation_path" | sed 's/:$//')

#!/bin/bash

# variable_to_remove="/home/dimitri/kaldi/tools"

# export PATH=$(echo "$PATH" | awk -v RS=: -v ORS=: '$0 != "'"$variable_to_remove"'"' | sed 's/:$//')

# export PATH=$(echo "$PATH" | awk -v RS=: -v ORS=: '$0 != "/home/dimitri/kaldi/tools"' | sed 's/:$//')

# export PATH=$(echo "$PATH" | sed -e "s#:$variable_to_remove:#:#g" -e "s#:$variable_to_remove\$##g" -e "s#^$variable_to_remove:#:#" -e "s#^$variable_to_remove\$##")
variable_to_remove="home/dimitri/kaldi/tools"

IFS=':' read -ra path_array <<< "$PATH"
new_path=""

for path in "${path_array[@]}"; do
  if [[ $path != "$variable_to_remove" ]]; then
    new_path+=":$path"
  fi
done

new_path="${new_path:1}"
# export PATH="$new_path"

echo "export PATH=$new_path" >> ~/.bashrc

source ~/.bashrc

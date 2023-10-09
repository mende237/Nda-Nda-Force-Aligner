#!/bin/bash

is_folder_exist() {
    folder_path=$1
    if [  -d "$folder_path" ]; then
        return 0
    else
        return 1
    fi
}

is_file_exist(){
    file_path=$1
    if [  -f "$file_path" ]; then
        return 0
    else
        return 1
    fi
}

print_warning() {
    local message="$1"
    echo -e "\033[1;33m[Warning]:\033[0m $message"
}


print_error() {
    local message="$1"
    echo -e "\033[1;31m[Error]:\033[0m $message"
}


print_info() {
    local message="$1"
    echo -e "\033[1;32m[Info]:\033[0m $message"
}

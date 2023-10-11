#!/bin/bash

setup_colors() {
  if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
    NOFORMAT='\033[0m' RED='\033[0;31m' GREEN='\033[0;32m' ORANGE='\033[0;33m' BLUE='\033[0;34m' PURPLE='\033[0;35m' CYAN='\033[0;36m' YELLOW='\033[1;33m'
  else
    NOFORMAT='' RED='' GREEN='' ORANGE='' BLUE='' PURPLE='' CYAN='' YELLOW=''
  fi
}
setup_colors
msg() {
  echo >&2 -e "${1-}"
}

declare -a ip_address_array=(
  "10.12.168.210"
  "10.12.168.211"
  "10.12.168.212"
  "10.12.168.213"
  "10.12.168.214"
)

declare -a hostname_array=(
  "insilicoapi00"
  "insilicoapi01"
  "insilicoapi02"
  "insilicoapi03"
  "insilicoapi04"
)

SSH_USER="insilico"
SSH_PASSWORD="7890uiop"

ssh_key_file="$HOME/.ssh/id_rsa"
authorized_file="/home/${SSH_USER}/.ssh/authorized_keys"

for ((j=0; j<${#ip_address_array[@]}; j++)); do
    ip="${ip_address_array[$j]}"
    hostname="${hostname_array[$j]}"
    ssh_key=`cat ${ssh_key_file}.pub`

    msg "${YELLOW}  copy ssh key to ${hostname}(${ip}) authorized_keys ${NOFORMAT}"
    sshpass -"p${SSH_PASSWORD}" ssh "$SSH_USER@$ip" " \
        if [ ! -f '$authorized_file' ]; then \
            echo '$ssh_key' | sudo tee -a $authorized_file; \
        else \
            if ! grep -qF '$ssh_key' ${authorized_file}; then \
                echo '$ssh_key' | sudo tee -a '${authorized_file}'; \
                echo '    successfully wrote key into $hostname'; \
            else \
                echo '    skipping: ssh-key already exist in ${authorized_file}'; \
            fi; \
        fi;"
done
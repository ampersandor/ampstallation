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
  "hadoop-api00"
  "hadoop-api01"
  "hadoop-api02"
  "hadoop-api03"
  "hadoop-api04"
)

HADOOP_VERSION="3.3.1"
JAVA_VERSION="openjdk-11-jdk"
SSH_USER="insilico"
SSH_PASSWORD="7890uiop"
hosts_file="/etc/hosts"
ssh_key_file="/home/${SSH_USER}/.ssh/id_rsa"
hadoop_dirname=hadoop-${HADOOP_VERSION}
hadoop_home="/home/${SSH_USER}/${hadoop_dirname}"
bash_file="/home/${SSH_USER}/.bashrc"

msg "${GREEN}########################## Install Java ########################### ${NOFORMAT}"
for ((i=0; i<${#ip_address_array[@]}; i++)); do
    ip="${ip_address_array[$i]}"
    msg "${BLUE} install ${JAVA_VERSION} on ${ip} ${NOFORMAT}"
    sshpass -"p${SSH_PASSWORD}" ssh "$SSH_USER@$ip" "sudo apt update && sudo apt install ${JAVA_VERSION} -y"
done



msg "${GREEN}########################## Create Host File on Each Node: ${hosts_file} ########################### ${NOFORMAT}"

for ((i=0; i<${#ip_address_array[@]}; i++)); do
    ip="${ip_address_array[$i]}"
    hostname="${hostname_array[$i]}"
    content_to_add="$ip $hostname"
    msg "${BLUE}Broadcasting ${content_to_add} to other nodes ${NOFORMAT}"
    for ((j=0; j<${#ip_address_array[@]}; j++)); do
        other_ip="${ip_address_array[$j]}"
        msg "${YELLOW}  writing into ${other_ip}... ${NOFORMAT}"
        sshpass -"p${SSH_PASSWORD}" ssh "$SSH_USER@$other_ip" " \
            if [ ! -f '$hosts_file' ]; then \
                echo '$content_to_add' | sudo tee -a $hosts_file; \
            else \
                if ! grep -qF '$content_to_add' '$hosts_file'; then \
                    echo '${content_to_add}' | sudo tee -a '${hosts_file}'; \
                    echo '    successfully wrote ${content_to_add} into ${hosts_file}'; \
                else \
                    echo '    skipping: ${content_to_add} already exist in ${hosts_file}'; \
                fi; \
            fi"
    done
done

msg "${GREEN}########################## Distribute Authentication Key-pairs ########################### ${NOFORMAT}"

for ((i=0; i<${#ip_address_array[@]}; i++)); do
    ip="${ip_address_array[$i]}"
    hostname="${hostname_array[$i]}"

    msg "${BLUE}Generating ssh key ${NOFORMAT}"
    sshpass -"p${SSH_PASSWORD}" ssh "$SSH_USER@$ip" " \
        ssh-keygen -q -t rsa -f ${ssh_key_file} -N '' <<< n;"

    msg "${BLUE}\\nRetrieving the key ${NOFORMAT}"
    ssh_key=`sshpass -"p${SSH_PASSWORD}" ssh "$SSH_USER@$ip" " \
        cat ${ssh_key_file}.pub;"`
    
    msg "${BLUE}Broadcasting ssh id of ${hostname} to other nodes..${NOFORMAT}"
    authorized_file="/home/${SSH_USER}/.ssh/authorized_keys"

    for ((j=0; j<${#ip_address_array[@]}; j++)); do
        other_ip="${ip_address_array[$j]}"
        other_hostname="${hostname_array[$j]}"
        msg "${YELLOW}  copy ssh key to ${other_hostname}(${other_ip}) authorized_keys ${NOFORMAT}"
        sshpass -"p${SSH_PASSWORD}" ssh "$SSH_USER@$other_ip" " \
            if [ ! -f '$authorized_file' ]; then \
                echo '$ssh_key' | sudo tee -a $authorized_file; \
            else \
                if ! grep -qF '$ssh_key' ${authorized_file}; then \
                    echo '$ssh_key' | sudo tee -a '${authorized_file}'; \
                    echo '    successfully wrote key into $other_hostname'; \
                else \
                    echo '    skipping: ssh-key already exist in ${authorized_file}'; \
                fi; \
            fi;"
    done
done


msg "${GREEN}########################## Download and Unpack Hadoop Binaries ########################### ${NOFORMAT}"


for ((i=0; i<${#ip_address_array[@]}; i++)); do
    msg "${BLUE}\\nDownload hadoop source in ${ip} ${NOFORMAT}"
    ip="${ip_address_array[$i]}"
    sshpass -"p${SSH_PASSWORD}" ssh "$SSH_USER@$ip" " \
        if [ ! -d '$hadoop_home' ]; then \
            wget https://dlcdn.apache.org/hadoop/common/${hadoop_dirname}/.tar.gz
            tar xzf ${hadoop_dirname}.tar.gz
            rm ${hadoop_dirname}.tar.gz
        else \
            echo ${hadoop_dirname} already exist
        fi;"
    
done




msg "${GREEN}########################## Set Environment Variables ########################### ${NOFORMAT}"
declare -a env_key_vals=(
  "HADOOP_HOME=${hadoop_home}"
  "HADOOP_INSTALL=\$HADOOP_HOME"
  "HADOOP_MAPRED_HOME=\$HADOOP_HOME"
  "HADOOP_COMMON_HOME=\$HADOOP_HOME"
  "HADOOP_HDFS_HOME=\$HADOOP_HOME"
  "YARN_HOME=\$HADOOP_HOME"
  "export PATH=\$PATH:\$HADOOP_HOME/sbin:\$HADOOP_HOME/bin"
)
for ((i=0; i<${#ip_address_array[@]}; i++)); do
    ip="${ip_address_array[$i]}"
    msg "${BLUE}\\nUpdate env variables in ${ip}:$bash_file ${NOFORMAT}"
    for ((j=0; j<${#env_key_vals[@]}; j++)); do
        env_key_val="${env_key_vals[$j]}"

        sshpass -"p${SSH_PASSWORD}" ssh "$SSH_USER@$ip" " \
            if [ ! -f '$bash_file' ]; then \
                echo '$env_key_val' | sudo tee -a $bash_file; \
            else \
                if ! grep -qF '$env_key_val' ${bash_file}; then \
                    echo '$env_key_val' | sudo tee -a '${bash_file}'; \
                    echo '    successfully wrote key into $bash_file'; \
                else \
                    echo '    skipping: $env_key_val already exist in ${bash_file}'; \
                fi; \
            fi;"
    done
    sshpass -"p${SSH_PASSWORD}" ssh "$SSH_USER@$ip" " \
        if ! grep -qF JAVA_HOME= ${bash_file}; then \
            echo JAVA_HOME="$(dirname $(dirname $(readlink -f /usr/bin/javac)))" | sudo tee -a '${bash_file}'; \
            echo '    successfully wrote key into $bash_file'; \
        else \
            echo '    skipping: JAVA_HOME="$(dirname $(dirname $(readlink -f /usr/bin/javac)))" already exist in ${bash_file}'; \
        fi; "
    sshpass -"p${SSH_PASSWORD}" ssh "$SSH_USER@$ip" "source '${bash_file}'"
done

msg "${GREEN}########################## Send file and script / Executes ########################### ${NOFORMAT}"

msg "${BLUE}Generate workers file ${NOFORMAT}"
rm workers
for ((i=1; i<${#hostname_array[@]}; i++)); do
    echo "${hostname_array[$i]}" >> workers
done

msg "${BLUE}Distribute files ${NOFORMAT}"
for ((i=0; i<${#ip_address_array[@]}; i++)); do
    ip="${ip_address_array[$i]}"
    msg "${BLUE}  sending configure.sh, workers to ${ip} ${NOFORMAT}"
    sshpass -"p${SSH_PASSWORD}" scp "configure.sh" "$SSH_USER@$ip:${hadoop_home}/"
    sshpass -"p${SSH_PASSWORD}" ssh "$SSH_USER@$ip" "bash ${hadoop_home}/configure.sh"
    sshpass -"p${SSH_PASSWORD}" scp "workers" "$SSH_USER@$ip:${hadoop_home}/etc/hadoop/workers"
done

msg "${GREEN}########################## Start dfs and yarn ########################### ${NOFORMAT}"

sshpass -"p${SSH_PASSWORD}" ssh "$SSH_USER@${ip_address_array[0]}" "echo y | ${hadoop_home}/bin/hdfs namenode -format && ${hadoop_home}/sbin/start-dfs.sh && ${hadoop_home}/sbin/start-yarn.sh"

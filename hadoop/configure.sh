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

SSH_USER="insilico"
SSH_PASSWORD="7890uiop"

HADOOP_VERSION="3.3.1"
hadoop_dirname=hadoop-${HADOOP_VERSION}

hadoop_home="/home/${SSH_USER}/${hadoop_dirname}"
data_dirname="/home/${SSH_USER}/data"


cd ${hadoop_home}/etc/hadoop/

datanode_dirname="${data_dirname}/datanode"
namenode_dirname="${data_dirname}/namenode"

#rm -rf $datanode_dirname
#rm -rf $namenode_dirname

mkdir -p $datanode_dirname
mkdir -p $namenode_dirname

msg "${GREEN}########################## Set NameNode Location (core-site.xml) ########################### ${NOFORMAT}"

# c\ command replaces the lines between
sed -i '/<configuration>/,/<\/configuration>/c\
<configuration> \
        <property> \
                <name>io.file.buffer.size<\/name> \
                <value>131072<\/value> \
        <\/property> \
        <property> \
                <name>fs.defaultFS<\/name> \
                <value>hdfs:\/\/'"${hostname_array[0]}"':9000<\/value> \
        <\/property> \
<\/configuration>' core-site.xml



msg "${GREEN}########################## Set path for HDFS (hdfs-site.xml) ########################### ${NOFORMAT}"

sed -i '/<configuration>/,/<\/configuration>/c\
<configuration> \
        <property> \
                <name>dfs.name.dir<\/name> \
                <value>'"${data_dirname}"'/namenode<\/value> \
        <\/property> \
        <property> \
                <name>dfs.data.dir<\/name> \
                <value>'"${data_dirname}"'/datanode<\/value> \
        <\/property> \
        <property> \
                <name>dfs.replication<\/name> \
                <value>2<\/value> \
        <\/property> \
</configuration>' hdfs-site.xml


msg "${GREEN}########################## Set YARN as Job Scheduler (mapred-site.xml) ########################### ${NOFORMAT}"

sed -i '/<configuration>/,/<\/configuration>/c\
<configuration> \
        <property> \
                <name>mapreduce.framework.name<\/name> \
                <value>yarn<\/value> \
        <\/property> \
<\/configuration>' mapred-site.xml

msg "${GREEN}########################## Configure YARN  (yarn-site.xml) ########################### ${NOFORMAT}"

sed -i '/<configuration>/,/<\/configuration>/c\
<configuration> \
    <property> \
        <name>yarn.nodemanager.aux-services<\/name> \
        <value>mapreduce_shuffle<\/value> \
    <\/property> \
</configuration>' yarn-site.xml


msg "${GREEN}########################## Set Java Home ########################### ${NOFORMAT}"

echo export JAVA_HOME="$(dirname $(dirname $(readlink -f /usr/bin/javac)))" >> hadoop-env.sh

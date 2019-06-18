#!/bin/sh
set -e

# parameters
dingtalk_token=${1:-''}
max_percent=${2:-80}
custom_host=${3:-''}
send_when_normal=${4:-false}

# check parameters
host=${custom_host:-"$HOSTNAME"}
if [ "${dingtalk_token}" = "" ]; then
    echo '[error] dingtalk token empty.'
    exit 1
fi

# disk monitor
# result=$(df -Ph | grep -v Filesystem | awk '{print $5,$6}' | awk -F "%" '{if($1>=10) {print $2,$1"%"}}')
result=$(df -Ph | grep -v Filesystem | awk '{print $5,$6}' | awk -F "%" '{if($1>=strtonum("'${max_percent}'")){print $2,$1"%"}}')
echo $result
# 挂载点 已用% / 13% /boot 17%

if [ "$result" ==  "" ]; then 
    echo '[info] normal.'
    if $send_when_normal ; then
        cont='主机 ['${host}']\n磁盘空间正常，使用率未超过'${max_percent}'%。'
        # echo $cont
        curl 'https://oapi.dingtalk.com/robot/send?access_token='${dingtalk_token} -H 'Content-Type: application/json' -d ' {"msgtype": "text", "text": {"content": "'"${cont}"'"}}'
    fi
else
    echo '[info] notify.'
    cont='主机 ['${host}']\n磁盘空间使用率超过'${max_percent}'%的目录及使用率为:\n'${result}'\n请及时释放磁盘空间。'
    # echo $cont
    curl 'https://oapi.dingtalk.com/robot/send?access_token='${dingtalk_token} -H 'Content-Type: application/json' -d ' {"msgtype": "text", "text": {"content": "'"${cont}"'"}}'
fi

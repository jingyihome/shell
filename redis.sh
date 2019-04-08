#!/bin/bash
###################################################
# File name: redis.sh                             #
# Autor zhanghaijun                               #
# Date: 2016-03-28                                #
# E-mail: zhj@zhj.cc                              #
# Website: https://www.diewufeiyang.com           #
# Github: https://github.com/jingyihome           #
###################################################
REDISPORT=$1
PASSWD='Test2018!'
HOSTS="127.0.0.1"
EXEC=/usr/local/webserver/redis/redis-server
CLIEXEC=/usr/local/webserver/redis/redis-cli
CONF="/usr/local/webserver/redis/${REDISPORT}.conf"

function exec_start_redis(){
    echo "start redis service..."
      ${EXEC} ${CONF}
}

function exec_stop_redis(){
    echo "stop redis service..."
      ${CLIEXEC} -h ${HOSTS} -p ${REDISPORT} -a ${PASSWD} shutdown
}

function exec_uptime_redis(){
    ${CLIEXEC} -h ${HOSTS} -p ${REDISPORT} -a ${PASSWD} info|grep uptime_in_days|awk -F":" '{print $NF}'
}

function exec_version_redis(){
    ${CLIEXEC} -h ${HOSTS} -p ${REDISPORT} -a ${PASSWD} info|grep redis_version|awk -F":" '{print $NF}'
}

# Start
if [[ $1 == *[!0-9]* ]]||[[ "$1" = "" ]]; then
    echo "ERROR! Redis port must a number!"
    exit 1
fi

action=$2
[ -z $2 ] && action=help
case "$action" in
help)
    echo "Usage: ./`basename $0` ${REDISPORT} {start|stop|restart}"
    ;;
start)
    exec_start_redis
    ;;
stop)
    exec_stop_redis
    ;;
restart)
    exec_stop_redis
    sleep 3;
    exec_start_redis
    ;;
uptime)
    exec_uptime_redis
    ;;
version)
    exec_version_redis
    ;;
*)
    echo "error! [${action}]"
    echo "Usage: ./`basename $0` ${REDISPORT} {start|stop|restart}"
    ;;
esac

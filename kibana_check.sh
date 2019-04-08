#!/bin/bash
###################################################
# File name: kibana_check.sh                      #
# Autor zhanghaijun                               #
# Date: 2016-03-28                                #
# E-mail: webmaster@loveyan.com                   #
# Website: https://www.diewufeiyang.com           #
# Github: https://github.com/jingyihome           #
###################################################
kdir="/home/ops/elk/kibana"
CheckURL="http://172.16.0.16:5601"
STATUS_CODE=`curl -o /dev/null -m 10 --connect-timeout 10 -s -w %{http_code} $CheckURL`
if [ "$STATUS_CODE" = "200" ]; then
    echo "OK"
else
    echo "error"
    cd $kdir/
    ./bin/kibana &
    echo "kibana service is stop，Time:`date +%Y-%m-%d-%H:%M:%S`" >> $kdir/kcheck.log
fi
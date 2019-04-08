#/bin/bash
###################################################
# File name: elasticsearch_clean.sh               #
# Autor zhanghaijun                               #
# Date: 2016-03-28                                #
# E-mail: zhj@zhj.cc                              #
# Website: https://www.diewufeiyang.com           #
# Github: https://github.com/jingyihome           #
###################################################
logfile="/home/ops/elk/elkDailyDel.log"
if test ! -f "${logfile}" ;then
    touch ${logfile}
fi
indices=$(curl -s "172.16.0.16:9200/_cat/indices?v"|grep 'logstash'|awk '{print $3}')
sixtyDaysAgo=$(date -d "$(date "+%Y%m%d") -30 days" "+%s")
function DelOrNot(){
    if [ $(($1-$2)) -ge 0 ] ;then
        echo 1
    else
        echo 0
    fi
}
for index in ${indices}
do
    indexDate=`echo ${index}|awk -F'-' '{print $NF}'|sed 's/\./-/g'`
    indexTime=`date -d "${indexDate}" "+%s"`
    if [ `DelOrNot ${indexTime} ${sixtyDaysAgo}` -eq 0 ] ;then
        delResult=`curl -s -XDELETE "172.16.0.16:9200/${index}"`
        echo "delResult is ${delResult}" >> ${logfile}
        if [ `echo ${delResult}|grep 'acknowledged'|wc -l` -eq 1 ] ;then
            echo "${index} had already been deleted!" >> ${logfile}
        else
            echo "there is something wrong happend when deleted ${index}" >> ${logfile}
        fi
    fi
done
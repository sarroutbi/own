#!/bin/bash
DEFAULT_SLEEP_TIME=3600
DEFAULT_POWER_DOWN_SLEEP_TIME=60
recheck_time=${DEFAULT_SLEEP_TIME}
recheck_on_power_down_time=${DEFAULT_POWER_DOWN_SLEEP_TIME}
log_file="/tmp/check_upsc.log"

## Parse options
while getopts "f:t:u:p:vh" OPTION
do
     case $OPTION in
         u)
             USER=$OPTARG
             ;;
         f)
             FROM=$OPTARG
             ;;
         t)
             TO=$OPTARG
             ;;
         p)
             PASSWORD=$OPTARG
             ;;
         h)
             usage_exit 0
             ;;
         v)
             set -x
             ;;
         ?)
             usage
             exit
             ;;
     esac
done


counter=0
while true;
do
    charge=$(upsc apc-700 | awk -F "battery.charge:" '{print $2}' | tr -d ' ')
    echo "CHARGE:=>${charge}<="
    echo "TO:=>${TO}<="
    if [ "${charge}" == "100" ];
    then
        if [ ${counter} -eq 0 ];
        then
            sendemail -f "${FROM}" -t "${TO}" -s smtp.gmail.com:587 -u "Informe de carga" -m "Informe de carga de UPSC:${charge}%"  -v -xu "${USER}" -xp "${PASSWORD}" -o tls=yes -v 2>&1 | tee "${log_file}"
            ((counter++))
        else
            if [ ${counter} -ge ${recheck_time} ];
            then
                counter=0
            else
                ((counter++))
            fi
            sleep 1
        fi
    else
        sendemail -f "${FROM}" -t "${TO}" -s smtp.gmail.com:587 -u "Informe de carga" -m "Warning, informe de carga de UPSC:${charge}%, posible corte de luz" -v -xu "${USER}" -xp "${PASSWORD}" -o tls=yes -v 2>&1 | tee "${log_file}"
        sleep "${recheck_on_power_down_time}"
    fi
done

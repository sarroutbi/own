#!/bin/bash
#
# Copyright (c) 2025, Sergio Arroutbi Braojos <sarroutb (at) redhat.com>
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
#
# Script that allows to check if mldonkey is running and to 
# poll to connect to desired servers.
# 
# CONFIGURABLE VARIABLES:
#
PATH=${PATH}:/usr/bin:/bin:/usr/sbin
MY_TIMER="900"
WAIT_FOR_MLNET_RUN="5"
PORT="4000"
HOST="localhost"
MLDNET="/usr/local/bin/mlnet &"
# DESIRED_SERVERS="Razorback DonkeyServer"
THIS_HOME="/home/user"
THIS_PATH="${THIS_HOME}/bin/mldonkey/"
LOGIN="admin"
PASSWORD="YOUR_PASSWORD_HERE"

## NOT CONFIGURABLE VARIABLES
#
# No need to configure this variable, will be filled automatically
DESIRED_SERVERS_ID=

## FUNCTIONS
#
# This function fills var DESIRED_SERVERS_ID with ids of 
# the parameter passed, whti must be the desired server  
function fill_des_id_my_mldonkey
{
	sleep 5
	for i in $(${THIS_PATH}/snd_ml_auth.exp vma | grep "$1" | awk '{print $2}' | tr -d "]");
        do
		DESIRED_SERVERS_ID=$DESIRED_SERVERS_ID" "$i
	done
}

# This function fills var DESIRED_SERVERS_ID with ids of 
# the parameter passed, whti must be the desired server  
function kill_mld_console_my_mldonkey
{
	MLD_CONSOLE_RUNNING=1
        while [ ${MLD_CONSOLE_RUNNING} -eq 1 ];
        do
		if ps a | awk '{print $5" "$6" "$7}' | grep "telnet ${HOST} ${PORT}" >> /dev/null;
		then
			PIDS=$(pgrep "telnet ${HOST} ${PORT}" | awk '{print $1}')
			kill -9 "${PIDS}" >> /dev/null
		else
			MLD_CONSOLE_RUNNING="0"
		fi
	done 
}

function main_my_mldonkey
{
	# 0 - Init
	DESIRED_SERVERS_ID=""
	cd ${THIS_PATH} || exit
        export PATH
 
	# 1 - Check if mld running
	if ! ${THIS_PATH}/snd_ml_auth.exp vd;
	then 
		echo "mldonkey not running, trying to run it ..."
		${MLDNET} &
		sleep ${WAIT_FOR_MLNET_RUN}
		${THIS_PATH}/snd_ml_auth.exp useradd ${LOGIN} ${PASSWORD} 
	else
		echo "mldonkey running correctly ..."
	fi
	
	# 2 - Kill opened consoles and auth
	kill_mld_console_my_mldonkey
	
	# 3 - Connect to desired servers 
	#for i in ${DESIRED_SERVERS}; 
	#do 
	#	fill_des_id_my_mldonkey $i
	#done
	#echo "=>$DESIRED_SERVERS_ID<="
	#${THIS_PATH}/snd_ml_auth.exp c ${DESIRED_SERVERS_ID}
	
	# 4 - Check servers 
	${THIS_PATH}./snd_ml_auth.exp vm

	# 5 - Check downloads 
	${THIS_PATH}/snd_ml_auth.exp vd
}

######### PROGRAM ########
# - Perform main program
#   repeating each MY_TIMER scs.
while true ;
do
	main_my_mldonkey;
	sleep ${MY_TIMER}
done
######## /PROGRAM ########


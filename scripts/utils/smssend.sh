#!/bin/sh
# sendsms
#
# Author: San Bergmans
# Parsing of parameters: Sergio Arroutbi
# www.sbprojects.com / www.oeioei.nl
#
# Sends an SMS to a phone number through Voipbuster.
# Obviously you'll need a Voipbuster account for this to wrok.
# use: sendsms +31612345678 Message to be sent
# Messages longer than 160 are refused by the service. The return message
# will be failure.
#
# Sending to more than one phone number is not reliable, you'll get a
# success response, you pay for the sent SMSes, but nothing is sent.
# Therefore stick to one phone number at a time.
#
# If you want a Fonera to send an SMS add the option --no-check-certificate
# to the wget command. The fonera doesn't kill the leading tab in the
# result string.

USER=""
PASS=""
FROM=""
SMS_TEXT=""
TO=""
VERBOSE=""

usage ()
{
    echo 
    echo "Usage:   $0 -u username -p password [-f from_number] -t phone_number -m \"sms text\" [-v] "
    echo "Example: $0 -u user -p passwd [-f +31612345678] -t +31987654321 -m \"This text is sent\" [-v] "
    echo 
}

usage_exit ()
{
    usage 
    exit "$1"
} 

while getopts "u:p:f:t:m:vh" OPTION
do
     case $OPTION in
         u)
             USER=$OPTARG
             ;;
         p)
             PASS=$OPTARG 
             ;;
         f)
             FROM=$OPTARG 
             ;;
         t)
             TO=$OPTARG
             ;;
         m)
             SMS_TEXT=$OPTARG
             ;;
         h)
             usage_exit 0
             ;;
         v)
             VERBOSE=y
             ;;
         ?)
             usage
             exit
             ;;
     esac
done 

if [ -z "$USER" ]; then usage_exit 1; fi
if [ -z "$PASS"  ]; then usage_exit 2; fi
#if [ -z "$FROM" ]; then usage_exit 3; fi
if [ -z "$TO" ]; then usage_exit 4; fi
if [ -z "$SMS_TEXT" ]; then usage_exit 5; fi

# Form the URL, including constants and parameters
#URL="https://www.voipbuster.com/myaccount/sendsms.php?username=$USER&password=$PASS&from=$FROM&to=\"$TO\"&text=$SMS_TEXT"
URL="https://www.voipbuster.com/myaccount/sendsms.php?username=$USER&password=$PASS&from=$FROM&to=$TO&text=$SMS_TEXT"

if [ -n "${VERBOSE}" ]; then
  echo "USER=$USER"
  echo "PASS=$PASS"
  echo "FROM=$FROM"
  echo "TO=$TO"
  echo "TEXT=$SMS_TEXT"
  echo "URL=$URL"
fi

# Send SMS and print the result string from the XML file returned by voipbuster
#wget "$URL" -O - 2> /dev/null 1> /dev/null
#wget -q "$URL" -O - | grep resultstring | sed -e 's,<resultstring>,,' -e 's,</resultstring>,,' -e 's," ",a,' -e 's,\t,,'
wget --no-check-certificate "$URL" -O - 

# Example result file from voipbuster
# Indented lines are preseded by a tab
# <?phpxml version "1.0" encoding="utf-8"?>> 
# <SmsResponse>
# 	<version>1</version>
#	<result>1</result>
#	<resultstring>success</resultstring>
#	<description></description>
#	<endcause></endcause>
# </SmsResponse>

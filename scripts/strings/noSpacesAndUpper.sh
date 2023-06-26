#!/bin/bash

TO_UPPER_PATH=/home/sarroutbi/bin/strings
export PATH=$PATH:$TO_UPPER_PATH

function noSpaces_usage()
{
  echo ""
  echo "noSpaces.sh usage:"
  echo ""
  echo "noSpaces.sh \"string\""
  echo ""
}

if [ $# -ne 1 ];
then
  noSpaces_usage
  exit 1 
fi

iteration=0

for i in $1; 
do 
  init=$(echo "$i" | cut -c1)
  Init=$(toUpper.sh "$init")
  Rest=$(echo "$i" | cut -c2-)
  if [ $iteration -eq 0 ];
  then
    echo -n "$i"
  else
    echo -n "${Init}${Rest}"
  fi
  ((iteration++))
done


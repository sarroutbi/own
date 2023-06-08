#!/bin/bash
#
# Moves files by:
# Setting all to lower case
# Quitting spaces and adding Capital Letter to Word after spaces
#

find . -iname "*" | while read -r entrada;
do
  salida_tmp=$(/home/sarroutb/RedHat/TASKS/OWN/own/scripts/strings/toLower.sh "$entrada")
  salida=$(/home/sarroutb/RedHat/TASKS/OWN/own/scripts/strings/noSpacesAndUpper.sh "$salida_tmp")
  if [ "$salida" != "$entrada" ];
  then
    mv "$entrada" "$salida";
  fi
done

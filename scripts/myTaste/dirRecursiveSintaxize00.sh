#!/bin/bash
#
# Recursive sintaxize all dirs from current one 
#

SINTAXIZE_PATH=/home/sarroutbi/bin/myTaste
SINTAXIZE_SCRIPT=dirSintaxize00.sh
SINTAXIZE_SCRIPT_RECURSIVE=dirRecursiveSintaxize00.sh

${SINTAXIZE_PATH}/${SINTAXIZE_SCRIPT}

for i in *;
do
  if test -d "$i";
  then
    echo "Detected dir [$i]:"
    cd $i
      ${SINTAXIZE_PATH}/${SINTAXIZE_SCRIPT_RECURSIVE} 
    cd - 
  fi
done

#!/bin/bash

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

echo "$1" | tr -d " "

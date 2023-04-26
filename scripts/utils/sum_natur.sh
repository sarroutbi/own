#!/bin/bash
#
test -z "${1}" && echo "Especifica el numero hasta el que sumar" && exit 1
echo "${1}" | grep -E "[0-9]{1,}" 2>/dev/null 1>/dev/null || {
  echo "Especifica un numero entero"
  exit 2
}

big_number=$1
num=1
sum=0

while [ $num -le "${big_number}" ];
do
  ((sum=num+sum))
  ((num=num+1))
done

echo "La suma es:${sum}"


#!/bin/bash
#
# Copyright (c) 2025, Sergio Arroutbi Braojos <sarroutbi (at) yahoo.es>
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
CHECK_LOOP=15
LINK='http://www.madrid.org/cs/Satellite?pagename=ComunidadMadrid/Comunes/Presentacion/popupGestionTelematica&language=es&c=CM_ConvocaPrestac_FA&cid=1354178312070&nombreVb=listas&other=1'
PRIMARY_LINK='http://www.madrid.org/cs/Satellite?pagename=ComunidadMadrid/Comunes/Presentacion/popupGestionTelematica&language=es&c=CM_ConvocaPrestac_FA&cid=1142674785607&nombreVb=listas'
GLOBAL_LINK="http://www.madrid.org"
TMP_LAST_INTERIM_CALLED=/tmp/ultimos_interinos_citados.pdf
TMP_NEXT_INTERIM_CALLED=/tmp/siguientes_interinos_citados.pdf
TMP_LAST_VOLUNTEER_CALLED=/tmp/ultimos_voluntarios_citados.pdf
TMP_NEXT_VOLUNTEER_CALLED=/tmp/siguientes_voluntarios_citados.pdf
TMP_INC_CALLED=/tmp/incorporados_lista.pdf
TMP_PRI_LAST_INTERIM_CALLED=/tmp/primaria_ultimos_interinos_citados.pdf
TMP_PRI_NEXT_INTERIM_CALLED=/tmp/primaria_siguientes_interinos_citados.pdf
TMP_PRI_LAST_VOLUNTEER_CALLED=/tmp/primaria_ultimos_voluntarios_citados.pdf
TMP_PRI_NEXT_VOLUNTEER_CALLED=/tmp/primaria_siguientes_voluntarios_citados.pdf
TMP_PRI_INC_CALLED=/tmp/primaria_incorporados_lista.pdf

# Function to retrieve the file to download. Parameters:
# 1 - The link from where download will be performed
# 2 - The global link
# 3 - Type of list (i.e.:interinos, voluntarios)
# 4 - File to write
function get_file()
{
  PARTIAL_LINK=$(wget "${1}" -O - -o/dev/null | grep "${3}" -A2 | awk -F 'a href=' {'print $2'}  | awk {'print $1'} | grep '[a-z]' | tr -d "'")
  TOTAL_LINK="${2}/${PARTIAL_LINK}"
  echo "wget ${TOTAL_LINK} -O \"${2}\""
  wget ${TOTAL_LINK} -O "${4}"
}

function get_list_date()
{
  wget ${LINK} -o/dev/null -O - | grep "interinos\|voluntarios" | grep -E '\([0-9]{0,2}/[0-9]{0,2}/[0-9]{1,4}\)' -o | sort | uniq | tail -1
}

function get_pri_list_date()
{
  wget ${PRIMARY_LINK} -o/dev/null -O - | grep "interinos\|voluntarios" | grep -E '\([0-9]{0,2}/[0-9]{0,2}/[0-9]{1,4}\)' -o | sort | uniq | tail -1
}

# Returns:
# 0: Valid Date
# 1: Invalid Date
function is_valid_date()
{
  echo $1 | egrep -E "[0-9]{1,2}/[0-9]{2}/[0-9]{4}" > /dev/null
  echo $?
}

function retrieve_files()
{
  echo "Retrieving files ..."
  get_file "${LINK}" "${GLOBAL_LINK}" "Citaciones para cubrir puestos ordinarios" ${TMP_LAST_INTERIM_CALLED}
  get_file "${LINK}" "${GLOBAL_LINK}" "Próximos interinos" ${TMP_NEXT_INTERIM_CALLED}
  get_file "${LINK}" "${GLOBAL_LINK}" "Citaciones para puestos voluntarios" ${TMP_LAST_VOLUNTEER_CALLED}
  get_file "${LINK}" "${GLOBAL_LINK}" "interinos que fueron citados para cubrir puestos voluntarios" ${TMP_NEXT_VOLUNTEER_CALLED}
}

function retrieve_pri_files()
{
  echo "Retrieving files ..."
  get_file "${PRIMARY_LINK}" "${GLOBAL_LINK}" "Citaciones para cubrir puestos ordinarios" ${TMP_PRI_LAST_INTERIM_CALLED}
  get_file "${PRIMARY_LINK}" "${GLOBAL_LINK}" "Próximos interinos" ${TMP_PRI_NEXT_INTERIM_CALLED}
  get_file "${PRIMARY_LINK}" "${GLOBAL_LINK}" "Citaciones para puestos voluntarios" ${TMP_PRI_LAST_VOLUNTEER_CALLED}
  get_file "${PRIMARY_LINK}" "${GLOBAL_LINK}" "interinos que fueron citados para cubir puestos voluntarios" ${TMP_PRI_NEXT_VOLUNTEER_CALLED}
}

LAST_DATE=$(get_list_date)
LAST_PRI_DATE=$(get_pri_list_date)

while true;
do
  NOW_DATE=$(get_list_date)
  NOW_INVALID_DATE=$(is_valid_date ${NOW_DATE})
  LAST_INVALID_DATE=$(is_valid_date ${LAST_DATE})

  NOW_PRI_DATE=$(get_pri_list_date)
  NOW_PRI_INVALID_DATE=$(is_valid_date ${NOW_PRI_DATE})
  LAST_PRI_INVALID_DATE=$(is_valid_date ${LAST_PRI_DATE})

  echo "NOW_DATE=${NOW_DATE}"
  echo "LAST_DATE=${LAST_DATE}"
  echo "NOW_INVALID_DATE=${NOW_INVALID_DATE}"
  echo "LAST_INVALID_DATE=${LAST_INVALID_DATE}"
  echo "NOW_PRI_DATE=${NOW_PRI_DATE}"
  echo "LAST_PRI_DATE=${LAST_PRI_DATE}"
  echo "NOW_PRI_INVALID_DATE=${NOW_PRI_INVALID_DATE}"
  echo "LAST_PRI_INVALID_DATE=${LAST_PRI_INVALID_DATE}"

  echo

  if [ "${NOW_DATE}" != "${LAST_DATE}" ] && [ ${NOW_INVALID_DATE} -eq 0 ] && [ ${LAST_INVALID_DATE} -eq 0 ];
  then
    retrieve_files
    /usr/local/src/sendEmail/sendEmail -f from@mail.com -t to@mail.com -u "Actualizacion de listas de interinos de secundaria" -u "Actualizacion de listas de interinos de secundaria" -m "Se ha detectado una actualizacion en la lista de interinos de secundaria. Fecha antigua:${LAST_DATE}, Fecha nueva:${NOW_DATE}.\nConsulte el enlace:\n${LINK}" -v -xu user -xp password -a "${TMP_LAST_INTERIM_CALLED}" -a "${TMP_NEXT_INTERIM_CALLED}" -a "${TMP_LAST_VOLUNTEER_CALLED}" -a "${TMP_NEXT_VOLUNTEER_CALLED}"
    LAST_DATE=${NOW_DATE}
  fi
  if [ "${NOW_PRI_DATE}" != "${LAST_PRI_DATE}" ] && [ ${NOW_PRI_INVALID_DATE} -eq 0 ] && [ ${LAST_PRI_INVALID_DATE} -eq 0 ];
  then
    retrieve_pri_files
    /usr/local/src/sendEmail/sendEmail -f from@mail.com -t to@mail.com -u "Actualizacion de listas de interinos de primaria" -u "Actualizacion de listas de interinos de primaria" -m "Se ha detectado una actualizacion en la lista de interinos de primaria. Fecha antigua:${LAST_PRI_DATE}, Fecha nueva:${NOW_PRI_DATE}.\nConsulte el enlace:\n${PRIMARY_LINK}" -v -xu user -xp password -a "${TMP_PRI_LAST_INTERIM_CALLED}" -a "${TMP_PRI_NEXT_INTERIM_CALLED}" -a "${TMP_PRI_LAST_VOLUNTEER_CALLED}" -a "${TMP_PRI_NEXT_VOLUNTEER_CALLED}"
    LAST_PRI_DATE=${NOW_PRI_DATE}
  fi
  sleep ${CHECK_LOOP}
done

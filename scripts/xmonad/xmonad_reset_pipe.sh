#!/bin/bash
#
MODE_LOOP=0
if [ "$1" = "1" ];
then
  MODE_LOOP=1
fi
xmonad_pid=$(pidof xmonad-x86_64-linux)
xmobar_pid=$(pidof xmobar)
echo "XMONAD PID:${xmonad_pid}"
echo "XMOBAR PID:${xmobar_pid}"

while true;
do
  xmonad_max_pipe=$(find . -iname "/proc/${xmonad_pid}/fd/*" | sort -n | tail -1)
  xmobar_max_pipe=$(find . -iname "/proc/${xmobar_pid}/fd/*" | sort -n | tail -1)
  echo "XMONAD MAX PIPE:${xmonad_max_pipe}"
  echo "XMOBAR MAX PIPE:${xmobar_max_pipe}"
  for xmonad_fd in $(seq 0 "${xmonad_max_pipe}");
  do
    cat /proc/"${xmonad_pid}"/fd/"${xmonad_fd}" &
  done
  for xmobar_fd in $(seq 0 "${xmobar_max_pipe}");
  do
    cat /proc/"${xmobar_pid}"/fd/"${xmobar_fd}" &
  done
  pid_cat=$(pidof cat)
  sleep 1
  test -z "${pid_cat}" && kill -9 "${pid_cat}" 2>/dev/null 1>/dev/null
  if [ ${MODE_LOOP} -eq 0 ];
  then
    break;
  fi
  sleep 5
  killall -9 cat
  pkill -CONT xmonad-x86_64-linux
  pkill -CONT xmobar
done

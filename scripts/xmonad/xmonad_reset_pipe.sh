#!/bin/bash
#
# Copyright (c) 2025, Sergio Arroutbi Braojos <sarroutbi (at) redhat.com>
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

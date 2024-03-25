#!/bin/bash
#
# Copyright (c) 2023, Sergio Arroutbi Braojos <sarroutbi (at) redhat.com>
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
LINES=""

usage ()
{
    echo
    echo "Usage:   $0 -l lines / -c commit_id [-h]"
    echo "Example: $0 -l 30 (will show latest 30 commits)"
    echo "Example: $0 -c 90633e1 (will show commits from 90633e1 to the end)"
    echo
}

usage_exit ()
{
    usage
    exit "$1"
}

dump_lines()
{
    git log --oneline | head -"${1}" | while read -r line;
    do
        commit_id=$(echo "${line}" | awk '{print $1}')
        message=${line//${commit_id} /}
        echo "* ${message} (${commit_id})"
    done
}


while getopts "l:c:h" OPTION
do
    case $OPTION in
         c)
             INITIAL_COMMIT_ID=$OPTARG
             ;;
         l)
             LINES=$OPTARG
             ;;
         h)
             usage_exit 0
             ;;
         *)
             usage_exit 1
             ;;
     esac
done


if [ -z "${LINES}" ] && [ -z "${INITIAL_COMMIT_ID}" ];
then
    usage_exit 1;
fi

if [ -n "${LINES}" ] && [ -n "${INITIAL_COMMIT_ID}" ];
then
    echo
    echo "Can not specify both lines and commit id"
    usage_exit 1;
fi

if [ -n "${LINES}" ]; then
    lines="${LINES}"
elif [ -n "${INITIAL_COMMIT_ID}" ]; then
    head_commit=$(git log | grep ^commit | head -n1 | awk '{print $2}')
    lines=$(git log  | grep commit | sed -n "/${head_commit}/,/${INITIAL_COMMIT_ID}/p" | wc -l)
fi

dump_lines "${lines}"

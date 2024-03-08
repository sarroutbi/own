#!/bin/bash
#
# Copyright (c) 2024, Sergio Arroutbi Braojos <sarroutbi (at) redhat.com>
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
SENTENCES_FILE=sentences.txt
AUTHOR=sarroutbi

function usage() {
  echo "$1 [-s sentence-file] [-a author]"
  return "$2"
}

while getopts "s:h" arg
do
  case "${arg}" in
    s) SENTENCES_FILE=${OPTARG}
       ;;
    h) usage "$0" 0
       ;;
    *) usage "$0" 1
       ;;
  esac
done

echo "---"
echo "created_by: ${AUTHOR}"
echo "seed_examples:"
cat "${SENTENCES_FILE}" | while read sentence;
do
    question="Convert this text into its Snake case form: $(echo -n "${sentence}")"
    answer=$(echo ${sentence} | sed -e 's/\(.*\)/\L\1/' | sed -e 's@ @_@g')
    echo "  - answer: ${answer}"
    printf "    question:\n      \"${question}\"\n"
done
echo "task_description: This skill provides the ability to convert text into its Snake case form."

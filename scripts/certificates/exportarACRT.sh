#!/bin/bash
#
# Copyright (c) 2025, Sergio Arroutbi Braojos <sarroutb (at) redhat.com>
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
# This script takes certificate as dumped by FNMT to .p12,
# so that it can be used in Firefox/Chrome
openssl pkcs12 -legacy -in "${1}" -clcerts -nokeys -out certificado.crt
openssl pkcs12 -legacy -in "${1}" -nocerts -out cifrado.key
openssl rsa -in cifrado.key -out privado.key
openssl pkcs12 -export -in certificado.crt -inkey privado.key -out certificado.p12

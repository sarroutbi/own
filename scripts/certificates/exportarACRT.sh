#!/bin/bash
# This script takes certificate as dumped by FNMT to .p12,
# so that it can be used in Firefox/Chrome
openssl pkcs12 -legacy -in "${1}" -clcerts -nokeys -out certificado.crt
openssl pkcs12 -legacy -in "${1}" -nocerts -out cifrado.key
openssl rsa -in cifrado.key -out privado.key
openssl pkcs12 -export -in certificado.crt -inkey privado.key -out certificado.p12

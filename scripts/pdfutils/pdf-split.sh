#!/bin/bash
FILES=""
for page in $(seq 1 10); do
    FILES="${FILES} BUR2022_RA_FR_BAT_MEL_200dpi-${page}.pdf" 
done
pdfunite ${FILES} BUR2022_RA_FR_BAT_MEL_200dpi-complete.pdf

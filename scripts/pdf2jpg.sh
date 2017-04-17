#!/bin/bash

set -ue
set -x

trap 'echo "$0(${LINENO}) ${BASH_COMMAND}"' ERR

[ 1 -eq $# ]


SRC_DIR=$1
DST_DIR=output



mkdir -p ${DST_DIR}

SRC_PATHs=$(find ${SRC_DIR} -type f -name "*.pdf")
for i in ${SRC_PATHs} ; do
	SRC_PATH=$i
	FILENAME=$(basename ${SRC_PATH})
	convert -density 300 ${SRC_PATH} ${DST_DIR}/${FILENAME}.jpg
done


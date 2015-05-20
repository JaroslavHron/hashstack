#!/bin/bash

: ${CONFIG:=r0d0_fenics}
# This program takes FEniCS profile (specified in $CONFIG) and converts it to
# latest dev version FEniCS stack

TEMPLATE_FILE=${CONFIG}.yaml
TMP_FILE=${CONFIG}-tmp.yaml
TMP1_FILE=${CONFIG}-tmp1.yaml

cp $TEMPLATE_FILE $TMP_FILE

PACKAGES="dolfin ffc fiat instant mshr ufl uflacs"
for PACKAGE in $PACKAGES; do
    CHANGESET=$(git ls-remote https://bitbucket.org/fenics-project/$PACKAGE.git master | awk '{ print $1 }')
    : ${DOLFIN_CHANGESET:=$CHANGESET}
    echo "Updating $PACKAGE to changeset $CHANGESET."
    sed "/$PACKAGE:/a\\
\\    sources:\\
\\      - key: git:$CHANGESET\\
\\        url: https://bitbucket.org/fenics-project/$PACKAGE.git\\
" $TMP_FILE > $TMP1_FILE
    mv $TMP1_FILE $TMP_FILE
    done

rm -f $TMP1_FILE

OUTPUT_FILE=${CONFIG}-${DOLFIN_CHANGESET}.yaml
if [ -f $OUTPUT_FILE ];
then
    echo "File $OUTPUT_FILE already exists. Not overwriting"
    echo "and keeping result in $TMP_FILE"
else
    mv $TMP_FILE $OUTPUT_FILE
    echo "New config stored in $OUTPUT_FILE"
fi

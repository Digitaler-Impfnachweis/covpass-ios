#!/bin/bash

git clone git@github.com:eu-digital-green-certificates/dcc-quality-assurance.git

FOLDER="Source/CovPassCommon/Tests/CovPassCommonTests/Resources/dcc-quality-assurance"

rm -rf $FOLDER
mkdir $FOLDER

for f in $(find dcc-quality-assurance -name '*.png'); do
    cp $f "$FOLDER/${f//\//_}"
done

rm -rf dcc-quality-assurance

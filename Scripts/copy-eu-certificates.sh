#!/bin/bash

FOLDER="Source/CovPassCommon/Tests/CovPassCommonTests/Resources/dcc-quality-assurance"
rm -rf $FOLDER
mkdir $FOLDER

for f in $(find dcc-quality-assurance -name '*.png'); do
    cp $f "$FOLDER/${f//\//_}"
done

rm -rf dcc-quality-assurance

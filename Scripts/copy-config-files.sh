#!/bin/sh

CONFIG="DEMO"

if [ $1 == "release" ]
then
   CONFIG="PROD"
fi

if [ $1 == "release-rki" ]
then
   CONFIG="PROD_RKI"
fi

echo "Copy configuration for ${CONFIG}"

cp -r "Certificates/${CONFIG}/TLS/" "Source/CovPassCommon/Sources/CovPassCommon/Resources/TLS/"
cp -r "Certificates/${CONFIG}/CA/" "Source/CovPassCommon/Sources/CovPassCommon/Resources/CA/"
cp -r "Certificates/${CONFIG}/DCC/" "Source/CovPassCommon/Sources/CovPassCommon/Resources/DCC/"

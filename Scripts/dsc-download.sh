#!/bin/bash

curl https://de.test.dscg.ubirch.com/trustList/DSC/ -o Certificates/DEMO/CA/dsc.json
echo "$(tail -n +2 Certificates/DEMO/CA/dsc.json)" > Certificates/DEMO/CA/dsc.json

curl https://de.test.dscg.ubirch.com/trustList/DSC/ -o Certificates/PROD/CA/dsc.json
echo "$(tail -n +2 Certificates/PROD/CA/dsc.json)" > Certificates/PROD/CA/dsc.json

curl https://de.dscg.ubirch.com/trustList/DSC/ -o Certificates/PROD_RKI/CA/dsc.json
echo "$(tail -n +2 Certificates/PROD_RKI/CA/dsc.json)" > Certificates/PROD_RKI/CA/dsc.json

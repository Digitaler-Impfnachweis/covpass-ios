#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# fetch privacy policies
for locale in "de" "en"; do

  SORCE_URL=${COPP_SOURCE_URL/\$L/${locale}}
  DESTINATION=`realpath "${SCRIPT_DIR}/../Source/CovPassApp/Source/Resources/Static/privacy-covpass-${locale}.html"`

  curl \
    --header "Authorization: token ${COPP_GITHUB_ACCESS_TOKEN}" \
    --header "Accept: application/vnd.github.v3.raw" \
    --fail \
    --location "${SORCE_URL}" > ${DESTINATION}

  # Check if new file is present and not empty
  if [ ! -s ${DESTINATION} ]; then
    echo "No policy file present or empty. Aborting!"
    exit 1
  fi
done

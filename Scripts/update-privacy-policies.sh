#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# don't bother with `realpath` being installed or not…
realpath() {
    [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}

# fetch privacy policies
for app in "covpass" "covpasscheck"; do
  for locale in "de" "en"; do

    # "https://${host}/repos/${repo_user}/${repo}/contents/privacy-\$A-\$L.html"
    SOURCE_URL=${COPP_SOURCE_URL/\$A/${app}}
    SOURCE_URL=${SOURCE_URL/\$L/${locale}}

    if [ "${app}" = "covpass" ]; then
      APP_DIR="CovPassApp"
    else
      APP_DIR="CovPassCheckApp"
    fi
    DESTINATION=`realpath "${SCRIPT_DIR}/../Source/${APP_DIR}/Source/Resources/Static/privacy-${app}-${locale}.html"`

    echo "${SOURCE_URL} --> ${DESTINATION}"

    curl \
      --header "Authorization: token ${COPP_GITHUB_ACCESS_TOKEN}" \
      --header "Accept: application/vnd.github.v3.raw" \
      --fail \
      --location "${SOURCE_URL}" > ${DESTINATION}

    # Check if new file is present and not empty
    if [ ! -s ${DESTINATION} ]; then
      echo "No policy file present or empty. Aborting!"
      exit 1
    fi
  done
done

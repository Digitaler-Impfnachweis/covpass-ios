#!/bin/sh

# Colors
Color_Off='\033[0m'       # Text Reset
BIRed='\033[1;91m'        # Red
BIGreen='\033[1;92m'      # Green

# Path
path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )

#Urls
twineRepoUrl="git@github.com:Digitaler-Impfnachweis/covpass-apps-i18n.git"
echo -e "${BIGreen}▄▄▄█████▓ █     █░ ██▓ ███▄    █ ▓█████                                       ${Color_Off}";
echo -e "${BIGreen}▓  ██▒ ▓▒▓█░ █ ░█░▓██▒ ██ ▀█   █ ▓█   ▀                                       ${Color_Off}";
echo -e "${BIGreen}▒ ▓██░ ▒░▒█░ █ ░█ ▒██▒▓██  ▀█ ██▒▒███                                         ${Color_Off}";
echo -e "${BIGreen}░ ▓██▓ ░ ░█░ █ ░█ ░██░▓██▒  ▐▌██▒▒▓█  ▄                                       ${Color_Off}";
echo -e "${BIGreen}  ▒██▒ ░ ░░██▒██▓ ░██░▒██░   ▓██░░▒████▒                                      ${Color_Off}";
echo -e "${BIGreen}  ▒ ░░   ░ ▓░▒ ▒  ░▓  ░ ▒░   ▒ ▒ ░░ ▒░ ░                                      ${Color_Off}";
echo -e "${BIGreen}    ░      ▒ ░ ░   ▒ ░░ ░░   ░ ▒░ ░ ░  ░                                      ${Color_Off}";
echo -e "${BIGreen}  ░        ░   ░   ▒ ░   ░   ░ ░    ░                                         ${Color_Off}";
echo -e "${BIGreen}             ░     ░           ░    ░  ░                                      ${Color_Off}";
echo -e "${BIGreen}                                                                              ${Color_Off}";
echo -e "${BIGreen}  ▄████ ▓█████  ███▄    █ ▓█████  ██▀███   ▄▄▄     ▄▄▄█████▓ ▒█████   ██▀███  ${Color_Off}";
echo -e "${BIGreen} ██▒ ▀█▒▓█   ▀  ██ ▀█   █ ▓█   ▀ ▓██ ▒ ██▒▒████▄   ▓  ██▒ ▓▒▒██▒  ██▒▓██ ▒ ██▒${Color_Off}";
echo -e "${BIGreen}▒██░▄▄▄░▒███   ▓██  ▀█ ██▒▒███   ▓██ ░▄█ ▒▒██  ▀█▄ ▒ ▓██░ ▒░▒██░  ██▒▓██ ░▄█ ▒${Color_Off}";
echo -e "${BIGreen}░▓█  ██▓▒▓█  ▄ ▓██▒  ▐▌██▒▒▓█  ▄ ▒██▀▀█▄  ░██▄▄▄▄██░ ▓██▓ ░ ▒██   ██░▒██▀▀█▄  ${Color_Off}";
echo -e "${BIGreen}░▒▓███▀▒░▒████▒▒██░   ▓██░░▒████▒░██▓ ▒██▒ ▓█   ▓██▒ ▒██▒ ░ ░ ████▓▒░░██▓ ▒██▒${Color_Off}";
echo -e "${BIGreen} ░▒   ▒ ░░ ▒░ ░░ ▒░   ▒ ▒ ░░ ▒░ ░░ ▒▓ ░▒▓░ ▒▒   ▓▒█░ ▒ ░░   ░ ▒░▒░▒░ ░ ▒▓ ░▒▓░${Color_Off}";
echo -e "${BIGreen}  ░   ░  ░ ░  ░░ ░░   ░ ▒░ ░ ░  ░  ░▒ ░ ▒░  ▒   ▒▒ ░   ░      ░ ▒ ▒░   ░▒ ░ ▒░${Color_Off}";
echo -e "${BIGreen}░ ░   ░    ░      ░   ░ ░    ░     ░░   ░   ░   ▒    ░      ░ ░ ░ ▒    ░░   ░ ${Color_Off}";
echo -e "${BIGreen}      ░    ░  ░         ░    ░  ░   ░           ░  ░            ░ ░     ░     ${Color_Off}";
echo -e "${BIGreen}                                                                              ${Color_Off}";

echo -e '\n'


sleep 1.5

#Check Twine is installed
twine_installed=$(gem list twine -i)
if [[ $twine_installed == false ]]; then
echo -ne "🚨 Twine ${BIRed} not installed${Color_Off} 🚨"
echo -ne '\n'
echo -ne "🚧 Twine install starting"
echo -ne '\n'
sleep 1
sudo gem install twine
echo -ne "✅ ${BIGreen}Twine installed${Color_Off}\r"
else
echo -ne "✅ ${BIGreen}Twine installed${Color_Off}\r"
fi
echo -ne '\n\n'
echo -ne "Downloading Twine text file: [${BIRed}#                             ${Color_Off}]"\\r
# Download Twine Text File to twine.txt
git clone ${twineRepoUrl}
sleep 0.5

echo -ne "Downloading Twine text file: [${BIRed}##############                ${Color_Off}]"\\r
sleep 0.5
echo -ne "Downloading Twine text file: [${BIRed}##############################${Color_Off}]"\\r
sleep 0.5

echo -ne "Generating strings file:     [${BIRed}#                             ${Color_Off}]"\\r
# Twining
twine generate-localization-file ./text-vaccination/twine_container_engine.txt $path/VaccinationUI/Sources/VaccinationUI/Resources/Locale/en.lproj/Localizable.strings --format apple
twine generate-localization-file ./text-vaccination/twine_container_engine.txt $path/VaccinationUI/Sources/VaccinationUI/Resources/Locale/de.lproj/Localizable.strings --format apple
sleep 0.5

echo -ne "Generating strings file:     [${BIRed}##############                ${Color_Off}]"\\r
sleep 0.5
echo -ne "Generating strings file:     [${BIRed}##############################${Color_Off}]"\\r
sleep 0.5

echo -ne '\n\n'

yes | rm -r $path/text-vaccination

echo -ne "✅ 🎉 ${BIGreen}Everything done!${Color_Off}"
afplay /System/Library/Sounds/Blow.aiff 
echo -ne '\n\n'

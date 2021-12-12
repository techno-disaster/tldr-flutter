#!/bin/bash
cd static
# json format for all commands with name, languages and platform
curl -s 'https://tldr.sh/assets/' |  jq '[.commands[] | {command: .name, languages: .language, platform: .platform[]}]' > commands2.json
# add a list of all supported languages to commands2.json
curl -s 'https://tldr.sh/assets/' |  jq '[{supportedLanguages: [.commands[] | .language | .[]] | unique}]' > temp.json && jq --slurp add commands2.json temp.json | sponge commands2.json && rm temp.json
git clone https://github.com/tldr-pages/tldr
for i in tldr/*pages*; do FILENAME=$(echo $i | cut -c 6-) && echo $FILENAME && zip -r "pages_zips/${FILENAME%/}.zip" "$i"; done
# incase someone is still on the old version he should still get pages.zip
cp pages_zips/pages.zip .
rm -rf tldr
version=$(curl -s "https://api.github.com/repos/Techno-Disaster/tldr-flutter/commits?path=tldrdict%2Fstatic&page=1&per_page=1" | jq -r '.[0].sha' | cut -c -6)
echo "{\"version\": \"$version\", \"lastUpdatedAt\": \"$(date +"%Y-%m-%d %T")\"}" > version.txt
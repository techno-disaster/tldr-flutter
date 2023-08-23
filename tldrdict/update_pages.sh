#!/bin/bash
cd static

# json format for all commands with name, languages and platform
curl -s 'https://tldr.sh/assets/'|  jq --compact-output '[.commands[] | {command: .name, info: .targets | group_by(.os)[] | {os: .[] | .os, languages: [.[] | .language]}}]  | unique' > commands2.json
git clone https://github.com/tldr-pages/tldr
zip -r allpages.zip tldr/pages*
zip -r pages.zip tldr/pages # incase someone is still on the old version he should still get pages.zip
rm -rf tldr
version=$(curl -s "https://api.github.com/repos/techno-disaster/tldr-flutter/commits?path=tldrdict%2Fstatic&page=1&per_page=1" | jq -r '.[0].sha' | cut -c -6)
echo "{\"version\": \"$version\", \"lastUpdatedAt\": \"$(date +"%Y-%m-%d %T")\"}" > version.txt # deperacated, use versiom.json
echo "{\"version\": \"$version\", \"lastUpdatedAt\": \"$(date +"%Y-%m-%d %T")\"}" > version.json
# add a list of all supported languages to commands2.json
curl -s 'https://tldr.sh/assets/' |  jq --compact-output '{supportedLanguages: [.commands[] | .language | .[]] | unique}' > temp.json && jq --compact-output --slurp add version.json temp.json | sponge version.json && rm temp.json

#!/bin/bash

cd static
git clone https://github.com/tldr-pages/tldr
zip -r pages.zip tldr/pages
rm -rf tldr
version=$(curl -s "https://api.github.com/repos/Techno-Disaster/tldr-flutter/commits?path=tldrdict%2Fstatic&page=1&per_page=1" | jq -r '.[0].sha' | cut -c -6)
echo "{\"version\": \"$version\", \"lastUpdatedAt\": \"$(date +"%Y-%m-%d %T")\"}" > version.txt
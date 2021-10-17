#!/bin/bash

git clone https://github.com/tldr-pages/tldr
zip -r pages.zip tldr/pages
echo "::set-output name=TAG_NAME::$(curl --upload-file pages.zip http://transfer.sh/pages.zip | cut -d/ -f 4)"  > static/version.txt
rm -rf tldr pages.zip
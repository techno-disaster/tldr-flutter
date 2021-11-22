#!/bin/bash

cd tldrdict/static
git clone https://github.com/tldr-pages/tldr
zip -r pages.zip tldr/pages
rm -rf tldr
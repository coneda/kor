#!/bin/bash

rm -f tmp/brakeman.html tmp/rubocop.html 

rubocop -C false -D -E -R -S -f html -o tmp/rubocop.html
brakeman -A -f html -o tmp/brakeman.html

xdg-open tmp/brakeman.html
xdg-open tmp/rubocop.html 
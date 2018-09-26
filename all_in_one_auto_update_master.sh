#!/bin/zsh
# Author: Robin Wen
# Date: 2015-03-10 11:43:27
# Desc: Auto push after update the repo.
# Test GitHub sync to GitCafe.

source ~/.zshrc > /dev/null 2>&1
git add -A .
git commit -m "$1"
fuckgfw git push origin master

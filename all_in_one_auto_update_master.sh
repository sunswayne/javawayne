#!/bin/bash
# Author: Robin Wen
# Date: 2015-03-10 11:43:27
# Desc: Auto push after update the repo.
# Test GitHub sync to GitCafe.

git add -A .
git commit -m "$1"
git push origin master
# git push gitcafe master:gitcafe-pages

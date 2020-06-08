#!/bin/bash
cd ./project
git add -A
git commit -m "backup"
ssh-add ../github
git remote set-url origin git+ssh://git@github.com/yz-wulala/iServer01Bkup.git
git push -u origin master

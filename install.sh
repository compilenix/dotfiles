#!/bin/bash
mkdir -p ~/bin
curl -L https://raw.githubusercontent.com/joeyh/myrepos/master/mr -o ~/bin/mr
~/bin/mr --trust-all bootstrap https://raw.githubusercontent.com/flat235/dotfiles-flat235/master/home/.mrconfig

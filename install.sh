#!/bin/bash

timestamp=$(date +%Y-%m-%d_%H-%M-%S)
vimrc_backup=/tmp/.vimrc.bak.$timestamp

# backup previous vimrc
if [ -f ~/.vimrc ]; then
  cp -R ~/.vimrc $vimrc_backup
  echo "Previous .vimrc was backed up to $vimrc_backup"
  echo "You can check the differences with:"
  echo "diff ~/.vimrc $vimrc_backup"
fi

# get new vimrc
wget -O ~/.vimrc https://raw.githubusercontent.com/ghomem/laziest-vim/refs/heads/main/vimrc &> /dev/null

# setup plugins
mkdir -p ~/.vim/autoload
wget -O ~/.vim/autoload/plug.vim https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim &> /dev/null

# make sure plugins are installed
echo | vim +PlugInstall +qall &> /dev/null

echo
echo "You vim configuration is now IDEalized."

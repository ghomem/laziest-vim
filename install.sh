#!/bin/bash

timestamp=$(date +%Y-%m-%d_%H-%M-%S)
vimrc_backup=/tmp/.vimrc.bak.$timestamp
files="$HOME/.vimrc $HOME/.tigrc"

# backup existing files
for f in $files; do
  if [ -f $f ]; then
    backup_file=/tmp/$(basename $f).$USER.$timestamp
    cp -f $f $backup_file
    echo "Previous $f was backed up to $backup_file"
    echo "You can check the differences with:"
    echo "diff $f $backup_file"
    echo
  else
    echo $f not found. No backup neeeded.
    echo
  fi
done

# get new vimrc
wget -O ~/.vimrc https://raw.githubusercontent.com/ghomem/laziest-vim/refs/heads/main/vimrc &> /dev/null

# setup plugins
mkdir -p ~/.vim/autoload
wget -O ~/.vim/autoload/plug.vim https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim &> /dev/null

# make sure plugins are installed
echo | vim +PlugInstall +qall &> /dev/null

# fine tune tigrc for colors
if [ ! -f $HOME/.tigrc ]; then
  touch $HOME/.tigrc
fi

# reference for tig colors:
# https://jonas.github.io/tig/doc/tigrc.5.html

# highlighted line
egrep color $HOME/.tigrc | grep -v "^#" | grep -q cursor || echo "color cursor default color237" >> $HOME/.tigrc
# status summary footer
egrep color $HOME/.tigrc | grep -v "^#" | grep -q title-focus || echo "color title-focus color237 color113 bold" >> $HOME/.tigrc
# same while a diffi sub-window is open
egrep color $HOME/.tigrc | grep -v "^#" | grep -q title-blur || echo "color title-blur color237 color113" >> $HOME/.tigrc


echo
echo "You vim configuration is now IDEalized."

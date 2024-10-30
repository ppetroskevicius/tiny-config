#/bin/bash
set -e                          # Exit on any error

DIR=$(dirname $(realpath $0))   # Get absolute path of script directory
cd $DIR

mkdir -p $HOME/.config/

ln -sf $DIR/.sshconfig $HOME/.ssh/config
ln -sf $DIR/.screenrc $HOME
ln -sf $DIR/.bash_profile $HOME
ln -sf $DIR/.bashrc $HOME
ln -sf $DIR/.zshrc $HOME
ln -sf $DIR/.tmux.conf $HOME
ln -sf $DIR/.vimrc $HOME
ln -sf $DIR/.gitconfig $HOME
ln -sf $DIR/.alacritty.toml $HOME

mkdir -p $HOME/.config/zed/
ln -sf $DIR/zed/keymap.json $HOME/.config/zed/
ln -sf $DIR/zed/settings.json $HOME/.config/zed/

rm -rf $HOME/.config/alacritty
mkdir -p $HOME/.config/alacritty/themes
git clone https://github.com/alacritty/alacritty-theme $HOME/.config/alacritty/themes

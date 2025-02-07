# runs for each non-login interactive shells like alacritty, or terminal in gnome

export PS1="\u@\h:\[\e[0;36m\]\w\[\e[0m\]$ "
export EDITOR='vim'
export CLICOLOR=1

export PATH=$HOME/.cargo/bin:$HOME/.local/bin:$PATH

eval "$(starship init bash)"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/home/fastctl/.lmstudio/bin"

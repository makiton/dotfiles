bindkey -e
alias ll="ls -al"
alias be="bundle exec"

export EDITOR=vim

fpath=($(brew --prefix)/share/zsh/site-functions $fpath)
autoload -U compinit
compinit -u

autoload -Uz vcs_info
setopt prompt_subst
zstyle ':vcs_info:*' formats '%F{green}%b%f'
zstyle ':vcs_info:*' actionformats '%F{green}%b%f(%F{red}%a%f)'
precmd() { vcs_info }    
PROMPT='${vcs_info_msg_0_}:%~/%% '

export GOPATH=$HOME
export PATH=$PATH:$GOPATH/bin

function peco-src () {
  local selected_dir=$(ghq list -p | peco --query "$LBUFFER")
  if [ -n "$selected_dir" ]; then
    BUFFER="cd ${selected_dir}"
    zle accept-line
  fi
  zle clear-screen
}
zle -N peco-src
bindkey '^]' peco-src

eval "$(rbenv init -)"

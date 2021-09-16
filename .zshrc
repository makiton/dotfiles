bindkey -e
alias ll="ls -al"
alias be="bundle exec"

setopt AUTO_CD
cdpath=(.. ~ ~/workspace)

export EDITOR=vim

fpath=($(brew --prefix)/share/zsh/site-functions $fpath)
autoload -U compinit
compinit -u

# histories
export HISTFILE=~/.zsh_history
export HISTSIZE=1000
export SAVEHIST=100000

setopt hist_ignore_dups
setopt EXTENDED_HISTORY

export LC_ALL=ja_JP.UTF-8
export LANG=ja_JP.UTF-8

autoload -Uz vcs_info
setopt prompt_subst
zstyle ':vcs_info:*' formats '%F{green}%b%f'
zstyle ':vcs_info:*' actionformats '%F{green}%b%f(%F{red}%a%f)'
precmd() { vcs_info }
PROMPT='${vcs_info_msg_0_}:%~/%% '

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

if type rbenv >/dev/null 2>&1; then
  export PATH=./bin:./vendor/bin:./node_modules/.bin:$PATH
  eval "$(rbenv init -)"
fi

if type pyenv >/dev/null 2>&1; then
  export PATH="$HOME/.pyenv/bin:$PATH"
  eval "$(pyenv init -)"
  export PYENV_ROOT="$HOME/.pyenv"
fi

if [ -e /usr/libexec/java_home ]; then
  export JAVA_HOME=`/usr/libexec/java_home -v 1.8`
fi

if type direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi

if type docker-machine >/dev/null 2>&1; then
  eval $(docker-machine env default)
fi

# The next line updates PATH for the Google Cloud SDK.
if [ -f "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc" ]; then source "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc"; fi
if [ -f "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc" ]; then source "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc"; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/makiton/google-cloud-sdk/completion.zsh.inc' ]; then source '/Users/makiton/google-cloud-sdk/completion.zsh.inc'; fi

if type nodenv >/dev/null 2>&1; then
  eval "$(nodenv init -)"
fi

set -o vi
source ~/.alias.sh

# Zoxide replacing z
eval "$(zoxide init zsh)"

alias ls='ls -GFh'
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
export TERM=alacritty

if [ -d "$HOME/.dotfiles" ]; then
  dotfiles config --local status.showUntrackedFiles no 2>/dev/null
fi

# Setting PATH for Python 3.11
# The original version is saved in .bash_profile.pysave
PATH="/Library/Frameworks/Python.framework/Versions/3.11/bin:${PATH}"
export PATH
export GEM_HOME=$HOME/.gem
export PATH=$GEM_HOME/bin:$PATH
export PATH="${HOME}/.local/bin:$PATH"
export PATH="$PATH:${HOME}/flutter/bin"
export PATH
# export PATH="/usr/local/opt/llvm/bin:$PATH"
. "$HOME/.cargo/env"
export PATH="/usr/local/opt/openal-soft/bin:$PATH"
export PATH="$HOME/.config/lua-language-server/bin:$PATH"
export PATH=/usr/local/bin:$PATH
export COMMON_CI_LOCAL="$HOME/ilab/Deloitte-US-Innovation-Technology/devops-common-ci"
export POETRY_HTTP_BASIC_PRIVATE_USERNAME=$(cat $HOME/.ssh/secrets/username.log)
export POETRY_HTTP_BASIC_PRIVATE_PASSWORD=$(cat $HOME/.ssh/secrets/password.log)
export DOCKER_DEFAULT_PLATFORM=linux/amd64

# Starship Prompt
eval "$(starship init zsh)"

alias luamake=/Users/ryandavis/.config/lua-language-server/3rd/luamake/luamake

nvm use 20
setup_python
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

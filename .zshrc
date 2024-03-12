set -o vi
source ~/.alias.sh

# Zoxide replacing z
eval "$(zoxide init zsh)"

alias ls='ls -GFh'

export NVM_DIR="$HOME/.nvm"
  [ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"  # This loads nvm
  [ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ] && . "/usr/local/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion
export TERM=alacritty

# Setting PATH for Python 3.11
# The original version is saved in .bash_profile.pysave
export ADFS_TOOLS="docker run -t -i -v ${HOME}/.aws:/tmp/aws_dir -v ~/.local/share/python_keyring:/root/.local/share/python_keyring dcil-docker-release.art.tools.deloitteinnovation.us/devi/adfs-tools:1.11.1 aws --aws-dir /tmp/aws_dir"
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
export COMMON_CI_LOCAL="$HOME/ilab/dl/devops-common-ci"
export POETRY_HTTP_BASIC_PRIVATE_USERNAME=$(cat $HOME/.ssh/secrets/username.log)
export POETRY_HTTP_BASIC_PRIVATE_PASSWORD=$(cat $HOME/.ssh/secrets/password.log)

# Starship Prompt
eval "$(starship init zsh)"

alias luamake=/Users/ryandavis/.config/lua-language-server/3rd/luamake/luamake
# Copy the EKS Access Token to the Clipboard (and paste into login page)
alias sdlc-token="aws eks get-token --cluster-name eks-sdlc --profile eks-sdlc | jq -r  '.status.token' | xclip -selection clipboard"

# Authenticate to AD and automatically assume an AWS Role
alias sdlc-login="${ADFS_TOOLS} --use-encrypted --domain DCI --profile eks-sdlc --ni --rp '.*ADFS-EKS-SDLC-ClusterAdmin$' --username=<DCI Username>"

nvm use 18
setup_python

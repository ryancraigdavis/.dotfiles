# simple function for creating new or attaching to current tmux session
# ARGS:
#  name (optional)
#  if given, <name> will be used as session id. Will attempt tmux attach if session is running
#  otherwise a new tmux session will be created using this name.
create_tmux_session()
{
   name=$1;
   command="";
   shift;
   if [ -z $name ]; then
      # create nameless tmux session and let tmux name it
      command="tmux new-session"
      echo $command
      $command
   else
      # we have a name
      # first search current tmux sessions to see if we can attach to session name
      current_named_sessions=`tmux list-sessions | cut -d':' -f1`
      for session_id in $current_named_sessions; do
         if [ "$name" == "$session_id" ]; then
            # we found a matching session name so attempt to attach to it
            command="tmux attach -t $name"
            break;
         fi
      done;
      if [ -z $command ]; then
         # we did not find a session name, so create new sesion.
         command="tmux new -s $name"
      fi
      $command
   fi
}

# Git live-log, a fork from https://gist.github.com/tlberglund/3714970
function gitwatch(){
   while :
   do
      clear
      git --no-pager log --graph --pretty=oneline --abbrev-commit --decorate --all $*
      sleep 1
   done
}

set_git_prompt()
{
   export PS1='\n\[\033]0;\u@\h:$(__git_ps1 " %s") \w\007\033[38m\]\u@\h:\[\033[02;34m\]\w\n\[\033[01;31m\]$(__git_ps1 "(%s)")\[\033[30m\]>\[\033[00m\]'
}


set_prompt()
{
   export PS1='\u@\h:$(pwd)\n>'
}

test_setup(){
   SELECT=""
   while [[ "$SELECT" != $'\x0a' && "$SELECT" != $'\x20' ]]; do
      echo "Press <Space> to move selection"
      echo "Press <Enter> to confirm selection"
      read -d'' -s -n1
      echo "Debug/$SELECT/${#SELECT}"
      [[ "$SELECT" == $'\x0a' ]] && echo "enter" # do your install stuff
      [[ "$SELECT" == $'\x20' ]] && echo "space" && echo -ne "$options" # reprint options  
   done
}
# Functions to determin git repo <project>/<repo>/<branch> identifiers
alias show_git_branch_name="git rev-parse --abbrev-ref HEAD"
alias show_git_project_name='git config --get remote.origin.url | sd ".*/scm/(.*)/.*\.git" "\$1"'
alias show_git_repo_name='git config --get remote.origin.url | sd ".*/scm/.*/(.*)\.git" "\$1"'
alias show_git_tag_name="git tag --points-at HEAD | head -1"

alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

alias restore_shell_echo='stty echo'
alias build_all_docker_images_here='for docker_file in $(fd Dockerfile); do docker_dir=$(dirname $(pwd)/$docker_file); env DOCKER_BUILDKIT=1 docker build --secret id=username,src=$HOME/.ssh/secrets/username.log --secret id=password,src=$HOME/.ssh/secrets/password.log $docker_dir -t test-build$(echo -; sd '\''/'\'' '\''_'\'' $docker_dir) --no-cache --build-arg FULL_VERSION=${FULL_VERSION:-$(show_git_tag_name)}; done'
alias refresh_alias='source ~/.alias.sh'
alias tm=create_tmux_session
alias tl="tmux list-sessions"
alias dir_list='dirs -v'
alias reset_tmux="tmux list-windows -a | while IFS=: read -r a b c; do tmux set-window-option -t "$a:$b" automatic-rename on; done"
alias save_and_exit="history >> ~/work/all_history.txt; exit"
alias nvimdiff="nvim -d"
alias setup_concourse_debug="source $HOME/ilab/devtest/setup_concourse_debug/setup_alias.sh"
alias devb="devcontainer build --workspace-folder \$(pwd)"
alias devu="devcontainer up --workspace-folder \$(pwd)"
alias deve="devu; devcontainer exec --workspace-folder \$(pwd)"
alias devz="deve zsh"

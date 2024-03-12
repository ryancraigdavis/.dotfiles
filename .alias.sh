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

# pushd_extra 
push_pop_extra()
{

   pushd_or_popd_command=$1
   dest_path=$2


   # if no argument is passed in, default to standard pushd withou args
   if [[ -z "$dest_path" ]]; then
      $pushd_or_popd_command 1>/dev/null;
   else
      # if argument is given to this function, determine if its
      # an integer or a path.
      if [ "$dest_path" -eq "$dest_path" ] 2>/dev/null; then
         # it's an integer since bash evaluated an integer expression
         # now double check that it's not a folder in current dir that
         # is has an integer name such as 1/ 2/ 400/ etc.
         if [ ! -e $dest_path ]; then
            $pushd_or_popd_command +$dest_path 1>/dev/null;
         else
            $pushd_or_popd_command $dest_path 1>/dev/null;
         fi
      else
         $pushd_or_popd_command $dest_path 1>/dev/null;
      fi
   fi
   dirs -v
}

pushd_extra()
{
   push_pop_extra pushd $1
}
popd_extra()
{
   push_pop_extra popd $1
}

set_git_prompt()
{
   export PS1='\n\[\033]0;\u@\h:$(__git_ps1 " %s") \w\007\033[38m\]\u@\h:\[\033[02;34m\]\w\n\[\033[01;31m\]$(__git_ps1 "(%s)")\[\033[30m\]>\[\033[00m\]'
}


set_prompt()
{
   export PS1='\u@\h:$(pwd)\n>'
}

# Create a setup script that prompts for which language, and then sets up a local project

setup_python3_here()
{
   # setup python virtual env for working directory
   # If inside virtual env; deactivate it
   # python3 -c "import sys; assert sys.prefix == sys.base_prefix" 2> /dev/null && deactivate;
   deactivate 2> /dev/null 
   if [ -e $(pwd)/pyproject.toml ]; then
      poetry install;
      poetry shell;
   else
      export venv_path=`python ~/.setup_scripts/python3/setup_python3_here_support.py`
      source ${venv_path}/bin/activate
   fi
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
source ~/ilab/devi/stash-tools/alias_shortcuts.sh
# Functions to determin git repo <project>/<repo>/<branch> identifiers
alias show_git_branch_name="git rev-parse --abbrev-ref HEAD"
alias show_git_project_name='git config --get remote.origin.url | sd ".*/scm/(.*)/.*\.git" "\$1"'
alias show_git_repo_name='git config --get remote.origin.url | sd ".*/scm/.*/(.*)\.git" "\$1"'
alias show_git_tag_name="git tag --points-at HEAD | head -1"
alias run_poetry_shell="deactivate; poetry shell"

alias restore_shell_echo='stty echo'
alias build_all_docker_images_here='for docker_file in $(fd Dockerfile); do docker_dir=$(dirname $(pwd)/$docker_file); env DOCKER_BUILDKIT=1 docker build --secret id=username,src=$HOME/.ssh/secrets/username.log --secret id=password,src=$HOME/.ssh/secrets/password.log $docker_dir -t test-build$(echo -; sd '\''/'\'' '\''_'\'' $docker_dir) --no-cache --build-arg FULL_VERSION=${FULL_VERSION:-$(show_git_tag_name)}; done'
alias refresh_alias='source ~/.alias.sh'
alias tm=create_tmux_session
alias tl="tmux list-sessions"
alias setup_python="source /Users/ryandavis/.virtualenvs/python3_11/bin/activate"
alias pd=pushd_extra
alias po=popd_extra
alias dir_list='dirs -v'
alias reset_tmux="tmux list-windows -a | while IFS=: read -r a b c; do tmux set-window-option -t "$a:$b" automatic-rename on; done"
alias save_and_exit="history >> ~/work/all_history.txt; exit"
alias nvimdiff="nvim -d"
alias setup_concourse_debug="source $HOME/ilab/devtest/setup_concourse_debug/setup_alias.sh"

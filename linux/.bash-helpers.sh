Black='\033[0;30m'
Red='\033[0;31m'
Green='\033[0;32m'
Brown_Orange='\033[0;33m'
Blue='\033[0;34m'
Purple='\033[0;35m'
Cyan='\033[0;36m'
Light_Gray='\033[0;37m'
Dark_Gray='\033[1;30m'
Light_Red='\033[1;31m'
Light_Green='\033[1;32m'
Yellow='\033[1;33m'
Light_Blue='\033[1;34m'
Light_Purple='\033[1;35m'
Light_Cyan='\033[1;36m'
White='\033[1;37m'
nc='\033[0m'

up() {
  for D in $(seq 1 $1); do
    cd ..
  done
}

# Show git branch name
force_color_prompt=yes
color_prompt=yes
parse_git_branch() {
  git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}
if [ "$color_prompt" = yes ]; then
  PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[01;31m\]$(parse_git_branch)\[\033[00m\]\$ '
else
  PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w$(parse_git_branch)\$ '
fi
unset color_prompt force_color_prompt

gitm() {
  git submodule foreach --recursive "$@"
}
#delete branch locally_if_not_exist_remote
delete_branch_local() {
  # Fetch the latest information from the remote repository
  git fetch -f -p -P

  # Get the list of all local branches
  local_branches=$(git branch | cut -c 3-)

  # Iterate through each local branch
  for branch in $local_branches; do
    # Check if the branch exists on the remote repository
    if ! git show-ref --quiet "refs/remotes/origin/$branch"; then
      echo "The branch '$branch' does not exist on the remote repository."
      echo "Deleting the local branch..."
      git branch -D "$branch" # Use -d to delete if merged, -D to force delete
    fi
  done
}
delete_branch_local_recur() {
  gitm "bash -c '$(declare -f delete_branch_local); delete_branch_local'"
}

rmr() {
  local ext="${1:-txt}" # Default to 'txt' if no argument is provided

  # Find and move files to trash using gio trash
  find . -type f -name "*.$ext" -exec echo "Moving to trash: {}" \; -exec gio trash {} \;
}

xcp() {
  # Function to copy file content to clipboard using xclip
  # If xclip is not installed, it will automatically install it.
  #
  # Usage: xcp <filename>
  # Example: xcp file.txt
  #
  # This will copy the contents of file.txt to the clipboard.
  # If xclip is not installed, it will be installed automatically.

  # Check if xclip is installed
  if ! command -v xclip &>/dev/null; then
    echo "xclip is not installed. Installing xclip..."
    sudo apt-get update && sudo apt-get install -y xclip
  fi

  # Check if the file exists
  if [ -f "$1" ]; then
    xclip -selection clipboard <"$1"
    echo "Copied contents of $1 to clipboard."
  else
    echo "Error: $1 is not a valid file."
  fi
}

export PATH="$PATH:/sbin:/usr/sbin:usr/local/sbin:"

alias ll="ls -l"
alias grep="grep --color=auto"
alias clean_debian='sudo apt-get autoremove -y && sudo apt-get purge -y && sudo apt-get autoremove --purge -y && sudo apt-get clean && sudo apt-get autoclean && sudo apt-get remove --purge $(dpkg --list | grep linux-image | awk '\''{ if ($1 == "ii") print $2}'\'' | grep -v $(uname -r | cut -d"-" -f1,2) | head -n -1) && sudo find /var/log -type f -name "*.log" -exec truncate -s 0 {} \; && sudo apt-get install -y localepurge && sudo localepurge && sudo apt-get install -y deborphan && sudo deborphan | xargs sudo apt-get -y remove --purge && echo "System cleanup complete!"'
# copied from oh-my-zsh/directories and change to my liking.

# Changing/making/removing directory
setopt auto_pushd
setopt pushd_ignore_dups
setopt pushdminus

# alias -g ... means that its a global alias (and therefore can be used with pipe command.. eg: cat file.txt | grep bob | .../bobs.txt )
alias -g ...='cd ../..'
alias -g ....='cd ../../..'
alias -g .....='cd ../../../..'
alias -g ......='cd ../../../../..'

alias -- -='cd -'
alias 1='cd -'
alias 2='cd -2'
alias 3='cd -3'
alias 4='cd -4'
alias 5='cd -5'
alias 6='cd -6'
alias 7='cd -7'
alias 8='cd -8'
alias 9='cd -9'

alias md='mkdir -p'
alias rd=rmdir

# List directory contents
alias ls='ls -G'

alias l='ls -lah'
alias lsa='ls -lah'
alias ll='ls -lh'
alias la='ls -lAh'

# clear the screen
alias c='clear'

# Shortcuts
alias dc="cd ~/Documents"
alias dl="cd ~/Downloads"
alias dt="cd ~/Desktop"
alias p="cd ~/projects"

## Create links to alias for all projects
for i in ~/projects/* ; do
  for x in "$i"/* ; do
    dir=$(dirname $x)
    name=$(basename $x)
#    echo "$(date +%s) - for $dir/$name"
    alias c."$name"="cd $dir/$name";
  done
done


alias la="l -A"
alias cl="clear && l"
alias cla="clear && la"
alias lsd="la | grep '^d'"
alias clsd="cla | grep '^d'"

# Looking at files
alias lsi='less -i'
alias tlf='tail -Fn100'


alias ff='find . -type f -name'

# Enable aliases to be sudo’ed
alias sudo='sudo '

# Get week number
alias week='date +%V'

alias grep='grep --color'

#Open the current folder with Finder
alias ofd='open_command $PWD'

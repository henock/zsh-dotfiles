# copied from oh-my-zsh/directories and change to my liking.

# Changing/making/removing directory
# the directory stack is updated automatically whenever you change directories using the cd command
setopt auto_pushd
# means that the pushd command ignores duplicate directory entries on the directory stack.
setopt pushd_ignore_dups
# When pushdminus is enabled, the pushd command will interpret a leading "-" character as a directory name, rather than a request to move up one directory.
setopt pushdminus

# alias -g ... means that its a global alias (and therefore can be used with pipe command.. eg: cat file.txt | grep bob | .../bobs.txt )
alias -g ..='cd ..'
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


# clear the screen
alias c='clear'

# List directory contents
alias ls='ls -G'            # -G show with colors
alias l='ls -ltrh'          # ls reversed modified timestamp, human readable
alias ll='l'
alias la='l -A'             # -A includes directory entries whose names begin with a dot (‘.’) except for . and ...
alias lsd="la | grep '^d'"  # show directories only
alias cl="clear && l"
alias cla="clear && la"
alias clsd="clear && lsd"
alias ldot='ls -ld .*'      # show dot files only (only works for current directory)

# Shortcuts
alias dc="cd ~/Documents"
alias dl="cd ~/Downloads"
alias dt="cd ~/Desktop"
alias p="cd ~/projects"


# Looking at files
alias lsi='less -i'
alias tlf='tail -Fn100'


alias ff='find . -type f -name'
alias ffd='find . -type d -name'

# Enable aliases to be sudo’ed
alias sudo='sudo '

# Get week number
alias week='date +%V'

alias grep='grep --color'
# grep in folders .. -R recursive subdirectories, -n precede with line numbers, -H filename headers, -C 5 print 5 context line numbers (before/after), --exclude-dir={.git} excludes .git folder from search
alias sgrep='grep -R -n -H -C 5 --exclude-dir=.git'

#Open the current folder with Finder
alias ofd='open_command $PWD'


# Create a new directory and enter it
function mkd() {
    mkdir -p "$@" && cd "$_";
}


# Create links to alias for all projects
for i in ~/projects/* ; do
  if [ -d "$i" ]; then
    for x in "$i"/* ; do
      dir=$(dirname "$x")
      name=$(basename "$x")
#      echo "$(date +%s) - for $dir/$name"
      alias c."$name"="cd $dir/$name";
    done
  fi
done
#! /bin/sh

start_time="$(date +%s)"

HISTFILE=${HOME}/.zsh_history
HIST_STAMPS="yyyy-mm-dd"
setopt EXTENDED_HISTORY
setopt SHARE_HISTORY
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY

export LINUX_USR=zewdeh
export PATH="$HOME/bin:$PATH";

#Stop highlighting text when pasting into the terminal
zle_highlight=('paste:none')


autoload colors
colors

# Reload the shell (i.e. invoke as a login shell)
alias reload="echo -n 'Reloading' && exec zsh "
alias zshrc='vim ${ZDOTDIR:-$HOME}/.zshrc' # Quick access to the .zshrc file

# Source my _extension files
for extension_file in ~/.zsh_config/.*.zsh; do
  echo -n "."
  [ -r "$extension_file" ] && [ -f "$extension_file" ] && source "$extension_file" ;
done;
unset extension_file;

# Sometimes  ctrl-a, ctrl-e, alt-<left> and alt-<right> stop working so setting them manually
bindkey -e
bindkey "[D" backward-word
bindkey "[C" forward-word

end_time="$(date +%s)"

echo "Time taken: $(($end_time - $start_time))s"

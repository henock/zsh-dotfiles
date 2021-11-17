# copied from oh-my-zsh/lib/clipboard.zsh and modified to my needs
function setup-clipboard() {
  emulate -L zsh
  function clicopy() { pbcopy < "${1:-/dev/stdin}"; }
  function clipaste() { pbpaste; }
}
# Copy $PWD into the clipboard
function copydir {
  emulate -L zsh
  print -n $PWD | clicopy
}

# Copy the content of $1 into the clipboard
function copyfile {
  emulate -L zsh
  clicopy $1
}



setup-clipboard || true

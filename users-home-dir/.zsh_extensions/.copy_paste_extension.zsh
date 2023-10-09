# copied from oh-my-zsh/lib/clipboard.zsh and modified to my needs
function setup-clipboard() {
  emulate -L zsh
  function clicopy() { pbcopy < "${1:-/dev/stdin}"; }
  function clipaste() { pbpaste; }
}
# Copy the full path of $PWD into the clipboard
function cpdir {
  emulate -L zsh
  print -n $PWD | clicopy
}

# Copy the content of $1 into the clipboard
function cpfile {
  emulate -L zsh
  clicopy "$1"
}

setup-clipboard || true
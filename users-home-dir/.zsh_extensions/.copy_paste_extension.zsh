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

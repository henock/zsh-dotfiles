# copied from oh-my-zsh and changed to my needs

# Preview a document instead of opening it with its default app.
function quick-look() {
  (( $# > 0 )) && qlmanage -p $* &>/dev/null &
}


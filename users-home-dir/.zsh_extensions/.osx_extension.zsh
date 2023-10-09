# copied from oh-my-zsh and changed to my needs

# Preview a document instead of opening it with its default app.
function quick-look() {
  (( $# > 0 )) && qlmanage -p $* &>/dev/null &
}

show_non_zero_response_code(){
   RETURN_CODE=$?;
   if [[ $RETURN_CODE != 0 ]] ; then
      echo -e "\033[31mERROR_RETURN_CODE: ${RETURN_CODE}\033[0m";
   fi
}

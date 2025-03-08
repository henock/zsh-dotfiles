

#oh-my-zsh plugins and extensions use the open_command
function open_command() {
  local  open_cmd='open'
  ${=open_cmd} "$@" &>/dev/null
}

#
# Get the value of an alias.
#
# Arguments:
#    1. alias - The alias to get its value from
# STDOUT:
#    The value of alias $1 (if it has one).
# Return value:
#    0 if the alias was found,
#    1 if it does not exist
#
function alias_value() {
    (( $+aliases[$1] )) && echo $aliases[$1]
}

function all_aliases(){
  for alias_name in ${(k)aliases}; do
      echo "Alias: \e[32m$alias_name\e[0m -> \e[31m${aliases[$alias_name]}\e[0m"
  done
}
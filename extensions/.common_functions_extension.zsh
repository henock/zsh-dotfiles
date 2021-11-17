

#oh-my-zsh plugins and extensions use the open_command
function open_command() {
  local  open_cmd='open'
  ${=open_cmd} "$@" &>/dev/null
}

# get the nvm-controlled node.js version
function nvm_prompt_info() {
  which nvm &>/dev/null || return
  local nvm_prompt=${$(nvm current)#v}
  echo "${ZSH_THEME_NVM_PROMPT_PREFIX}${nvm_prompt}${ZSH_THEME_NVM_PROMPT_SUFFIX}"
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

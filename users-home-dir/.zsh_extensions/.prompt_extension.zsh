# original code came from - oh-my-zsh Bureau Theme
# Icons are installed fonts from https://www.nerdfonts.com/cheat-sheet

ZSH_THEME_GIT_PROMPT_PREFIX="%F{grey}"                                   # branch icon
ZSH_THEME_GIT_PROMPT_SUFFIX="%f"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg_bold[green]%}󰸞%{$reset_color%}"         # check icon
ZSH_THEME_GIT_PROMPT_AHEAD="%{$fg[cyan]%}%{$reset_color%}"               # move to top icon
ZSH_THEME_GIT_PROMPT_BEHIND="%{$fg[magenta]%}%{$reset_color%}"           # move to bottom icon
ZSH_THEME_GIT_PROMPT_STAGED="%{$fg_bold[green]%} %{$reset_color%}"       # diff added icon
ZSH_THEME_GIT_PROMPT_UNSTAGED="%{$fg_bold[yellow]%} %{$reset_color%}"    # file moved icon
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg_bold[red]%}󱈸󱈸%{$reset_color%}"      # exclamation thick icon

bureau_git_branch () {
  ref=$(command git symbolic-ref HEAD 2> /dev/null) || \
  ref=$(command git rev-parse --short HEAD 2> /dev/null) || return
  echo "${ref#refs/heads/}"
}

bureau_git_status() {
  _STATUS=""

  # check status of files
  _INDEX=$(command git status --porcelain 2> /dev/null)
  if [[ -n "$_INDEX" ]]; then
    if $(echo "$_INDEX" | command grep -q '^[AMRD]. '); then
      _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_STAGED"
    fi
    if $(echo "$_INDEX" | command grep -q '^.[MTD] '); then
      _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_UNSTAGED"
    fi
    if $(echo "$_INDEX" | command grep -q -E '^\?\? '); then
      _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_UNTRACKED"
    fi
    if $(echo "$_INDEX" | command grep -q '^UU '); then
      _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_UNMERGED"
    fi
  else
    _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_CLEAN"
  fi

  # check status of local repository
  _INDEX=$(command git status --porcelain -b 2> /dev/null)
  if $(echo "$_INDEX" | command grep -q '^## .*ahead'); then
    _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_AHEAD"
  fi
  if $(echo "$_INDEX" | command grep -q '^## .*behind'); then
    _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_BEHIND"
  fi
  if $(echo "$_INDEX" | command grep -q '^## .*diverged'); then
    _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_DIVERGED"
  fi

  if $(command git rev-parse --verify refs/stash &> /dev/null); then
    _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_STASHED"
  fi

  echo $_STATUS
}

bureau_git_prompt () {
  local _branch=$(bureau_git_branch)
  local _status=$(bureau_git_status)
  local _result=""
  if [[ "${_branch}x" != "x" ]]; then
    _result="$ZSH_THEME_GIT_PROMPT_PREFIX$_branch"
    if [[ "${_status}x" != "x" ]]; then
      _result="$_result $_status"
    fi
    _result="$_result$ZSH_THEME_GIT_PROMPT_SUFFIX"
  fi
  echo $_result
}


bureau_precmd () {
  print -rP '%F{green}%*%f $(bureau_git_prompt) %F{blue}% %1d %f'
}

# Enable prompt substitution
setopt prompt_subst

PROMPT='%0(?.. %F{red} <%?> %f) %F{green}%f '
RPROMPT=''

autoload -U add-zsh-hook
add-zsh-hook precmd bureau_precmd


### Using the above because the below was not working in tmux :/
### Originally from https://dev.to/cassidoo/customizing-my-zsh-prompt-3417
#autoload -Uz vcs_info
#zstyle ':vcs_info:*' enable git
#zstyle ':vcs_info:git:*' formats '( %b)'
#
#precmd() {
#  vcs_info
#}
#
##setopt PROMPT_SUBST
#setopt prompt_subst
#PROMPT='%F{green}%*%f %F{blue}%1d%f ${vcs_info_msg_0_} %0(?.. %F{red} <%?> %f)$ '

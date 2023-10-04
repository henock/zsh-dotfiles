#! /bin/bash
set -eu

source extensions/.utils.zsh


function undeploy_zsh_dot_files() {
  check_with_user_and_remove ~/.zshrc
  check_with_user_and_remove ~/.gvimrc
  check_with_user_and_remove ~/.vimrc
  check_with_user_and_remove ~/.zsh_extensions
  check_with_user_and_remove ~/.zsh_plugins
  check_with_user_and_remove ~/.zsh_sessions
}


function show_undeploy_help() {
  local bold_font=$(tput bold)
  local normal_font=$(tput sgr0)
  echo -e ""
  echo -e "${bold_font}SYNOPSIS${normal_font}"
  echo -e ""
  echo -e "    ./undeploy-from-home-folder.sh [options]"
  echo -e ""
  echo -e "${bold_font}DESCRIPTION${normal_font}"
  echo -e ""
  echo -e "The ${bold_font}undeploy-from-home-folder.sh${normal_font} script undeploys the .zsh-dotfiles from your home folder. Unlinking symlinks, and deleting all .zsh-dotfiles folders."
  echo -e ""
  echo -e "    The following options are available: \n"
  echo -e "    ${bold_font}-h${normal_font}     show this help page\n"
  echo -e "    ${bold_font}-v${normal_font}     verbose mode\n"
  echo -e "    ${bold_font}-u${normal_font}     undeploy files\n"
}




function deal_with_undeploy_options() {
  while getopts "vhu" option; do
    case $option in
      v)
        VERBOSE=true
        ;;
      h)
        show_help=true
        ;;
      u)
        show_help=false
        ;;
      \?)
        show_help=true
      ;;
    esac
  done

  shift $(expr $OPTIND - 1 )  # Strip off options

  if [[ $show_help = true ]]; then
    show_undeploy_help
    exit 0;
  fi
}



function run_script() {
  VERBOSE=false
  TRUE=0
  FALSE=1
  USER_ANSWER_YES=1
  USER_ANSWER_NO=2
  PROMPT_FOR_ANY_CONFIRMATIONS="$USER_ANSWER_YES"
  show_help=true

  deal_with_undeploy_options "$@"
  undeploy_zsh_dot_files
}


############################################################
#######           SCRIPT STARTS HERE                 ########
############################################################

run_script "$@"


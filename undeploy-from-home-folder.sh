#! /bin/bash

source users-home-dir/.zsh_extensions/.utils.zsh

function undeploy_zsh_dot_files() {
  set_project_dirs

  if [ "$RUN_AS_TEST" = true ]; then
    USERS_HOME="$BASE_DIR/TEST"
  fi

  check_with_user_and_remove "$USERS_HOME/.vim"
  check_with_user_and_remove "$USERS_HOME/.zshrc"
  check_with_user_and_remove "$USERS_HOME/.gvimrc"
  check_with_user_and_remove "$USERS_HOME/.vimrc"
  check_with_user_and_remove "$USERS_HOME/.zsh_extensions"
  check_with_user_and_remove "$USERS_HOME/.zsh_plugins"
  check_with_user_and_remove "$USERS_HOME/.zsh_sessions"
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
  echo -e "The ${bold_font}undeploy-from-home-folder.sh${normal_font} script undeploys the .zsh-dotfiles from your home folder. Unlinking symlinks, and deletes all .zsh-dotfiles installed folders."
  echo -e ""
  echo -e "  (deletes)  .vim/"
  echo -e "  (unlinks)  .zshrc"
  echo -e "  (unlinks)  .gvimrc"
  echo -e "  (unlinks)  .vimrc"
  echo -e "  (deletes)  .zsh_extensions/"
  echo -e "  (deletes)  .zsh_plugins/"
  echo -e ""
  echo -e "    The following options are available: \n"
  echo -e "    ${bold_font}-h${normal_font}     show this help page\n"
  echo -e "    ${bold_font}-t${normal_font}     run in test mode (does the work in <project-base-dir>/TEST folder\n"
  echo -e "    ${bold_font}-v${normal_font}     verbose mode (takes precedence over silent mode)\n"
  echo -e "    ${bold_font}-S${normal_font}     silent mode - asks no questions\n"
  echo -e "    ${bold_font}-u${normal_font}     undeploy files\n"
}

function deal_with_undeploy_options() {
  while getopts "vhutS" option; do
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
      t)
        RUN_AS_TEST=true
        ;;
      S)
        show_help=false
        SILENT=true
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
  SILENT=false
  RUN_AS_TEST=false
  TRUE=0
  FALSE=1
  USER_ANSWER_YES=1
  USER_ANSWER_NO=2
  show_help=true

  deal_with_undeploy_options "$@"
  undeploy_zsh_dot_files
  exec zsh
}


############################################################
#######           SCRIPT STARTS HERE                 ########
############################################################

run_script "$@"
#! /bin/bash
set -eu


source extensions/.utils.zsh

# Note: /bin/bash is required for ~/.* expansion in loop below


# Credit: Original version found here: https://github.com/jeffaco/dotfiles/blob/master/nix/bootstrap.sh

# Set up soft links from files to their destination (in home directory)

# Can't use something like 'readlink -e $0' because that doesn't work everywhere
# And HP doesn't define $PWD in a sudo environment, so we define our own

function upsert_symlink() {
  #  Symlink can't simply be overwritten, we first remove the one present before we can link a new file.
  TARGET_FILE=$1
  SOURCE_FILE=$2
  
  if [ -f "$TARGET_FILE" ] || [ -h "$TARGET_FILE" ]; then
    echo_in_verbose_mode "Removing file: $TARGET_FILE"
    rm "$TARGET_FILE"
  fi
  echo_in_verbose_mode "Creating the link $TARGET_FILE -> $SOURCE_FILE"
  ln -s "$SOURCE_FILE" "$TARGET_FILE"
}

function check_with_user_and_remove() {
  target_file="$1"
  if [ -e "$target_file" ]; then
    ls_of_target_file="\n\n$(ls -la $1)\n\n"
    if [ -d "$target_file" ]; then
      users_response="$(check_user_wants_to_proceed_allow_for_default Do you want to delete the directory $target_file and all its contents)"
      if [[ "$users_response" -eq "$USER_ANSWER_YES" ]]; then
        echo_in_verbose_mode "Deleting dir: $target_file"
        rm -rf "$target_file"
      fi
    elif  [ -h "$target_file" ]; then
      users_response="$(check_user_wants_to_proceed_allow_for_default Do you want to unlink $ls_of_target_file)"
      if [[ "$users_response" -eq "$USER_ANSWER_YES" ]]; then
        echo_in_verbose_mode "Unlinking: $target_file"
        unlink "$target_file"
      fi
    elif  [ -f "$target_file" ]; then
      users_response="$(check_user_wants_to_proceed_allow_for_default Do you want to delete $ls_of_target_file)"
      if [[ "$users_response" -eq "$USER_ANSWER_YES" ]]; then
        echo_in_verbose_mode "Deleting file $target_file"
        rm "$target_file"
      fi
    fi
  fi
}

function display_file_and_its_existence(){
  FILE="$1"
  if [ "$#" -eq 2 ]; then
    FILE_PREFIX_COMMENT="$2"
  else
    FILE_PREFIX_COMMENT=""
  fi
  EXISTENCE=" (exists)"
  if [ ! -e "$FILE" ]; then
    EXISTENCE=" (Doesn't exist and will be created)"
  fi
  echo "$FILE_PREFIX_COMMENT $FILE $EXISTENCE"
}

function create_folder_if_it_does_exist() {
  FOLDER="$1"
  if [ ! -d "$FOLDER" ]; then
    mkdir "$FOLDER"
  fi
}

function check_user_wants_to_proceed_allow_for_default() {
  if [[ "$PROMPT_FOR_ANY_CONFIRMATIONS" -eq "$USER_ANSWER_YES" ]]; then
    users_response=$(check_user_wants_to_proceed "$@")
    echo "$users_response"
  else
    echo "$USER_ANSWER_YES"
  fi
}
function check_user_wants_to_proceed() {
  PROMPT=$@
  echo -e "$PROMPT [y/n]: "  > /dev/tty
  read -r USER_ANSWER

  if [[ "y" == "$USER_ANSWER" ]]; then
    echo "$USER_ANSWER_YES";
  else
    echo "$USER_ANSWER_NO";
  fi
}



function deploy_links_and_folders() {

  PLUGINS_DIR="$BASE_DIR/plugins"
  EXTENSIONS_DIR="$BASE_DIR/extensions/"
  VIM_FILES_DIR="$BASE_DIR/vim-files-for-users-home-dir/"
  VIM_FOLDERS="$BASE_DIR/vim-folders"
  SYNTAX_HIGHLIGHTING_FILE=".zsh-syntax-highlighting.zsh"
  ZSHRC_FILES_DIR="$BASE_DIR/zshrc-files-for-users-home-dir/"

  SYNTAX_HIGHLIGHTING_FILE_IN_PROJECT_DIR="$PLUGINS_DIR/$SYNTAX_HIGHLIGHTING_FILE"

  VIM_DIR_IN_HOME="$HOME/.vim"
  PLUGIN_DIR_IN_HOME="$HOME/.zsh_plugins"
  EXTENSIONS_DIR_IN_HOME="$HOME/.zsh_extensions"
  ZSHRC_FILE_IN_HOME_DIR="$HOME/.zshrc"
  SYNTAX_HIGHLIGHTING_FILE_IN_HOME_DIR="$PLUGIN_DIR_IN_HOME/$SYNTAX_HIGHLIGHTING_FILE"

  echo -e "\n\n"
  echo -e "Source files/folder...\n"
  echo "BASE_DIR                                : $BASE_DIR";
  echo "PLUGINS_DIR                             : $PLUGINS_DIR";
  echo "VIM_FILES_DIR                           : $VIM_FILES_DIR";
  echo "VIM_FOLDERS                             : $VIM_FOLDERS";
  echo "EXTENSIONS_DIR                          : $EXTENSIONS_DIR";
  echo "ZSHRC_FILES_DIR                         : $ZSHRC_FILES_DIR";
  echo "SYNTAX_HIGHLIGHTING_FILE_IN_PROJECT_DIR : $SYNTAX_HIGHLIGHTING_FILE_IN_PROJECT_DIR";

  echo -e "\nTarget files/folder...\n"

  display_file_and_its_existence "$VIM_DIR_IN_HOME" "VIM_DIR_IN_HOME                         : "
  display_file_and_its_existence "$PLUGIN_DIR_IN_HOME" "PLUGIN_DIR_IN_HOME                      : "
  display_file_and_its_existence "$EXTENSIONS_DIR_IN_HOME" "EXTENSIONS_DIR_IN_HOME                  : "
  display_file_and_its_existence "$ZSHRC_FILE_IN_HOME_DIR" "ZSHRC_FILE_IN_HOME_DIR                  : "
  display_file_and_its_existence "$SYNTAX_HIGHLIGHTING_FILE_IN_HOME_DIR" "SYNTAX_HIGHLIGHTING_FILE_IN_HOME_DIR    : "

  echo -e "\n"

  users_response=$(check_user_wants_to_proceed_allow_for_default "Do you want to deploy with config above")
  if [ "$users_response" -eq "$USER_ANSWER_NO" ]; then
    echo "Exiting."
    exit 0;
  fi


  PROMPT_FOR_ANY_CONFIRMATIONS="$USER_ANSWER_NO"

  if [ "$VERBOSE" = true ]; then
    users_response=$(check_user_wants_to_proceed "Prompt before changes" )
    if [ "$users_response" -ne "$USER_ANSWER_NO" ]; then
      PROMPT_FOR_ANY_CONFIRMATIONS="$USER_ANSWER_YES"
    fi
  fi


  check_with_user_and_remove "$VIM_DIR_IN_HOME"
  check_with_user_and_remove "$PLUGIN_DIR_IN_HOME"
  check_with_user_and_remove "$EXTENSIONS_DIR_IN_HOME"

  check_with_user_and_remove "$ZSHRC_FILE_IN_HOME_DIR"
  check_with_user_and_remove "$SYNTAX_HIGHLIGHTING_FILE_IN_HOME_DIR"

  echo -e "\nDeploying .zshrc and all my extension files...\n"

  create_folder_if_it_does_exist "$PLUGIN_DIR_IN_HOME"
  create_folder_if_it_does_exist "$EXTENSIONS_DIR_IN_HOME"
  create_folder_if_it_does_exist "$VIM_DIR_IN_HOME"
  create_folder_if_it_does_exist "$VIM_DIR_IN_HOME/backups"
  create_folder_if_it_does_exist "$VIM_DIR_IN_HOME/swaps"
  create_folder_if_it_does_exist "$VIM_DIR_IN_HOME/undo"
  create_folder_if_it_does_exist "$VIM_DIR_IN_HOME/colors"
  create_folder_if_it_does_exist "$VIM_DIR_IN_HOME/syntax"

  symlink_files_in_folder "$ZSHRC_FILES_DIR" "$HOME" "$TRUE"
  symlink_files_in_folder "$VIM_FILES_DIR" "$HOME" "$TRUE"
  symlink_files_in_folder "$EXTENSIONS_DIR" "$EXTENSIONS_DIR_IN_HOME" "$TRUE"
  symlink_files_in_folder "$VIM_FOLDERS/colors" "$VIM_DIR_IN_HOME/colors" "$FALSE"
  symlink_files_in_folder "$VIM_FOLDERS/syntax" "$VIM_DIR_IN_HOME/syntax" "$FALSE"

  upsert_symlink "$SYNTAX_HIGHLIGHTING_FILE_IN_HOME_DIR" "$PLUGINS_DIR/zsh-syntax-highlighting.zsh"
}


function symlink_files_in_folder() {
  SOURCE_DIR="$1"
  DESTINATION_DIR="$2"
  DOT_FILES="$3"
  SOURCE_PATH="$SOURCE_DIR/*"
  create_folder_if_it_does_exist "$DESTINATION_DIR"
  if [ "$DOT_FILES" -eq "$TRUE" ]; then
    SOURCE_PATH="$SOURCE_DIR.*"
  fi
  echo -e "\nSymlinking files in folder: $SOURCE_PATH -> $DESTINATION_DIR"
  for i in $SOURCE_PATH ; do
    [ ! -f $i ]  && continue    # Ignore anything that is not a file
    SOURCE_DIR=`dirname $i`
    DOT_FILE=`basename $i`
    SOURCE_FILE="$SOURCE_DIR/$DOT_FILE"
    TARGET_FILE="$DESTINATION_DIR/$DOT_FILE"
    echo_in_verbose_mode -e "        Symliking file: $SOURCE_FILE -> $TARGET_FILE"
    upsert_symlink "$TARGET_FILE" "$SOURCE_FILE"
  done
}


function setting_up_sublime_key_mappings_file() {
  set +e #Temprarily allow a command to fail without exiting the script.
  SUBLIME_KEYMAP_DIR=$(find ~/Library/Application\ Support/Sublime* | grep '/Packages/User' | head -n1)
  set -e
  if [[ -d "$SUBLIME_KEYMAP_DIR" ]]; then
    set +e #Temprarily allow a command to fail without exiting the script.
    SUBLIME_KEYMAP_FILE=$(find "$SUBLIME_KEYMAP_DIR" |  grep '/Default (OSX).sublime-keymap$')
    set -e
    MY_SUBLIME_KEYMAP_FILE="$BASE_DIR/sublime/Default (OSX).sublime-keymap"
    PERFORM_COPY=-1
    if [ -f "$SUBLIME_KEYMAP_FILE" ]; then
      if ! diff "$SUBLIME_KEYMAP_FILE" "$MY_SUBLIME_KEYMAP_FILE"; then
        BACK_UP_NAME_EXTENSION="$(date | sed 's/ /_/g')"
        BACK_UP_FILE="$SUBLIME_KEYMAP_FILE.bak-$BACK_UP_NAME_EXTENSION"
        echo "Found a sublime keymap file different to mine (above is the difference) backed it up to $BACK_UP_FILE"
        mv "$SUBLIME_KEYMAP_FILE" "$BACK_UP_FILE"
        echo "And replacing it with mine"
        PERFORM_COPY=0
      fi
    else
      echo "Sublime keymap not found, copying in mine"
      PERFORM_COPY=0
    fi

    if [ "$PERFORM_COPY" -eq 0 ]; then
      echo "Copying $MY_SUBLIME_KEYMAP_FILE to $SUBLIME_KEYMAP_DIR"
      cp "$MY_SUBLIME_KEYMAP_FILE" "$SUBLIME_KEYMAP_DIR"
    fi
  else
    echo "Sublime folder not found, not setting the keymap file."
  fi
}

function show_deploy_help() {
  BOLD=$(tput bold)
  NORM=$(tput sgr0)
  echo -e ""
  echo -e "${BOLD}SYNOPSIS${NORM}"
  echo -e ""
  echo -e "    ./deploy-to-home-folder.sh [options]"
  echo -e ""
  echo -e "${BOLD}DESCRIPTION${NORM}"
  echo -e ""
  echo -e "The ${BOLD}deploy-to-home-folder.sh${NORM} script deploys the .zsh-dotfiles to your home folder. Replacing respective files and folders."
  echo -e ""
  echo -e "    The following options are available: \n"
  echo -e "    ${BOLD}-h${NORM}     show this help page\n"
  echo -e "    ${BOLD}-v${NORM}     verbose mode\n"
  echo -e "    ${BOLD}-d${NORM}     deploy files\n"
}




############################################################
#######           SCRIPT START HERE                 ########
############################################################

VERBOSE=false
TRUE=0
FALSE=1
USER_ANSWER_YES=1   # Default
USER_ANSWER_NO=2
PROMPT_FOR_ANY_CONFIRMATIONS="$USER_ANSWER_YES"
show_help=true

while getopts "vhd" option; do
  case $option in
    v)
      VERBOSE=true
      ;;
    h)
      show_help=true
      ;;
    d)
      show_help=false
      ;;
    \?)
      show_help=true
    ;;
  esac
done

shift $(expr $OPTIND - 1 )  # Strip off options

if [[ $show_help = true ]]; then
  show_deploy_help
  exit 0;
fi

# Only ever want to do this the first time
case $0 in
    /*|~*)
        PROJECT_DIR="$(dirname "$0")"
        ;;
    *)
        PWD="`pwd`"
        PROJECT_DIR="$(dirname "$PWD/$0")"
        ;;
esac

BASE_DIR="$(cd $PROJECT_DIR; pwd -P)"  # Setting BASEDIR to something like /Users/<userName>/projects/zsh-dotfiles/

deploy_links_and_folders

setting_up_sublime_key_mappings_file


if [ "$VERBOSE" = true ]; then
  users_response=$(check_user_wants_to_proceed "\n\nRestart zsh to apply the .files" )
  if [ "$users_response" -eq "$USER_ANSWER_NO" ]; then
    echo "Exiting...  you will need to reload manually (ie. by running 'exec zsh')."
    exit 0;
  fi
fi

echo -en "\n\nReloading by running 'exec zsh'\n\n" && exec zsh
#! /bin/bash
set -eu

# Credit: Original version found here: https://github.com/jeffaco/dotfiles/blob/master/nix/bootstrap.sh

# Set up soft links from files to their destination (in home directory)

# Note: /bin/bash is required for ~/.* expansion in loop below

# Can't use something like 'readlink -e $0' because that doesn't work everywhere
# And HP doesn't define $PWD in a sudo environment, so we define our own

function check_for_and_remove_symlinks() {
  TARGET_FILE=$1
  if [ -f "$TARGET_FILE" ] || [ -h "$TARGET_FILE" ]; then
#    echo "Replacing file: $TARGET_FILE"
    rm "$TARGET_FILE"
  else
    echo "Creating the link for $TARGET_FILE"
  fi
}

function symlink_my_zsh_extensions() {
  EXTENSIONS_DIR="$BASE_DIR/extensions/"
  PLUGINS_DIR="$BASE_DIR/plugins"
  ZSHRC_FILE_IN_PROJECT="$BASE_DIR/.zshrc"
  CONFIG_FOLDER_IN_HOME="$HOME/.zsh_config"
  PLUGIN_FOLDER_IN_HOME="$HOME/.zsh_plugins"
  ZSHRC_FILE_IN_HOME_FOLDER="$HOME/.zshrc"

  echo -e "\n\n"
  echo "PROJECT_FOLDER             : $PROJECT_FOLDER";
  echo "BASE_DIR                   : $BASE_DIR";
  echo "EXTENSIONS_DIR             : $EXTENSIONS_DIR";
  echo "PLUGINS_DIR                : $PLUGINS_DIR";
  echo "PLUGIN_FOLDER_IN_HOME      : $PLUGIN_FOLDER_IN_HOME";
  echo "ZSHRC_FILE_IN_PROJECT      : $ZSHRC_FILE_IN_PROJECT";
  echo "CONFIG_FOLDER_IN_HOME      : $CONFIG_FOLDER_IN_HOME";
  echo "ZSHRC_FILE_IN_HOME_FOLDER  : $ZSHRC_FILE_IN_HOME_FOLDER";
  echo -e "\n"

  echo -e "\nDeploying .zshrc and all my extension files...\n"

  test -d "$CONFIG_FOLDER_IN_HOME" || echo -e "\nCreating folder $CONFIG_FOLDER_IN_HOME\n" && mkdir -p "$CONFIG_FOLDER_IN_HOME" || echo "Problems creating $CONFIG_FOLDER_IN_HOME mkdir failed with: $? "

  check_for_and_remove_symlinks "$ZSHRC_FILE_IN_HOME_FOLDER"
  echo "Creating the link $ZSHRC_FILE_IN_PROJECT -> $ZSHRC_FILE_IN_HOME_FOLDER"
  ln -s "$ZSHRC_FILE_IN_PROJECT" "$ZSHRC_FILE_IN_HOME_FOLDER"


  # 'deploy' the dotfiles to the users home dir by symlinking them to the project location eg. ~/.aliases_extension -> <this_projects_location>/.aliases_extension
  for i in "$EXTENSIONS_DIR".* ; do
    [ ! -f $i ]  && continue    # Ignore anything that is not a file
    SOURCE_DIR=`dirname $i`
    DOT_FILE=`basename $i`
    SOURCE_FILE="$SOURCE_DIR/$DOT_FILE"
    TARGET_FILE="$CONFIG_FOLDER_IN_HOME/$DOT_FILE"
    check_for_and_remove_symlinks "$TARGET_FILE"
    echo "Creating the link $TARGET_FILE -> $SOURCE_FILE"
    ln -s "$SOURCE_FILE" "$TARGET_FILE"
  done
}



function setting_up_syntax_highlighting() {
  SYNTAX_HIGHLIGHTING_PLUGIN="$PLUGIN_FOLDER_IN_HOME/.zsh-syntax-highlighting.zsh"
  #Only have one plugin atm - and that has to be the last sourced file in .zshrc so cant do it dynamically
  test -d "$PLUGIN_FOLDER_IN_HOME" || echo "Creating $PLUGIN_FOLDER_IN_HOME" && mkdir -p "$PLUGIN_FOLDER_IN_HOME"
  check_for_and_remove_symlinks "$SYNTAX_HIGHLIGHTING_PLUGIN"
  ln -s  "$PLUGINS_DIR/zsh-syntax-highlighting.zsh" "$SYNTAX_HIGHLIGHTING_PLUGIN"
}

function setting_up_sublime_key_mappings_file() {
  set +e #Temprarily allow a command to fail without exiting the script.
  SUBLIME_KEYMAP_FOLDER=$(find ~/Library/Application\ Support/Sublime* | grep '/Packages/User' | head -n1)
  set -e
  if [[ -d "$SUBLIME_KEYMAP_FOLDER" ]]; then
    set +e #Temprarily allow a command to fail without exiting the script.
    SUBLIME_KEYMAP_FILE=$(find "$SUBLIME_KEYMAP_FOLDER" |  grep '/Default (OSX).sublime-keymap$')
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
      echo "Copying $MY_SUBLIME_KEYMAP_FILE to $SUBLIME_KEYMAP_FOLDER"
      cp "$MY_SUBLIME_KEYMAP_FILE" "$SUBLIME_KEYMAP_FOLDER"
    fi
  else
    echo "Sublime folder not found, not setting the keymap file."
  fi

}


#### Script starts here ########
# Only ever want to do this the first time
case $0 in
    /*|~*)
        PROJECT_FOLDER="$(dirname "$0")"
        ;;
    *)
        PWD="`pwd`"
        PROJECT_FOLDER="$(dirname "$PWD/$0")"
        ;;
esac

BASE_DIR="$(cd $PROJECT_FOLDER; pwd -P)"  # Setting BASEDIR to something like /Users/<userName>/projects/zsh-dotfiles/
symlink_my_zsh_extensions
setting_up_syntax_highlighting
setting_up_sublime_key_mappings_file

echo -e ""
echo -e ""
echo -e "Restarting zsh to apply the .files in 3"
sleep 1
echo -e "                                      2"
sleep 1
echo -e "                                      1"
sleep 1

echo -n 'Reloading' && exec zsh
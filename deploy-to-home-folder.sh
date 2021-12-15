#! /bin/bash
set -eu

# Credit: Original version found here: https://github.com/jeffaco/dotfiles/blob/master/nix/bootstrap.sh

# Set up soft links from files to their destination (in home directory)

# Note: /bin/bash is required for ~/.* expansion in loop below

# Can't use something like 'readlink -e $0' because that doesn't work everywhere
# And HP doesn't define $PWD in a sudo environment, so we define our own

function check_for_and_remove_symlinks() {
  TARGET_FILE=$1
  if [ -f "$TARGET_FILE" -o -h "$TARGET_FILE" ]; then
#    echo "Replacing file: $TARGET_FILE"
    rm "$TARGET_FILE"
  else
    echo "Creating the link $i -> $TARGET_FILE"
  fi
}

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


SYNTAX_HIGHLIGHTING_PLUGIN="$PLUGIN_FOLDER_IN_HOME/.zsh-syntax-highlighting.zsh"
#Only have one plugin atm - and that has to be the last sourced file in .zshrc so cant do it dynamically
test -d "$PLUGIN_FOLDER_IN_HOME" || echo "Creating $PLUGIN_FOLDER_IN_HOME" && mkdir -p "$PLUGIN_FOLDER_IN_HOME"
check_for_and_remove_symlinks "$SYNTAX_HIGHLIGHTING_PLUGIN"
ln -s  "$PLUGINS_DIR/zsh-syntax-highlighting.zsh" "$SYNTAX_HIGHLIGHTING_PLUGIN"


echo -n 'Reloading' && exec zsh
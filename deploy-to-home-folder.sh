#! /bin/bash
set -eu

# Credit: Original version found here: https://github.com/jeffaco/dotfiles/blob/master/nix/bootstrap.sh

# Set up soft links from files to their destination (in home directory)

# Note: /bin/bash is required for ~/.* expansion in loop below

# Can't use something like 'readlink -e $0' because that doesn't work everywhere
# And HP doesn't define $PWD in a sudo environment, so we define our own

function chek_for_and_remove_symlinks() {
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

# Setting BASEDIR to something like /Users/<userName>/projects/zsh-dotfiles/
BASE_DIR="$(cd $PROJECT_FOLDER; pwd -P)"
EXTENSIONS_DIR="$BASE_DIR/extensions/"
ZSHRC_FILE="$BASE_DIR/.zshrc"
TARGET_DIR="$HOME/.zsh_config/"


echo -e "\nDeploying .zshrc and all my extension files...\n"

test -d "$TARGET_DIR"] || echo "Creating $TARGET_DIR" && mkdir -p "$TARGET_DIR"
chek_for_and_remove_symlinks "$HOME/.zshrc"
ln -s "$ZSHRC_FILE" "$HOME/.zshrc"

# 'deploy' the dotfiles to the users home dir by symlinking them to the project location eg. ~/.aliases_extension -> <this_projects_location>/.aliases_extension
for i in "$EXTENSIONS_DIR".* ; do
  [ ! -f $i ]  && continue    # Ignore anything that is not a file
  SOURCE_DIR=`dirname $i`
  DOT_FILE=`basename $i`
  SOURCE_FILE="$SOURCE_DIR/$DOT_FILE"
  TARGET_FILE="$TARGET_DIR/$DOT_FILE"
  chek_for_and_remove_symlinks "$TARGET_FILE"
  echo "ln -s $SOURCE_FILE $TARGET_FILE"
  ln -s "$SOURCE_FILE" "$TARGET_FILE"
done

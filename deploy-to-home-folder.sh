#! /bin/bash

# Credit: Original version found here: https://github.com/jeffaco/dotfiles/blob/master/nix/bootstrap.sh

# Set up soft links from files to their destination (in home directory)

# Note: /bin/bash is required for ~/.* expansion in loop below

# Can't use something like 'readlink -e $0' because that doesn't work everywhere
# And HP doesn't define $PWD in a sudo environment, so we define our own

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
BASE_DIR="`(cd \"$PROJECT_FOLDER\"; pwd -P)`"

# 'deploy' the dotfiles to the users home dir by symlinking them to the project location eg. ~/.aliases -> <this_projects_location>/.aliases
for i in "$BASE_DIR"/.{aliases,zshrc,ig_functions}; do


  [ ! -f $i ] && echo "$i does not exist continuing..." && continue

#  DOT_FILE_DIR=`dirname $i`
  DOT_FILE=`basename $i`
  TARGET_FILE=$HOME/$DOT_FILE

    echo "Deploying $DOT_FILE"


  if [ -f "$TARGET_FILE" -o -h "$TARGET_FILE" ]; then
#    echo "Replacing file: $TARGET_FILE"
    rm "$TARGET_FILE"
  else
    echo "Creating the link $i -> $TARGET_FILE"
  fi

  ln -s "$i" "$TARGET_FILE"
done

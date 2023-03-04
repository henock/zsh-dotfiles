#! /bin/bash
set -eu
# Note: /bin/bash is required for ~/.* expansion in loop below


# Credit: Original version found here: https://github.com/jeffaco/dotfiles/blob/master/nix/bootstrap.sh

# Set up soft links from files to their destination (in home directory)

# Can't use something like 'readlink -e $0' because that doesn't work everywhere
# And HP doesn't define $PWD in a sudo environment, so we define our own

function create_or_replace_symlinks() {
  #  Symlink can't simply be overwritten, we first remove the one present before we can link a new file.
  TARGET_FILE=$1
  SOURCE_FILE=$2
  if [ -f "$TARGET_FILE" ] || [ -h "$TARGET_FILE" ]; then
    echo "Removing file: $TARGET_FILE"
    rm "$TARGET_FILE"
  fi
  echo "Creating the link $TARGET_FILE -> $SOURCE_FILE"
  ln -s "$SOURCE_FILE" "$TARGET_FILE"
}

function check_with_user_and_remove() {
  TARGET_FILE="$1"
  if [ -e "$TARGET_FILE" ]; then
    LS_OF_TARGET_FILE="\n\n$(ls -la $1)\n\n"
    if [ -d "$TARGET_FILE" ]; then
      DELETE="$(check_user_wants_to_proceed Do you want to delete the directory $TARGET_FILE and all its contents)"
      if [[ $DELETE -eq 1 ]]; then
        echo "Deleting dir: $TARGET_FILE"
        rm -rf "$TARGET_FILE"
      fi
    elif  [ -h "$TARGET_FILE" ]; then
      DELETE="$(check_user_wants_to_proceed Do you want to unlink $LS_OF_TARGET_FILE)"
      if [[ $DELETE -eq 1 ]]; then
        echo "Unlinking: $TARGET_FILE"
        unlink "$TARGET_FILE"
      fi
    elif  [ -f "$TARGET_FILE" ]; then
      DELETE="$(check_user_wants_to_proceed Do you want to delete $LS_OF_TARGET_FILE)"
      if [[ $DELETE -eq 1 ]]; then
        echo "Deleting file $TARGET_FILE"
        rm "$TARGET_FILE"
      fi
    fi
  fi
}

function check_user_wants_to_proceed() {
  PROMPT=$@
  echo -e "$PROMPT [y/n]: "  > /dev/tty
  read USER_ANSWER
  if [[ "y" == "$USER_ANSWER" ]]; then
    echo 1;
  else
    echo 0;
  fi
}

function symlink_my_zsh_extensions() {
  EXTENSIONS_DIR="$BASE_DIR/extensions/"
  PLUGINS_DIR="$BASE_DIR/plugins/"
  ZSHRC_FILE_IN_PROJECT="$BASE_DIR/.zshrc"
  EXTENSIONS_DIR_IN_HOME="$HOME/.zsh_extensions"
  PLUGIN_DIR_IN_HOME="$HOME/.zsh_plugins"
  ZSHRC_FILE_IN_HOME_DIR="$HOME/.zshrc"

  echo -e "\n\n"
  echo -e "Source files/folder...\n"
  echo "BASE_DIR                   : $BASE_DIR";
  echo "PROJECT_DIR                : $PROJECT_DIR";
  echo "ZSHRC_FILE_IN_PROJECT      : $ZSHRC_FILE_IN_PROJECT";
  echo "PLUGINS_DIR                : $PLUGINS_DIR";
  echo "EXTENSIONS_DIR             : $EXTENSIONS_DIR";

  echo -e "\nTarget files/folder...\n"

  echo "PLUGIN_DIR_IN_HOME         : $PLUGIN_DIR_IN_HOME";
  echo "EXTENSIONS_DIR_IN_HOME     : $EXTENSIONS_DIR_IN_HOME";
  echo "ZSHRC_FILE_IN_HOME_DIR     : $ZSHRC_FILE_IN_HOME_DIR";
  echo -e "\n"

  PROCEED=$(check_user_wants_to_proceed "Do you want to deploy to target folders")
  if [ "$PROCEED" -eq 0 ]; then
    echo "Exiting."
    exit 0;
  fi

  check_with_user_and_remove "$ZSHRC_FILE_IN_HOME_DIR"
  check_with_user_and_remove "$EXTENSIONS_DIR_IN_HOME"
  check_with_user_and_remove "$PLUGIN_DIR_IN_HOME"

  echo -e "\nDeploying .zshrc and all my extension files...\n"

  test -d "$EXTENSIONS_DIR_IN_HOME" \
      || echo -e "\nCreating folder $EXTENSIONS_DIR_IN_HOME\n" \
      && mkdir -p "$EXTENSIONS_DIR_IN_HOME" \
      || echo "Problems creating $EXTENSIONS_DIR_IN_HOME mkdir failed with: $? "

  create_or_replace_symlinks "$ZSHRC_FILE_IN_HOME_DIR" "$ZSHRC_FILE_IN_PROJECT"


  # 'deploy' the dotfiles to the users home dir by symlinking them to the project location eg. ~/.aliases_extension -> <this_projects_location>/.aliases_extension
  for i in "$EXTENSIONS_DIR".* ; do
    [ ! -f $i ]  && continue    # Ignore anything that is not a file
    SOURCE_DIR=`dirname $i`
    DOT_FILE=`basename $i`
    SOURCE_FILE="$SOURCE_DIR/$DOT_FILE"
    TARGET_FILE="$EXTENSIONS_DIR_IN_HOME/$DOT_FILE"
    create_or_replace_symlinks "$TARGET_FILE" "$SOURCE_FILE"
  done
}



function setting_up_syntax_highlighting() {
  SYNTAX_HIGHLIGHTING_PLUGIN="$PLUGIN_DIR_IN_HOME/.zsh-syntax-highlighting.zsh"
  #Only have one plugin atm - and that has to be the last sourced file in .zshrc so cant do it dynamically
  test -d "$PLUGIN_DIR_IN_HOME" || echo "Creating $PLUGIN_DIR_IN_HOME" && mkdir -p "$PLUGIN_DIR_IN_HOME"
  create_or_replace_symlinks "$SYNTAX_HIGHLIGHTING_PLUGIN" "$PLUGINS_DIR/zsh-syntax-highlighting.zsh"
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

# Only ever want to do this the first time
function copy_vim_files_to_root(){
  #Copy .vim files to home folder
  cp ./.vim/.vimrc/ ~/.vimrc
  cp -r ./.vim/.gvimrc/ ~/.gvimrc

  #Copy .vim/<folders> to ~/.vim/<folders>
  cp -r ./.vim/backups/ ~/.vim/backups
  cp -r ./.vim/colors ~/.vim/colors
  cp -r ./.vim/syntax/ ~/.vim/syntax
  cp -r ./.vim/swaps/ ~/.vim/swaps
  cp -r ./.vim/undo/ ~/.vim/undo
}

function setting_up_vim() {
  if [ ! -e ~/.vim/swaps/ ]; then
      echo ".vim folder not set up yet.. find ~/.vim looks like so"
      find ~/.vim
    read -p "Do you want me to copy over .vim/<folders>  (backups|colors|swaps|syntax|undo) into ~ (y/n) " -n 1;
    echo "";
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      copy_vim_files_to_root;
      source ~/.vimrc
      source ~/.gvimrc
    fi;
  fi
}


#### Script starts here ########
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
symlink_my_zsh_extensions
setting_up_vim
setting_up_syntax_highlighting
setting_up_sublime_key_mappings_file


PROCEED=$(check_user_wants_to_proceed "Restart zsh to apply the .files" )
if [ "$PROCEED" -eq 0 ]; then
  echo "Exiting."
  exit 0;
fi

echo -n 'Reloading' && exec zsh
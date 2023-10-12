#! /bin/bash

# Reset
Colour_Off="\033[0m"       # Text Reset

# Regular Colors
Black="\033[30m"        # Black
Red="\033[31m"          # Red
Green="\033[32m"        # Green
Yellow="\033[33m"       # Yellow
Blue="\033[34m"         # Blue
Purple="\033[35m"       # Purple
Cyan="\033[36m"         # Cyan
White="\033[37m"        # White

# Background
On_Black="\033[40m"       # Black
On_Red="\033[41m"         # Red
On_Green="\033[42m"       # Green
On_Yellow="\033[43m"      # Yellow
On_Blue="\033[44m"        # Blue
On_Purple="\033[45m"      # Purple
On_Cyan="\033[46m"        # Cyan
On_White="\033[47m"       # White

function set_project_dirs() {
  PWD="`pwd`"
  PROJECT_DIR="$(dirname "$PWD/$0")"
  BASE_DIR="$(cd $PROJECT_DIR; pwd -P)"  # Setting BASE_DIR to something like /Users/<userName>/projects/zsh-dotfiles/
  LOCAL_USERS_HOME_DIR="$BASE_DIR/users-home-dir"

  if [ "$RUN_AS_TEST" = true ]; then
    USERS_HOME="$BASE_DIR/TEST"
    mkdir -p "$USERS_HOME"
  else
    USERS_HOME="$HOME"
  fi
}

function check_with_user_and_remove() {
  local target_file="$1"
  local ls_of_target_file
  if [ -e "$target_file" ]; then
    ls_of_target_file="\n\n$(ls -la $1)\n"
    if [ -d "$target_file" ]; then
       echo ""
       read -p "Do you want to delete the directory $target_file and all its contents [y/n]: " reply
      if [[ $reply =~ ^[Yy]$ ]]; then
        echo_in_verbose_mode "Deleting dir:  $(ls -la $target_file)"
        rm -rf "$target_file"
      else
        echo -e "\nExiting please deal with $target_file and restart."
        exit 0;
      fi
    elif  [ -h "$target_file" ]; then
      echo ""
      read -p "Do you want to unlink $ls_of_target_file [y/n]: " reply
      if [[  $reply =~ ^[Yy]$ ]]; then
        echo_in_verbose_mode "Unlinking: $target_file"
        unlink "$target_file"
      else
        echo -e "\nExiting please deal with $target_file and restart."
        exit 0;
      fi
    elif  [ -f "$target_file" ]; then
      echo ""
      read -p "Do you want to delete $ls_of_target_file [y/n]: " reply
      if [[  $reply =~ ^[Yy]$ ]]; then
        echo_in_verbose_mode "Deleting file $target_file"
        rm "$target_file"
      else
        echo -e "\nExiting please deal with $target_file and restart."
        exit 0;
      fi
    fi
  fi
}


function echo_in_verbose_mode() {
  if [[ "$VERBOSE" = true ]]; then
    echo -e "$1"
  fi
}

function short_date() {
  echo "$(date '+%Y.%m.%d%n')"
}
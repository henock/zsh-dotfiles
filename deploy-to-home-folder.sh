#! /bin/bash

source extensions/.utils.zsh

# Note: /bin/bash is required for ~/.* expansion in loop below


# Credit: Original version found here: https://github.com/jeffaco/dotfiles/blob/master/nix/bootstrap.sh

# Set up soft links from files to their destination (in home directory)

# Can't use something like 'readlink -e $0' because that doesn't work everywhere
# And HP doesn't define $PWD in a sudo environment, so we define our own

function upsert_symlink() {
  #  Symlink can't simply be overwritten, we first remove the one present before we can link a new file.
  local target_file=$1
  local source_file=$2
  
  if [ -f "$target_file" ] || [ -h "$target_file" ]; then
    echo_in_verbose_mode "Removing file: $target_file"
    rm "$target_file"
  fi
  echo_in_verbose_mode "Creating the link $target_file -> $source_file"
  ln -s "$source_file" "$target_file"
}

function check_with_user_and_backup() {
  local target_file="$1"
  local backup_destination="$2"
  if [ -e "$target_file" ]; then
    local ls_of_target_file="\n\n$(ls -la $1)\n\n"
    if  [ -f "$target_file" ]; then
      if [ "$#" -eq 1 ]; then
        local back_up_name_extension=$(short_date)
        backup_destination="$target_file.bak.$back_up_name_extension"
      fi
      local users_response="$(check_user_wants_to_proceed_allow_for_default Do you want to backup $ls_of_target_file to $backup_destination)"
      if [[ "$users_response" -eq "$USER_ANSWER_YES" ]]; then
        echo_in_verbose_mode "Backing up file $target_file to $backup_destination"
        cp "$target_file" "$backup_destination"
      fi
    fi
  fi
}

function display_file_and_its_existence(){
  local file="$1"
  local file_prefix_comment

  if [ "$#" -eq 2 ]; then
    file_prefix_comment="$2"
  else
    file_prefix_comment=""
  fi
  local existence=" Will be \033[31mreplaced\033[0m :"
  if [ ! -e "$file" ]; then
    existence=" Will be \033[32mcreated\033[0m  :"
  fi
  echo -e "$existence $file_prefix_comment $file"
}

function create_folder_if_it_does_exist() {
  local folder="$1"
  if [ ! -d "$folder" ]; then
    mkdir "$folder"
  fi
}

function deploy_links_and_folders() {
  local plugins_dir="$BASE_DIR/plugins"
  local extensions_dir="$BASE_DIR/extensions/"
  local vim_files_dir="$BASE_DIR/vim-files-for-users-home-dir/"
  local vim_folders="$BASE_DIR/vim-folders"
  local syntax_highlighting_file=".zsh-syntax-highlighting.zsh"
  local zshrc_files_dir="$BASE_DIR/zshrc-files-for-users-home-dir/"

  local syntax_highlighting_file_in_project_dir="$plugins_dir/$syntax_highlighting_file"

  local vim_dir_in_home="$HOME/.vim"
  local plugin_dir_in_home="$HOME/.zsh_plugins"
  local extensions_dir_in_home="$HOME/.zsh_extensions"
  local zshrc_file_in_home_dir="$HOME/.zshrc"
  local syntax_highlighting_file_in_home_dir="$plugin_dir_in_home/$syntax_highlighting_file"

  echo -e "\nPath where the zsh-dotfiles actually sit  :  $BASE_DIR\n";
  display_file_and_its_existence "$vim_dir_in_home"
  display_file_and_its_existence "$plugin_dir_in_home"
  display_file_and_its_existence "$extensions_dir_in_home"
  display_file_and_its_existence "$zshrc_file_in_home_dir"
  display_file_and_its_existence "$syntax_highlighting_file_in_home_dir"

  echo -e "\n"

  users_response=$(check_user_wants_to_proceed_allow_for_default "Do you want to deploy with config above")
  if [ "$users_response" -eq "$USER_ANSWER_NO" ]; then
    echo "Exiting."
    exit 0;
  fi

  if [[ "$SILENT" = false ]]; then
    users_response=$(check_user_wants_to_proceed "Prompt before changes" )
    if [ "$users_response" -eq "$USER_ANSWER_NO" ]; then
      SILENT=true
    fi
  fi

  check_with_user_and_remove "$vim_dir_in_home"
  check_with_user_and_remove "$plugin_dir_in_home"
  check_with_user_and_remove "$extensions_dir_in_home"

  check_with_user_and_backup "$zshrc_file_in_home_dir"
  check_with_user_and_remove "$syntax_highlighting_file_in_home_dir"

  create_folder_if_it_does_exist "$plugin_dir_in_home"
  create_folder_if_it_does_exist "$extensions_dir_in_home"
  create_folder_if_it_does_exist "$vim_dir_in_home"
  create_folder_if_it_does_exist "$vim_dir_in_home/backups"
  create_folder_if_it_does_exist "$vim_dir_in_home/swaps"
  create_folder_if_it_does_exist "$vim_dir_in_home/undo"
  create_folder_if_it_does_exist "$vim_dir_in_home/colors"
  create_folder_if_it_does_exist "$vim_dir_in_home/syntax"

  symlink_files_in_folder "$zshrc_files_dir" "$HOME" "$TRUE"
  symlink_files_in_folder "$vim_files_dir" "$HOME" "$TRUE"
  symlink_files_in_folder "$extensions_dir" "$extensions_dir_in_home" "$TRUE"
  symlink_files_in_folder "$vim_folders/colors" "$vim_dir_in_home/colors" "$FALSE"
  symlink_files_in_folder "$vim_folders/syntax" "$vim_dir_in_home/syntax" "$FALSE"

  upsert_symlink "$syntax_highlighting_file_in_home_dir" "$plugins_dir/zsh-syntax-highlighting.zsh"
}


function symlink_files_in_folder() {
  local source_dir="$1"
  local destination_dir="$2"
  local dot_files="$3"
  local source_path="$source_dir/*"
  create_folder_if_it_does_exist "$destination_dir"
  if [ "$dot_files" -eq "$TRUE" ]; then
    source_path="$source_dir.*"
  fi
  echo -e "\nSymlinking files in folder: $source_path -> $destination_dir"
  for i in $source_path ; do
    [ ! -f $i ]  && continue    # Ignore anything that is not a file
    source_dir=`dirname $i`
    local dot_file=`basename $i`
    local source_file="$source_dir/$dot_file"
    local target_file="$destination_dir/$dot_file"
    echo_in_verbose_mode "        Symliking file: $source_file -> $target_file"
    upsert_symlink "$target_file" "$source_file"
  done
}


function setting_up_sublime_key_mappings_file() {
  set +e #Temprarily allow a command to fail without exiting the script.
  local sublime_keymap_dir=$(find ~/Library/Application\ Support/Sublime* | grep '/Packages/User' | head -n1)
  set -eu
  if [[ -d "$sublime_keymap_dir" ]]; then
    set +e #Temprarily allow a command to fail without exiting the script.
    local sublime_keymap_file=$(find "$sublime_keymap_dir" |  grep '/Default (OSX).sublime-keymap$')
    set -eu
    local my_sublime_keymap_file="$BASE_DIR/sublime/Default (OSX).sublime-keymap"
    local perform_copy=-1
    if [ -f "$sublime_keymap_file" ]; then
      if ! diff "$sublime_keymap_file" "$my_sublime_keymap_file"; then
        local back_up_name_extension=$(short_date)
        local back_up_file="$sublime_keymap_file.bak-$back_up_name_extension"
        echo "Found a sublime keymap file different to mine (above is the difference) backed it up to $back_up_file"
        mv "$sublime_keymap_file" "$back_up_file"
        echo "And replacing it with mine"
        perform_copy=0
      fi
    else
      echo "Sublime keymap not found, copying in mine"
      perform_copy=0
    fi

    if [ "$perform_copy" -eq 0 ]; then
      echo "Copying $my_sublime_keymap_file to $sublime_keymap_dir"
      cp "$my_sublime_keymap_file" "$sublime_keymap_dir"
    fi
  else
    echo "Sublime folder not found, not setting the keymap file."
  fi
}

function show_deploy_help() {
  local bold_font=$(tput bold)
  local normal_font=$(tput sgr0)
  echo -e ""
  echo -e "${bold_font}SYNOPSIS${normal_font}"
  echo -e ""
  echo -e "    ./deploy-to-home-folder.sh [options] <project dir - defaults to current>"
  echo -e ""
  echo -e "${bold_font}DESCRIPTION${normal_font}"
  echo -e ""
  echo -e "  The ${bold_font}deploy-to-home-folder.sh${normal_font} script deploys the .zsh-dotfiles to your home folder. Replacing respective files and folders."
  echo -e ""
  echo -e "  Configured files"
  echo -e ""
  echo -e "  .vim"
  echo -e "      /swaps"
  echo -e "      /undo"
  echo -e "      /colors"
  echo -e "      /colors/solarized.vim -----------------------> {path to zsh-dotfiles}/solarized.vim"
  echo -e "      /syntax"
  echo -e "      /syntax/json.vim ----------------------------> {path to zsh-dotfiles}/json.vim"
  echo -e "      /backups"
  echo -e "  .zshrc -------------------------------------------> {path to zsh-dotfiles}/zshrc-files-for-users-home-dir/.zshrc"
  echo -e "  .gvimrc ------------------------------------------> {path to zsh-dotfiles}/vim-files-for-users-home-dir/.gvimrc"
  echo -e "  .vimrc -------------------------------------------> {path to zsh-dotfiles}/vim-files-for-users-home-dir/.vimrc"
  echo -e "  .zsh_extensions/{bunch of extensions files} ------> {path to zsh-dotfiles}/{bunch of extensions files}"
  echo -e "  .zsh_plugins/{bunch of plugins files} ------------> {path to zsh-dotfiles}/{bunch of plugins files}"
  echo -e ""
  echo -e "    The following options are available: \n"
  echo -e "    ${bold_font}-h${normal_font}     show this help page\n"
  echo -e "    ${bold_font}-v${normal_font}     verbose mode  - Is verbose when performing actions (takes precedence over silent mode).\n"
  echo -e "    ${bold_font}-S${normal_font}     silent mode - asks no questions\n"
  echo -e "    ${bold_font}-d${normal_font}     deploy files  - Actually deploys the zsh-dot files to your home folder and loads them in (does not work when in preview mode).\n"
}

function deal_with_options() {
  local show_help=true

  while getopts "vhdS" option; do
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
    show_deploy_help
    exit 0;
  fi
}


function set_project_dirs() {
  PWD="`pwd`"
  PROJECT_DIR="$(dirname "$PWD/$0")"
  BASE_DIR="$(cd $PROJECT_DIR; pwd -P)"  # Setting BASEDIR to something like /Users/<userName>/projects/zsh-dotfiles/
}

function reload_zsh() {
  if [ "$VERBOSE" = true ]; then
    users_response=$(check_user_wants_to_proceed "\n\nRestart zsh to apply the .files" )
    if [ "$users_response" -eq "$USER_ANSWER_NO" ]; then
      echo "Exiting...  you will need to reload manually (ie. by running 'exec zsh')."
      exit 0;
    fi
  fi

  echo -en "\n\nReloading by running 'exec zsh'\n\n" && exec zsh
}

function run_script() {
  VERBOSE=false
  SILENT=false
  TRUE=0
  FALSE=1
  USER_ANSWER_YES=1
  USER_ANSWER_NO=2
  show_help=true


  deal_with_options "$@"
  set_project_dirs "$@"
  deploy_links_and_folders
  reload_zsh
  setting_up_sublime_key_mappings_file
}


############################################################
#######           SCRIPT STARTS HERE                 ########
############################################################

run_script "$@"
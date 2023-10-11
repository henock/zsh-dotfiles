#! /bin/bash

source users-home-dir/.zsh_extensions/.utils.zsh

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
  if [[ -e "$target_file" ]]; then
    echo_in_verbose_mode "$target_file exists"
    if [ "$#" -eq 1 ]; then
      local back_up_name_extension=$(short_date)
      local backup_destination="$target_file.$back_up_name_extension.bak"
    fi

    if [[ -d "$target_file" ]]; then
      local users_response=$(check_user_wants_to_proceed "\n\nDo you want to backup \(by moving\) dir \n$target_file to\n$backup_destination")
      if [[ "$users_response" -eq "$USER_ANSWER_YES" ]]; then
        echo_in_verbose_mode "\n\nBacking up dir \n$target_file to \n$backup_destination"
        mv -f "$target_file" "$backup_destination"
      fi
    elif [[ -f "$target_file" ]]; then
      local ls_of_target_file="\n$(ls $1)\n"
      local users_response=$(check_user_wants_to_proceed "\n\nDo you want to backup \(by moving\):\n$target_file to\n$backup_destination")
      if [[ "$users_response" -eq "$USER_ANSWER_YES" ]]; then
        echo_in_verbose_mode "Backing up file $target_file to $backup_desdirn"
        mv -f "$target_file" "$backup_destination"
      fi
    fi
  fi
}

function display_file_and_its_future(){
  local file="$1"
  local file_prefix_comment

  if [ "$#" -eq 2 ]; then
    file_prefix_comment="$2"
  else
    file_prefix_comment=""
  fi
  local existence=" Will be \033[31m backed up and replaced \033[0m :"
  if [ ! -e "$file" ]; then
    existence=" Will be \033[32m created \033[0m                :"
  fi
  echo -e "$existence $file_prefix_comment $file"
}

function create_dir_if_it_does_exist() {
  local dir="$1"
  if [ ! -d "$dir" ]; then
    echo_in_verbose_mode "Creating dir $dir"
    mkdir "$dir"
  fi
}

function create_dir_tree() {
  local local_dir_path="$1"
  local create_dir_in_path="$2"

  echo_in_verbose_mode "create_dir_tree: local_dir_path=$local_dir_path"
  echo_in_verbose_mode "create_dir_tree: create_dir_in_path=$create_dir_in_path"

  if [[ -d "$local_dir_path" ]]; then
    create_dir_if_it_does_exist "$create_dir_in_path"
    if [ "$(ls -A $local_dir_path)" ]; then
      for file in $(ls -A $local_dir_path); do    # colors/syntax
        create_dir_tree "$local_dir_path/$file" "$create_dir_in_path/$file"
      done
    fi
  else
    echo_in_verbose_mode "Not creating dir for $local_dir_path as it not a directory"
  fi
}

function deploy_object() {
    local object="${1}"
    local action="${2}"

    local object_in_users_home="$USERS_HOME/$object"
    local object_in_local_home="$LOCAL_USERS_HOME_DIR/$object"

    if [[ "$action" = "CHECK_STATUS" ]]; then
      display_file_and_its_future "$object_in_users_home"
    elif [[ "$action" = "CREATE_DIRS" ]]; then
      check_with_user_and_backup "$object_in_users_home"
      echo_in_verbose_mode "Creating directories for $object_in_local_home"
      create_dir_tree "$object_in_local_home" "$object_in_users_home"
    elif [[ "$action" = "DEPLOY" ]]; then
      echo_in_verbose_mode "Deploying $object_in_local_home"
      check_with_user_and_backup "$object_in_users_home"
      echo_in_verbose_mode "\nSymlinking: $object_in_users_home -> $object_in_local_home"
      upsert_symlink "$object_in_users_home" "$object_in_local_home"
    fi
}

function deploy_links_and_folders() {
  echo -e "\nPath where the zsh-dotfiles actually sit  :  $LOCAL_USERS_HOME_DIR";
  echo -e "\nPath where we are going to write them to  :  $USERS_HOME\n\n";

  for file in {.vim,.gvimrc,.vimrc,.zsh_extensions,.zsh_plugins,.zshrc}; do
    deploy_object "$file" "CHECK_STATUS"
  done

  users_response=$(check_user_wants_to_proceed "Do you want to deploy with config above")
  if [ "$users_response" -eq "$USER_ANSWER_NO" ]; then
    echo "Exiting."
    exit 0;
  fi

  if [[ "$SILENT" = false ]]; then
    users_response=$(check_user_wants_to_proceed "Do you want a prompt before each backup" )
    if [ "$users_response" -eq "$USER_ANSWER_NO" ]; then
      SILENT=true
    fi
  fi

  deploy_object ".vim" "CREATE_DIRS"

  for file in {.gvimrc,.vimrc,.zsh_extensions,.zsh_plugins,.zshrc,.vim/colors/solarized.vim,.vim/syntax/json.vim}; do
    deploy_object "$file" "DEPLOY"
  done

  create_local_only_extension_file

}

function create_local_only_extension_file() {
    local file_to_create="$LOCAL_USERS_HOME_DIR/.zsh_extensions/.local_only_extension.zsh"
    if [ ! -e "$file_to_create" ]; then
      echo_in_verbose_mode "Creating file: $file_to_create"
      echo "# This file is used to allow you to write functions" >> "$file_to_create"
      echo "# or aliases that you dont want to have in source control" >> "$file_to_create"
    else
      echo -e "\n\n.local_only_extension.zsh file already exists, leaving it alone. \nfull path: $file_to_create\n"
    fi
}

function setting_up_sublime_key_mappings_file() {
  set +e #Temprarily allow a command to fail without exiting the script.
  local sublime_dir="~/Library/Application Support/Sublime"
  set -eu
  if [[ -e "$sublime_dir" ]]; then
    local sublime_keymap_dir=$(find ~/Library/Application\ Support/Sublime* | grep '/Packages/User' | head -n1)
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
      echo "Sublime key map dir not found, not setting the keymap file."
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
  echo -e "    ./deploy-to-home-folder.sh [options]"
  echo -e ""
  echo -e "${bold_font}DESCRIPTION${normal_font}"
  echo -e ""
  echo -e "  The ${bold_font}deploy-to-home-folder.sh${normal_font} script deploys the .zsh-dotfiles to your home folder. Replacing respective files and folders."
  echo -e "  The deployed files are actually symlinked back to the respective files in this project (allowing you to manage them in source control outside your home directory)."
  echo -e ""
  echo -e "  Missing directories are created, files are symlinked."
  echo -e ""
  echo -e "  .vim/"
  echo -e "       |_ backups/"
  echo -e "       |_ colors/"
  echo -e "       |_ colors/solarized.vim ------------------------> {path to zsh-dotfiles}/.vim/colors/solarized.vim"
  echo -e "       |_ swaps/"
  echo -e "       |_ syntax/"
  echo -e "       |_ syntax/json.vim -----------------------------> {path to zsh-dotfiles}/.vim/syntax/json.vim"
  echo -e "       |_ undo/"
  echo -e ""
  echo -e "  .zshrc ----------------------------------------------> {path to zsh-dotfiles}/.zshrc"
  echo -e "  .gvimrc ---------------------------------------------> {path to zsh-dotfiles}/.gvimrc"
  echo -e "  .vimrc ----------------------------------------------> {path to zsh-dotfiles}/.vimrc"
  echo -e "  .zsh_extensions/{bunch of extensions files} ---------> {path to zsh-dotfiles}/.zsh_extensions/{bunch of extensions files}"
  echo -e "  .zsh_plugins/{bunch of plugins files} ---------------> {path to zsh-dotfiles}/.zsh_plugins/{bunch of plugins files}"
  echo -e ""
  echo -e "    The following options are available: \n"
  echo -e "    ${bold_font}-h${normal_font}     show this help page\n"
  echo -e "    ${bold_font}-t${normal_font}     run in test mode (does the work in <project-base-dir>/TEST folder\n"
  echo -e "    ${bold_font}-S${normal_font}     silent mode - asks no questions\n"
  echo -e "    ${bold_font}-v${normal_font}     verbose mode  - Is verbose when performing actions (takes precedence over silent mode).\n"
  echo -e "    ${bold_font}-d${normal_font}     deploy files  - Actually deploys the zsh-dot files to your home folder and loads them in (does not work when in preview mode).\n"
}

function deal_with_options() {
  local show_help=true

  while getopts "vhdtS" option; do
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
      t)
        RUN_AS_TEST=true
        ;;
      S)
        show_help=false
        SILENT=true
        ;;
      ?)  # we only show help for any invalid options
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


function reload_zsh() {
  if [ "$RUN_AS_TEST" = true ]; then
    echo -e "\nNot reloading zsh because we are running as a test\n"
  else
    if [ "$VERBOSE" = true ]; then
      users_response=$(check_user_wants_to_proceed "Restart zsh to apply the .files" )
      if [ "$users_response" -eq "$USER_ANSWER_NO" ]; then
        echo "Exiting...  you will need to reload manually (ie. by running 'exec zsh')."
        exit 0;
      fi
    fi
    echo -en "\n\nReloading by running 'exec zsh'\n\n" && exec zsh
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
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
      local users_response="$(check_user_wants_to_proceed \\n\\nDo you want to backup \(by moving\) dir \\n$target_file to\\n$backup_destination)"
      if [[ "$users_response" -eq "$USER_ANSWER_YES" ]]; then
        echo_in_verbose_mode "\n\nBacking up dir \n$target_file to \n$backup_destination"
        mv -f "$target_file" "$backup_destination"
      fi
    elif [[ -f "$target_file" ]]; then
      local ls_of_target_file="\n$(ls $1)\n"

      local users_response="$(check_user_wants_to_proceed \\n\\nDo you want to backup \(by moving\):\\n$target_file to\\n$backup_destination)"

      if [[ "$users_response" -eq "$USER_ANSWER_YES" ]]; then
        echo_in_verbose_mode "Backing up file $target_file to $backup_desdirn"
        mv -f "$target_file" "$backup_destination"
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
  local existence=" Will be \033[31mbacked up and replaced\033[0m :"
  if [ ! -e "$file" ]; then
    existence=" Will be \033[32mcreated\033[0m  :"
  fi
  echo -e "$existence $file_prefix_comment $file"
}

function create_folder_if_it_does_exist() {
  local folder="$1"
  if [ ! -d "$folder" ]; then
    echo_in_verbose_mode "Creating folder $folder"
    mkdir "$folder"
  fi
}

function create_dir_tree() {
  local local_dir_path="$1"
  local create_dir_in_path="$2"

  echo_in_verbose_mode "create_dir_tree: local_dir_path=$local_dir_path"
  echo_in_verbose_mode "create_dir_tree: create_dir_in_path=$create_dir_in_path"

  if [[ -d "$local_dir_path" ]]; then
    mkdir -p "$create_dir_in_path"
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
      display_file_and_its_existence "$object_in_users_home"
    elif [[ "$action" = "CREATE_DIRS" ]]; then
      echo_in_verbose_mode "Creating directories for $object_in_local_home"
      create_dir_tree "$object_in_local_home" "$object_in_users_home"
    elif [[ "$action" = "DEPLOY" ]]; then
      echo_in_verbose_mode "Deploying $object_in_local_home"
      check_with_user_and_backup "$object_in_users_home"
    fi
}

function deploy_links_and_folders() {

  echo -e "\nPath where the zsh-dotfiles actually sit  :  $LOCAL_USERS_HOME_DIR";
  echo -e "\nPath where we are going to write them to  :  $USERS_HOME\n\n";

  deploy_object ".vim" "CHECK_STATUS"
  deploy_object ".gvimrc" "CHECK_STATUS"
  deploy_object ".vimrc" "CHECK_STATUS"
  deploy_object ".zsh_extensions" "CHECK_STATUS"
  deploy_object ".zshrc" "CHECK_STATUS"

  users_response=$(check_user_wants_to_proceed "Do you want to deploy with config above")
  if [ "$users_response" -eq "$USER_ANSWER_NO" ]; then
    echo "Exiting."
    exit 0;
  fi

  if [[ "$SILENT" = false ]]; then
    users_response=$(check_user_wants_to_proceed "Do you want a prompt before each change" )
    if [ "$users_response" -eq "$USER_ANSWER_NO" ]; then
      SILENT=true
    fi
    echo "SILENT=$SILENT"
  fi

  deploy_object ".vim" "CREATE_DIRS"
  deploy_object ".vim" "DEPLOY"
exit 0
  deploy_object ".gvimrc" "DEPLOY"
  deploy_object ".vimrc" "DEPLOY"
  deploy_object ".zsh_extensions" "DEPLOY"
  deploy_object ".zshrc" "DEPLOY"
  deploy_object ".vim/colors/solarized.vim" "DEPLOY"
  deploy_object ".vim/syntax/json.vim" "DEPLOY"

  symlink_dir "$extensions_dir" "$extensions_dir_in_home"

  symlink_file "$zshrc_file" "$zshrc_file_in_home_dir"
  symlink_file "$vim_dir/colors/solarized.vim" "$vim_dir_in_home/colors/solarized.vim"
  symlink_file "$vim_dir/syntax/json.vim" "$vim_dir_in_home/syntax/json.vim"


#  symlink_file "$syntax_highlighting_file_in_home_dir" "$plugins_dir/zsh-syntax-highlighting.zsh"
}


function symlink_dir() {
  local source_dir="$1"
  local destination_dir="$2"
  echo_in_verbose_mode "\nSymlinking dir: $destination_dir -> $source_dir"
  upsert_symlink "$destination_dir" "$source_dir"
}

function symlink_file() {
  local source_file="$1"
  local destination_file="$2"
  echo_in_verbose_mode "\nSymlinking file: $destination_file -> $source_file"
  upsert_symlink "$destination_file" "$source_file"
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
  echo -e "    ${bold_font}-t${normal_font}     run in test move (does the work in <project-base-dir>/TEST folder\n"
  echo -e "    ${bold_font}-v${normal_font}     verbose mode  - Is verbose when performing actions (takes precedence over silent mode).\n"
  echo -e "    ${bold_font}-S${normal_font}     silent mode - asks no questions\n"
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
  BASE_DIR="$(cd $PROJECT_DIR; pwd -P)"  # Setting BASE_DIR to something like /Users/<userName>/projects/zsh-dotfiles/
  LOCAL_USERS_HOME_DIR="$BASE_DIR/users-home-dir"

  if [ "$RUN_AS_TEST" = true ]; then
    USERS_HOME="$BASE_DIR/TEST"
    mkdir "$USERS_HOME"
  else
    USERS_HOME="$HOME"
  fi
}

function reload_zsh() {
  if [ "$RUN_AS_TEST" = true ]; then
    echo "Not reloading zsh because we are running as a test"
  else
    if [ "$VERBOSE" = true ]; then
      users_response=$(check_user_wants_to_proceed "\n\nRestart zsh to apply the .files" )
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
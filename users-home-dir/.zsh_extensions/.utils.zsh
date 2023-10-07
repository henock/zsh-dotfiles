#! /bin/bash


function check_user_wants_to_proceed() {
  if [[ "$SILENT" = false || "$VERBOSE" = true  ]]; then
    local prompt=$@
    echo -e "$prompt" > /dev/tty
    echo -n "[y/n]: "  > /dev/tty
    read -r user_answer

    if [[ "y" == "$user_answer" ]]; then
      echo "$USER_ANSWER_YES";
    else
      echo "$USER_ANSWER_NO";
    fi
  else
    echo "$USER_ANSWER_YES";
  fi
}

function check_with_user_and_remove() {
  local target_file="$1"
  local users_response
  local ls_of_target_file
  if [ -e "$target_file" ]; then
    ls_of_target_file="\n\n$(ls -la $1)\n\n"
    if [ -d "$target_file" ]; then
      users_response=$(check_user_wants_to_proceed "Do you want to delete the directory $target_file and all its contents")
      if [[ "$users_response" -eq "$USER_ANSWER_YES" ]]; then
        echo_in_verbose_mode "Deleting dir: $target_file"
        rm -rf "$target_file"
      fi
    elif  [ -h "$target_file" ]; then
      users_response=$(check_user_wants_to_proceed "Do you want to unlink $ls_of_target_file")
      if [[ "$users_response" -eq "$USER_ANSWER_YES" ]]; then
        echo_in_verbose_mode "Unlinking: $target_file"
        unlink "$target_file"
      fi
    elif  [ -f "$target_file" ]; then
      users_response=$(check_user_wants_to_proceed "Do you want to delete $ls_of_target_file")
      if [[ "$users_response" -eq "$USER_ANSWER_YES" ]]; then
        echo_in_verbose_mode "Deleting file $target_file"
        rm "$target_file"
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
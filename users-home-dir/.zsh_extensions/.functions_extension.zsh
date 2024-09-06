
hash git &>/dev/null;
if [ $? -eq 0 ]; then
    function gdiff() {
        git diff --no-index --color-words "$@";
    }
fi;


hash jq &>/dev/null;
if [ $? -eq 0 ]; then

  jq_logs_and_errors='grep -io "\"message\":.*\|\"stack_trace\":.*" | sed "s/\\n/\n/g" | sed "s/\\t/\t/g"'

  function jql() {
    while read -r data; do
        printf "%s" "$data" |jq -R -r '. as $line | try from json catch $line'
    done
  }

  function jqlg() {
    if [ $# -ne 1 ]; then    # log level
        echo "Usage:  <kubectl logs...> | jqll <text to grep for>"
    fi
    while read -r data; do
        printf "%s" "$data" | jq -R -r '. as $line | try from json catch $line' | "$jq_logs_and_errors" | grep -i "$2"
    done
  }

  function jqle() {
    while read -r data; do
        if [ $# -eq 1 ]; then    # log level
            printf "%s" "$data" | jq -R -r '. as $line | try from json catch $line' | grep -ib4 "\"level\": \"error\"" | "$jq_logs_and_errors"
        fi
    done
  }

  function jqll() {
    while read -r data; do
        if [ $# -eq 1 ]; then    # log level
            printf "%s" "$data" | jq -R -r '. as $line | try fromjson catch $line' | grep -ib4 "\"level\": \"$1\"" | "$jq_logs_and_errors"
        else
            printf "%s" "$data" | jq -R -r '. as $line | try fromjson catch $line' | grep -io "\"message\":.*\|\"stack_trace\":.*" | sed 's/\\n/\n/g' | sed 's/\\t/\t/g'
        fi
    done
  }
fi


function watch() {
  if [ $# -ne 2 ]; then
    echo -e "\n\nUsage  :  watch <sleep seconds> <command>\n\n"
    echo -e "examples   :  watch 2 ls"
    echo -e "           :  watch 2 'ls -l | grep bob'"
  else
     while :; do
      clear
      date
      echo ""
      bash -c "$2"
      sleep "${1}"
    done
  fi
}


function dos2unix() {
  if [[ $# -eq 0 ]]; then
    echo -e "\nUsage: dos2unix <input-file> [output-file]\n"
    echo -e 'if the [output-file] is omitted then;  $1 convert  "$1.dos-to-unix-step" && mv "$1.dos-to-unix-step" $1'
  elif [[ $# -eq 1 ]]; then
    local dos_to_unis_step_file="$1.dos-to-unix-step"
    cat "$1" | awk '{ sub ("\r$", "" ); print }' > "$dos_to_unis_step_file" && mv "$dos_to_unis_step_file" "$1"
  elif [[ $# -eq 2 ]]; then
    cat "$1" | awk '{ sub ("\r$", "" ); print }' > $2
  fi
}


# `tre` is a shorthand for `tree` with hidden files and color enabled, ignoring
# the `.git` directory, listing directories first. The output gets piped into
# `less` with options to preserve color and line numbers, unless the output is
# small enough for one screen.
function tre() {
    tree -aC -I '.git|node_modules|bower_components|.idea|target' --dirsfirst "$@" | less -FRNX;
}

function replace_spaces_with_dashes() {
    echo "$@" | sed 's/ /-/g'
}

function prefix_zero_to_a_single_digit_if_needed() {
    case "$@"  in
      "1") echo '01';;
      "2") echo '02';;
      "3") echo '03';;
      "4") echo '04';;
      "5") echo '05';;
      "6") echo '06';;
      "7") echo '07';;
      "8") echo '08';;
      "9") echo '09';;
      *) echo "$@"
    esac
}

function get_numeric_month() {
    case "$1"  in
      "Jan") echo '01';;
      "Feb") echo '02';;
      "Mar") echo '03';;
      "Apr") echo '04';;
      "May") echo '05';;
      "Jun") echo '06';;
      "Jul") echo '07';;
      "Aug") echo '08';;
      "Sep") echo '09';;
      "Oct") echo '10';;
      "Nov") echo '11';;
      "Dec") echo '12';;
      *) echo "'$1' cant be converted to a month expected [Jan..Dec]";;
    esac
}

function file_created_date() {
  #The GetFileInfo command is deprecated so 1st check if it still there
  command -v GetFileInfo > /dev/null 2>&1
	if [ $? -eq 1 ]; then
    echo "GetFileInfo not found, exiting"
    say "GetFileInfo not found, exiting"
		exit 1
	fi

	#Output of GetFileInfo is in US date format
  echo $(GetFileInfo -d "$@" | awk '{print $1}' | awk 'BEGIN { FS = "/" }; {print $3 "."  $1 "." $2}')
}

#Rename all files prefixing last modified date and replacing space to have _ instead
function rename_prefixing_created_date_replacing_spaces(){
  for i in "$@"; do
    if [[ -d $i ]] || [[ -f $i ]]; then
      echo_in_verbose_mode "About to rename:     '$i'"
      local new_name="$i"

      if [[ $HAS_REQUESTED_AN_OPTION -eq 0 ]] || [[ $REPLACE_SPACES -eq 1 ]] ; then
        new_name=$(replace_spaces_with_dashes "$i");
      fi

      if [[ $HAS_REQUESTED_AN_OPTION -eq 0 ]] || [[ $PREFIX_DATE -eq 1 ]]; then
        new_name="$(file_created_date "$i")_$new_name"
      fi

      move_file_with_prompt "$i" "$new_name";
    else
      echo "Unhandled file type, skipping '$i'"
    fi
  done
}

function move_file_with_prompt(){
    local from_path="$1"
    local to_path="$2"
    local user_input
    if [[ "$from_path" != "$to_path" ]]; then
      if [[ PROMPT_FOR_CONFIRMATION -eq 1 ]]; then
        echo "Rename: '$from_path' -> '$to_path' [y/n/a]?"
        read -r user_input;
        case "$user_input" in
          "a" | "A")
            PROMPT_FOR_CONFIRMATION=0
            ;& #Fall though
          "y" | "Y")
            mv "$from_path" "$to_path";
            ;;
          *)
            echo "$from_path not moved."
            ;;
        esac
      else
          echo_in_verbose_mode "Renaming: '$from_path' -> '$to_path'."
          mv "$from_path" "$to_path";
      fi
    else
      echo_in_verbose_mode "Skipping renaming: '$from_path' -> '$to_path' as they are identical."
    fi
}

# renames files/folders with <YYYY-MM-DD-original-file-name-with-spaces-replaced-by-dashes>
function rnc(){
  if [ "$#" -eq 0 ]; then
    show_rename_clean_help
  else

    unset VERBOSE
    unset SHOW_HELP
    unset PREFIX_DATE
    unset REPLACE_SPACES
    unset PROMPT_FOR_CONFIRMATION
    unset HAS_REQUESTED_AN_OPTION

    HAS_REQUESTED_AN_OPTION=0
    PROMPT_FOR_CONFIRMATION=1

    while getopts "vrhdp" option; do
      case $option in
        v)
          VERBOSE=true
          ;;
        r)
          REPLACE_SPACES=1
          HAS_REQUESTED_AN_OPTION=1
          ;;
        h)
          SHOW_HELP=1
          ;;
        d)
          PREFIX_DATE=1
          HAS_REQUESTED_AN_OPTION=1
          ;;
        p)
          PROMPT_FOR_CONFIRMATION=1
          ;;
        \?)
          SHOW_HELP=1
        ;;
      esac
    done

    shift $(expr $OPTIND - 1 )  # Strip off options

    if [[ $SHOW_HELP -eq 1 ]]; then
      show_rename_clean_help
      return 1;
    else


      echo_in_verbose_mode "Calling with VERBOSE=$VERBOSE"
      echo_in_verbose_mode "Calling with SHOW_HELP=$SHOW_HELP"
      echo_in_verbose_mode "Calling with PREFIX_DATE=$PREFIX_DATE"
      echo_in_verbose_mode "Calling with REPLACE_SPACES=$REPLACE_SPACES"
      echo_in_verbose_mode "Calling with PROMPT_FOR_CONFIRMATION=$PROMPT_FOR_CONFIRMATION"
      echo_in_verbose_mode "Calling with HAS_REQUESTED_AN_OPTION=$HAS_REQUESTED_AN_OPTION"
      rename_prefixing_created_date_replacing_spaces "$@"
    fi
  fi
}

function show_rename_clean_help() {
  local bold_font=$(tput bold)
  local normal_font=$(tput sgr0)
  echo -e ""
  echo -e "${bold_font}SYNOPSIS${normal_font}"
  echo -e ""
  echo -e "    rnc [options] <files>"
  echo -e ""
  echo -e "${bold_font}DESCRIPTION${normal_font}"
  echo -e ""
  echo -e "The ${bold_font}rnc${normal_font} utility renames the files passed in, replacing spaces with dashes and prefixing the creation date in YYYY-MM-DD format."
  echo -e "If no options are passed it will do the full rename with a prompt for each file."
  echo -e ""
  echo -e ""
  echo -e "    The following options are available: \n"
  echo -e "    ${bold_font}-h${normal_font}     show this help page\n"
  echo -e "    ${bold_font}-v${normal_font}     verbose mode\n"
  echo -e "    ${bold_font}-r${normal_font}     replace spaces\n"
  echo -e "    ${bold_font}-d${normal_font}     prefix created date\n"
  echo -e "    ${bold_font}-p${normal_font}     prompt before moving files\n\n"
}

function diff_folders(){
  local folder1="$1"
  local folder2="$2"

  local default_options="-qr"
  local ignored_files='.icloud\|.DS_Store\|^Common subdirectories'

  if [ "$#" -ne 2 ]; then
    __diff_folders_help "$default_options" "$ignored_files"
  else
    echo -e ""
    echo -e ""
    echo -e "calling: diff $default_options $folder1 $folder2"
    diff "$default_options" "$folder1" "$folder2" | grep -v "$ignored_files"
  fi
}

function __diff_folders_help() {
  local options="$1"
  local ignored_files="$2"
  local bold_font=$(tput bold)
  local normal_font=$(tput sgr0)
  echo -e ""
  echo -e "${bold_font}SYNOPSIS${normal_font}"
  echo -e ""
  echo -e "    diff_folders [options] <folder1> <folder2>"
  echo -e ""
  echo -e "${bold_font}DESCRIPTION${normal_font}"
  echo -e ""
  echo -e "The ${bold_font}diff_folders${normal_font} Diff folders excluding ignored files by using  '| grep -v $ignored_files'"
  echo -e ""
  echo -e " Default command diff $options <folder1> <folder2>"
}
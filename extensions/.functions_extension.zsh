
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
        printf "%s" "$data" |jq -R -r '. as $line | try fromjson catch $line'
    done
  }

  function jqlg() {
    if [ $# -ne 1 ]; then    # log level
        echo "Usage:  <kubectl logs...> | jqll <text to grep for>"
    fi
    while read -r data; do
        printf "%s" "$data" | jq -R -r '. as $line | try fromjson catch $line' | "$jq_logs_and_errors" | grep -i "$2"
    done
  }

  function jqle() {
    while read -r data; do
        if [ $# -eq 1 ]; then    # log level
            printf "%s" "$data" | jq -R -r '. as $line | try fromjson catch $line' | grep -ib4 "\"level\": \"error\"" | "$jq_logs_and_errors"
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
  echo "$#"
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
    echo -e "\nUsage: dos-to-unix <input-file> [output-file]\n"
    echo -e 'if the $2 is omitted then;  $1 convert  "$1-dos-to-unix-step" && mv "$1-dos-to-unix-step" $1'
  elif [[ $# -eq 1 ]]; then
    DOS_TO_UNIS_STEP_FILE="$1.dos_to_unix_step"
    cat "$1" | awk '{ sub ("\r$", "" ); print }' > "$DOS_TO_UNIS_STEP_FILE" && mv "$DOS_TO_UNIS_STEP_FILE" "$1"
  elif [[ $# -eq 2 ]]; then
    cat "$1" | awk '{ sub ("\r$", "" ); print }' > $2
  fi
}


# `tre` is a shorthand for `tree` with hidden files and color enabled, ignoring
# the `.git` directory, listing directories first. The output gets piped into
# `less` with options to preserve color and line numbers, unless the output is
# small enough for one screen.
function tre() {
    tree -aC -I '.git|node_modules|bower_components|.idea' --dirsfirst "$@" | less -FRNX;
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
    case "$@"  in
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
      *) echo "Unexpected_month_for_$@";;
    esac
}

function file_created_date() {
  #The GetFileInfo command is depricated so 1st check if it still there
  command -v GetFileInfo > /dev/null 2>&1
	if [ $? -eq 1 ]; then
    echo "GetFileInfo not found, exiting"
    say "GetFileInfo not found, exiting"
		exit 1
	fi

	#Output of GetFileInfo is in US date format
  echo $(GetFileInfo -d "$@" | awk '{print $1}' | awk 'BEGIN { FS = "/" }; {print $3 "-"  $1 "-" $2}')
}

#Rename all files prefixing last modified date and replacing space to have _ instead
function rename_prefixing_created_date_replacing_spaces(){
  for i in "$@"; do
    if [[ -d $i ]] || [[ -f $i ]]; then
      echo_in_verbose_mode "About to rename:     '$i'"
      NEW_NAME="$i"

      if [[ $HAS_REQUESTED_AN_OPTION -eq 0 ]] || [[ $REPLACE_SPACES -eq 1 ]] ; then
        NEW_NAME=$(replace_spaces_with_dashes "$i");
      fi

      if [[ $HAS_REQUESTED_AN_OPTION -eq 0 ]] || [[ $PREFIX_DATE -eq 1 ]]; then
        NEW_NAME="$(file_created_date "$i")_$NEW_NAME"
      fi

      move_file_with_prompt "$i" "$NEW_NAME";
    else
      echo "Unhandled file type, skipping '$i'"
    fi
  done
}

function move_file_with_prompt(){
    FROM="$1"
    TO="$2"
    if [[ "$FROM" != "$TO" ]]; then
      if [[ PROMPT_FOR_CONFIRMATION -eq 1 ]]; then
        echo "Rename: '$FROM' -> '$TO' [y/n/a]?"
        read -r USER_INPUT;
        case "$USER_INPUT" in
          "a" | "A")
            PROMPT_FOR_CONFIRMATION=0
            ;& #Fall though
          "y" | "Y")
            mv "$FROM" "$TO";
            ;;
          *)
            echo "$FROM not moved."
            ;;
        esac
      else
          echo_in_verbose_mode "Renaming: '$FROM' -> '$TO'."
          mv "$FROM" "$TO";
      fi
    else
      echo_in_verbose_mode "Skipping renaming: '$FROM' -> '$TO' as they are identical."
    fi
}

# renames files/folders with <YYYY-MM-DD-original-file-name-with-spaces-replaced-with-dashes>
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
  BOLD=$(tput bold)
  NORM=$(tput sgr0)
  echo -e ""
  echo -e "${BOLD}SYNOPSIS${NORM}"
  echo -e ""
  echo -e "    rnc [options] <files>"
  echo -e ""
  echo -e "${BOLD}DESCRIPTION${NORM}"
  echo -e ""
  echo -e "The ${BOLD}rnc${NORM} utility renames the files passed in, replacing spaces with dashes and prefixing the creation date in YYYY-MM-DD format."
  echo -e "If no options are passed it will do the full rename with a prompt for each file."
  echo -e ""
  echo -e ""
  echo -e "    The following options are available: \n"
  echo -e "    ${BOLD}-h${NORM}     show this help page\n"
  echo -e "    ${BOLD}-v${NORM}     verbose mode\n"
  echo -e "    ${BOLD}-r${NORM}     replace spaces\n"
  echo -e "    ${BOLD}-d${NORM}     prefix created date\n"
  echo -e "    ${BOLD}-p${NORM}     prompt before moving files\n\n"
}


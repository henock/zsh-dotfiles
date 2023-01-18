
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
  elif [[ $# -eq 2 ]] then
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

function replace_spaces_with_underscores() {
    echo "$@" | sed 's/ /_/g'
}

function prepend_zero_to_a_single_digit_if_needed() {
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
    long_list=`ls -lU "$@"`
    year=`echo $long_list | awk '{print $8;}'`;
    month_as_string=`echo $long_list | awk '{print $6;}'`;
    day=`echo $long_list | awk '{print $7;}'`;
    day=`prepend_zero_to_a_single_digit_if_needed $day`
    month=`get_numeric_month $month_as_string`
    echo "$year-$month-$day";
}

#Rename all files with space to have underscores instead
function rename_replacing_spaces(){
   for i in "$@"; do
     minus_spaces=$(replace_spaces_with_underscores "$i");
     mv "$i" "$minus_spaces";
   done
}

#Raname files to have the date of file created in yyyy-mm-dd-<file-name> format
function rename_prepending_created_date(){
   for i in "$@"; do
     new_file_name=$(file_created_date "$i")"_$i"
     mv "$i" "$new_file_name";
  done
}

#Rename all files prePending last modified date and replacing space to have _ instead
function rename_prepending_created_date_replacing_spaces(){
   for i in "$@"; do
     minus_spaces=$(replace_spaces_with_underscores "$i");
     new_file_name=$(file_created_date "$i")"_$minus_spaces"
     mv "$i" "$new_file_name";
   done
}
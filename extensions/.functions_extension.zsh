
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
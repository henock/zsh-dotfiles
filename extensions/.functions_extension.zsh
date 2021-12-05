
hash git &>/dev/null;
if [ $? -eq 0 ]; then
    function gdiff() {
        git diff --no-index --color-words "$@";
    }
fi;


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
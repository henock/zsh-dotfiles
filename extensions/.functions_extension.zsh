
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

hash git &>/dev/null;
if [ $? -eq 0 ]; then
    function gdiff() {
        git diff --no-index --color-words "$@";
    }
fi;

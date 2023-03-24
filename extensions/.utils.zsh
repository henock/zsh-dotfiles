

function echo_in_verbose_mode() {
  if [[ "$VERBOSE" = true ]]; then
    echo -e "$1"
  fi
}
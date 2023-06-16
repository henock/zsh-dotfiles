
# Check homebrew is installed and setting into path if its not already there.
if [ -e "/opt/homebrew/bin/brew" ] || [ -e "/usr/local/bin/brew" ]; then
  echo "Found that Homebrew is installed."
  PREFIX_PATH=$(brew config | grep HOMEBREW_PREFIX | sed 's/HOMEBREW_PREFIX\: //' )
  FOUND_IN_PATH=$(echo "$PATH" | grep -o "$PREFIX_PATH" )
  echo "PREFIX_PATH=$PREFIX_PATH"
  echo "FOUND_IN_PATH=$FOUND_IN_PATH"
  if [ -z "$FOUND_IN_PATH" ]; then
    echo "HOMEBREW_PREFIX not found in path setting it (PATH=$PREFIX_PATH:\$PATH)"
    PATH="$PREFIX_PATH":"$PATH"
  else
    echo "HOMEBREW_PREFIX found in path, nothing to do ($FOUND_IN_PATH found in PATH=$PATH)"
  fi
else
	echo "================================================================================"
	echo "|     Homebrew not found on the system - you will need to install it first!     |"
	echo "================================================================================"
fi
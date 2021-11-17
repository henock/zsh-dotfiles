# Sublime Text aliases

# Create symlink for sublime.
if [ -e "/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl" ]; then
	if [ ! -e ~/bin ]; then
		mkdir ~/bin
		echo "Created ~/bin folder"
	fi
	if [ ! -e ~/bin/sublime ]; then
		echo "Symlink to Sublime not found adding it."
		ln -s "/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl" ~/bin/sublime
		echo "Done."
	fi

	function st() {
      if [ $# -eq 0 ]; then
          sublime .;
      else
          sublime "$@";
      fi;
  }

  # Define sst only if sudo exists
  (( $+commands[sudo] )) && alias sst='sudo st'

else
	echo "================================================================================"
	echo "|     Sublime not found on the system - you will need to install it first!     |"
	echo "================================================================================"
	echo "sleeping for 3"
	sleep 3
fi





# Git
alias gco='git checkout'
alias gs='git status -s'
alias gc='git commit'
alias ga='git add'
alias gaa='git add --all'
alias gcm='git commit -m'
alias gacm='git add . && git commit -am'
alias gcf='git config --list'
# View abbreviated SHA, description, and history graph of the latest 20 commits
alias gl='git log --pretty=format:"%C(auto)%h %C(blue)%ad %C(green)(%an)%C(reset) %s" --date=format:"%Y-%m-%d" -n 20 --graph'
# Show the diff between the latest commit and the current state
alias gd='git diff-index --quiet HEAD -- || clear; git --no-pager diff --patch-with-stat'
alias gds='git diff --staged'
alias gp='git pull'
alias gpush='git push'
alias gb='git branch'
alias gba='git branch -a'
alias gcom='git checkout master'
alias gt='git tag -l'
# Gitlab specific
alias gtrace='glab ci trace'

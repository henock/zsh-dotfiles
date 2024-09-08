
# Git
alias gco='git checkout'
alias gs='git status -s'
alias gc='git commit'
alias ga='git add'
alias gaa='git add --all'
alias gcm='git commit -m'
alias gcam='git commit -a -m'
alias gcf='git config --list'
# View abbreviated SHA, description, and history graph of the latest 20 commits
alias gl='git log --pretty=oneline -n 20 --graph --abbrev-commit'
# Show the diff between the latest commit and the current state
alias gd='git diff-index --quiet HEAD -- || clear; git --no-pager diff --patch-with-stat'
alias gds='git diff --staged'
alias gp='git pull'
alias gpo='git push origin'
alias gb='git branch'
alias gba='git branch -a'
alias gcom='gco master'
alias gt='git tag -l'

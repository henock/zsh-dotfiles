#! /bin/zsh

## Java home
export JAVA_8_HOME=$(/usr/libexec/java_home -v1.8)
export JAVA_11_HOME=$(/usr/libexec/java_home -v11)
export JAVA_17_HOME=$(/usr/libexec/java_home -v17)
export JAVA_21_HOME=$(/usr/libexec/java_home -v9)

## Java alias
alias java8='export JAVA_VERSION=1.8; export JAVA_HOME=$JAVA_8_HOME'
alias java11='export JAVA_VERSION=11; export JAVA_HOME=$JAVA_11_HOME'
alias java17='export JAVA_VERSION=17; export JAVA_HOME=$JAVA_17_HOME'
alias java21='export JAVA_VERSION=9; export JAVA_HOME=$JAVA_21_HOME'


#Maven
alias mci='mvn clean install'
alias mci-t='mvn clean install -Dmaven.test.skip=true'
alias mct='mvn clean test'


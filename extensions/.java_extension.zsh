#! /bin/zsh

## Java home
export JAVA_8_HOME=$(/usr/libexec/java_home -v1.8)
export JAVA_11_HOME=$(/usr/libexec/java_home -v11)
export JAVA_16_HOME=$(/usr/libexec/java_home -v16)

## Java alias
alias java8='export JAVA_VERSION=1.8; export JAVA_HOME=$JAVA_8_HOME'
alias java11='export JAVA_VERSION=11; export JAVA_HOME=$JAVA_11_HOME'
alias java16='export JAVA_VERSION=16; export JAVA_HOME=$JAVA_16_HOME'
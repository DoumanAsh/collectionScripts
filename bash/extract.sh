#!/bin/bash

if [ $# -lt 1 ];then
  echo "Usage: `basename $0` FILES"
  exit 1
fi

extract () {
    for arg in $@ ; do
        if [ -f $arg ] ; then
            case $arg in
                *.tar.bz2)  tar xjf $arg      ;;
                *.tar.gz)   tar xzf $arg      ;;
                *.tar.xz)   tar xz $arg      ;;
                *.bz2)      bunzip2 $arg      ;;
                *.gz)       gunzip $arg       ;;
                *.tar)      tar xf $arg       ;;
                *.tbz2)     tar xjf $arg      ;;
                *.tgz)      tar xzf $arg      ;;
                *.zip)      unzip $arg        ;;
                *.Z)        uncompress $arg   ;;
                *.rar)      rar x $arg        ;;  # 'rar' must to be installed
                *.jar)      jar -xvf $arg     ;;  # 'jdk' must to be installed
                *)          echo "'$arg' cannot be extracted via extract()" ;;
            esac
        else
            echo "'$arg' is not a archive file"
        fi
    done
}

extract $@

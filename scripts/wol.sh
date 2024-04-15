#!/bin/zsh

alias wol=fn_wol

function fn_wol() {(
  set -e;

  local cmd=$1
  local tgt=$2
  local device=''

  # set target device
  case $tgt in
    heim)
      device=$LUFTHEIM
      ;;
    *)
      echo "wol: unknown target $tgt"
      return 1
    ;;
  esac

  # do WOL or Sleep on network
  case $cmd in
    wake)
      wakeonlan $device
      ;;
    sleep)
      ;;
    *)
      echo "wol: unknown command $cmd"
      return 1
    ;;
  esac
)}
autoload fn_wol

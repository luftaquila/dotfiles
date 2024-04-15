#!/bin/zsh

alias wol=fn_wol

function fn_wol() {(
  set -e;

  local cmd=$1
  local tgt=$2
  local device=''
  local sleepcmd="%windir%\System32\rundll32.exe powrprof.dll,SetSuspendState 0,1,0"

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
      ssh $LUFTHEIM_ID@$LUFTHEIM_IP -p $LUFTHEIM_PORT $sleepcmd
      ;;
    *)
      echo "wol: unknown command $cmd"
      return 1
    ;;
  esac
)}
autoload fn_wol

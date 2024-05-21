#!/bin/zsh

export PATH="$PATH:/opt/rtst/arm-none-eabi/bin:/opt/rtst/powerpc-unknown-elf/bin:/opt/rtst/powerpc-unknown-eabispe/bin"

alias bsp=fn_bsp

alias bb=fn_rtworks_build
alias mm=fn_rtworks_misra

alias lr=fn_rtworks_local_run
alias le=fn_rtworks_local_execute_fast
alias les=fn_rtworks_local_execute

alias rr=fn_rtworks_remote_run
alias re=fn_rtworks_remote_execute

alias tt=fn_t32_launch

alias qq='RELAY=`cat ~/rtworks/relay`; push-return $RELAY;'
alias cons='source ~/rtworks/bsp.sh; tio $CONSOLE -b 115200'

alias elf=fn_elf
alias dmp=fn_dmp


############################## BSP CONFIG ##############################
function fn_bsp() {(
  nvim ~/rtworks/bsp.sh;

  source ~/rtworks/bsp.sh;
  cd ~/rtworks/builder;
  ./init.py -b $BSP
)}
autoload fn_bsp


############################## BUILD ##############################
function fn_rtworks_build() {(
  set -e;
  RTWORKS_DIR=~/rtworks

  fn_patch_autostart_delay 0;

  while [[ $# -gt 0 ]]; do
    case $1 in
      -d|--dir)
        RTWORKS_DIR="`pwd`/$2"
        shift
        shift
        ;;
      *)
        RTWORKS_OPTION="$1"
        shift
        ;;
    esac
  done

  cd "$RTWORKS_DIR/builder";
  ./build.py -adg$RTWORKS_OPTION;

  # transfer elf objects to remote for t32 debugging
  # fn_transfer_t32_objects "wolke.luftaquila.io"
)}
autoload fn_rtworks_build

function fn_patch_autostart_delay() {(
  set -e;
  local delay=$1;

  cd ~/rtworks/builder/build.kernel;

  if [ -f CMakeCache.txt ]; then
    sed -i '' -E "s/^(CONFIG_AUTOSTART_DELAY:STRING=)(.*)/\1$delay/" CMakeCache.txt;
  fi
)}
autoload fn_patch_autostart_delay


############################## MISRA ##############################
function fn_rtworks_misra() {(
  set -e;
  source ~/rtworks/bsp.sh;
  TARGET=$1;

  if   [[ "$TARGET" == "p" ]]; then TARGET="partition";
  elif [[ "$TARGET" == "k" ]]; then TARGET="kernel";
  fi

  cd ~/rtworks/$TARGET/build;
  cmake -DBSP=$BSP -DUSE_MISRA_CHECKER=1 ..;
  ../misc/scripts/report_misra.sh | bat --language=c;
)}
autoload fn_rtworks_misra


############################## LAUNCH LOCAL ##############################
function fn_rtworks_local_run() {(
  set -e;
  source ~/rtworks/bsp.sh;
  RELAY=`cat ~/rtworks/relay`

  if   [[ "$BSP" == "t2080rdb" ]];      then push-return $RELAY;
  elif [[ "$BSP" == "ima_fcc-t2080" ]]; then push-toggle $RELAY;
  else push-return $RELAY;
  fi
)}
autoload fn_rtworks_local_run

function fn_rtworks_local_execute() {(
  set -e;

  fn_rtworks_build "$1";
  fn_rtworks_local_run;
)}
autoload fn_rtworks_local_execute

function fn_rtworks_local_execute_fast() {(
  set -e;

  fn_rtworks_local_run;
  fn_rtworks_build "$1";
)}
autoload fn_rtworks_local_execute_fast


############################## LAUNCH REMOTE ##############################
function fn_rtworks_remote_run() {(
  set -e;
  BSP=t2080rdb
  TIMEOUT=""

  if [[ ! -z $1 ]]; then
    TIMEOUT="-t $1"
  fi

  cd ~/rtworks/remote;
  ruby remote.rb -b $BSP -u ~/rtworks/builder/load.scr $TIMEOUT;
)}
autoload fn_rtworks_remote_run

function fn_rtworks_remote_execute() {(
  set -e;

  fn_rtworks_build "$1";
  fn_rtworks_remote_run;
)}
autoload fn_rtworks_remote_execute


############################## binutils ##############################
fn_elf() {(
  set -e;
  source ~/rtworks/bsp.sh;

  $TOOLCHAIN-readelf -e ${@:1}; # pass all options
)}

fn_dmp() {(
  set -e;
  source ~/rtworks/bsp.sh;

  $TOOLCHAIN-objdump -dS ${@:1} > '/tmp/objdump';
  sed -i '' -E '1 s/^.*$/# vim: set filetype=objdump:/' /tmp/objdump
)}


############################## TRACE32 ##############################
function fn_t32_launch() {(
  set -e;
  source ~/rtworks/bsp.sh;

  echo "GLOBAL &CPU\n&CPU=\"$CPU\"" > ~/.trace32/cpu.cmm

  ~/t32/bin/macosx64/t32m$ARCH-qt -c ~/t32/config_usb.t32
)}
autoload fn_t32_launch

function fn_transfer_t32_objects() {(
  echo '[INF] transferring ELF and changed files to remote...'

  local target=$1
  scp /private/tftpboot/rtworks_merged.elf $target:.trace32
  scp $HOME/rtworks/builder/build.partition1/rtworks_partition.elf $target:.trace32

  fn_scp_git_diff "$HOME/rtworks/kernel" "rtworks/kernel" "$target"
  fn_scp_git_diff "$HOME/rtworks/partition" "rtworks/partition" "$target"
)}
autoload fn_transfer_diff_for_remote_t32

function fn_scp_git_diff() {(
  set -e;

  local source_dir=$1
  local target_dir=$2
  local target=$3

  cd $source_dir;
  local diff=$(git diff --name-only)

  for file in $diff; do
    local dest=$(dirname $file)
    scp "$file" "$target:$target_dir/$dest";
  done
)}
autoload fn_scp_git_diff


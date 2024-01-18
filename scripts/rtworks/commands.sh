export PATH="$PATH:/opt/rtst/arm-none-eabi/bin:/opt/rtst/powerpc-unknown-elf/bin"

alias bsp=fn_bsp

alias bb=fn_rtworks_build
alias mm=fn_rtworks_misra
alias lr=fn_rtworks_local_run
alias rr=fn_rtworks_remote_run
alias le=fn_rtworks_local_execute
alias re=fn_rtworks_remote_execute

alias qq='MODEM=`cat ~/rtworks/modem`; push-return $MODEM;'

function fn_bsp() {(
  vi ~/rtworks/bsp.sh;
  cd ~/rtworks/builder;
  ./init.py -b `~/rtworks/bsp.sh`
)}

function fn_rtworks_build() {(
  set -e;
  RTWORKS_DIR=~/rtworks

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
  pwd;
  ./build.py -adg$RTWORKS_OPTION;
)}

function fn_rtworks_misra() {(
  set -e;
  BSP=`~/rtworks/bsp.sh`;
  TARGET=$1;

  if   [[ "$TARGET" == "p" ]]; then TARGET="partition";
  elif [[ "$TARGET" == "k" ]]; then TARGET="kernel";
  fi

  cd ~/rtworks/$TARGET/build;
  cmake -DBSP=$BSP -DUSE_MISRA_CHECKER=1 ..;
  ../misc/scripts/report_misra.sh | bat;
)}

function fn_rtworks_remote_run() {(
  set -e;
  BSP=t2080rdb;

  cd ~/rtworks/remote;
  ruby remote.rb -b $BSP -u ~/rtworks/builder/load.scr;
)}

function fn_rtworks_remote_execute() {(
  set -e;

  fn_rtworks_build "$1";
  fn_rtworks_remote_run;
)}

function fn_rtworks_local_run() {(
  set -e;
  BSP=`~/rtworks/bsp.sh`;
  MODEM=`cat ~/rtworks/modem`

  if   [[ "$BSP" == "t2080rdb" ]];      then push-return $MODEM;
  elif [[ "$BSP" == "ima_fcc-t2080" ]]; then push-toggle $MODEM;
  else push-return $MODEM;
  fi
)}

function fn_rtworks_local_execute() {(
  set -e;

  fn_rtworks_build "$1";
  fn_rtworks_local_run;
)}

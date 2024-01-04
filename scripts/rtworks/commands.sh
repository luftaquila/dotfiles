alias bsp="(vi ~/rtworks/bsp.sh; cd ~/rtworks/builder; ./init.py -b `~/rtworks/bsp.sh`)"

alias RB=fn_rtworks_build
alias RM=fn_rtworks_misra
alias RR=fn_rtworks_remote_run
alias RE=fn_rtworks_remote_execute

function fn_rtworks_build() {(
  set -e;
  OPTION=$1;

  cd ~/rtworks/builder;
  ./build.py -adg$OPTION;
)}

function fn_rtworks_misra() {(
  set -e;
  BSP=`~/rtworks/bsp.sh`;
  TARGET=$1;

  if [[ "$TARGET" == "p" ]]; then TARGET="partition";
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
  BSP=t2080rdb;

  fn_rtworks_build;
  fn_rtworks_remote_run;
)}


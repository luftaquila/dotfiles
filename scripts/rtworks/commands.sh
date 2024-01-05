alias bsp="(vi ~/rtworks/bsp.sh; cd ~/rtworks/builder; ./init.py -b `~/rtworks/bsp.sh`)"

alias bb=fn_rtworks_build
alias mm=fn_rtworks_misra
alias ee= # fn_rtworks_build_run
alias rr=fn_rtworks_remote_run
alias re=fn_rtworks_remote_execute

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

  echo DIR=$RTWORKS_DIR
  echo OPT=$RTWORKS_OPTION

  cd "$RTWORKS_DIR/builder";
  pwd;
  ./build.py -adg$RTWORKS_OPTION;
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


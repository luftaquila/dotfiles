#!/usr/bin/env bash
#
# tmux status line accelerator.
#
# tmux forks its single-threaded server for every distinct #(shell-command) in
# the status line, once per status-interval. Each fork stalls the server for
# ~12ms no matter how cheap the command is, so the handful of jobs a themed
# status line installs freezes tmux for ~60-90ms every tick -- which is felt as
# input stutter while typing.
#
# This rewrites status-left / status-right so every #(cmd) becomes a #{@...}
# user option, then keeps those options fresh from this one long-lived process.
# status-interval is untouched: the bar still redraws at the same rate, the
# redraw just no longer forks anything.
#
# Run from .tmux.conf *after* the theme has built the status line:
#   run -b '.../scripts/tmux-status.sh >/dev/null 2>&1'

PIDFILE="${TMUX_TMPDIR:-/tmp}/tmux-status-$(id -u).pid"
OPT_PREFIX="@_status_seg"
CMD_PREFIX="@_status_cmd"

############################################################################
# single instance
############################################################################
SELF=${BASH_SOURCE[0]##*/}

# Never signal a pid we have not positively identified as a predecessor of this
# script: a stale pidfile whose pid has been recycled would otherwise take an
# unrelated process down with it -- including, potentially, the tmux server.
is_predecessor() {
  local pid=$1
  case $pid in
    "" | *[!0-9]*) return 1 ;;
    "$$") return 1 ;;
  esac
  ps -o command= -p "$pid" 2>/dev/null | grep -q -- "$SELF"
}

if [ -r "$PIDFILE" ]; then
  old=$(cat "$PIDFILE" 2>/dev/null)
  if is_predecessor "$old"; then
    kill "$old" 2>/dev/null
    for _ in 1 2 3 4 5 6 7 8 9 10; do
      kill -0 "$old" 2>/dev/null || break
      sleep 0.05
    done
    # still alive and still ours: escalate rather than run two daemons
    if kill -0 "$old" 2>/dev/null && is_predecessor "$old"; then
      kill -9 "$old" 2>/dev/null
    fi
  fi
fi
echo "$$" >"$PIDFILE"
# only drop the pidfile if it is still ours -- a successor may have claimed it
trap '[ "$(cat "$PIDFILE" 2>/dev/null)" = "$$" ] && rm -f "$PIDFILE"' EXIT

############################################################################
# refresh policy
############################################################################
# @status-refresh-overrides: space separated "<command substring>=<seconds>".
# First match wins. 0 means "evaluate once at startup", for static values.
# A command matching no rule keeps being evaluated every second, as before.
default_interval=1
overrides=()
IFS=' ' read -r -a overrides <<<"$(tmux show-option -gqv @status-refresh-overrides)"

interval_for() {
  local cmd=$1 rule pattern seconds
  for rule in ${overrides[@]+"${overrides[@]}"}; do
    pattern=${rule%=*}
    seconds=${rule##*=}
    [ -n "$pattern" ] || continue
    case $cmd in *"$pattern"*) ;; *) continue ;; esac
    case $seconds in
      "" | *[!0-9]*) continue ;;
      *) echo "$seconds"; return ;;
    esac
  done
  echo "$default_interval"
}

############################################################################
# segment discovery
############################################################################
cmds=()

# set SEG_IDX to the index of $1 in cmds, appending it when new -- mirrors
# tmux, which shares a single job between identical #() commands.
# Sets a global instead of printing: a $(...) subshell could not grow cmds.
seg_index() {
  local cmd=$1 i
  for i in ${cmds[@]+"${!cmds[@]}"}; do
    if [ "${cmds[i]}" = "$cmd" ]; then SEG_IDX=$i; return; fi
  done
  cmds[${#cmds[@]}]=$cmd
  SEG_IDX=$((${#cmds[@]} - 1))
}

# set CONVERTED to $1 with every #(cmd) replaced by #{@_status_segN}, growing
# cmds along the way -- again a global, so the appends survive
convert() {
  local in=$1 out= i=0 n=${#1} j depth cmd ch
  while [ "$i" -lt "$n" ]; do
    if [ "${in:i:2}" = '#(' ]; then
      j=$((i + 2)); depth=1; cmd=
      while [ "$j" -lt "$n" ]; do
        ch=${in:j:1}
        if [ "$ch" = '(' ]; then
          depth=$((depth + 1))
        elif [ "$ch" = ')' ]; then
          depth=$((depth - 1))
          [ "$depth" -eq 0 ] && break
        fi
        cmd=$cmd$ch
        j=$((j + 1))
      done
      if [ "$depth" -ne 0 ]; then   # unbalanced -- leave the remainder alone
        out=$out${in:i}
        break
      fi
      seg_index "$cmd"
      out=$out"#{${OPT_PREFIX}${SEG_IDX}}"
      i=$((j + 1))
    else
      out=$out${in:i:1}
      i=$((i + 1))
    fi
  done
  CONVERTED=$out
}

convert "$(tmux show-option -gqv status-left)";  new_left=$CONVERTED
convert "$(tmux show-option -gqv status-right)"; new_right=$CONVERTED
converted=${#cmds[@]}

if [ "$converted" -eq 0 ]; then
  # status line was already converted by an earlier run and no config reload
  # happened since -- recover the command list from the stashed options
  i=0
  while :; do
    cmd=$(tmux show-option -gqv "${CMD_PREFIX}${i}")
    [ -n "$cmd" ] || break
    cmds[$i]=$cmd
    i=$((i + 1))
  done
fi

[ "${#cmds[@]}" -gt 0 ] || exit 0

############################################################################
# prime every segment, then swap the status line over in one atomic command
############################################################################
intervals=()
values=()
apply=()
for i in "${!cmds[@]}"; do
  intervals[$i]=$(interval_for "${cmds[i]}")
  # command substitution already forks a subshell, so eval cannot leak state
  value=$(eval "${cmds[i]}" 2>/dev/null)
  values[$i]=${value##*$'\n'}   # tmux only ever shows a job's last line
  [ "${#apply[@]}" -gt 0 ] && apply[${#apply[@]}]=';'
  apply[${#apply[@]}]=set; apply[${#apply[@]}]=-g
  apply[${#apply[@]}]="${OPT_PREFIX}${i}"; apply[${#apply[@]}]="${values[i]}"
  if [ "$converted" -gt 0 ]; then
    apply[${#apply[@]}]=';'
    apply[${#apply[@]}]=set; apply[${#apply[@]}]=-g
    apply[${#apply[@]}]="${CMD_PREFIX}${i}"; apply[${#apply[@]}]="${cmds[i]}"
  fi
done

if [ "$converted" -gt 0 ]; then
  apply[${#apply[@]}]=';'
  apply[${#apply[@]}]=set; apply[${#apply[@]}]=-g
  apply[${#apply[@]}]=status-left; apply[${#apply[@]}]="$new_left"
  apply[${#apply[@]}]=';'
  apply[${#apply[@]}]=set; apply[${#apply[@]}]=-g
  apply[${#apply[@]}]=status-right; apply[${#apply[@]}]="$new_right"
fi
tmux "${apply[@]}" 2>/dev/null || exit 1

############################################################################
# update loop
############################################################################
tick=1
while :; do
  sleep 1
  batch=()
  for i in "${!cmds[@]}"; do
    [ "${intervals[i]}" -eq 0 ] && continue
    [ $((tick % intervals[i])) -eq 0 ] || continue

    value=$(eval "${cmds[i]}" 2>/dev/null)
    value=${value##*$'\n'}

    if [ "$value" != "${values[i]}" ]; then
      values[$i]=$value
      [ "${#batch[@]}" -gt 0 ] && batch[${#batch[@]}]=';'
      batch[${#batch[@]}]=set; batch[${#batch[@]}]=-g
      batch[${#batch[@]}]="${OPT_PREFIX}${i}"; batch[${#batch[@]}]="$value"
    fi
  done

  if [ "${#batch[@]}" -gt 0 ]; then
    tmux "${batch[@]}" 2>/dev/null || exit 0
  elif [ $((tick % 5)) -eq 0 ]; then
    tmux has-session >/dev/null 2>&1 || exit 0
  fi

  tick=$((tick + 1))
done

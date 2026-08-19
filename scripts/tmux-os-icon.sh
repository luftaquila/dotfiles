#!/usr/bin/env bash
#
# Print this machine's Nerd Font OS glyph.
#
# The glyph is read out of the [os.symbols] table in the starship config, so the
# tmux status bar and the shell prompt cannot drift apart -- edit starship.toml
# and both follow. Prints nothing (exit 0) when the OS or the table entry cannot
# be resolved, which just leaves the status bar without an icon.

self_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# starship's [os.symbols] keys come from the os_info crate, not from uname
os_key() {
  case $(uname -s) in
    Darwin) echo Macos; return ;;
    MINGW* | MSYS* | CYGWIN*) echo Windows; return ;;
    Linux) ;;
    *) return ;;
  esac

  local id=
  if [ -r /etc/os-release ]; then
    id=$(. /etc/os-release 2>/dev/null && printf '%s' "${ID:-}")
  fi

  case $id in
    arch) echo Arch ;;
    debian) echo Debian ;;
    ubuntu) echo Ubuntu ;;
    fedora) echo Fedora ;;
    alpine) echo Alpine ;;
    centos) echo CentOS ;;
    rhel) echo RedHatEnterprise ;;
    redhat) echo Redhat ;;
    rocky) echo RockyLinux ;;
    opensuse*) echo openSUSE ;;
    sles | suse) echo SUSE ;;
    nixos) echo NixOS ;;
    raspbian) echo Raspbian ;;
    manjaro) echo Manjaro ;;
    linuxmint) echo Mint ;;
    pop) echo Pop ;;
    *) echo Linux ;;
  esac
}

config=${STARSHIP_CONFIG:-}
for candidate in "$config" "$self_dir/../tools/starship/starship.toml" \
                 "${XDG_CONFIG_HOME:-$HOME/.config}/starship.toml"; do
  [ -n "$candidate" ] && [ -r "$candidate" ] && { config=$candidate; break; }
  config=
done
[ -n "$config" ] || exit 0

key=$(os_key)
[ -n "$key" ] || exit 0

# pull `Key = "<glyph>"` out of the [os.symbols] table only
awk -v want="$key" '
  /^[[:space:]]*\[/ { in_table = ($0 ~ /^[[:space:]]*\[os\.symbols\]/); next }
  !in_table { next }
  {
    line = $0
    sub(/[[:space:]]*#.*$/, "", line)
    if (match(line, /^[[:space:]]*[A-Za-z_][A-Za-z0-9_]*[[:space:]]*=/) == 0) next
    key = substr(line, RSTART, RLENGTH - 1)
    gsub(/[[:space:]]/, "", key)
    if (key != want) next
    if (match(line, /"[^"]*"/) == 0) next
    printf "%s", substr(line, RSTART + 1, RLENGTH - 2)
    exit
  }
' "$config"

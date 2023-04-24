#!/usr/bin/env bash

####################################################################
## Initialize

HOST_DIR="$1"
if [ -z "$HOST_DIR" -o ! -d "$HOST_DIR" ]; then
  echo "Missing or invalid argument #1 (host dir)" 1>&2
  exit 1
fi
HOST_TYPE=$(cat "$HOST_DIR/host.type")

DEST="/opt/nebula/abell-250"
DEST_CACHE_DIR="$DEST/cache"
DEST_BIN_DIR="$DEST/bin"
DEST_ETC_DIR="$DEST/etc"
NEBULA_VERSION=1.6.1
SYSTEMD_SERVICE=nebula-abell-250

####################################################################
## Methods

function check_deps() {
  for CMD in wget tar unzip ; do
    if [ -z `which $CMD` ]; then
      fatal "Missing required command: $CMD"
    fi
  done
}

function install_nebula() {
  ## Not (yet) reliably available on distros. Get the standalone builds.
  local url=
  local fmt=tar.gz
  local env=$(uname -s -m)

  case "$env" in
    'Darwin arm64') url="https://github.com/slackhq/nebula/releases/download/v${NEBULA_VERSION}/nebula-darwin.zip" ; fmt=zip ; ;;
    'Linux x86_64') url="https://github.com/slackhq/nebula/releases/download/v${NEBULA_VERSION}/nebula-linux-amd64.tar.gz " ; ;;
    *) fatal "Failed to determine download for \"$env\"" ; ;;
  esac

  local cachefile="$DEST_CACHE_DIR/nebula-${NEBULA_VERSION}.$fmt"
  if [ -f "$cachefile" -a -f "$DEST_BIN_DIR/nebula" ]; then
    ## It appears that we have already downloaded this version.
    return
  fi

  if [ ! -f "$cachefile" ]; then
    wget "$url" -O "$cachefile"
  fi

  case "$fmt" in
    tar.gz)
      (cd "$DEST_BIN_DIR" && tar xvzf "$cachefile")
      ;;
    zip)
      (cd "$DEST_BIN_DIR" && unzip "$cachefile")
      ;;
    *)
      fatal "Invalid format"
      ;;
  esac
}

function install_dirs() {
  for DIR in "$@" ; do
    if [ ! -d "$DIR" ]; then
      mkdir "$DIR"
    fi
  done
}

function install_config() {
  cp certs/ca.crt "$HOST_DIR"/host.* "$DEST_ETC_DIR/"

  cp "config/$HOST_TYPE.yml" "$DEST_ETC_DIR/config.d/"
  case "$HOST_TYPE" in
    server|workstation)
      cp "config/network.yml" "$DEST_ETC_DIR/config.d/"
      ;;
  esac
}

function generate_runner() {
  echo '#!/usr/bin/env bash'
  echo "cd $DEST_ETC_DIR"
  echo "sudo $DEST_BIN_DIR/nebula -config config.d"
}

function stop_host_agent() {
  if [ -d "/etc/systemd/system" ]; then
    if [ -f "/etc/systemd/system/$SYSTEMD_SERVICE.service" ]; then
      echo "Stop systemd launcher ($SYSTEMD_SERVICE.service)"
       systemctl stop "$SYSTEMD_SERVICE"
    fi
  fi
}

function install_host_agent() {
  generate_runner > "$DEST/connect.sh"
  chmod 755 "$DEST/connect.sh"

  if [ -d "/etc/systemd/system" ]; then
    echo "Install systemd launcher ($SYSTEMD_SERVICE.service)"
    cp "config/systemd.service" "/etc/systemd/system/$SYSTEMD_SERVICE.service"
    systemctl daemon-reload
    systemctl enable "$SYSTEMD_SERVICE"
    systemctl start "$SYSTEMD_SERVICE"
  else
    echo "To connect, please run:"
    echo
    echo "  $ $DEST/connect.sh"
  fi
}

function fatal() {
  echo "$@" 1>&2
  exit 1
}

####################################################################
## Main

check_deps
stop_host_agent
install_dirs "/opt/nebula" "$DEST" "$DEST_BIN_DIR" "$DEST_CACHE_DIR" "$DEST_ETC_DIR" "$DEST_ETC_DIR/config.d"
install_nebula
install_config
install_host_agent

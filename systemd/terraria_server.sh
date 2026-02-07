#!/usr/bin/env bash
set -e

TERRARIA_SESSION="terraria"
TERRARIA_USER=$(whoami)
TERRARIA_HOME="/opt/terraria"
TERRARIA_WORLD="$TERRARIA_HOME/worlds/Comical_Terraria_of_Seeds.wld"
TERRARIA_SERVER="$TERRARIA_HOME/TerrariaServer.bin.x86_64"

start() {
  if tmux has-session -t "$TERRARIA_SESSION" 2>/dev/null; then
    echo "Terraria already running"
    exit 0
  fi

  echo "Starting Terraria server..."
  tmux new-session -d -s "$TERRARIA_SESSION" \
    "cd $TERRARIA_HOME && exec $TERRARIA_SERVER -world $TERRARIA_WORLD"
}

stop() {
  if ! tmux has-session -t "$TERRARIA_SESSION" 2>/dev/null; then
    echo "Terraria not running"
    exit 0
  fi

  echo "Stopping Terraria server..."
  tmux send-keys -t "$TERRARIA_SESSION" "exit" C-m

  # Wait up to 30s for clean shutdown
  for i in {1..30}; do
    sleep 1
    if ! tmux has-session -t "$TERRARIA_SESSION" 2>/dev/null; then
      echo "Terraria stopped cleanly"
      return
    fi
  done

  echo "Force killing tmux session"
  tmux kill-session -t "$TERRARIA_SESSION"
}

status() {
  if tmux has-session -t "$TERRARIA_SESSION" 2>/dev/null; then
    echo "Terraria is running (tmux session: $TERRARIA_SESSION)"
  else
    echo "Terraria is stopped"
  fi
}

case "${1:-}" in
  start) start ;;
  stop) stop ;;
  restart)
    stop
    start
    ;;
  status) status ;;
  *)
    echo "Usage: $0 {start|stop|restart|status}"
    exit 1
    ;;
esac

1) 
pgrep2() {
  ps -o pid,comm | grep -E "$1" | grep -Ev grep
}

2) runlimit.sh

time=$1
shift
"$@" &
TARGET_PID=$!
sleep "$time" &
SLEEP_PID=$!
wait -n
if kill -0 "$TARGET_PID" 2>/dev/null; then 
  kill "$TARGET_PID"
elif kill -0 "$SLEEP_PID" 2>/dev/null; then
  kill "$SLEEP_PID"
fi

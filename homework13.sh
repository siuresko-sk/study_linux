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

3) spamer.sh
kol=""
time=""
script=""
while [[ $1 ]] ; do
  case "$1" in
    --instances )
      shift
      kol=$1
      shift;;
    --delay )
      shift
      time=$1
      shift;;
    *) 
      script=( "$@" )
      break;;
  esac
done
for (( i=1; i<=kol; i++ )); do
    "${script[@]}" &
    sleep $time
done     
wait

4) temptouch.sh
touch "$1"
( sleep $2 ; rm "$1" ) &

5) killboss.sh

mode=""
case "$1" in
  --cpu)
    mode="pcpu";;
  --mem)
    mode="pmem";;
  *)
    echo Флаг не указан
    exit 1;;
esac
BOSS=$( ps -o pid,comm --sort=-$mode | head -n 2 | tail -n 1 )
echo "$BOSS"
BOSS_DATA=( $BOSS )
BOSS_PID=${BOSS_DATA[0]}
kill "$BOSS_PID"

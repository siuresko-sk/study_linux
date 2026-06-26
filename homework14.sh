1) dfalarm
#!/usr/bin/env bash
while true ; do
  usage=$(df --output=pcent $1 | tail -n +2 | sed "s/\%//" ) 
  if (( $usage > 90 )) ; then
    echo "Внимание! Дисковое пространство заполнено более чем на 90%"
  fi
  sleep 5m
done

chmod u+x dfalarm.sh

2) wgetalarm.sh
#!/usr/bin/env bash
if wget -qO - https://true-time.com/moscow/ | grep 'class="hour-minutes-string"' | grep -q '00' ; then
  echo "Alarm!"
fi

chmod u+x wgetalarm.sh
bash spamer --instances 5 --delay 1 ./wgetalarm.sh

3) somecurls.sh
#!/usr/bin/env bash
curl -s "https://jsonplaceholder.typicode.com/posts/99" 
for (( i=1; i<4; i++ )) ; do
  curl -X POST "https://jsonplaceholder.typicode.com/posts/" \
    -H "Content-Type: application/json; charset=UTF-8" \
    -d "{\"title\": \"post $i\", \"body\": \"content\", \"userId\": 1}"
done 

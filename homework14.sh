1) dfalarm
#!/usr/bin/env bash
while true ; do
  usage=$(df --output=pcent $1 | tail -n +2 | sed "s/\%//" ) 
  if [[ $usage -gt 90 ]] ; then
    echo "Внимание! Дисковое пространство заполнено более чем на 90%"
  fi
  sleep 5m
done

chmod u+x dfalarm.sh

1.1) мое my.sh
#!/usr/bin/env bash
for file in "$@" ; do
  chmod 700 "$file"
done

chmod +x my.sh 

1.2) наше our.sh
#!/usr/bin/env bash
for file in "$@" ; do
  sudo chown :$USER "$file"
  chmod 770 "$file"
done

chmod +x our.sh 

2) xtouch.sh

ext="${1##*.}"
shb=""
case "$ext" in
  sh)
    shb="#!/usr/bin/env bash";;
  py)
    shb="#!/usr/bin/env python3";;
  js)
    shb="#!/usr/bin/env node";;
  *)
    echo "Данное расширение не поддерживается"
    exit 1;;
esac 
echo $shb > "$1"
touch "$1" 
chmod u+x "$1"

3) modfilter

"#!/usr/bin/env bash"
flag=""
case "$1" in
  r | read)
    flag="-readable";;
  w | write)
    flag="-writable";;
  x | execute)
    flag="-executable";;
  *)
    echo "Флаг не определен"
    exit 1
esac
find . $flag -ls

4) shebanger
#!/usr/bin/env bash
dest_dir=""
if [[ "$1" == "-e" || "$1" == "--export" ]] ; then
  dest_dir="$2"
  find . -type f \( -name "*.sh" -or -name "*.bash" \) | while read -r file; do
    chmod u+x $file
    name=$(basename "$file")
    mv "$file" "$dest_dir/${name%.*}"
  done
else 
  find . -type f \( -name "*.sh" -or -name "*.bash" \) -exec chmod u+x {} +
fi

5)
ORIGINAL_PATH="$PATH"
cd() {
  builtin cd "$@"
  PATH="$ORIGINAL_PATH:${PWD}"
}

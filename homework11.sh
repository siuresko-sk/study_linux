1) swap 
name1=$(basename ${1:?Укажите первый файл}) 
name2=$(basename ${2:?Укажите второй файл}) 
if [[ $name1 == $name2 ]] ; then 
  cat $1 > temp_file.txt 
  cat $2 > $1 
  cat temp_file.txt > $2 
  rm temp_file.txt 
else 
  mv $1 temp_file.txt 
  mv $2 $1 
  mv temp_file.txt $2 
fi 

2.1) rgbcat 
while [[ $1 ]] ; do 
  case $1 in 
    -r | --red) 
      shift 
      red_list+=(“$1”) 
      shift;; 
    -g | --green) 
      shift 
      green_list+=(“$1”) 
      shift;; 
    -b | --blue) 
      shift
      blue_list+=(“$1”) 
      shift;; 
    *) 
      file_list+=(“$1”);; 
  esac 
  shift 
done 

for file in "${file_list[@]}"; do 
  content=$(cat "$file") 
  for word in "${red_list[@]}"; do 
    content=$(echo "$content" | sed -E "s/$word/\033[0;31m$word\033[0m/g") 
  done 
  for word in "${green_list[@]}"; do 
    content=$(echo "$content" | sed -E "s/$word/\033[0;32m$word\033[0m/g") 
  done 
  for word in "${blue_list[@]}"; do 
    content=$(echo "$content" | sed -E "s/$word/\033[0;34m$word\033[0m/g") 
  done 
  echo -e "$content" 
done 

2.2) my_format_function.sh
BOLD=$(tput bold) 
NORMAL=$(tput sgr0) 
custom_format() { 
  read -d '' content 
  word_list="$@" 
  for word in $word_list; do 
    local big_word="${word^^}" 
    content=$(echo "$content" | sed -E "s/$word/$BOLD$big_word$NORMAL/g ") 
  done 
  echo -e “$content”
} 
export -f custom_format

основной файл
source my_format_function.sh
RED="\033[0;31m" 
GREEN="\033[0;32m" 
BLUE="\033[0;34m" 
NO_COLOR="\033[0m" 

while [[ $1 ]] ; do 
  case $1 in 
    -r | --red) 
      shift 
      red_list+=(“$1”) 
      shift;; 
    -g | --green) 
      shift 
      green_list+=(“$1”) 
      shift;; 
    -b | --blue) 
      shift 
      blue_list+=(“$1”) 
      shift;; 
    -c | --custom) 
      shift 
      custom_list+=("$1") 
      shift;; 
    *) 
      file_list+=(“$1”);; 
  esac 
  shift
done 

rgbcat() { 
    read -d '' content 
    color_code="$1" 
    shift 
    word_list="$@" 
    for word in $word_list; do
      content=$(echo "$content" | sed -E "s/$word/$color_code$word$NO_COLOR/g") 
    done 
    echo -e "$content" 
}

cat ${file_list[@]} | rgbcat "$RED" ${red_list[@]} | rgbcat "$GREEN" ${green_list[@]} | rgbcat "$BLUE" ${blue_list[@]} | custom_format ${custom_list[@]} | xargs -0 echo -e

3) restore.sh

source $(dirname $0)/backup-dirs
DEFAULT_BACKUP_FOLDER=~/projects/draft/chap11/backup-folder
help_message=$(cat << END 
Usage: bash restore.sh [OPTIONS] 
Restore backup files that are specified in \`backup-dirs\`. 

Options: 
-h, --help 			show help message 
-z, --targz 			extract backup files from \`tar\` and \`gz\` 
-i, --input [SOURCE ]  	specify backup SOURCE path 
-g, --git-pull 			pull changes from git repository 
-e, --extra [EXTRA_ROOT] also restore extra files to EXTRA_ROOT  
END 
) 

source_pwd=$PWD
need_archive=false
backup_folder=$DEFAULT_BACKUP_FOLDER

show_help() { 
  echo "$help_message" 
} 

do_restore() { 
  for file in ${conffiles[@]}; do 
    mkdir -p ~/.config/$(dirname $file) 
    cp -Tr $backup_folder/$file ~/.config/$file 
  done 
  for (( i=0; i < ${#homefiles[@]}; i++ )); do 
    mkdir -p ~/$(dirname ${homefiles[$i]}) 
    cp -Tr $backup_folder/${homefiles[$i]} ~/${homefiles[$i]} 
  done 
}

git_pull() { 
  if [[ $need_pull ]] ; then 
    cd $backup_folder 
    git pull 
    cd $source_pwd 
  fi 
} 

extra_restore() { 
  extra_root=$1 
  shift 
  for file in $@; do 
    mkdir -p $extra_root/$(dirname $file) 
    cp -Tr $backup_folder/$file $extra_root/$file 
  done 
} 

decompress() {
  archive_tgz="${backup_folder}.tgz"
  archive_targz="${backup_folder}.tar.gz"
    if $need_extract; then
        if [[ -e $archive_tgz ]] ; then
          tar -xzf $archive_tgz  -C $backup_folder
          rm -rf "$archive_tgz"
        elif [[ -e $archive_targz ]] ; then
          tar -xzf $archive_targz -C $backup_folder
          rm -rf "$archive_targz"
        else
          echo Отсутствует архив для распаковки
        exit 1
      fi
  fi
}

function main { 
  while [[ $1 ]]; do 
    case $1 in 
      -z|--targz) 
        need_extract=true;;
      -i|--input) 
        shift 
        backup_folder=$1;; 
      -g|--git-pull) 
        need_pull=true;; 
      -h|--help) 
        show_help 
        exit;; 
      -e|--extra) 
        shift 
        extra_root=$1 
        extra_files=$(read_extra_files);; 
    esac 
    shift
  done 
		
	git_pull
	decompress
  	do_restore
	extra_restore $extra_root $extra_files
}

main "$@"

4.1)
BOLD=$(tput bold) 
NORMAL=$(tput sgr0)
LITDIR=".lit"

do_feed() {
	mkdir -p "$LITDIR"
	ls -A | grep -vE "\\${LITDIR}" | xargs tar -czf $LITDIR/"${feed_name}.tgz"
	echo Создан ${LITDIR}/${feed_name}.tgz
}

do_need() {
	[[ -e ${LITDIR}/${need_name}.tgz ]] || { echo "Не существует ${LITDIR}/${need_name}.tgz" ; exit 1; }
	tar -xzf ${LITDIR}/${need_name}.tgz -C .
	echo Восстановлен ${LITDIR}/${need_name}.tgz
}

do_exhibit() {
	[[ -e $LITDIR ]] || { echo "Пусто" ; exit 0 ; }
	ls -Alt $LITDIR \
        | cut -d ' ' -f '6-9' \
        | sed -E "s/(:[0-9]{2}) (.*)\.tgz$/\1 | ${BOLD}\2${NORMAL}/" \
        | tail -n +2
}

main() {
	[[ -z "$1" ]] && { echo "Не введены команды"; exit 1; }
	case $1 in
		e* )
			need_exhibit=true;;
		f* )
			shift
			feed_name=${1:?Не указано название изменения};;
		n* )
			shift
			need_name=${1:?Не указано название изменения};;
		*)
			echo Не введены команды
			exit 1;;
	esac
	if [[ $need_exhibit ]] ; then
		do_exhibit
	elif [[ $feed_name ]] ; then
		do_feed
	elif [[ $need_name ]] ; then
		do_need
	fi
}

main "$@"

4.2) 
BOLD=$(tput bold) 
NORMAL=$(tput sgr0)
LITDIR=".lit"
LITIGNORE=".litignore"

do_feed() {
	mkdir -p "$LITDIR"
	if [[ -e $LITIGNORE ]] ; then
		list_ignore=$(grep -E -v "(^#|^\s*)" "$LITIGNORE")
	else 
		list_ignore=""
	fi
	list_ignore="$list_ignore
$LITDIR"
	ls -A | grep -Ev -f <(echo "$list_ignore") | xargs tar -czf $LITDIR/"${feed_name}.tgz"
	echo Создан ${LITDIR}/${feed_name}.tgz
}

do_need() {
	[[ -e ${LITDIR}/${need_name}.tgz ]] || { echo "Не существует ${LITDIR}/${need_name}.tgz" ; exit 1; }
	tar -xzf ${LITDIR}/${need_name}.tgz -C .
	echo Восстановлен ${LITDIR}/${need_name}.tgz
}

do_exhibit() {
	[[ -e $LITDIR ]] || { echo "Пусто" ; exit 0 ; }
	ls -Alt $LITDIR \
        | cut -d ' ' -f '6-9' \
        | sed -E "s/(:[0-9]{2}) (.*)\.tgz$/\1 | ${BOLD}\2${NORMAL}/" \
        | tail -n +2
}

main() {
	[[ -z "$1" ]] && { echo "Не введены команды"; exit 1; }
	case $1 in
		e* )
			need_exhibit=true;;
		f* )
			shift
			feed_name=${1:?Не указано название изменения};;
		n* )
			shift
			need_name=${1:?Не указано название изменения};;
		*)
			echo Не введены команды
			exit 1;;
	esac
	if [[ $need_exhibit ]] ; then
		do_exhibit
	elif [[ $feed_name ]] ; then
		do_feed
	elif [[ $need_name ]] ; then
		do_need
	fi
}

main "$@"

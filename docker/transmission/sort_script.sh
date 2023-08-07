#!/bin/bash

# Считывание файлов из папки 

base_dir=~/media
search_dir=~/downloads
films_dir=$base_dir/films
serials_dir=$base_dir/serials
other_dir=~/other


function SerialProcess () {
    echo "[INFO] SerialProcessStart"
    name_serial=$(echo ${1##*/} | grep -P -o "[a-zA-Z]*" | head -1)
    season=$(echo ${1##*/} | grep -P "[Ss]\d\d" -o | grep -P "[1-9]" -o)
    
    path_to_dir="$serials_dir/$name_serial/season_$season"
    
    echo "[INFO] Name_serial $name_serial season $season path_to_dir $path_to_dir"

    if [[ ! -d $path_to_dir ]]; then
	echo "[DEBUG] Create dir $path_to_dir"
        mkdir -p $path_to_dir
    fi

    echo "[DEBUG] move $1 to $path_to_dir/"
    mv $1 "$path_to_dir/"
}

function FilmProcess () {
    echo "[INFO] FilmProcessStart"
    if [[ $1 =~ "2D" ]]; then
        echo "[DEBUG] move $1 to $films_dir/2D/"
    	mv $1 "$films_dir/2D/$(echo ${1##*/} | sed 's/2D//')" 
    elif [[ $1 =~ "3D" ]]; then
        echo "[DEBUG] move $1 to $films_dir/3D/"
	mv "$1" "$films_dir/3D/$(echo ${1##*/} | sed 's/3D//')"
    fi
}


function checking () {
    echo "[INFO] CHECKING FILE $1"
    if [[ ${1##*.} =~ (mkv|avi|mp4) ]]; then
        if [[ $1 =~ [Ss][0-9][1-9] ]]; then 
	    SerialProcess $1
        elif [[ $1 =~ (2D|3D) ]]; then
            FilmProcess $1
        fi
    fi
}


for entry in "$search_dir"/*
do
    if [[ -f $entry ]]; then
	checking $entry
    elif [[ -d $entry ]]; then
    	for i in "$entry"/*
        do
            checking $i
        done
	if [[ -d $entry && "$(ls -A "$entry" 2> /dev/null)" == "" ]]; then
	    echo "[INFO] remove empti dir $entry"
            rm -rf $entry
	fi	
    fi	
done

if [[ "$(ls -A "$search_dir" 2> /dev/null)" != "" ]]; then
	echo "[INFO] move $search_dir to $other_dir"  	
    mv "$search_dir"/* "$other_dir/"
fi

# entry=/test/test.txt
# ${entry%.*} /test/test
# ${entry##*.} txt
# ${entry##*/} test.txt
# filename=$(basename -- "#entry") test.txt

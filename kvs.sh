#!/usr/bin/env bash
cd `dirname $0`
state_file="state"

OUTPUT_VALUE_ONLY=0

usase_exit(){
    echo "Usase: $0 [OPTIONS] [COMMAND] [args...]"
    echo -e "COMMAND"
    echo -e "\tget [keys...] : get value by key"
    echo -e "\tgetgroup [groups...] : get value by group"
    echo -e "\ttoggle [key] : toggle bool value by key"
    echo -e "\tset [key] [value] (group) : set value to key"
    echo -e "\tsetgroup [group] [keys...] : set group to key"
    echo -e "\tlist : get existing keys"
    echo -e "\tlistgroup : get existing groups"
    echo
    echo -e "OPTIONS"
    echo -e "\t-s : output value only"
    exit 1
}

_get_value_by_key(){
    value=`echo "$state" | grep $'\t'"$key"$'\t' | sed -e 's/.*\t.*\t//g'`
}

_get_group_by_key(){
    group=`echo "$state" | grep $'\t'"$key"$'\t' | sed -e 's/\t.*\t.*//g'`
    if [ ! "$group" ]; then
        group='NOGROUP'
    fi
}

_get_keys_by_group(){
    keys=`echo "$state" | grep "^$group"$'\t'| sed -e 's/.*\t\(.*\)\t.*/\1/g'`
}

_set_value_and_group_by_key(){
    if [ ! "$group" ]; then
        _get_group_by_key
    fi
    sed $state_file -i -e "/^.*\t$key\t.*$/d"
    echo -e "$group\t$key\t$value" >> $state_file
}

_set_group_to_key(){
    _get_value_by_key
    _set_value_and_group_by_key
}

_print_key_value(){
    if [ $OUTPUT_VALUE_ONLY -eq 1 ]; then
        echo -e "$value"
    else
        echo -e "$key\t$value"
    fi
}

_print_value(){
    echo -e "$value"
}

_print_key_group(){
    echo -e "$key\t$group"
}
get_value_by_keys(){
    if [ "$#" -eq 0 ]; then
        usase_exit
        exit 1
    fi

    for key in $@; do
        _get_value_by_key
        _print_key_value
    done
}

get_value_by_groups(){
    if [ "$#" -eq 0 ]; then
        usase_exit
        exit 1
    fi
    groups=$@

    for group in $groups; do
        _get_keys_by_group
        for key in $keys; do
            _get_value_by_key
            _print_key_value
        done
    done
}

set_value(){
    if [ ! "$1" -o ! "$2" ]; then
        usase_exit
        exit 1
    fi

    key=$1
    value=$2
    group=$3
    _set_value_and_group_by_key
    _print_key_value
}

toggle_value(){
    if [ ! "$1" ]; then
        usase_exit
        exit 1
    fi
    key=$1
    _get_value_by_key

    case "$value" in
    0        ) value=1;;
    1        ) value=0;;
    [Ff]alse ) value=true;;
    [Tt]rue  ) value=false;;
    *        ) exit 1;;
    esac

    _set_value_and_group_by_key
    _print_key_value
}

add_group(){
    if [ ! "$1" -o ! "$2" ]; then
        usase_exit
    fi
    key=$1
    group=$2
    _set_group_to_key
    _print_key_group

}

list_keys(){
    cat $state_file | sed -e 's/.*\t\(.*\)\t.*/\1/g'
}

list_group(){
    cat $state_file | sed -e 's/\t.*\t.*//g' | grep -v "^$" | sort | uniq
}

touch $state_file
state=`cat $state_file`

while getopts s OPT; do
    case $OPT in
        s) OUTPUT_VALUE_ONLY=1;;
    esac
done
shift $(expr $OPTIND - 1)

if [ ! "$1" ];then
    usase_exit
fi
command=$1

case "$command" in
    "get"      ) shift 1; get_value_by_keys $*;;
    "getgroup" ) shift 1; get_value_by_groups $*;;
    "toggle"   ) toggle_value $2;;
    "set"      ) shift 1; set_value $*;;
    "setgroup" ) shift 1; add_group $*;;
    "list"     ) list_keys;;
    "listgroup") list_group;;
    *          ) usase_exit ;;
esac

#!/bin/bash

if [ $# -lt 1 ];then
    echo "usage : $0 cmd [params]"
    return 1;
fi

cmd=$1
param=$2

shift 1
params=" $@"

if [ ".$cmd" == ".make_alias" ]; then

    shbookmark_dir="${BASH_SOURCE[0]}"
    while [ -h "$shbookmark_dir" ]; do shbookmark_dir=`readlink "${shbookmark_dir}"`; done
    shbookmark_dir="$( cd -P "$( dirname "$shbookmark_dir" )" && pwd )"

    ss=$shbookmark_dir/shbookmark.sh

    pref=${param:-g}
    eval "alias ${pref}a='.     $ss add'"
    eval "alias ${pref}='.      $ss go'"
    eval "alias ${pref}del='.   $ss delete'"
    eval "alias ${pref}clean='. $ss clean'"

    if [ ".$SHBOOKMARK_COLOR" == "." ]; then
        export SHBOOKMARK_COLOR=1
    fi

    if [ ".$SHBOOKMARK_CASE_SENSITIVE" == "." ]; then
        export SHBOOKMARK_CASE_SENSITIVE=0
    fi

    return
fi

param=${param:-$PWD}
param=${param/#$HOME/"~"}

bookmarkFile=~/.shbookmark
tmp=$bookmarkFile.tmp

[ -f $bookmarkFile ] || >$bookmarkFile


shbookmark_goto() { cd $1; }
shbookmark_mv() { [ -f "$tmp" ] && mv -f $tmp $bookmarkFile; }
shbookmark_reverse()
{ #{{{
    local p=""
    for i in $*; do
        p="$i $p"
    done
    p=${p% }
    echo -nE "$p"
} #}}}
shbookmark_tree()
{ #{{{
    local paths="$*"

    rpaths=$(shbookmark_reverse $paths)
    tmpl="!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"

    path=${rpaths%% *}
    rpaths=${rpaths#* }


    newr=""
    for prev in $rpaths; do
        sppath=${path//\// }
        spprev=${prev//\// }

        stripped=""
        for e in $sppath;do 
            if [ "$e" == "${spprev%% *}" ]; then
                elen=${#e}
                stripped=$stripped${tmpl:${#stripped}:$elen+1}
                spprev=${spprev#* }
                sppath=${sppath#* }
            else
                tmpl=${tmpl:0:${#stripped}}"|!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
                stripped=$stripped\`${sppath// /\/}
                break
            fi
        done
        newr="${stripped#!} $newr"

        path=$prev
    done

    echo -nE "$prev ${newr% }"
} #}}}


case $cmd in

    add)
        echo "$param" >> $bookmarkFile \
            && { sort $bookmarkFile | uniq > $tmp; } && shbookmark_mv

        echo "$param has been added to bookmark"
        ;;

    delete)
        fgrep -v "$param" $bookmarkFile > $tmp && shbookmark_mv

        echo "$param" has been deleted
        ;;

    go)
        while [ 1 ];do

            if [ `cat $bookmarkFile | wc -l` -eq 0 ]; then
                echo "no bookmarks, 'ga' to add first"
                return
            fi

            if [ ".$SHBOOKMARK_CASE_SENSITIVE" == ".1" ]; then
                caseflag=""
            else
                caseflag=" -i "
            fi
            filteringCommand="cat $bookmarkFile"
            keywords=""
            for cond in $params;do
                if [ "${cond:0:1}" == "-" ];then
                    flg=" -v "
                    cond=${cond:1}
                else
                    flg=""
                    keywords="$keywords\|$cond"
                fi
                filteringCommand="$filteringCommand | fgrep $caseflag $flg $cond"
            done
            keywords=${keywords:2}

            if [ ".$keywords" == "." ]; then
                highlight_ptn="$"
            else
                highlight_ptn="$keywords\|$"
            fi


            echo "::$params"

            hm=${HOME//\//\\\/}
            count=`eval $filteringCommand | wc -l`
            paths=`eval $filteringCommand | sed "s/$hm/~/"`


            if [ $count -eq 0 ];then
                echo "nothing found.............."
                params=${params% *}
                continue

            elif [ $count -eq 1 ];then
                _dst="$(eval $filteringCommand)"
                eval "shbookmark_goto $_dst"
                return 0
            else

                if [ "$SHBOOKMARK_TREE" == "1" ];then
                    paths=$(shbookmark_tree $paths)
                fi

                i=0
                for p in $paths; do
                    let i=i+1
                    idx=$(printf "%3d" $i)
                    line="   $idx --- ${p//!/ }"
                    echo -E "$line"
                done | \
                    if [ "$SHBOOKMARK_COLOR" == "1" ]; then
                        grep $caseflag --color=auto "$highlight_ptn"
                    else
                        cat
                    fi


                echo -e "\n"

                echo "(Press ENTER to select by number)"
                read -p "Search For :" sel

                # ENTER entered
                if [[ "x$sel" = "x" ]];then

                    read -n1 -p "N=" sel

                    if [ "x$sel" == "x" ]; then
                        sel=1
                    fi
                    ar=(`eval $filteringCommand`)
                    echo ""
                    eval "shbookmark_goto ${ar[$sel-1]}"
                    return 0

                else
                    params="$params $sel"
                    continue
                fi
            fi

        done
        ;;



    clean)

        hm=${HOME//\//\\\/}
        for entry in $(cat $bookmarkFile); do
            en=$(echo $entry | sed "s/~/$hm/")
            if [ -d $en ];then
                echo $entry >> $tmp
            else
                echo "$entry doesn't exist"
            fi
        done
        shbookmark_mv
        ;;

    *)
        ;;
esac


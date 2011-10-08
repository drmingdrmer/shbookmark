#!/bin/bash


bookmarkFile=~/.shbookmark
tmp=$bookmarkFile.tmp


if [ $# -lt 1 ];then
    echo "usage : $0 cmd [params]"
    return 1;
fi

cmd=$1
param=$2

shift 1
params=" $@"

param=${param:-$PWD}
param=${param/#$HOME/~}


if [[ ! -f $bookmarkFile ]];then
    >$bookmarkFile
fi


sh_bookmark_goto() { cd $1; }
sh_bookmark_reverse()
{
    local p=""
    for i in $*; do
        p="$i $p"
    done
    p=${p% }
    echo -nE "$p"
}



case $cmd in

    add)
        echo "$param" >> $bookmarkFile
        sort $bookmarkFile | uniq > $tmp
        mv -f $tmp $bookmarkFile

        echo "$param has been added to bookmark"
        ;;

    delete)
        fgrep -v "$param" $bookmarkFile > $tmp
        mv -f $tmp $bookmarkFile

        echo "$param" has been deleted
        ;;


    go)
        while [ 1 ];do

            if [ `cat $bookmarkFile | wc -l` -eq 0 ]; then
                echo "no bookmarks, 'ga' to add first"
                return
            fi

            filteringCommand="cat $bookmarkFile"
            keywords=""
            for cond in $params;do
                if [ `expr "$cond" : "-"` -eq 1 ];then
                    flg=" -v "
                    cond=${cond:1}
                else
                    flg=""
                    keywords="$keywords\|$cond"
                fi
                filteringCommand="$filteringCommand | fgrep $flg $cond"
            done


            echo "::$params"

            hm=${HOME//\//\\\/}
            count=`eval $filteringCommand | wc -l`
            paths=`eval $filteringCommand | sed "s/$hm/~/"`


            if [ $count -eq 0 ];then
                echo "nothing found.............."
                params=${params% *}
                continue

            elif [ $count -eq 1 ];then
                sh_bookmark_goto `eval $filteringCommand`
                return 0
            else


                echo -e "\n"

                rpaths=$(sh_bookmark_reverse $paths)
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

                paths="$prev ${newr% }"

                i=0
                for p in $paths; do
                    let i=i+1
                    echo -E "   $i --- ${p//!/ }" | grep --color=auto "${keywords:2}\|$"
                done


                echo -e "\n"

                echo "(Press ENTER then select by number)"
                read -p "Search For :" sel

                # ENTER entered
                if [[ "x$sel" = "x" ]];then
                    read -n1 -p "N=" sel
                    if [ "x$sel" == "x" ]; then
                        sel=1
                    fi
                    ar=(`eval $filteringCommand`)
                    echo ""
                    sh_bookmark_goto ${ar[$sel-1]}
                    return 0

                else
                    params="$params $sel"
                    continue
                fi
            fi

        done
        ;;



    clean)

        for entry in `cat $bookmarkFile`;do
            if [ -d $entry ];then
                echo $entry >> $tmp
            else
                echo "$entry doesn't exist"
            fi
        done
        mv $tmp $bookmarkFile
        ;;

    *)
        ;;
esac


#!/bin/bash
#
# vcd2gtkw.sh
#
# This script creates a .gtkw (waveform save file) from a .vcd (value change
# dump). Waves are added in the order they are found in the VCD, which normally
# matches the order of port, signal declarations etc in the design source. Wave
# colours are cycled as the hierarchy levels are traversed.
#
# Arguments:
#  $1 : vcd filename
#  $2 : gtkw filename
#  $3 : (optional) hierarchy levels to descend, 0 = all (default if omitted)

vcd_filename=$1
gtkw_filename=$2
if [ -z "$3" ]; then
    levels=0;
else
    levels=$3
fi
echo "vcd2gtkw.sh: $1 -> $2 (levels = $3)"
echo "[\*] vcd2gtkw.sh: $1 -> $2 (levels = $3)" > $gtkw_filename
declare -a hlevel=() # current hierarchy level
scope="" # current scope name
declare -a waves=() # waves gathered for current scope
color=7
wave_name=""
function join_with { local IFS="$1"; shift; echo "$*"; }
while read -r line; do # read file line by line
    if [[ ${line:0:1} == "\$" ]]; then
        IFS=' ' read -ra line_tokens <<< "$line" # split line into tokens
        cmd=${line_tokens[0]} # cmd = 1st token
        cmd="${cmd:1}" # strip $ from cmd
        if [ "$cmd" = "enddefinitions" ]; then # marks end of defs section of VCD
            break
        fi
        if [[ "$cmd" == *"scope"* ]]; then # change of scope
            if [ ${#waves[@]} -ne 0 ]; then # there are some waves to dump
                echo "-$(join_with // ${hlevel[*]})" >> $gtkw_filename # comment: current hierarchy level
                color=$(( (color%7)+1 )) # cycle colour
                # dump waves
                dn=""            # deferred wave name      } for building vectors
                di=""            #          wave index     }  from bits
                df=""            #          wave 1st index }
                declare -a dw=() #          wave list      }
                for w in ${waves[*]}; do # dump waves
                    if [ ${w:0-1} = "]" ]; then # wave is vector (whole or bit)
                        IFS='[' read -ra w_parts <<< "${w::-1}"
                        n=${w_parts[0]} # name
                        i=${w_parts[1]} # index
                        if [[ "$i" == *":"* ]]; then # whole vector
                            n=$w
                            i=""
                        fi
                    else # scalar
                        n=$w
                        i=""
                    fi
                    if [ "$di" != "" ]; then # previous wave was vector bit
                        if [ "$dn" != "$n" ]; then # this wave is not part of that vector
                            # dump previous wave vector
                            echo "#{$dn[$df:$di]} ${dw[*]}" >> $gtkw_filename
                            dw=()
                        else # this wave is part of that vector
                            dw+=("$w")
                        fi
                    else # no previous wave to consider
                        df=$i
                        dw=()
                    fi
                    if [ "$i" = "" ]; then # this wave is not vector bit
                        echo "[color] $color" >> $gtkw_filename
                        echo "$w" >> $gtkw_filename
                    fi
                    dn=$n
                    di=$i
                done
                if [ "$di" != "" ]; then # deal with final deferred wave
                    echo "#{$dn[$df:$di]} ${dw[*]}" >> $gtkw_filename
                    dw=()
                fi
                waves=() # reset wave list
            fi
        fi
        if [ "$cmd" = "scope" ]; then
            scope=${line_tokens[2]} # new scope name (descend hierarchy)
            hlevel+=("$scope")
        elif [ "$cmd" = "upscope" ]; then # ascend hierarchy
            unset 'hlevel[$(( ${#hlevel[@]}-1 ))]' # pop last element
            if [ ${#hlevel[@]} -ne 0 ]; then
                scope=${hlevel[-1]}
            else
                scope=""
            fi
        elif [ "$cmd" = "var" ]; then
            wave_name=${line_tokens[4]}
            if [[ "${line_tokens[5]}" == "["*"]" ]]; then # bus wire - concatenate index
                wave_name="$wave_name${line_tokens[5]}"
            fi
            # add signal if not too far down in hierarchy
            if [ $levels -eq 0 ] || [ ${#hlevel[@]} le $levels]; then
                waves+=("$(join_with . ${hlevel[*]}).$wave_name")
            fi
        fi
    fi
done <"$vcd_filename"

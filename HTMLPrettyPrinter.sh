#!/bin/bash

input_file="$1"

if [ ! -f "$input_file" ]; then
    echo "Fisierul nu exista!"
    exit 1
fi

progress_bar() {
    progress=$1
    total=$2

    percent=$(echo "scale=2; $progress / $total * 100" | bc)
    percent=$(echo "$percent / 1" | bc)
    fill=$((percent / 2))

    bar=""
    for ((step=0; step<50; step++)); do
        if [[ step -lt fill ]]; then
            bar+="#"
        else
            bar+="."
        fi
    done

    echo -ne "\r[$bar] $percent%"
}

singletons=("<area>" "<base>" "<br>" "<col>" "<command>" "<embed>" "<hr>" "<img>" "<input>" "<keygen>" "<link>" "<meta>" "<param>" "<source>" "<track>" "<wbr>")
inline=("<abbr>" "<acronym>" "<b>" "<bdo>" "<br>" "<button>" "<cite>" "<code>" "<dfn>" "<em>" "<i>" "<kbd>" "<q>" "<samp>" "<small>" "<span>" "<strong>" "<sub>" "<sup>" "<time>" "<var>")

text=$(<"$input_file")

output_file="pretty_$input_file"

> $output_file

level=-1

for (( i=0; i<${#text}; i++ )); do
    pos=0
    for (( i=0; i<${#text}; i++ )); do
        if [[ "${text:$i:3}" == "<!d" ]] || [[ "${text:$i:3}" == "<!D" ]]; then
            echo -n "${text:$i:15}" >> $output_file
            pos=$i+16
            break
        fi
    done
    
    for (( i=$pos; i<${#text}; i++ )); do
        progress_bar "$i" "${#text}"

        if [[ "${text:$i:1}" == "<" ]]; then
            if [[ "${text:$i+1:1}" != "/" ]]; then
                tag=""
                ok=0
                sg=0
                inl=0
                for (( j=$i; j<${#text}; j++ )); do
                    if [[ "${text:$j:1}" == " " ]] || [[ "${text:$j:1}" == ">" ]] && [[ $ok -eq 0 ]]; then
                        ok=1
                        tag_low=$(echo "$tag" | tr "[A-Z]" "[a-z]")

                        for k in "${singletons[@]}"; do
                            if [[ "$k" == "$tag_low>" ]]; then
                                sg=1
                                break
                            fi
                        done

                        for k in "${inline[@]}"; do
                            if [[ "$k" == "$tag_low>" ]]; then
                                inl=1
                                break
                            fi
                        done
                    fi

                    tag+=${text:$j:1}
                    if [[ "${text:$j:1}" == ">" ]]; then
                        level=$level+1

                        if [[ $inl -eq 1 ]]; then
                            echo -n "$tag" >> $output_file
                        else
                            echo -n $'\n' >> $output_file
                            for (( k=1; k<=$level; k++ )); do
                                echo -n $'\t' >> $output_file
                            done

                            echo -n "$tag" >> $output_file
                        fi

                        if [[ $sg -eq 1 ]]; then
                            level=$level-1
                        fi

                        i=$j
                        break
                    fi
                done

                if [[ $sg -eq 0 ]]; then
                    for (( j=$i+1; j<${#text}; j++ )); do
                        if [[ "${text:$j:1}" == "<" ]]; then
                            i=$j-1
                            break
                        fi

                        if [[ "${text:$j:1}" != " " ]] && [[ "${text:$j:1}" != $'\n' ]] && [[ "${text:$j:1}" != $'\t' ]] && [[ "${text:$j:1}" != "<" ]]; then
                            if [[ $inl -eq 0 ]] && [[ "${tag:0:3}" != "<a " ]]; then
                                echo -n $'\n' >> $output_file
                                for (( k=1; k<=$level+1; k++ )); do
                                    echo -n $'\t' >> $output_file
                                done
                            fi

                            content=""
                            while (( j<${#text} )); do
                                if [[ "${text:$j:1}" == "<" ]]; then
                                    if [[ "${text:$j+1:1}" != "/" ]]; then
                                        echo -n "$content" >> $output_file
                                    fi
                                    break
                                fi

                                content+="${text:j:1}"
                                if [[ "${text:$j:1}" != " " ]] && [[ "${text:$j:1}" != $'\n' ]] && [[ "${text:$j:1}" != $'\t' ]]; then
                                    echo -n "$content" >> $output_file
                                    content=""
                                fi

                                j=$j+1
                            done
                            i=$j-1
                            break
                        fi
                    done
                    i=$j-1
                
                else
                    content=""
                    for (( j=$i+1; j<${#text}; j++ )); do
                        if [[ "${text:$j:1}" == "<" ]]; then
                            i=$j-1
                            break
                        fi

                        content+="${text:j:1}"
                        if [[ "${text:$j:1}" != " " ]] && [[ "${text:$j:1}" != $'\n' ]] && [[ "${text:$j:1}" != $'\t' ]]; then
                            echo -n "$content" >> $output_file
                            content=""
                        fi
                    done
                    i=$j-1
                fi

            else
                tag=""
                ok=0
                inl=0
                for (( j=$i; j<${#text}; j++ )); do
                    if [[ "${text:$j:1}" == " " ]] || [[ "${text:$j:1}" == ">" ]] && [[ $ok -eq 0 ]]; then
                        ok=1
                        tag_low=$(echo "<${tag:2:${#tag}}" | tr "[A-Z]" "[a-z]")

                        for k in "${inline[@]}"; do
                            if [[ "$k" == "$tag_low>" ]]; then
                                inl=1
                                break
                            fi
                        done
                    fi

                    tag+=${text:$j:1}
                    if [[ "${text:$j:1}" == ">" ]]; then
                        if [[ $inl -eq 1 ]]; then
                            echo -n "$tag" >> $output_file
                        else
                            if [[ "$tag" != "</a>" ]]; then
                                echo -n $'\n' >> $output_file
                                for (( k=1; k<=$level; k++ )); do
                                    echo -n $'\t' >> $output_file
                                done
                            fi

                            echo -n "$tag" >> $output_file
                        fi

                        level=$level-1

                        i=$j
                        break
                    fi
                done

                content=""
                for (( j=$i+1; j<${#text}; j++ )); do
                    if [[ "${text:$j:1}" == "<" ]]; then
                        i=$j-1
                        break
                    fi
                    
                    content+="${text:j:1}"
                    if [[ "${text:$j:1}" != " " ]] && [[ "${text:$j:1}" != $'\n' ]] && [[ "${text:$j:1}" != $'\t' ]]; then
                        echo -n "$content" >> $output_file
                        content=""
                    fi
                done
                i=$j-1
            fi
        fi
    done
done

progress_bar "${#text}" "${#text}"
echo -n $'\n'
echo "Fisierul formatat a fost salvat ca \"$output_file\"."
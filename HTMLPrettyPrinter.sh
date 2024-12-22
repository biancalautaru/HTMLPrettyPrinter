#!/bin/bash

input_file="$1"

if [ ! -f "$input_file" ]; then
    echo "Fisierul nu exista!"
    exit 1
fi

singletons=("<area>" "<base>" "<br>" "<col>" "<command>" "<embed>" "<hr>" "<img>" "<input>" "<keygen>" "<link>" "<meta>" "<param>" "<source>" "<track>" "<wbr>")
inline=("<abbr>" "<acronym>" "<b>" "<bdo>" "<br>" "<button>" "<cite>" "<code>" "<dfn>" "<em>" "<i>" "<kbd>" "<q>" "<samp>" "<small>" "<span>" "<strong>" "<sub>" "<sup>" "<time>" "<var>")

text=$(<"$input_file")

output_file="pretty_$input_file"

> $output_file

level=-1

for (( i=0; i<${#text}; i++ )); do
    poz=0
    for (( i=0; i<${#text}; i++ )); do
        if [[ "${text:$i:3}" == "<!d" ]] || [[ "${text:$i:3}" == "<!D" ]]; then # cazul doctype
            echo -n "${text:$i:15}" >> $output_file
            poz=$i+16
            break
        fi
    done
    
    for (( i=$poz; i<${#text}; i++ )); do
        if [[ "${text:$i:1}" == "<" ]]; then
            if [[ "${text:$i+1:1}" != "/" ]]; then # tag de deschidere
                tag=""
                ok=0
                sg=0
                inl=0
                for (( j=$i; j<${#text}; j++ )); do
                    if [[ "${text:$j:1}" == " " ]] || [[ "${text:$j:1}" == ">" ]] && [[ $ok -eq 0 ]]; then
                        ok=1
                        tag_low=$(echo "$tag" | tr "[A-Z]" "[a-z]")

                        for k in "${singletons[@]}"; do
                            if [[ "$k" == "$tag_low>" ]]; then # sg=1 daca e singleton
                                sg=1
                                break
                            fi
                        done

                        for k in "${inline[@]}"; do
                            if [[ "$k" == "$tag_low>" ]]; then # inl=1 daca e inline
                                inl=1
                                break
                            fi
                        done
                    fi

                    tag+=${text:$j:1}
                    if [[ "${text:$j:1}" == ">" ]]; then
                        level=$level+1 # pune tag pe stiva
                        if [[ $inl -eq 1 ]]; then # daca e tag inline, nu pun taburi si newline
                            echo -n "$tag" >> $output_file
                        else
                            echo -n $'\n' >> $output_file
                            for (( k=1; k<=$level; k++ )); do
                                echo -n $'\t' >> $output_file
                            done
                            echo -n "$tag" >> $output_file
                        fi

                        if [[ $sg -eq 1 ]]; then # scoate tag de pe stiva daca e singleton
                            level=$level-1
                        fi

                        i=$j
                        break
                    fi
                done

                if [[ $sg -eq 0 ]]; then
                    for (( j=$i+1; j<${#text}; j++ )); do
                        if [[ "${text:$j:1}" == "<" ]]; then # ajunge la urmatorul tag
                            break
                        fi

                        if [[ "${text:$j:1}" != " " ]] && [[ "${text:$j:1}" != $'\n' ]] && [[ "${line:$j:1}" != $'\t' ]]; then # aici incepe textul
                            if [[ $inl -eq 0 ]]; then
                                echo -n $'\n' >> $output_file
                                for (( k=1; k<=$level+1; k++ )); do
                                    echo -n $'\t' >> $output_file
                                done
                            fi

                            content=""
                            while (( j<${#text} )); do # afiseaza caracterele pana la urmatorul tag
                                if [[ "${text:$j:1}" == "<" ]]; then
                                    if [[ "${text:$j+1:1}" != "/" ]]; then
                                        echo -n "$content" >> $output_file
                                    fi
                                    break
                                fi
                                content+="${text:j:1}"
                                if [[ "${text:$j:1}" != " " ]] && [[ "${text:$j:1}" != $'\n' ]] && [[ "${line:$j:1}" != $'\t' ]]; then
                                    echo -n "$content" >> $output_file
                                    content=""
                                fi
                                j=$j+1
                            done
                            break
                        fi
                    done
                    i=$j-1
                
                else
                    content=""
                    for (( j=$i+1; j<${#text}; j++ )); do
                        if [[ "${text:$j:1}" == "<" ]]; then # ajunge la urmatorul tag
                            break
                        fi
                        content+="${text:j:1}"
                        if [[ "${text:$j:1}" != " " ]] && [[ "${text:$j:1}" != $'\n' ]] && [[ "${line:$j:1}" != $'\t' ]]; then
                            echo -n "$content" >> $output_file
                            content=""
                        fi
                    done
                    i=$j-1
                fi

            else # tag de inchidere
                tag=""
                ok=0
                inl=0
                for (( j=$i; j<${#text}; j++ )); do
                    if [[ "${text:$j:1}" == " " ]] || [[ "${text:$j:1}" == ">" ]] && [[ $ok -eq 0 ]]; then
                        ok=1
                        tag_low=$(echo "<${tag:2:${#tag}}" | tr "[A-Z]" "[a-z]")

                        for k in "${inline[@]}"; do
                            if [[ "$k" == "$tag_low>" ]]; then # inl=1 daca e inline
                                inl=1
                                break
                            fi
                        done
                    fi

                    tag+=${text:$j:1}
                    if [[ "${text:$j:1}" == ">" ]]; then
                        if [[ $inl -eq 1 ]]; then # daca e tag inline, nu pun taburi si newline
                            echo -n "$tag" >> $output_file
                        else
                            echo -n $'\n' >> $output_file
                            for (( k=1; k<=$level; k++ )); do
                                echo -n $'\t' >> $output_file
                            done
                            echo -n "$tag" >> $output_file
                        fi

                        level=$level-1 # scoate tag de pe stiva

                        i=$j
                        break
                    fi
                done

                content=""
                for (( j=$i+1; j<${#text}; j++ )); do
                    if [[ "${text:$j:1}" == "<" ]]; then # ajunge la urmatorul tag
                        break
                    fi
                    content+="${text:j:1}"
                    if [[ "${text:$j:1}" != " " ]] && [[ "${text:$j:1}" != $'\n' ]] && [[ "${line:$j:1}" != $'\t' ]]; then
                        echo -n "$content" >> $output_file
                        content=""
                    fi
                done
                i=$j-1
            fi
        fi
    done
done

echo "Fisierul formatat a fost salvat ca \"$output_file\"."
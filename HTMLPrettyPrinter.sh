#!/bin/bash

input_file="$1"

if [ ! -f "$input_file" ]; then
    echo "Fisierul nu exista!"
    exit 1
fi

singletons=("<area>" "<base>" "<br>" "<col>" "<command>" "<embed>" "<hr>" "<img>" "<input>" "<keygen>" "<link>" "<meta>" "<param>" "<source>" "<track>" "<wbr>")
inline=("<abbr>" "<acronym>" "<b>" "<bdo>" "<button>" "<cite>" "<code>" "<dfn>" "<em>" "<i>" "<kbd>" "<q>" "<samp>" "<small>" "<span>" "<strong>" "<sub>" "<sup>" "<time>" "<var>")

output_file="pretty_$input_file"

> $output_file

level=-1

cat $input_file | while IFS="" read -r line || [[ -n "$line" ]]; do
    poz=0
    for (( i=0; i<${#line}; i++ )); do
        if [[ "${line:$i:3}" == "<!d" ]] || [[ "${line:$i:3}" == "<!D" ]]; then # cazul doctype
            echo -n "${line:$i:15}" >> $output_file
            poz=$i+16
            break
        fi
    done
    
    for (( i=$poz; i<${#line}; i++ )); do
        if [[ "${line:$i:1}" == "<" ]]; then
            if [[ "${line:$i+1:1}" != "/" ]]; then # tag de deschidere
                tag=""
                ok=0
                sg=0
                inl=0
                for (( j=$i; j<${#line}; j++ )); do
                    if [[ "${line:$j:1}" == " " ]] || [[ "${line:$j:1}" == ">" ]] && [[ $ok -eq 0 ]]; then
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

                    tag+=${line:$j:1}
                    if [[ "${line:$j:1}" == ">" ]]; then
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
            fi

            if [[ "${line:$i+1:1}" == "/" ]]; then # tag de inchidere
                tag=""
                ok=0
                inl=0
                for (( j=$i; j<${#line}; j++ )); do
                    if [[ "${line:$j:1}" == " " ]] || [[ "${line:$j:1}" == ">" ]] && [[ $ok -eq 0 ]]; then
                        ok=1
                        tag_low=$(echo "<${tag:2:${#tag}}" | tr "[A-Z]" "[a-z]")

                        for k in "${inline[@]}"; do
                            if [[ "$k" == "$tag_low>" ]]; then # inl=1 daca e inline
                                inl=1
                                break
                            fi
                        done
                    fi

                    tag+=${line:$j:1}
                    if [[ "${line:$j:1}" == ">" ]]; then
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
            fi

        # else
            # sarim pana la primul caracter care nu e spatiu sau < si afisam
            # la fiecare spatiu, parcurgem spatiile si le afisam abia daca ajungem la un caracter care nu e spatiu si nu e <
        fi
    done
done

echo "Fisierul formatat a fost salvat ca \"$output_file\"."
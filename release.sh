#!/bin/bash

# Current Version: 1.2.10 (Fixed domain processing)

## How to get and use?
# git clone "https://github.com/hezhijie0327/GFWList2AGH.git" && bash ./GFWList2AGH/release.sh

## Function
# Get Data
function GetData() {
    cnacc_domain=(
        "https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/direct-list.txt"
        "https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/apple-cn.txt"
        "https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/master/rule/Clash/GoogleFCM/GoogleFCM.list"
        "https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/master/rule/Clash/GovCN/GovCN.list"
        "https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/master/rule/Clash/China/China.list"
        "https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/master/rule/Clash/ChinaMaxNoIP/ChinaMaxNoIP.list"
        "https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/master/rule/Clash/DouYin/DouYin.list"
        "https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/master/rule/Clash/Tencent/Tencent.list"
        "https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/master/rule/Clash/UnionPay/UnionPay.list"
        "https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/master/rule/Clash/XiaoHongShu/XiaoHongShu.list"
        "https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/master/rule/Clash/ChinaUnicom/ChinaUnicom.list"
        "https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/master/rule/Clash/ChinaMobile/ChinaMobile.list"
        "https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/master/rule/Clash/ChinaTelecom/ChinaTelecom.list"
        "https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/master/rule/Clash/ChinaNoMedia/ChinaNoMedia.list"
        "https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/master/rule/Clash/JingDong/JingDong.list"
        "https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/master/rule/Clash/BiliBili/BiliBili.list"
        "https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/master/rule/Clash/Pinduoduo/Pinduoduo.list"
        "https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/master/rule/Clash/XiaoMi/XiaoMi.list"
        "https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/master/rule/Clash/NetEase/NetEase.list"
        "https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/master/rule/Clash/NetEaseMusic/NetEaseMusic.list"
    )
    cnacc_trusted=(
        "https://raw.githubusercontent.com/felixonmars/dnsmasq-china-list/master/accelerated-domains.china.conf"
        "https://raw.githubusercontent.com/felixonmars/dnsmasq-china-list/master/apple.china.conf"
        "https://raw.githubusercontent.com/felixonmars/dnsmasq-china-list/master/google.china.conf"
    )
    gfwlist_base64=(
        "https://raw.githubusercontent.com/Loukky/gfwlist-by-loukky/master/gfwlist.txt"
        "https://raw.githubusercontent.com/gfwlist/gfwlist/master/gfwlist.txt"
        "https://raw.githubusercontent.com/poctopus/gfwlist-plus/master/gfwlist-plus.txt"
    )
    gfwlist_domain=(
        "https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/gfw.txt"
        "https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/greatfire.txt"
        "https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/proxy-list.txt"
        "https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/master/rule/Surge/Global/Global_Domain.list"
        "https://raw.githubusercontent.com/pexcn/gfwlist-extras/master/gfwlist-extras.txt"
    )
    gfwlist2agh_modify=(
        "https://raw.githubusercontent.com/WPF0414/GFWList2AGH/refs/heads/source/data/data_modify.txt"
    )
    rm -rf ./gfwlist2* ./Temp && mkdir ./Temp && cd ./Temp
    for cnacc_domain_task in "${!cnacc_domain[@]}"; do
        curl -s --connect-timeout 15 "${cnacc_domain[$cnacc_domain_task]}" >> ./cnacc_domain.tmp
    done
    for cnacc_trusted_task in "${!cnacc_trusted[@]}"; do
        curl -s --connect-timeout 15 "${cnacc_trusted[$cnacc_trusted_task]}" >> ./cnacc_trusted.tmp
    done
    for gfwlist_base64_task in "${!gfwlist_base64[@]}"; do
        curl -s --connect-timeout 15 "${gfwlist_base64[$gfwlist_base64_task]}" | base64 -d >> ./gfwlist_base64.tmp
    done
    for gfwlist_domain_task in "${!gfwlist_domain[@]}"; do
        curl -s --connect-timeout 15 "${gfwlist_domain[$gfwlist_domain_task]}" >> ./gfwlist_domain.tmp
    done
    for gfwlist2agh_modify_task in "${!gfwlist2agh_modify[@]}"; do
        curl -s --connect-timeout 15 "${gfwlist2agh_modify[$gfwlist2agh_modify_task]}" >> ./gfwlist2agh_modify.tmp
    done
}

# Analyse Data
function AnalyseData() {
    # Create a more inclusive domain regex that handles numeric domains like "0.zone"
    domain_regex="^([a-z0-9*\-]([a-z0-9\-]{0,61}[a-z0-9])?\.)+[a-z0-9][a-z0-9\-]{0,61}[a-z0-9]$"
    lite_domain_regex="^[a-z0-9*\-][a-z0-9\-]{0,61}[a-z0-9](\.[a-z0-9][a-z0-9\-]{0,61}[a-z0-9])+$"
    
    # Pre-process the input files to properly handle DOMAIN and convert DOMAIN-SUFFIX to wildcard pattern
    # Filter out comments first with highest priority
    cat "./cnacc_domain.tmp" | grep -v "^#" | grep -v "DOMAIN:" | grep -v "IP-CIDR:" | grep -v "TOTAL:" | sed -E 's/^DOMAIN-SUFFIX,([^,]+)$/\*-a.\1/g; s/^(DOMAIN|DOMAIN-KEYWORD|URL-REGEX),//g' > "./cnacc_domain_processed.tmp"
    cat "./gfwlist_domain.tmp" | grep -v "^#" | grep -v "DOMAIN:" | grep -v "IP-CIDR:" | grep -v "TOTAL:" | sed -E 's/^DOMAIN-SUFFIX,([^,]+)$/\*-a.\1/g; s/^(DOMAIN|DOMAIN-KEYWORD|URL-REGEX),//g' > "./gfwlist_domain_processed.tmp"
    
    # Debug: Save the pre-processed files for inspection
    cp "./cnacc_domain.tmp" "./debug_original_cnacc_domain.tmp"
    cp "./cnacc_domain_processed.tmp" "./debug_processed_cnacc_domain.tmp"
    
    # Continue with the standard processing but prioritize comment filtering
    cat "./gfwlist2agh_modify.tmp" | grep -v "^#" | grep "\(\@\%\@\)\|\(\@\%\!\)\|\(\!\&\@\)\|\(\@\@\@\)" | tr -d "\!\%\&\(\)\*\@" | sort | uniq > "./cnacc_addition.tmp"
    cat "./gfwlist2agh_modify.tmp" | grep -v "^#" | grep "\(\!\%\!\)\|\(\@\&\!\)\|\(\!\%\@\)\|\(\!\!\!\)" | tr -d "\!\%\&\(\)\*\@" | sort | uniq > "./cnacc_subtraction.tmp"
    cat "./gfwlist2agh_modify.tmp" | grep -v "^#" | grep "\(\*\%\*\)\|\(\*\*\*\)" | tr -d "\!\%\&\(\)\*\@" | xargs | sed "s/\ /\|/g" | sort | uniq > "./cnacc_exclusion.tmp"
    cat "./gfwlist2agh_modify.tmp" | grep -v "^#" | grep "\(\*\%\*\)\|\(\*\*\*\)" | tr -d "\!\%\&\(\)\*\@" | xargs | sed "s/\ /\|/g" | sort | uniq > "./lite_cnacc_exclusion.tmp"
    cat "./gfwlist2agh_modify.tmp" | grep -v "^#" | grep "\(\!\%\*\)\|\(\!\*\*\)" | tr -d "\!\%\&\(\)\*\@" | xargs | sed "s/\ /\|/g" | sort | uniq > "./cnacc_keyword.tmp"
    cat "./gfwlist2agh_modify.tmp" | grep -v "^#" | grep "\(\!\%\*\)\|\(\!\*\*\)" | tr -d "\!\%\&\(\)\*\@" | xargs | sed "s/\ /\|/g" | sort | uniq > "./lite_cnacc_keyword.tmp"
    cat "./gfwlist2agh_modify.tmp" | grep -v "^#" | grep "\(\@\&\@\)\|\(\@\&\!\)\|\(\!\%\@\)\|\(\@\@\@\)" | tr -d "\!\%\&\(\)\*\@" | sort | uniq > "./gfwlist_addition.tmp"
    cat "./gfwlist2agh_modify.tmp" | grep -v "^#" | grep "\(\!\&\!\)\|\(\@\%\!\)\|\(\!\&\@\)\|\(\!\!\!\)" | tr -d "\!\%\&\(\)\*\@" | sort | uniq > "./gfwlist_subtraction.tmp"
    cat "./gfwlist2agh_modify.tmp" | grep -v "^#" | grep "\(\*\&\*\)\|\(\*\*\*\)" | tr -d "\!\%\&\(\)\*\@" | xargs | sed "s/\ /\|/g" | sort | uniq > "./gfwlist_exclusion.tmp"
    cat "./gfwlist2agh_modify.tmp" | grep -v "^#" | grep "\(\*\&\*\)\|\(\*\*\*\)" | tr -d "\!\%\&\(\)\*\@" | xargs | sed "s/\ /\|/g" | sort | uniq > "./lite_gfwlist_exclusion.tmp"
    cat "./gfwlist2agh_modify.tmp" | grep -v "^#" | grep "\(\!\&\*\)\|\(\!\*\*\)" | tr -d "\!\%\&\(\)\*\@" | xargs | sed "s/\ /\|/g" | sort | uniq > "./gfwlist_keyword.tmp"
    cat "./gfwlist2agh_modify.tmp" | grep -v "^#" | grep "\(\!\&\*\)\|\(\!\*\*\)" | tr -d "\!\%\&\(\)\*\@" | xargs | sed "s/\ /\|/g" | sort | uniq > "./lite_gfwlist_keyword.tmp"
    
    # Extract lite domains (only valid domains), prioritize comment filtering
    cat "./cnacc_addition.tmp" | grep -v "^#" | grep -E "${lite_domain_regex}" | sort | uniq > "./lite_cnacc_addition.tmp"
    cat "./gfwlist_addition.tmp" | grep -v "^#" | grep -E "${lite_domain_regex}" | sort | uniq > "./lite_gfwlist_addition.tmp"
    
    # Process trusted CNAccelerator domains, prioritize comment filtering
    cat "./cnacc_trusted.tmp" | grep -v "^#" | sed "s/\/114\.114\.114\.114//g;s/server\=\///g" | tr "A-Z" "a-z" > "./cnacc_trust.tmp"
    cat "./cnacc_trust.tmp" | grep -v "^#" | grep -E "${lite_domain_regex}" | sort | uniq > "./lite_cnacc_trust.tmp"
    
    # Process main domain lists with more flexible filtering and maintain wildcard patterns, prioritize comment filtering
    cat "./cnacc_domain_processed.tmp" | grep -v "^#" | sed "s/domain\://g;s/full\://g" | tr "A-Z" "a-z" | grep -E "${domain_regex}" > "./cnacc_checklist.tmp"
    cat "./gfwlist_base64.tmp" "./gfwlist_domain_processed.tmp" | grep -v "^#" | sed "s/domain\://g;s/full\://g;s/http\:\/\///g;s/https\:\/\///g" | tr -d "|" | tr "A-Z" "a-z" | grep -E "${domain_regex}" > "./gfwlist_checklist.tmp"
    
    # Save debug copies before domain extraction
    cp "./cnacc_checklist.tmp" "./debug_cnacc_checklist.tmp"
    cp "./gfwlist_checklist.tmp" "./debug_gfwlist_checklist.tmp"
    
    # Process lite domain lists, prioritize comment filtering
    cat "./cnacc_checklist.tmp" | grep -v "^#" | rev | cut -d "." -f 1,2 | rev | sort | uniq > "./lite_cnacc_checklist.tmp"
    cat "./gfwlist_checklist.tmp" | grep -v "^#" | rev | cut -d "." -f 1,2 | rev | sort | uniq > "./lite_gfwlist_checklist.tmp"
    
    # Create raw lists with more lenient filtering
    awk 'NR == FNR { tmp[$0] = 1 } NR > FNR { if ( tmp[$0] != 1 ) print }' "./cnacc_checklist.tmp" "./gfwlist_checklist.tmp" > "./gfwlist_raw.tmp"
    awk 'NR == FNR { tmp[$0] = 1 } NR > FNR { if ( tmp[$0] != 1 ) print }' "./gfwlist_checklist.tmp" "./cnacc_checklist.tmp" > "./cnacc_raw.tmp"
    
    # Create lite raw lists
    awk 'NR == FNR { tmp[$0] = 1 } NR > FNR { if ( tmp[$0] != 1 ) print }' "./lite_cnacc_checklist.tmp" "./lite_gfwlist_checklist.tmp" > "./lite_gfwlist_raw.tmp"
    awk 'NR == FNR { tmp[$0] = 1 } NR > FNR { if ( tmp[$0] != 1 ) print }' "./lite_gfwlist_checklist.tmp" "./lite_cnacc_checklist.tmp" > "./lite_cnacc_raw.tmp"
    
    # Process trusted domains
    awk 'NR == FNR { tmp[$0] = 1 } NR > FNR { if ( tmp[$0] != 1 ) print }' "./cnacc_trust.tmp" "./gfwlist_raw.tmp" > "./gfwlist_raw_new.tmp"
    awk 'NR == FNR { tmp[$0] = 1 } NR > FNR { if ( tmp[$0] != 1 ) print }' "./cnacc_trust.tmp" "./lite_gfwlist_raw.tmp" > "./lite_gfwlist_raw_new.tmp"
    
    # Combine lists, prioritize comment filtering
    cat "./cnacc_raw.tmp" "./lite_cnacc_raw.tmp" "./cnacc_addition.tmp" "./lite_cnacc_addition.tmp" "./cnacc_trust.tmp" "./lite_cnacc_trust.tmp" | grep -v "^#" | sort | uniq > "./cnacc_added.tmp"
    cat "./gfwlist_raw_new.tmp" "./lite_gfwlist_raw_new.tmp" "./gfwlist_addition.tmp" "./lite_gfwlist_addition.tmp" | grep -v "^#" | sort | uniq > "./gfwlist_added.tmp"
    cat "./lite_cnacc_raw.tmp" "./lite_cnacc_addition.tmp" "./lite_cnacc_trust.tmp" | grep -v "^#" | sort | uniq > "./lite_cnacc_added.tmp"
    cat "./lite_gfwlist_raw_new.tmp" "./lite_gfwlist_addition.tmp" | grep -v "^#" | sort | uniq > "./lite_gfwlist_added.tmp"
    
    # Apply subtractions
    awk 'NR == FNR { tmp[$0] = 1 } NR > FNR { if ( tmp[$0] != 1 ) print }' "./cnacc_subtraction.tmp" "./cnacc_added.tmp" > "./cnacc_data.tmp"
    awk 'NR == FNR { tmp[$0] = 1 } NR > FNR { if ( tmp[$0] != 1 ) print }' "./gfwlist_subtraction.tmp" "./gfwlist_added.tmp" > "./gfwlist_data.tmp"
    awk 'NR == FNR { tmp[$0] = 1 } NR > FNR { if ( tmp[$0] != 1 ) print }' "./cnacc_subtraction.tmp" "./lite_cnacc_added.tmp" > "./lite_cnacc_data.tmp"
    awk 'NR == FNR { tmp[$0] = 1 } NR > FNR { if ( tmp[$0] != 1 ) print }' "./gfwlist_subtraction.tmp" "./lite_gfwlist_added.tmp" > "./lite_gfwlist_data.tmp"
    
    # Debug: Check content of intermediate files before wildcard filtering
    echo "Debug: Content count before wildcard filtering"
    echo "cnacc_data.tmp count: $(wc -l < ./cnacc_data.tmp)"
    echo "gfwlist_data.tmp count: $(wc -l < ./gfwlist_data.tmp)"
    echo "lite_cnacc_data.tmp count: $(wc -l < ./lite_cnacc_data.tmp)"
    echo "lite_gfwlist_data.tmp count: $(wc -l < ./lite_gfwlist_data.tmp)"
    
    # Remove single domains covered by wildcard (*-a.) patterns independently for each list
    # Process cnacc_data.tmp: Extract wildcards and remove matching single domains within cnacc_data
    cat "./cnacc_data.tmp" | grep "^\*-a\." | sed 's/^\*-a\.//g' > "./cnacc_wildcards.tmp"
    if [ -s "./cnacc_wildcards.tmp" ]; then
        cat "./cnacc_data.tmp" | grep -v "^\*-a\." | awk 'NR == FNR { tmp[$0] = 1 } NR > FNR { if ( tmp[$0] != 1 ) print }' "./cnacc_wildcards.tmp" - > "./cnacc_data_non_wildcard_filtered.tmp"
        cat "./cnacc_data_non_wildcard_filtered.tmp" "./cnacc_data.tmp" | grep "^\*-a\." | sort | uniq > "./cnacc_data_filtered.tmp"
    else
        cp "./cnacc_data.tmp" "./cnacc_data_filtered.tmp"
    fi
    
    # Process gfwlist_data.tmp: Extract wildcards and remove matching single domains within gfwlist_data
    cat "./gfwlist_data.tmp" | grep "^\*-a\." | sed 's/^\*-a\.//g' > "./gfwlist_wildcards.tmp"
    if [ -s "./gfwlist_wildcards.tmp" ]; then
        cat "./gfwlist_data.tmp" | grep -v "^\*-a\." | awk 'NR == FNR { tmp[$0] = 1 } NR > FNR { if ( tmp[$0] != 1 ) print }' "./gfwlist_wildcards.tmp" - > "./gfwlist_data_non_wildcard_filtered.tmp"
        cat "./gfwlist_data_non_wildcard_filtered.tmp" "./gfwlist_data.tmp" | grep "^\*-a\." | sort | uniq > "./gfwlist_data_filtered.tmp"
    else
        cp "./gfwlist_data.tmp" "./gfwlist_data_filtered.tmp"
    fi
    
    # Process lite_cnacc_data.tmp: Extract wildcards and remove matching single domains within lite_cnacc_data
    cat "./lite_cnacc_data.tmp" | grep "^\*-a\." | sed 's/^\*-a\.//g' > "./lite_cnacc_wildcards.tmp"
    if [ -s "./lite_cnacc_wildcards.tmp" ]; then
        cat "./lite_cnacc_data.tmp" | grep -v "^\*-a\." | awk 'NR == FNR { tmp[$0] = 1 } NR > FNR { if ( tmp[$0] != 1 ) print }' "./lite_cnacc_wildcards.tmp" - > "./lite_cnacc_data_non_wildcard_filtered.tmp"
        cat "./lite_cnacc_data_non_wildcard_filtered.tmp" "./lite_cnacc_data.tmp" | grep "^\*-a\." | sort | uniq > "./lite_cnacc_data_filtered.tmp"
    else
        cp "./lite_cnacc_data.tmp" "./lite_cnacc_data_filtered.tmp"
    fi
    
    # Process lite_gfwlist_data.tmp: Extract wildcards and remove matching single domains within lite_gfwlist_data
    cat "./lite_gfwlist_data.tmp" | grep "^\*-a\." | sed 's/^\*-a\.//g' > "./lite_gfwlist_wildcards.tmp"
    if [ -s "./lite_gfwlist_wildcards.tmp" ]; then
        cat "./lite_gfwlist_data.tmp" | grep -v "^\*-a\." | awk 'NR == FNR { tmp[$0] = 1 } NR > FNR { if ( tmp[$0] != 1 ) print }' "./lite_gfwlist_wildcards.tmp" - > "./lite_gfwlist_data_non_wildcard_filtered.tmp"
        cat "./lite_gfwlist_data_non_wildcard_filtered.tmp" "./lite_gfwlist_data.tmp" | grep "^\*-a\." | sort | uniq > "./lite_gfwlist_data_filtered.tmp"
    else
        cp "./lite_gfwlist_data.tmp" "./lite_gfwlist_data_filtered.tmp"
    fi
    
    # Debug: Check content of filtered files after wildcard filtering
    echo "Debug: Content count after wildcard filtering"
    echo "cnacc_data_filtered.tmp count: $(wc -l < ./cnacc_data_filtered.tmp)"
    echo "gfwlist_data_filtered.tmp count: $(wc -l < ./gfwlist_data_filtered.tmp)"
    echo "lite_cnacc_data_filtered.tmp count: $(wc -l < ./lite_cnacc_data_filtered.tmp)"
    echo "lite_gfwlist_data_filtered.tmp count: $(wc -l < ./lite_gfwlist_data_filtered.tmp)"
    
    # Save final data arrays after filtering out single domains covered by wildcards, prioritize comment filtering
    cnacc_data=($(cat "./cnacc_data_filtered.tmp" | grep -v "^#" | sort | uniq))
    gfwlist_data=($(cat "./gfwlist_data_filtered.tmp" | grep -v "^#" | sort | uniq))
    lite_cnacc_data=($(cat "./lite_cnacc_data_filtered.tmp" | grep -v "^#" | sort | uniq))
    lite_gfwlist_data=($(cat "./lite_gfwlist_data_filtered.tmp" | grep -v "^#" | sort | uniq))
    
    # Debug: Check final array sizes
    echo "Debug: Final array sizes"
    echo "cnacc_data size: ${#cnacc_data[@]}"
    echo "gfwlist_data size: ${#gfwlist_data[@]}"
    echo "lite_cnacc_data size: ${#lite_cnacc_data[@]}"
    echo "lite_gfwlist_data size: ${#lite_gfwlist_data[@]}"
}

# Generate Rules
function GenerateRules() {
    function FileName() {
        if [ "${generate_file}" == "black" ]; then
            generate_temp="black"
        elif [ "${generate_file}" == "white" ]; then
            generate_temp="white"
        else
            generate_temp="debug"
        fi
        if [ "${software_name}" == "smartdns" ]; then
            file_extension="conf"
        else
            file_extension="dev"
        fi
        if [ ! -d "../gfwlist2${software_name}" ]; then
            mkdir "../gfwlist2${software_name}"
        fi
        file_name="${generate_temp}list_${generate_mode}.${file_extension}"
        file_path="../gfwlist2${software_name}/${file_name}"
    }

    case ${software_name} in
        smartdns)
            if [ "${generate_mode}" == "full" ]; then
                if [ "${generate_file}" == "black" ]; then
                    FileName && for gfwlist_data_task in "${!gfwlist_data[@]}"; do
                        echo "${gfwlist_data[$gfwlist_data_task]}" >> "${file_path}"
                    done
                elif [ "${generate_file}" == "white" ]; then
                    FileName && for cnacc_data_task in "${!cnacc_data[@]}"; do
                        echo "${cnacc_data[$cnacc_data_task]}" >> "${file_path}"
                    done
                elif [ "${generate_file}" == "debug" ]; then
                    # Generate a debug file with problematic domains
                    FileName
                    cp "./debug_domain_check.txt" "${file_path}"
                    # Also copy the debug files to output
                    cp ./debug_*.tmp "../gfwlist2${software_name}/"
                fi
            elif [ "${generate_mode}" == "lite" ]; then
                if [ "${generate_file}" == "black" ]; then
                    FileName && for lite_gfwlist_data_task in "${!lite_gfwlist_data[@]}"; do
                        echo "${lite_gfwlist_data[$lite_gfwlist_data_task]}" >> "${file_path}"
                    done
                elif [ "${generate_file}" == "white" ]; then
                    FileName && for lite_cnacc_data_task in "${!lite_cnacc_data[@]}"; do
                        echo "${lite_cnacc_data[$lite_cnacc_data_task]}" >> "${file_path}"
                    done
                fi
            fi
        ;;
        *)
            exit 1
    esac
}

# Output Data with Debug Output
function OutputData() {
    ## SmartDNS
    software_name="smartdns" && generate_file="black" && generate_mode="full" && foreign_group="foreign" && GenerateRules
    software_name="smartdns" && generate_file="white" && generate_mode="full" && domestic_group="domestic" && GenerateRules
    cd .. && rm -rf ./Temp
    exit 0
}

## Process
# Call GetData
GetData
# Call AnalyseData
AnalyseData
# Call OutputData
OutputData

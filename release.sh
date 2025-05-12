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
    
    # Process all domain list files - Improved to handle multiple formats systematically
    
    # Step 1: Filter out comments and empty lines, keep only relevant entries for processing
    cat "./cnacc_domain.tmp" | grep -v "^#" | grep -v "^$" > "./cnacc_domain_no_comments.tmp"
    cat "./gfwlist_domain.tmp" | grep -v "^#" | grep -v "^$" > "./gfwlist_domain_no_comments.tmp"
    
    # Step 2: Process rules by type and extract only the domain part
    # Process DOMAIN and DOMAIN-SUFFIX entries
    cat "./cnacc_domain_no_comments.tmp" | grep "^DOMAIN" | sed -E 's/^DOMAIN-SUFFIX,([^,]+)$/\1/g; s/^DOMAIN,([^,]+)$/\1/g' > "./cnacc_domain_processed.tmp"
    cat "./gfwlist_domain_no_comments.tmp" | grep "^DOMAIN" | sed -E 's/^DOMAIN-SUFFIX,([^,]+)$/\1/g; s/^DOMAIN,([^,]+)$/\1/g' > "./gfwlist_domain_processed.tmp"
    
    # Process URL and other entries that might contain domains
    cat "./cnacc_domain_no_comments.tmp" | grep -v "^DOMAIN" | grep -v "^IP-CIDR" | sed -E 's/^(URL-REGEX|IP6-CIDR|PROCESS-NAME|USER-AGENT),.*//g' | grep -v "^$" >> "./cnacc_domain_processed.tmp"
    cat "./gfwlist_domain_no_comments.tmp" | grep -v "^DOMAIN" | grep -v "^IP-CIDR" | sed -E 's/^(URL-REGEX|IP6-CIDR|PROCESS-NAME|USER-AGENT),.*//g' | grep -v "^$" >> "./gfwlist_domain_processed.tmp"
    
    # Debug: Save intermediate processed files
    cp "./cnacc_domain_no_comments.tmp" "./debug_cnacc_domain_no_comments.tmp"
    
    # Process GFWList from base64 sources
    if [ -f "./gfwlist_base64.tmp" ]; then
        cat "./gfwlist_base64.tmp" | grep -v "^!" | grep -v "^$" | grep -v "\[" > "./gfwlist_base64_filtered.tmp"
    fi
    
    # Process trusted China domain lists (dnsmasq format)
    if [ -f "./cnacc_trusted.tmp" ]; then
        cat "./cnacc_trusted.tmp" | grep -v "^#" | grep -v "^$" | sed -e 's/^server=\///g' -e 's/\/.*$//g' > "./cnacc_trusted_processed.tmp"
    fi
    
    # Combine all processed domain lists
    cat ./cnacc_domain_processed.tmp ./cnacc_trusted_processed.tmp 2>/dev/null | sort -u > ./all_cnacc_domains.tmp
    cat ./gfwlist_domain_processed.tmp ./gfwlist_base64_filtered.tmp 2>/dev/null | sort -u > ./all_gfw_domains.tmp
    
    # Apply regex filtering to ensure valid domains only
    cat ./all_cnacc_domains.tmp | grep -E "$domain_regex" > ./cnacc_data_filtered.tmp
    cat ./all_gfw_domains.tmp | grep -E "$domain_regex" > ./gfwlist_data_filtered.tmp
    
    # Create lite versions with second-level domains only
    cat ./cnacc_data_filtered.tmp | grep -E "$lite_domain_regex" | sed -e 's/^.*\.\([^.]*\.[^.]*\)$/\1/g' | sort -u > ./lite_cnacc_data.tmp
    cat ./gfwlist_data_filtered.tmp | grep -E "$lite_domain_regex" | sed -e 's/^.*\.\([^.]*\.[^.]*\)$/\1/g' | sort -u > ./lite_gfwlist_data.tmp
    
    # Apply custom modifications
    if [ -f "./gfwlist2agh_modify.tmp" ]; then
        cat "./gfwlist2agh_modify.tmp" | grep -v "^#" | grep -v "^$" | while read line; do
            mode=$(echo $line | cut -d ',' -f1)
            domain=$(echo $line | cut -d ',' -f2)
            if [ "$mode" == "add-white" ]; then
                echo "$domain" >> ./cnacc_data_filtered.tmp
            elif [ "$mode" == "add-black" ]; then
                echo "$domain" >> ./gfwlist_data_filtered.tmp
            elif [ "$mode" == "remove-white" ]; then
                sed -i "/^$domain$/d" ./cnacc_data_filtered.tmp
            elif [ "$mode" == "remove-black" ]; then
                sed -i "/^$domain$/d" ./gfwlist_data_filtered.tmp
            fi
        done
    fi
    
    # Generate debug file with any problematic entries
    cat ./cnacc_domain_processed.tmp ./gfwlist_domain_processed.tmp 2>/dev/null | grep -v -E "$domain_regex" > ./debug_domain_check.txt
    
    # Final preparations for generating rules
    readarray -t cnacc_data < <(cat ./cnacc_data_filtered.tmp | sort -u)
    readarray -t gfwlist_data < <(cat ./gfwlist_data_filtered.tmp | sort -u)
    readarray -t lite_cnacc_data < <(cat ./lite_cnacc_data.tmp | sort -u)
    readarray -t lite_gfwlist_data < <(cat ./lite_gfwlist_data.tmp | sort -u)
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
    software_name="smartdns" && generate_file="debug" && generate_mode="full" && GenerateRules
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

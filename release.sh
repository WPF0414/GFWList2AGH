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
# Analyse Data
# Analyse Data
function AnalyseData() {
    # Create a more inclusive domain regex that handles numeric domains like "0.zone"
    domain_regex="^([a-z0-9*\-]([a-z0-9\-]{0,61}[a-z0-9])?\.)+[a-z0-9][a-z0-9\-]{0,61}[a-z0-9]$"
    lite_domain_regex="^[a-z0-9*\-][a-z0-9\-]{0,61}[a-z0-9](\.[a-z0-9][a-z0-9\-]{0,61}[a-z0-9])+$"
    
    # Pre-process the input files to properly handle DOMAIN and convert DOMAIN-SUFFIX to wildcard pattern
    # Filter out comments, stats (like DOMAIN: 9), IP-CIDR, disabled content, and other irrelevant lines
    cat "./cnacc_domain.tmp" | grep -v "^#" | grep -v "DOMAIN:" | grep -v "IP-CIDR:" | grep -v "TOTAL:" | grep -v "disabled:" | grep -v "http" | sed -E 's/^DOMAIN-SUFFIX,([^,]+)$/\*-a.\1/g; s/^(DOMAIN|DOMAIN-KEYWORD|URL-REGEX),//g' > "./cnacc_domain_processed.tmp"
    cat "./gfwlist_domain.tmp" | grep -v "^#" | grep -v "DOMAIN:" | grep -v "IP-CIDR:" | grep -v "TOTAL:" | grep -v "disabled:" | grep -v "http" | sed -E 's/^DOMAIN-SUFFIX,([^,]+)$/\*-a.\1/g; s/^(DOMAIN|DOMAIN-KEYWORD|URL-REGEX),//g' > "./gfwlist_domain_processed.tmp"
    
    # Debug: Save the pre-processed files for inspection
    cp "./cnacc_domain.tmp" "./debug_original_cnacc_domain.tmp"
    cp "./cnacc_domain_processed.tmp" "./debug_processed_cnacc_domain.tmp"
    
    # Continue with the standard processing but use the pre-processed files
    cat "./gfwlist2agh_modify.tmp" | grep -v "\#" | grep "\(\@\%\@\)\|\(\@\%\!\)\|\(\!\&\@\)\|\(\@\@\@\)" | tr -d "\!\%\&\(\)\*\@" | sort | uniq > "./cnacc_addition.tmp"
    cat "./gfwlist2agh_modify.tmp" | grep -v "\#" | grep "\(\!\%\!\)\|\(\@\&\!\)\|\(\!\%\@\)\|\(\!\!\!\)" | tr -d "\!\%\&\(\)\*\@" | sort | uniq > "./cnacc_subtraction.tmp"
    cat "./gfwlist2agh_modify.tmp" | grep -v "\#" | grep "\(\*\%\*\)\|\(\*\*\*\)" | tr -d "\!\%\&\(\)\*\@" | xargs | sed "s/\ /\|/g" | sort | uniq > "./cnacc_exclusion.tmp"
    cat "./gfwlist2agh_modify.tmp" | grep -v "\#" | grep "\(\*\%\*\)\|\(\*\*\*\)" | tr -d "\!\%\&\(\)\*\@" | xargs | sed "s/\ /\|/g" | sort | uniq > "./lite_cnacc_exclusion.tmp"
    cat "./gfwlist2agh_modify.tmp" | grep -v "\#" | grep "\(\!\%\*\)\|\(\!\*\*\)" | tr -d "\!\%\&\(\)\*\@" | xargs | sed "s/\ /\|/g" | sort | uniq > "./cnacc_keyword.tmp"
    cat "./gfwlist2agh_modify.tmp" | grep -v "\#" | grep "\(\!\%\*\)\|\(\!\*\*\)" | tr -d "\!\%\&\(\)\*\@" | xargs | sed "s/\ /\|/g" | sort | uniq > "./lite_cnacc_keyword.tmp"
    cat "./gfwlist2agh_modify.tmp" | grep -v "\#" | grep "\(\@\&\@\)\|\(\@\&\!\)\|\(\!\%\@\)\|\(\@\@\@\)" | tr -d "\!\%\&\(\)\*\@" | sort | uniq > "./gfwlist_addition.tmp"
    cat "./gfwlist2agh_modify.tmp" | grep -v "\#" | grep "\(\!\&\!\)\|\(\@\%\!\)\|\(\!\&\@\)\|\(\!\!\!\)" | tr -d "\!\%\&\(\)\*\@" | sort | uniq > "./gfwlist_subtraction.tmp"
    cat "./gfwlist2agh_modify.tmp" | grep -v "\#" | grep "\(\*\&\*\)\|\(\*\*\*\)" | tr -d "\!\%\&\(\)\*\@" | xargs | sed "s/\ /\|/g" | sort | uniq > "./gfwlist_exclusion.tmp"
    cat "./gfwlist2agh_modify.tmp" | grep -v "\#" | grep "\(\*\&\*\)\|\(\*\*\*\)" | tr -d "\!\%\&\(\)\*\@" | xargs | sed "s/\ /\|/g" | sort | uniq > "./lite_gfwlist_exclusion.tmp"
    cat "./gfwlist2agh_modify.tmp" | grep -v "\#" | grep "\(\!\&\*\)\|\(\!\*\*\)" | tr -d "\!\%\&\(\)\*\@" | xargs | sed "s/\ /\|/g" | sort | uniq > "./gfwlist_keyword.tmp"
    cat "./gfwlist2agh_modify.tmp" | grep -v "\#" | grep "\(\!\&\*\)\|\(\!\*\*\)" | tr -d "\!\%\&\(\)\*\@" | xargs | sed "s/\ /\|/g" | sort | uniq > "./lite_gfwlist_keyword.tmp"
    
    # Extract lite domains (only valid domains)
    cat "./cnacc_addition.tmp" | grep -E "${lite_domain_regex}" | sort | uniq > "./lite_cnacc_addition.tmp"
    cat "./gfwlist_addition.tmp" | grep -E "${lite_domain_regex}" | sort | uniq > "./lite_gfwlist_addition.tmp"
    
    # Process trusted CNAccelerator domains
    cat "./cnacc_trusted.tmp" | sed "s/\/114\.114\.114\.114//g;s/server\=\///g" | tr "A-Z" "a-z" > "./cnacc_trust.tmp"
    cat "./cnacc_trust.tmp" | grep -E "${lite_domain_regex}" | sort | uniq > "./lite_cnacc_trust.tmp"
    
    # Process main domain lists with more flexible filtering and maintain wildcard patterns
    cat "./cnacc_domain_processed.tmp" | sed "s/domain\://g;s/full\://g" | tr "A-Z" "a-z" | grep -E "${domain_regex}" > "./cnacc_checklist.tmp"
    cat "./gfwlist_base64.tmp" "./gfwlist_domain_processed.tmp" | sed "s/domain\://g;s/full\://g;s/http\:\/\///g;s/https\:\/\///g" | tr -d "|" | tr "A-Z" "a-z" | grep -E "${domain_regex}" > "./gfwlist_checklist.tmp"
    
    # Save debug copies before domain extraction
    cp "./cnacc_checklist.tmp" "./debug_cnacc_checklist.tmp"
    cp "./gfwlist_checklist.tmp" "./debug_gfwlist_checklist.tmp"
    
    # Process lite domain lists
    cat "./cnacc_checklist.tmp" | rev | cut -d "." -f 1,2 | rev | sort | uniq > "./lite_cnacc_checklist.tmp"
    cat "./gfwlist_checklist.tmp" | rev | cut -d "." -f 1,2 | rev | sort | uniq > "./lite_gfwlist_checklist.tmp"
    
    # Create raw lists with more lenient filtering
    awk 'NR == FNR { tmp[$0] = 1 } NR > FNR { if ( tmp[$0] != 1 ) print }' "./cnacc_checklist.tmp" "./gfwlist_checklist.tmp" > "./gfwlist_raw.tmp"
    awk 'NR == FNR { tmp[$0] = 1 } NR > FNR { if ( tmp[$0] != 1 ) print }' "./gfwlist_checklist.tmp" "./cnacc_checklist.tmp" > "./cnacc_raw.tmp"
    
    # Create lite raw lists
    awk 'NR == FNR { tmp[$0] = 1 } NR > FNR { if ( tmp[$0] != 1 ) print }' "./lite_cnacc_checklist.tmp" "./lite_gfwlist_checklist.tmp" > "./lite_gfwlist_raw.tmp"
    awk 'NR == FNR { tmp[$0] = 1 } NR > FNR { if ( tmp[$0] != 1 ) print }' "./lite_gfwlist_checklist.tmp" "./lite_cnacc_checklist.tmp" > "./lite_cnacc_raw.tmp"
    
    # Process trusted domains
    awk 'NR == FNR { tmp[$0] = 1 } NR > FNR { if ( tmp[$0] != 1 ) print }' "./cnacc_trust.tmp" "./gfwlist_raw.tmp" > "./gfwlist_raw_new.tmp"
    awk 'NR == FNR { tmp[$0] = 1 } NR > FNR { if ( tmp[$0] != 1 ) print }' "./cnacc_trust.tmp" "./lite_gfwlist_raw.tmp" > "./lite_gfwlist_raw_new.tmp"
    
    # Combine lists
    cat "./cnacc_raw.tmp" "./lite_cnacc_raw.tmp" "./cnacc_addition.tmp" "./lite_cnacc_addition.tmp" "./cnacc_trust.tmp" "./lite_cnacc_trust.tmp" | sort | uniq > "./cnacc_added.tmp"
    cat "./gfwlist_raw_new.tmp" "./lite_gfwlist_raw_new.tmp" "./gfwlist_addition.tmp" "./lite_gfwlist_addition.tmp" | sort | uniq > "./gfwlist_added.tmp"
    cat "./lite_cnacc_raw.tmp" "./lite_cnacc_addition.tmp" "./lite_cnacc_trust.tmp" | sort | uniq > "./lite_cnacc_added.tmp"
    cat "./lite_gfwlist_raw_new.tmp" "./lite_gfwlist_addition.tmp" | sort | uniq > "./lite_gfwlist_added.tmp"
    
    # Apply subtractions
    awk 'NR == FNR { tmp[$0] = 1 } NR > FNR { if ( tmp[$0] != 1 ) print }' "./cnacc_subtraction.tmp" "./cnacc_added.tmp" > "./cnacc_data_before_wildcard.tmp"
    awk 'NR == FNR { tmp[$0] = 1 } NR > FNR { if ( tmp[$0] != 1 ) print }' "./gfwlist_subtraction.tmp" "./gfwlist_added.tmp" > "./gfwlist_data_before_wildcard.tmp"
    awk 'NR == FNR { tmp[$0] = 1 } NR > FNR { if ( tmp[$0] != 1 ) print }' "./cnacc_subtraction.tmp" "./lite_cnacc_added.tmp" > "./lite_cnacc_data_before_wildcard.tmp"
    awk 'NR == FNR { tmp[$0] = 1 } NR > FNR { if ( tmp[$0] != 1 ) print }' "./gfwlist_subtraction.tmp" "./lite_gfwlist_added.tmp" > "./lite_gfwlist_data_before_wildcard.tmp"
    
    # Handle wildcard domains: Remove specific domains covered by wildcard patterns (e.g., *-a.example.com covers sub.example.com)
    # Process cnacc data
    > "./cnacc_data.tmp"
    cat "./cnacc_data_before_wildcard.tmp" | while IFS= read -r domain; do
        if [[ "$domain" == *"-a."* ]]; then
            # Wildcard domain, keep it and remove specific domains covered by it
            wildcard_suffix=$(echo "$domain" | sed 's/.*-a\.//')
            grep -v "^[^[:space:]]*\.$wildcard_suffix$" "./cnacc_data_before_wildcard.tmp" > "./cnacc_data_temp.tmp"
            mv "./cnacc_data_temp.tmp" "./cnacc_data_before_wildcard.tmp"
            echo "$domain" >> "./cnacc_data.tmp"
        else
            # Non-wildcard domain, keep it if not already removed
            if grep -q "^$domain$" "./cnacc_data_before_wildcard.tmp"; then
                echo "$domain" >> "./cnacc_data.tmp"
            fi
        fi
    done
    
    # Process gfwlist data
    > "./gfwlist_data.tmp"
    cat "./gfwlist_data_before_wildcard.tmp" | while IFS= read -r domain; do
        if [[ "$domain" == *"-a."* ]]; then
            # Wildcard domain, keep it and remove specific domains covered by it
            wildcard_suffix=$(echo "$domain" | sed 's/.*-a\.//')
            grep -v "^[^[:space:]]*\.$wildcard_suffix$" "./gfwlist_data_before_wildcard.tmp" > "./gfwlist_data_temp.tmp"
            mv "./gfwlist_data_temp.tmp" "./gfwlist_data_before_wildcard.tmp"
            echo "$domain" >> "./gfwlist_data.tmp"
        else
            # Non-wildcard domain, keep it if not already removed
            if grep -q "^$domain$" "./gfwlist_data_before_wildcard.tmp"; then
                echo "$domain" >> "./gfwlist_data.tmp"
            fi
        fi
    done
    
    # Process lite cnacc data
    > "./lite_cnacc_data.tmp"
    cat "./lite_cnacc_data_before_wildcard.tmp" | while IFS= read -r domain; do
        if [[ "$domain" == *"-a."* ]]; then
            # Wildcard domain, keep it and remove specific domains covered by it
            wildcard_suffix=$(echo "$domain" | sed 's/.*-a\.//')
            grep -v "^[^[:space:]]*\.$wildcard_suffix$" "./lite_cnacc_data_before_wildcard.tmp" > "./lite_cnacc_data_temp.tmp"
            mv "./lite_cnacc_data_temp.tmp" "./lite_cnacc_data_before_wildcard.tmp"
            echo "$domain" >> "./lite_cnacc_data.tmp"
        else
            # Non-wildcard domain, keep it if not already removed
            if grep -q "^$domain$" "./lite_cnacc_data_before_wildcard.tmp"; then
                echo "$domain" >> "./lite_cnacc_data.tmp"
            fi
        fi
    done
    
    # Process lite gfwlist data
    > "./lite_gfwlist_data.tmp"
    cat "./lite_gfwlist_data_before_wildcard.tmp" | while IFS= read -r domain; do
        if [[ "$domain" == *"-a."* ]]; then
            # Wildcard domain, keep it and remove specific domains covered by it
            wildcard_suffix=$(echo "$domain" | sed 's/.*-a\.//')
            grep -v "^[^[:space:]]*\.$wildcard_suffix$" "./lite_gfwlist_data_before_wildcard.tmp" > "./lite_gfwlist_data_temp.tmp"
            mv "./lite_gfwlist_data_temp.tmp" "./lite_gfwlist_data_before_wildcard.tmp"
            echo "$domain" >> "./lite_gfwlist_data.tmp"
        else
            # Non-wildcard domain, keep it if not already removed
            if grep -q "^$domain$" "./lite_gfwlist_data_before_wildcard.tmp"; then
                echo "$domain" >> "./lite_gfwlist_data.tmp"
            fi
        fi
    done
    
    # Save final data arrays
    cnacc_data=($(cat "./cnacc_data.tmp" | sort | uniq))
    gfwlist_data=($(cat "./gfwlist_data.tmp" | sort | uniq))
    lite_cnacc_data=($(cat "./lite_cnacc_data.tmp" | sort | uniq))
    lite_gfwlist_data=($(cat "./lite_gfwlist_data.tmp" | sort | uniq))
    
    # Create special debug file with specific domains
    echo "Checking for specific domains:" > "./debug_domain_check.txt"
    grep -i "0.zone" ./cnacc_domain.tmp ./cnacc_domain_processed.tmp ./cnacc_checklist.tmp ./cnacc_data.tmp >> "./debug_domain_check.txt" || echo "0.zone not found" >> "./debug_domain_check.txt"
    grep -i "alt1-mtalk.google.com" ./cnacc_domain.tmp ./cnacc_domain_processed.tmp ./cnacc_checklist.tmp ./cnacc_data.tmp >> "./debug_domain_check.txt" || echo "alt1-mtalk.google.com not found" >> "./debug_domain_check.txt"
    grep -i "gov.cn" ./cnacc_domain.tmp ./cnacc_domain_processed.tmp ./cnacc_checklist.tmp ./cnacc_data.tmp >> "./debug_domain_check.txt" || echo "gov.cn not found" >> "./debug_domain_check.txt"
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

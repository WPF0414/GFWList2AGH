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
    awk 'NR == FNR { tmp[$0] = 1 } NR > FNR { if ( tmp[$0] != 1 ) print }' "./lite_gfwlist_checklist.tmp" "./lite_cnacc_raw.tmp" > "./lite_cnacc_raw.tmp"
    
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

    # New: Remove duplicates covered by wildcard rules (e.g., *-a.domain covers sub.domain)
    # Process for cnacc (white list)
    cat "./cnacc_data.tmp" | grep -v "^#" | sort | uniq > "./cnacc_data_no_dup.tmp"
    > "./cnacc_data_final.tmp"
    while IFS= read -r line; do
        if [[ "$line" == *-a.* ]]; then
            # Extract the domain part after *-a.
            wildcard_domain=$(echo "$line" | sed 's/.*-a\.//')
            # Skip adding specific domains covered by this wildcard
            grep -v "^[a-z0-9-]*\.$wildcard_domain$" "./cnacc_data_no_dup.tmp" > "./cnacc_data_no_dup.tmp.new"
            mv "./cnacc_data_no_dup.tmp.new" "./cnacc_data_no_dup.tmp"
        fi
        echo "$line" >> "./cnacc_data_final.tmp"
    done < "./cnacc_data_no_dup.tmp"

    # Process for gfwlist (black list)
    cat "./gfwlist_data.tmp" | grep -v "^#" | sort | uniq > "./gfwlist_data_no_dup.tmp"
    > "./gfwlist_data_final.tmp"
    while IFS= read -r line; do
        if [[ "$line" == *-a.* ]]; then
            # Extract the domain part after *-a.
            wildcard_domain=$(echo "$line" | sed 's/.*-a\.//')
            # Skip adding specific domains covered by this wildcard
            grep -v "^[a-z0-9-]*\.$wildcard_domain$" "./gfwlist_data_no_dup.tmp" > "./gfwlist_data_no_dup.tmp.new"
            mv "./gfwlist_data_no_dup.tmp.new" "./gfwlist_data_no_dup.tmp"
        fi
        echo "$line" >> "./gfwlist_data_final.tmp"
    done < "./gfwlist_data_no_dup.tmp"

    # Process for lite_cnacc (white list)
    cat "./lite_cnacc_data.tmp" | grep -v "^#" | sort | uniq > "./lite_cnacc_data_no_dup.tmp"
    > "./lite_cnacc_data_final.tmp"
    while IFS= read -r line; do
        if [[ "$line" == *-a.* ]]; then
            wildcard_domain=$(echo "$line" | sed 's/.*-a\.//')
            grep -v "^[a-z0-9-]*\.$wildcard_domain$" "./lite_cnacc_data_no_dup.tmp" > "./lite_cnacc_data_no_dup.tmp.new"
            mv "./lite_cnacc_data_no_dup.tmp.new" "./lite_cnacc_data_no_dup.tmp"
        fi
        echo "$line" >> "./lite_cnacc_data_final.tmp"
    done < "./lite_cnacc_data_no_dup.tmp"

    # Process for lite_gfwlist (black list)
    cat "./lite_gfwlist_data.tmp" | grep -v "^#" | sort | uniq > "./lite_gfwlist_data_no_dup.tmp"
    > "./lite_gfwlist_data_final.tmp"
    while IFS= read -r line; do
        if [[ "$line" == *-a.* ]]; then
            wildcard_domain=$(echo "$line" | sed 's/.*-a\.//')
            grep -v "^[a-z0-9-]*\.$wildcard_domain$" "./lite_gfwlist_data_no_dup.tmp" > "./lite_gfwlist_data_no_dup.tmp.new"
            mv "./lite_gfwlist_data_no_dup.tmp.new" "./lite_gfwlist_data_no_dup.tmp"
        fi
        echo "$line" >> "./lite_gfwlist_data_final.tmp"
    done < "./lite_gfwlist_data_no_dup.tmp"

    # Save final data arrays, prioritize comment filtering
    cnacc_data=($(cat "./cnacc_data_final.tmp" | grep -v "^#" | sort | uniq))
    gfwlist_data=($(cat "./gfwlist_data_final.tmp" | grep -v "^#" | sort | uniq))
    lite_cnacc_data=($(cat "./lite_cnacc_data_final.tmp" | grep -v "^#" | sort | uniq))
    lite_gfwlist_data=($(cat "./lite_gfwlist_data_final.tmp" | grep -v "^#" | sort | uniq))
}

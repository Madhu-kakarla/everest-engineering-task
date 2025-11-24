#!/bin/bash

# Automated Test Script for Courier Application
# Tests both Problem 1 and Problem 2 with expected outputs

echo "======================================================================"
echo "Testing Courier Service Application"
echo "======================================================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

PASSED=0
FAILED=0

# Function to run test
run_test() {
    local test_name=$1
    local input_file=$2
    local expected_output=$3
    
    echo -n "Testing $test_name... "
    
    actual_output=$(ruby courier_service.rb < "$input_file" 2>&1)
    
    if [ "$actual_output" = "$expected_output" ]; then
        echo -e "${GREEN}PASSED${NC}"
        ((PASSED++))
        return 0
    else
        echo -e "${RED}FAILED${NC}"
        echo "  Expected:"
        echo "$expected_output" | sed 's/^/    /'
        echo "  Actual:"
        echo "$actual_output" | sed 's/^/    /'
        ((FAILED++))
        return 1
    fi
}

echo "----------------------------------------------------------------------"
echo "Problem 1: Delivery Cost Estimation"
echo "----------------------------------------------------------------------"
echo ""

# Test 1: Problem 1 sample input
expected_output_1="PKG1 0 175
PKG2 0 275
PKG3 35 665"

run_test "Problem 1 - Sample Input" "test_input_problem1.txt" "$expected_output_1"
echo ""

echo "----------------------------------------------------------------------"
echo "Problem 2: Delivery Time Estimation"
echo "----------------------------------------------------------------------"
echo ""

# Test 2: Problem 2 sample input
expected_output_2="PKG1 0 750 4.0
PKG2 0 1475 1.79
PKG3 0 2350 1.43
PKG4 0 1500 0.86
PKG5 0 2125 4.21"

run_test "Problem 2 - Sample Input" "test_input_problem2.txt" "$expected_output_2"
echo ""

# Test 3: Edge case - single package
echo "Creating additional test case: Single Package..."
cat > test_single_package.txt << EOF
100 1
PKG1 10 50 OFR003
EOF

expected_output_3="PKG1 23 428"
run_test "Edge Case - Single Package" "test_single_package.txt" "$expected_output_3"
echo ""

# Test 4: Edge case - invalid offer code
echo "Creating additional test case: Invalid Offer..."
cat > test_invalid_offer.txt << EOF
100 2
PKG1 15 10 INVALID
PKG2 20 30 OFR001
EOF

expected_output_4="PKG1 0 300
PKG2 0 450"
run_test "Edge Case - Invalid Offer" "test_invalid_offer.txt" "$expected_output_4"
echo ""

# Test 5: Multiple vehicles with single package
echo "Creating additional test case: One Package, Two Vehicles..."
cat > test_one_pkg_two_vehicles.txt << EOF
100 1
PKG1 50 30 NA
2 70 200
EOF

expected_output_5="PKG1 0 750 0.43"
run_test "Edge Case - One Package, Two Vehicles" "test_one_pkg_two_vehicles.txt" "$expected_output_5"
echo ""

# Cleanup temporary test files
rm -f test_single_package.txt test_invalid_offer.txt test_one_pkg_two_vehicles.txt

echo "======================================================================"
echo "Test Summary"
echo "======================================================================"
echo -e "Total tests: $((PASSED + FAILED))"
echo -e "${GREEN}Passed: $PASSED${NC}"
echo -e "${RED}Failed: $FAILED${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}All tests passed! ✓${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed. Please review the output above.${NC}"
    exit 1
fi

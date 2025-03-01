#!/bin/bash

# Script to run Neovim configuration tests

# Ensure we're in the correct directory
cd "$(dirname "$0")/../.." || exit 1

# Define colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to run a test
run_test() {
  local test_file=$1
  local test_name=$2
  
  echo -e "${BLUE}Running $test_name tests...${NC}"
  
  # Run the test
  nvim --headless --noplugin -u "test/minimal.vim" -c "source $test_file" -c "qa!"
  
  # Check exit code
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ $test_name tests passed${NC}"
    return 0
  else
    echo -e "${RED}✗ $test_name tests failed${NC}"
    return 1
  fi
}

# Run all tests
echo -e "${BLUE}Starting Neovim configuration tests${NC}"

failed=0

# Run basic tests
run_test "test/basic_test.vim" "Basic" || ((failed++))

# Run config tests
run_test "test/config_test.vim" "Configuration" || ((failed++))

# Output summary
echo ""
if [ $failed -eq 0 ]; then
  echo -e "${GREEN}All tests passed!${NC}"
  exit 0
else
  echo -e "${RED}$failed test suite(s) failed${NC}"
  exit 1
fi
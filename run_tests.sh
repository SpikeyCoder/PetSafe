#!/bin/bash

# PetSafe Automated UI Testing Script
# This script runs XCUITests with comprehensive logging and generates reports

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_NAME="PetSafe"
SCHEME="PetSafe"
TEST_PLAN="PetSafeUITests"
SIMULATOR="iPhone 17"
IOS_VERSION="17.2"

# Output directories
OUTPUT_DIR="${PROJECT_DIR}/test_results"
LOGS_DIR="${OUTPUT_DIR}/logs"
SCREENSHOTS_DIR="${OUTPUT_DIR}/screenshots"
REPORTS_DIR="${OUTPUT_DIR}/reports"
DERIVED_DATA_DIR="${OUTPUT_DIR}/derived_data"

# Timestamp for this run
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="${LOGS_DIR}/test_run_${TIMESTAMP}.log"
RESULTS_FILE="${LOGS_DIR}/test_results_${TIMESTAMP}.txt"

# Create output directories
mkdir -p "${LOGS_DIR}"
mkdir -p "${SCREENSHOTS_DIR}"
mkdir -p "${REPORTS_DIR}"
mkdir -p "${DERIVED_DATA_DIR}"

# Print banner
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║         PetSafe Automated Test Suite Runner             ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Function to print section headers
print_section() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

# Function to log with timestamp
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "${LOG_FILE}"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Verify Xcode is installed
print_section "Verifying Environment"
if ! command_exists xcodebuild; then
    echo -e "${RED}ERROR: xcodebuild not found. Please install Xcode.${NC}"
    exit 1
fi

log "✓ Xcode found: $(xcodebuild -version | head -1)"

# Find simulator - prefer booted simulator
print_section "Finding Simulator"
SIMULATOR_UDID=$(xcrun simctl list devices | grep "${SIMULATOR}" | grep "Booted" | head -1 | grep -oE '\([A-Fa-f0-9\-]+\)' | tr -d '()')

if [ -z "$SIMULATOR_UDID" ]; then
    # No booted simulator, find first available
    SIMULATOR_UDID=$(xcrun simctl list devices available | grep "${SIMULATOR}" | grep -v "unavailable" | head -1 | grep -oE '\([A-Fa-f0-9\-]+\)' | tr -d '()')
fi

if [ -z "$SIMULATOR_UDID" ]; then
    echo -e "${YELLOW}WARNING: Simulator '${SIMULATOR}' not found. Using default...${NC}"
    DESTINATION="platform=iOS Simulator,name=iPhone 15 Pro"
else
    log "✓ Found simulator: ${SIMULATOR} (${SIMULATOR_UDID})"
    DESTINATION="platform=iOS Simulator,id=${SIMULATOR_UDID}"
fi

# Boot simulator if needed
log "Booting simulator..."
xcrun simctl boot "${SIMULATOR_UDID}" 2>/dev/null || true

# Open Simulator.app GUI
log "Opening Simulator.app..."
open -a Simulator
sleep 3

# Clean build folder
print_section "Cleaning Build Folder"
log "Removing previous build artifacts..."
xcodebuild clean \
    -project "${PROJECT_DIR}/${PROJECT_NAME}.xcodeproj" \
    -scheme "${SCHEME}" \
    -destination "${DESTINATION}" \
    >> "${LOG_FILE}" 2>&1

log "✓ Build folder cleaned"

# Build for testing
print_section "Building Tests"
log "Building test target..."

xcodebuild build-for-testing \
    -project "${PROJECT_DIR}/${PROJECT_NAME}.xcodeproj" \
    -scheme "${SCHEME}" \
    -destination "${DESTINATION}" \
    -enableCodeCoverage YES \
    ANTHROPIC_LOG=debug \
    >> "${LOG_FILE}" 2>&1

if [ $? -eq 0 ]; then
    log "✓ Tests built successfully"
else
    echo -e "${RED}ERROR: Build failed. Check ${LOG_FILE} for details.${NC}"
    exit 1
fi

# Run tests
print_section "Running UI Tests"
log "Executing test suite..."

# Start timestamp
START_TIME=$(date +%s)

# Run all tests
if command_exists xcpretty; then
    # Use xcpretty for formatted output if available
    xcodebuild test-without-building \
        -project "${PROJECT_DIR}/${PROJECT_NAME}.xcodeproj" \
        -scheme "${SCHEME}" \
        -destination "${DESTINATION}" \
        -only-testing:PetSafeUITests \
        -disable-concurrent-testing \
        -maximum-concurrent-test-device-destinations 1 \
        -resultBundlePath "${REPORTS_DIR}/TestResults_${TIMESTAMP}.xcresult" \
        -enableCodeCoverage YES \
        ANTHROPIC_LOG=debug \
        | tee -a "${LOG_FILE}" \
        | xcpretty --report html --output "${REPORTS_DIR}/test_report_${TIMESTAMP}.html" \
        | tee -a "${RESULTS_FILE}"
else
    # Run without xcpretty
    xcodebuild test-without-building \
        -project "${PROJECT_DIR}/${PROJECT_NAME}.xcodeproj" \
        -scheme "${SCHEME}" \
        -destination "${DESTINATION}" \
        -only-testing:PetSafeUITests \
        -disable-concurrent-testing \
        -maximum-concurrent-test-device-destinations 1 \
        -resultBundlePath "${REPORTS_DIR}/TestResults_${TIMESTAMP}.xcresult" \
        -enableCodeCoverage YES \
        ANTHROPIC_LOG=debug \
        2>&1 | tee -a "${LOG_FILE}"
fi

TEST_EXIT_CODE=$?

# End timestamp
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

# Extract test results
print_section "Test Results Summary"

TOTAL_TESTS=$(grep -o "Test Case.*passed\|Test Case.*failed" "${LOG_FILE}" | wc -l | tr -d ' ')
PASSED_TESTS=$(grep -o "Test Case.*passed" "${LOG_FILE}" | wc -l | tr -d ' ')
FAILED_TESTS=$(grep -o "Test Case.*failed" "${LOG_FILE}" | wc -l | tr -d ' ')

echo ""
log "Total Tests:   ${TOTAL_TESTS}"
log "Passed:        ${PASSED_TESTS}"
log "Failed:        ${FAILED_TESTS}"
log "Duration:      ${DURATION}s"
echo ""

# Copy screenshots from derived data
print_section "Collecting Screenshots"
SCREENSHOTS_SRC="${DERIVED_DATA_DIR}/Logs/Test/Attachments"
if [ -d "${SCREENSHOTS_SRC}" ]; then
    cp -R "${SCREENSHOTS_SRC}"/* "${SCREENSHOTS_DIR}/" 2>/dev/null || true
    SCREENSHOT_COUNT=$(find "${SCREENSHOTS_DIR}" -name "*.png" | wc -l | tr -d ' ')
    log "✓ Collected ${SCREENSHOT_COUNT} screenshots"
else
    log "No screenshots found"
fi

# Generate summary report
print_section "Generating Report"

cat > "${REPORTS_DIR}/summary_${TIMESTAMP}.txt" << EOF
PetSafe UI Test Summary
=======================

Run Date:     $(date)
Duration:     ${DURATION} seconds
Simulator:    ${SIMULATOR}

Test Results:
-------------
Total Tests:  ${TOTAL_TESTS}
Passed:       ${PASSED_TESTS}
Failed:       ${FAILED_TESTS}
Success Rate: $(( PASSED_TESTS * 100 / TOTAL_TESTS ))%

Output Files:
-------------
Full Log:     ${LOG_FILE}
HTML Report:  ${REPORTS_DIR}/test_report_${TIMESTAMP}.html
Screenshots:  ${SCREENSHOTS_DIR}/
Results:      ${REPORTS_DIR}/TestResults_${TIMESTAMP}.xcresult

To view detailed results:
    open ${REPORTS_DIR}/TestResults_${TIMESTAMP}.xcresult
    open ${REPORTS_DIR}/test_report_${TIMESTAMP}.html

EOF

cat "${REPORTS_DIR}/summary_${TIMESTAMP}.txt"

# Final status
print_section "Test Run Complete"

if [ $TEST_EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}✓ All tests passed!${NC}"
else
    echo -e "${RED}✗ Some tests failed. Check reports for details.${NC}"
fi

echo ""
echo -e "${BLUE}Results saved to:${NC} ${OUTPUT_DIR}"
echo ""

# Return test exit code
exit $TEST_EXIT_CODE

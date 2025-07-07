#!/bin/bash
# tests/test_debloat.sh
# Automated test script for the Ubuntu Debloater (debloat.sh).
# This script creates a mock environment to test debloat.sh without
# actually modifying the host system.

# --- Configuration and Setup ---

# Exit immediately if a command exits with a non-zero status.
# Treat unset variables as an error when substituting.
# Exit if any command in a pipeline fails.
set -euo pipefail

# Define test environment variables
TEST_DIR="/tmp/debloater_test_$(date +%s)"
MOCK_ROOT="${TEST_DIR}/mock_root"
MOCK_BIN="${MOCK_ROOT}/usr/bin"
MOCK_ETC="${MOCK_ROOT}/etc"
DEBLOATER_SOURCE_DIR="$(dirname "$(readlink -f "$0")")/.." # Path to linuxtoys/debloater

# Global test counters
TEST_COUNT=0
PASSED_COUNT=0
FAILED_COUNT=0

# --- Logging Functions ---

log_info() {
    echo "✅ [INFO] $1"
}

log_error() {
    echo "❌ [ERROR] $1" >&2
    FAILED_COUNT=$((FAILED_COUNT + 1))
}

log_test_start() {
    TEST_COUNT=$((TEST_COUNT + 1))
    echo ""
    echo "--- Running Test $TEST_COUNT: $1 ---"
}

log_test_pass() {
    PASSED_COUNT=$((PASSED_COUNT + 1))
    echo "--- Test $TEST_COUNT PASSED ---"
}

# --- Mock System Commands ---

# Mock apt-get: This function will simulate apt-get purge, autoremove, autoclean, install
# It will log the command and arguments to a file, rather than actually executing them.
mock_apt_get() {
    echo "MOCK_APT_GET_CALLED: $@" >> "${TEST_DIR}/apt_log.txt"
    # Simulate success
    return 0
}

# Mock dpkg: This function will simulate dpkg -s (status check)
# It checks against a predefined list of "installed" packages in our mock environment.
# Argument 1: -s (status)
# Argument 2: package_name
mock_dpkg() {
    if [[ "$1" == "-s" ]]; then
        local pkg_name="$2"
        # Check if the package is in our mock installed list
        if grep -q "^${pkg_name}$" "${TEST_DIR}/mock_installed_packages.txt" 2>/dev/null; then
            echo "Package: ${pkg_name}"
            echo "Status: install ok installed"
            return 0 # Package is "installed"
        else
            return 1 # Package is "not installed"
        fi
    else
        echo "MOCK_DPKG_CALLED: $@" >> "${TEST_DIR}/dpkg_log.txt"
        return 0 # Simulate success for other dpkg commands
    fi
}

# Mock command: This function will simulate `command -v`
mock_command() {
    if [[ "$1" == "-v" ]]; then
        case "$2" in
            apt)
                # Always report apt as existing for our tests
                echo "${MOCK_BIN}/apt-get"
                return 0
                ;;
            # Add other commands if debloat.sh checks for them
            *)
                # For other commands, check if they exist in the real system
                # or if we need to mock them specifically.
                # For now, let's assume they exist if not apt.
                command -v "$2" >/dev/null 2>&1
                return $?
                ;;
        esac
    else
        echo "MOCK_COMMAND_CALLED: $@" >> "${TEST_DIR}/command_log.txt"
        return 0
    fi
}


# --- Test Environment Setup and Teardown ---

setup_test_env() {
    log_info "Setting up test environment in ${TEST_DIR}..."
    mkdir -p "${TEST_DIR}"
    mkdir -p "${MOCK_BIN}"
    mkdir -p "${MOCK_ETC}"

    # Create mock apt-get and dpkg executables
    # These will redirect to our mock functions
    echo '#!/bin/bash' > "${MOCK_BIN}/apt-get"
    echo "source \"${DEBLOATER_SOURCE_DIR}/scripts/functions.sh\"" >> "${MOCK_BIN}/apt-get" # Source real functions if needed
    echo "mock_apt_get \"\$@\"" >> "${MOCK_BIN}/apt-get"
    chmod +x "${MOCK_BIN}/apt-get"

    echo '#!/bin/bash' > "${MOCK_BIN}/dpkg"
    echo "source \"${DEBLOATER_SOURCE_DIR}/scripts/functions.sh\"" >> "${MOCK_BIN}/dpkg" # Source real functions if needed
    echo "mock_dpkg \"\$@\"" >> "${MOCK_BIN}/dpkg"
    chmod +x "${MOCK_BIN}/dpkg"

    # Create a mock `command` for `command_exists`
    echo '#!/bin/bash' > "${MOCK_BIN}/command"
    echo "source \"${DEBLOATER_SOURCE_DIR}/scripts/functions.sh\"" >> "${MOCK_BIN}/command" # Source real functions if needed
    echo "mock_command \"\$@\"" >> "${MOCK_BIN}/command"
    chmod +x "${MOCK_BIN}/command"


    # Copy the debloater scripts and config to the test directory
    cp -r "${DEBLOATER_SOURCE_DIR}" "${TEST_DIR}/debloater"

    # Set up a mock PATH to prioritize our mock binaries
    export PATH="${MOCK_BIN}:${PATH}"

    # Initialize mock installed packages list
    echo "" > "${TEST_DIR}/mock_installed_packages.txt"
    echo "" > "${TEST_DIR}/apt_log.txt" # Clear apt log for each test run
}

cleanup_test_env() {
    log_info "Cleaning up test environment..."
    rm -rf "${TEST_DIR}"
    unset PATH # Unset the modified PATH
}

# --- Helper Functions for Tests ---

# Function to simulate a distribution
simulate_distro() {
    local distro_id="$1"
    local distro_like="${2:-ubuntu}" # Default to ubuntu like
    echo "ID=${distro_id}" > "${MOCK_ETC}/os-release"
    echo "ID_LIKE=${distro_like}" >> "${MOCK_ETC}/os-release"
    echo "VERSION_ID=\"22.04\"" >> "${MOCK_ETC}/os-release"
    echo "NAME=\"Test Distro\"" >> "${MOCK_ETC}/os-release"
}

# Function to add mock installed packages
add_mock_installed_packages() {
    for pkg in "$@"; do
        echo "$pkg" >> "${TEST_DIR}/mock_installed_packages.txt"
    done
}

# Function to run debloat.sh with simulated user input
run_debloat_script() {
    local user_input="$1" # 'y' or 'n'
    echo "$user_input" | "${TEST_DIR}/debloater/debloat.sh"
}

# Function to assert that apt-get was called with specific arguments
assert_apt_purge_called() {
    local expected_packages="$@"
    local expected_call="MOCK_APT_GET_CALLED: purge --assume-yes ${expected_packages[*]}"
    if grep -qF "$expected_call" "${TEST_DIR}/apt_log.txt"; then
        log_info "Assertion Passed: 'apt-get purge' called with expected packages."
        return 0
    else
        log_error "Assertion Failed: 'apt-get purge' not called with expected packages."
        log_info "Expected: $expected_call"
        log_info "Actual apt_log.txt content:"
        cat "${TEST_DIR}/apt_log.txt"
        return 1
    fi
}

assert_apt_autoremove_called() {
    if grep -q "MOCK_APT_GET_CALLED: autoremove --purge --assume-yes" "${TEST_DIR}/apt_log.txt"; then
        log_info "Assertion Passed: 'apt-get autoremove' called."
        return 0
    else
        log_error "Assertion Failed: 'apt-get autoremove' not called."
        log_info "Actual apt_log.txt content:"
        cat "${TEST_DIR}/apt_log.txt"
        return 1
    fi
}

assert_apt_autoclean_called() {
    if grep -q "MOCK_APT_GET_CALLED: autoclean --assume-yes" "${TEST_DIR}/apt_log.txt"; then
        log_info "Assertion Passed: 'apt-get autoclean' called."
        return 0
    else
        log_error "Assertion Failed: 'apt-get autoclean' not called."
        log_info "Actual apt_log.txt content:"
        cat "${TEST_DIR}/apt_log.txt"
        return 1
    fi
}

assert_no_apt_purge_called() {
    local expected_call="MOCK_APT_GET_CALLED: purge"
    if grep -qF "$expected_call" "${TEST_DIR}/apt_log.txt"; then
        log_error "Assertion Failed: 'apt-get purge' was called unexpectedly."
        log_info "Actual apt_log.txt content:"
        cat "${TEST_DIR}/apt_log.txt"
        return 1
    else
        log_info "Assertion Passed: 'apt-get purge' was NOT called as expected."
        return 0
    fi
}


# --- Test Cases ---

# Test 1: Basic Ubuntu Debloat
test_ubuntu_debloat() {
    log_test_start "Basic Ubuntu Debloat"
    setup_test_env

    # Simulate Ubuntu
    simulate_distro "ubuntu"

    # Create mock config file
    echo "libreoffice-writer" > "${TEST_DIR}/debloater/config/ubuntu_bloat.list"
    echo "thunderbird" >> "${TEST_DIR}/debloater/config/ubuntu_bloat.list"

    # Simulate these packages being installed
    add_mock_installed_packages "libreoffice-writer" "thunderbird"

    # Run the script with 'y' for confirmation
    run_debloat_script "y" || true # Allow script to exit with error if it fails unexpectedly

    # Assertions
    assert_apt_purge_called "libreoffice-writer" "thunderbird"
    assert_apt_autoremove_called
    assert_apt_autoclean_called

    log_test_pass
    cleanup_test_env
}

# Test 2: Basic Kubuntu Debloat
test_kubuntu_debloat() {
    log_test_start "Basic Kubuntu Debloat"
    setup_test_env

    # Simulate Kubuntu
    simulate_distro "kubuntu"

    # Create mock config file
    echo "kmahjongg" > "${TEST_DIR}/debloater/config/kubuntu_bloat.list"
    echo "dragonplayer" >> "${TEST_DIR}/debloater/config/kubuntu_bloat.list"

    # Simulate these packages being installed
    add_mock_installed_packages "kmahjongg" "dragonplayer"

    # Run the script with 'y' for confirmation
    run_debloat_script "y" || true

    # Assertions
    assert_apt_purge_called "kmahjongg" "dragonplayer"
    assert_apt_autoremove_called
    assert_apt_autoclean_called

    log_test_pass
    cleanup_test_env
}

# Test 3: No packages to remove (empty list)
test_no_packages_to_remove() {
    log_test_start "No packages to remove (empty list)"
    setup_test_env

    # Simulate Ubuntu
    simulate_distro "ubuntu"

    # Create an empty config file
    echo "" > "${TEST_DIR}/debloater/config/ubuntu_bloat.list"

    # Run the script with 'y' for confirmation (though it shouldn't matter)
    run_debloat_script "y" || true

    # Assertions: No purge should be called, but autoremove/autoclean still happen
    assert_no_apt_purge_called # Ensure purge was NOT called
    assert_apt_autoremove_called
    assert_apt_autoclean_called

    log_test_pass
    cleanup_test_env
}

# Test 4: User cancels debloating
test_user_cancels() {
    log_test_start "User cancels debloating"
    setup_test_env

    # Simulate Ubuntu
    simulate_distro "ubuntu"

    # Create mock config file
    echo "libreoffice-writer" > "${TEST_DIR}/debloater/config/ubuntu_bloat.list"

    # Simulate this package being installed
    add_mock_installed_packages "libreoffice-writer"

    # Run the script with 'n' for cancellation
    run_debloat_script "n" || true # Allow script to exit with error (expected behavior for cancel)

    # Assertions: No purge, autoremove, or autoclean should be called
    assert_no_apt_purge_called
    # Check that autoremove/autoclean were NOT called if the main operation was cancelled
    if grep -q "MOCK_APT_GET_CALLED: autoremove" "${TEST_DIR}/apt_log.txt"; then
        log_error "Assertion Failed: 'autoremove' was called after user cancellation."
    else
        log_info "Assertion Passed: 'autoremove' was NOT called after user cancellation."
    fi
    if grep -q "MOCK_APT_GET_CALLED: autoclean" "${TEST_DIR}/apt_log.txt"; then
        log_error "Assertion Failed: 'autoclean' was called after user cancellation."
    else
        log_info "Assertion Passed: 'autoclean' was NOT called after user cancellation."
    fi

    log_test_pass
    cleanup_test_env
}

# Test 5: Packages not installed are skipped
test_skip_non_installed_packages() {
    log_test_start "Skipping non-installed packages"
    setup_test_env

    # Simulate Ubuntu
    simulate_distro "ubuntu"

    # Create mock config file with some installed and some not installed packages
    echo "package-installed-1" > "${TEST_DIR}/debloater/config/ubuntu_bloat.list"
    echo "package-not-installed-1" >> "${TEST_DIR}/debloater/config/ubuntu_bloat.list"
    echo "package-installed-2" >> "${TEST_DIR}/debloater/config/ubuntu_bloat.list"
    echo "package-not-installed-2" >> "${TEST_DIR}/debloater/config/ubuntu_bloat.list"

    # Simulate only some packages being installed
    add_mock_installed_packages "package-installed-1" "package-installed-2"

    # Run the script with 'y' for confirmation
    run_debloat_script "y" || true

    # Assertions: Only installed packages should be purged
    assert_apt_purge_called "package-installed-1" "package-installed-2"
    assert_apt_autoremove_called
    assert_apt_autoclean_called

    log_test_pass
    cleanup_test_env
}


# --- Run All Tests ---
log_info "Starting all Debloater tests..."

test_ubuntu_debloat
test_kubuntu_debloat
test_no_packages_to_remove
test_user_cancels
test_skip_non_installed_packages

# --- Final Summary ---
echo ""
echo "==================================="
echo "Test Summary:"
echo "Total Tests: ${TEST_COUNT}"
echo "Passed: ${PASSED_COUNT}"
echo "Failed: ${FAILED_COUNT}"
echo "==================================="

if [ "$FAILED_COUNT" -eq 0 ]; then
    log_info "All tests passed successfully!"
else
    log_error "Some tests failed. Please review the output above."
    exit 1
fi

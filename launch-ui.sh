#!/bin/bash

# Personal Trainer App - UI Launch Script
# Builds and launches the Flutter app on Linux desktop

set -e  # Exit on error

# Color codes for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

echo "=========================================="
echo "Personal Trainer App - UI Launcher"
echo "=========================================="
echo ""

# 1. Set up Flutter PATH
print_info "Setting up Flutter PATH..."
export PATH="$HOME/flutter/bin:$PATH"

# 2. Verify Flutter installation
if ! command -v flutter &> /dev/null; then
    print_error "Flutter not found! Please install Flutter SDK."
    exit 1
fi
print_success "Flutter found: $(flutter --version | head -1)"
echo ""

# 3. Check if we need to run build_runner
print_info "Checking if code generation is needed..."
if [ "$1" == "--generate" ] || [ "$1" == "-g" ]; then
    print_info "Running build_runner (code generation)..."
    flutter pub run build_runner build --delete-conflicting-outputs
    print_success "Code generation complete"
    echo ""
fi

# 4. Build release bundle
print_info "Building Flutter app (release mode)..."
flutter build linux --release

if [ $? -eq 0 ]; then
    print_success "Build completed successfully"
else
    print_error "Build failed"
    exit 1
fi
echo ""

# 5. Launch the app
BUNDLE_DIR="build/linux/x64/release/bundle"
EXECUTABLE="$BUNDLE_DIR/personal_trainer_app"

if [ ! -f "$EXECUTABLE" ]; then
    print_error "Executable not found at $EXECUTABLE"
    exit 1
fi

print_success "Launching Personal Trainer App..."
echo ""
print_info "App is starting..."
print_info "Press Ctrl+C to stop the app"
echo ""

# Change to bundle directory and run the app
cd "$BUNDLE_DIR"
./personal_trainer_app

# Note: The app runs in foreground, so this script will block until the app closes

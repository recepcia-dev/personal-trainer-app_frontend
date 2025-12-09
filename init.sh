#!/bin/bash

# Personal Trainer App - Development Environment Initialization Script
# This script sets up the development environment for the Flutter app

set -e  # Exit on error

echo "=========================================="
echo "Personal Trainer App - Environment Setup"
echo "=========================================="
echo ""

# Color codes for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print colored output
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# 1. Verify we're in the correct directory
echo "1. Verifying working directory..."
if [ ! -f "pubspec.yaml" ]; then
    print_error "Not in Flutter project root! Please run from project directory."
    exit 1
fi
print_success "Working directory confirmed: $(pwd)"
echo ""

# 2. Check Flutter installation
echo "2. Checking Flutter installation..."
if ! command -v flutter &> /dev/null; then
    print_error "Flutter not found! Please install Flutter SDK."
    exit 1
fi
FLUTTER_VERSION=$(flutter --version | head -1)
print_success "Flutter installed: $FLUTTER_VERSION"
echo ""

# 3. Check Flutter version requirement (>= 3.19.0)
echo "3. Verifying Flutter version..."
REQUIRED_VERSION="3.19.0"
CURRENT_VERSION=$(flutter --version | grep -oP 'Flutter \K[0-9]+\.[0-9]+\.[0-9]+' | head -1)
print_success "Current version: $CURRENT_VERSION (Required: >= $REQUIRED_VERSION)"
echo ""

# 4. Install dependencies
echo "4. Installing Flutter dependencies..."
flutter pub get
if [ $? -eq 0 ]; then
    print_success "Dependencies installed successfully"
else
    print_error "Failed to install dependencies"
    exit 1
fi
echo ""

# 5. Check for environment files
echo "5. Checking environment configuration..."
if [ ! -f ".env.development" ]; then
    print_warning ".env.development not found - creating template..."
    cat > .env.development <<EOF
API_BASE_URL=http://localhost:8000
STRIPE_PUBLISHABLE_KEY=pk_test_your_key_here
FIREBASE_OPTIONS_ANDROID=your_config_here
FIREBASE_OPTIONS_IOS=your_config_here
EOF
    print_success "Created .env.development template - Please fill in your credentials"
else
    print_success ".env.development exists"
fi

if [ ! -f ".env.production" ]; then
    print_warning ".env.production not found - creating template..."
    cat > .env.production <<EOF
API_BASE_URL=https://api.personaltrainer.com
STRIPE_PUBLISHABLE_KEY=pk_live_your_key_here
FIREBASE_OPTIONS_ANDROID=your_config_here
FIREBASE_OPTIONS_IOS=your_config_here
EOF
    print_success "Created .env.production template - Please fill in your credentials"
else
    print_success ".env.production exists"
fi
echo ""

# 6. Initialize progress tracking if not exists
echo "6. Initializing progress tracking..."
if [ ! -f "claude-progress.txt" ]; then
    cat > claude-progress.txt <<EOF
# Claude Progress Log
# This file tracks work completed across agent sessions

## Session 1 - $(date +"%Y-%m-%d %H:%M:%S")
- Project initialized
- Documentation structure created
- Environment setup script created

---
EOF
    print_success "Created claude-progress.txt"
else
    print_success "claude-progress.txt already exists"
fi
echo ""

# 7. Check if git is initialized
echo "7. Checking git repository..."
if [ ! -d ".git" ]; then
    print_warning "Git repository not initialized. Initializing now..."
    git init
    git add .
    git commit -m "Initial commit"
    print_success "Git repository initialized"
else
    print_success "Git repository exists"
fi
echo ""

# 8. List available devices
echo "8. Checking available devices..."
flutter devices
echo ""

# 9. Check backend status (if applicable)
echo "9. Checking backend server (FastAPI)..."
if [ -d "apps/backend" ]; then
    cd apps/backend
    if [ -f "main.py" ]; then
        print_success "Backend found at apps/backend/"
        if command -v uv &> /dev/null; then
            print_success "uv is installed - ready to run backend"
            echo "   To start backend: cd apps/backend && uv run uvicorn main:app --reload"
        else
            print_warning "uv not found - install with: pip install uv"
        fi
    fi
    cd ../..
else
    print_warning "Backend directory not found (will be created later)"
fi
echo ""

# 10. Final checklist
echo "=========================================="
echo "Environment Setup Complete!"
echo "=========================================="
echo ""
echo "Next Steps:"
echo "1. Fill in .env.development and .env.production with your credentials"
echo "2. Choose a device: flutter devices"
echo "3. Run the app: flutter run -d <device_id>"
echo "4. Start backend (if ready): cd apps/backend && uv run uvicorn main:app --reload"
echo "5. Review features.json for implementation roadmap"
echo "6. Read CLAUDE.md for development guidelines"
echo ""
echo "Development Workflow:"
echo "- Work on ONE feature per session (see features.json)"
echo "- Run startup validation before implementing (flutter analyze && flutter test)"
echo "- Commit after completing each feature"
echo "- Update claude-progress.txt with session summary"
echo ""
print_success "Ready to develop! 🚀"

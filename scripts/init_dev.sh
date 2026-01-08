#!/bin/bash

set -e

export PATH="$HOME/flutter/bin:$PATH"

echo "🚀 Personal Trainer App - Dev Mode Setup"
echo "=========================================="

# Step 1: Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Step 2: Run code generation
echo "🔨 Running code generation..."
flutter pub run build_runner build --delete-conflicting-outputs

# Step 3: Analyze code
echo "🔍 Analyzing code..."
flutter analyze

# Step 4: Run tests
echo "✅ Running tests..."
flutter test

# Step 5: Run app
echo "▶️  Starting dev mode app..."
flutter run -t lib/main_dev.dart

echo ""
echo "✨ Dev mode initialization complete!"

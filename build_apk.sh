#!/bin/bash

# Flutter Meal Analyzer App - APK Build Script
# Make sure to set your Gemini API key before running this script

echo "🍽️ Building Flutter Meal Analyzer APK..."

# Check if API key is set
if [ -z "$GEMINI_API_KEY" ]; then
    echo "❌ Error: GEMINI_API_KEY environment variable is not set!"
    echo "Please run: export GEMINI_API_KEY=\"your_api_key_here\""
    exit 1
fi

echo "✅ API Key found: ${GEMINI_API_KEY:0:10}..."

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Check Flutter doctor
echo "🔍 Checking Flutter environment..."
flutter doctor

# Build release APK with API key
echo "🔨 Building release APK with API key..."
flutter build apk --release --dart-define=GEMINI_API_KEY=$GEMINI_API_KEY

# Check if APK was created
if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
    echo "✅ APK built successfully!"
    echo "📱 APK location: build/app/outputs/flutter-apk/app-release.apk"
    echo "📏 APK size: $(du -h build/app/outputs/flutter-apk/app-release.apk | cut -f1)"
else
    echo "❌ APK build failed!"
    exit 1
fi

echo "🎉 Build complete! Your APK is ready for testing and submission."

#!/bin/bash

# Project configuration
PROJECT_NAME="sunni"
SCHEME_NAME="sunni"
BUILD_CONFIGURATION="Release"
EXPORT_OPTIONS_PLIST="AppStoreExportOptions.plist"

# Output directories
ARCHIVE_PATH="./build_signed/${PROJECT_NAME}.xcarchive"
IPA_PATH="./build_signed"

echo "------------------------------------------------"
echo "Starting SIGNED IPA Build Process for App Store..."
echo "------------------------------------------------"

# 1. Clean build directory
echo "Step 1: Cleaning..."
rm -rf "./build_signed"
mkdir -p "./build_signed"

# 2. Archive the project
echo "Step 2: Archiving project..."
xcodebuild archive \
    -workspace "${PROJECT_NAME}.xcworkspace" \
    -scheme "${SCHEME_NAME}" \
    -configuration "${BUILD_CONFIGURATION}" \
    -archivePath "${ARCHIVE_PATH}" \
    -destination "generic/platform=iOS" \
    -allowProvisioningUpdates \
    -quiet

if [ $? -ne 0 ]; then
    echo "Error: Archive failed. Please ensure your 'food' provisioning profile is installed in Xcode."
    exit 1
fi

# 3. Export IPA
echo "Step 3: Exporting Signed IPA..."
xcodebuild -exportArchive \
    -archivePath "${ARCHIVE_PATH}" \
    -exportPath "${IPA_PATH}" \
    -exportOptionsPlist "${EXPORT_OPTIONS_PLIST}" \
    -allowProvisioningUpdates \
    -quiet

if [ $? -ne 0 ]; then
    echo "Error: Export failed. This usually happens if the Distribution Certificate is missing from your Keychain."
    exit 1
fi

echo "------------------------------------------------"
echo "Success! SIGNED IPA generated in ${IPA_PATH}"
echo "------------------------------------------------"

# 4. Optional Upload
echo "Would you like to upload to App Store Connect now? (y/n)"
read -r answer
if [ "$answer" != "${answer#[Yy]}" ]; then
    echo "Uploading..."
    xcrun altool --upload-app -f "${IPA_PATH}/${PROJECT_NAME}.ipa" -t ios -u "hoangducthinh17460@icloud.com" -p "crvl-tawy-wibc-ulxg"
fi

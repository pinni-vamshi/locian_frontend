#!/bin/bash

# Script to help fix Xcode ProfessionRoutines configuration
# This script checks the current state and provides instructions

echo "🔍 Checking Xcode Project Configuration..."
echo ""

# Check if ProfessionRoutines exists
if [ -d "locian/ProfessionRoutines" ]; then
    echo "✅ ProfessionRoutines folder exists on disk"
    echo "   Location: locian/ProfessionRoutines"
    echo ""
    
    # Count JSON files
    json_count=$(find locian/ProfessionRoutines -name "*.json" | wc -l | tr -d ' ')
    echo "   Found $json_count JSON files"
    echo ""
else
    echo "❌ ProfessionRoutines folder not found!"
    exit 1
fi

echo "📋 Instructions to Fix in Xcode:"
echo ""
echo "Since your project uses File System Synchronization (objectVersion 77),"
echo "the ProfessionRoutines folder should be automatically included."
echo ""
echo "However, if you're getting duplicate file errors, it means:"
echo "1. Individual JSON files were manually added to Build Phases"
echo "2. Or the folder was added as a group instead of being auto-synced"
echo ""
echo "🔧 Fix Steps:"
echo ""
echo "STEP 1: Remove Individual File References"
echo "  1. Open Xcode"
echo "  2. Click project name (blue icon)"
echo "  3. Select 'locian' target"
echo "  4. Go to 'Build Phases' tab"
echo "  5. Expand 'Copy Bundle Resources'"
echo "  6. Look for individual JSON files (German.json, French.json, etc.)"
echo "  7. Select each one and press DELETE"
echo "  8. Keep only the 'locian' folder reference (if any)"
echo ""
echo "STEP 2: Verify File System Sync"
echo "  1. In Project Navigator, the 'locian' folder should show all subfolders"
echo "  2. ProfessionRoutines should appear automatically (no manual add needed)"
echo "  3. If ProfessionRoutines is missing, it will be auto-detected on next build"
echo ""
echo "STEP 3: Clean and Rebuild"
echo "  1. Product → Clean Build Folder (Shift+Cmd+K)"
echo "  2. Product → Build (Cmd+B)"
echo ""
echo "✅ After these steps, the build should succeed!"
echo ""


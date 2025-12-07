#!/bin/bash

set -e

SPECS_DIR="specs"

echo "Creating agent development folder structure..."

mkdir -p "$SPECS_DIR/docs"
mkdir -p "$SPECS_DIR/features/backlog"
mkdir -p "$SPECS_DIR/features/open"
mkdir -p "$SPECS_DIR/features/wip"
mkdir -p "$SPECS_DIR/features/done"
mkdir -p "$SPECS_DIR/features/abandoned"
mkdir -p "$SPECS_DIR/tasks/backlog"
mkdir -p "$SPECS_DIR/tasks/open"
mkdir -p "$SPECS_DIR/tasks/wip"
mkdir -p "$SPECS_DIR/tasks/done"
mkdir -p "$SPECS_DIR/tasks/abandoned"

echo "✓ Created specs/ folder structure"
echo "  - docs/"
echo "  - features/ (backlog, open, wip, done, abandoned)"
echo "  - tasks/ (backlog, open, wip, done, abandoned)"
echo ""
echo "Agent development environment ready!"

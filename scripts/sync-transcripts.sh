#!/usr/bin/env bash
set -euo pipefail

SOURCE="$HOME/.claude/projects"
DEST="$AGENT_OUTPUT_DIR/transcripts"

mkdir -p "$DEST"

find "$SOURCE" -name "*.jsonl" -type f | while read -r file; do
    timestamp=$(date -r "$file" "+%Y%m%d_%H%M%S")
    basename=$(basename "$file" .jsonl)
    target="$DEST/${timestamp}_${basename}.jsonl"

    if [ ! -f "$target" ]; then
        cp "$file" "$target"
        echo "Synced: ${timestamp}_${basename}.jsonl"
    fi
done

echo "Transcript sync complete."
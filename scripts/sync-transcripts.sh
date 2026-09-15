#!/usr/bin/env bash
set -euo pipefail

: "${AGENT_OUTPUT_DIR:?AGENT_OUTPUT_DIR is not set}"

# BSD date -r takes epoch seconds, GNU date -r takes a filename. Windows sets
# the output dir with backslashes, which git bash cannot use as a path.
case "$(uname)" in
    Darwin)
        fmt_mtime() { stat -f "%Sm" -t "%Y%m%d_%H%M%S" "$1"; }
        ;;
    MINGW*|MSYS*|CYGWIN*)
        fmt_mtime() { date -r "$1" "+%Y%m%d_%H%M%S"; }
        AGENT_OUTPUT_DIR="${AGENT_OUTPUT_DIR//\\//}"
        ;;
    *)
        fmt_mtime() { date -r "$1" "+%Y%m%d_%H%M%S"; }
        ;;
esac

SOURCE="$HOME/.claude/projects"
DEST="$AGENT_OUTPUT_DIR/transcripts"

mkdir -p "$DEST"

find "$SOURCE" -name "*.jsonl" -type f | while read -r file; do
    timestamp=$(fmt_mtime "$file")
    basename=$(basename "$file" .jsonl)
    target="$DEST/${timestamp}_${basename}.jsonl"

    if [ ! -f "$target" ]; then
        cp "$file" "$target"
        echo "Synced: ${timestamp}_${basename}.jsonl"
    fi
done

echo "Transcript sync complete."

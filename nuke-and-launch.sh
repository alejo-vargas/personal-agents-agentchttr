#!/usr/bin/env bash
# nuke-and-launch.sh — Failsafe full restart of agentchattr
# Usage:
#   bash nuke-and-launch.sh claude codex reviewer racer absolute_reviewer
#   bash nuke-and-launch.sh claude codex
#   bash nuke-and-launch.sh                          # server only
#
# IMPORTANT: Run with `bash`, not `sh` (macOS sh doesn't support all features).

set -e

AGENTS=("$@")

# --- Agent configuration functions ---

get_rename() {
    case "$1" in
        claude)             echo "funky" ;;
        codex)              echo "outsider" ;;
        reviewer)           echo "reviewer" ;;
        racer)              echo "racer" ;;
        absolute_reviewer)  echo "absolute-reviewer" ;;
        *)                  echo "" ;;
    esac
}

get_slot() {
    case "$1" in
        reviewer)           echo "claude-2" ;;
        racer)              echo "claude-3" ;;
        absolute_reviewer)  echo "claude-4" ;;
        *)                  echo "$1" ;;
    esac
}

get_tmux() {
    case "$1" in
        reviewer)           echo "agentchattr-claude-2" ;;
        racer)              echo "agentchattr-claude-3" ;;
        absolute_reviewer)  echo "agentchattr-claude-4" ;;
        *)                  echo "agentchattr-$1" ;;
    esac
}

echo "=== NUKING ALL AGENTCHATTR ==="

# 1. Kill all agentchattr tmux sessions
for s in $(tmux list-sessions -F '#{session_name}' 2>/dev/null | grep '^agentchattr-'); do
    echo "  Killing tmux session: $s"
    tmux kill-session -t "$s" 2>/dev/null || true
done

# 2. Kill server and wrappers
pkill -f "wrapper.py" 2>/dev/null || true
pkill -f "python.*run.py" 2>/dev/null || true
sleep 2

# 3. Clear renames.json so the server starts with clean slot names
# (we rename via API after all agents are registered)
rm -f ~/agentchattr/data/renames.json

# 4. Verify clean
remaining=$(ps aux | grep -E "wrapper.py|python.*run.py" | grep -v grep | wc -l | tr -d ' ')
if [ "$remaining" -gt 0 ]; then
    echo "  WARNING: $remaining processes still alive, force killing..."
    pkill -9 -f "wrapper.py" 2>/dev/null || true
    pkill -9 -f "python.*run.py" 2>/dev/null || true
    sleep 1
fi

echo "=== STARTING SERVER ==="
cd ~/agentchattr
source .venv/bin/activate
python run.py &
SERVER_PID=$!
sleep 3

if ! curl -s http://localhost:8300 > /dev/null 2>&1; then
    echo "ERROR: Server failed to start"
    exit 1
fi
echo "  Server running (PID $SERVER_PID)"

if [ ${#AGENTS[@]} -eq 0 ]; then
    echo "=== No agents requested. Server only. ==="
    echo "Web UI: http://localhost:8300"
    exit 0
fi

# Sort agents: claude family in slot order first, then non-claude
CLAUDE_ORDER="claude reviewer racer absolute_reviewer"
SORTED_AGENTS=()
for c in $CLAUDE_ORDER; do
    for a in "${AGENTS[@]}"; do
        if [ "$a" = "$c" ]; then
            SORTED_AGENTS+=("$a")
        fi
    done
done
for a in "${AGENTS[@]}"; do
    is_claude=0
    for c in $CLAUDE_ORDER; do
        if [ "$a" = "$c" ]; then is_claude=1; break; fi
    done
    if [ $is_claude -eq 0 ]; then
        SORTED_AGENTS+=("$a")
    fi
done

echo "=== LAUNCHING AGENTS: ${SORTED_AGENTS[*]} ==="
cd ~/agentchattr/macos-linux
for agent in "${SORTED_AGENTS[@]}"; do
    script="start_${agent}.sh"
    if [ ! -f "$script" ]; then
        echo "  WARNING: $script not found, skipping $agent"
        continue
    fi
    echo "  Starting $agent..."
    sh "$script" 2>/dev/null &
    sleep 6
done

# Give wrappers time to fully register
sleep 3

echo "=== RENAMING AGENTS ==="
TOKEN=$(curl -s http://localhost:8300 | grep -o 'window.__SESSION_TOKEN__="[^"]*"' | cut -d'"' -f2)

for agent in "${SORTED_AGENTS[@]}"; do
    label=$(get_rename "$agent")
    slot=$(get_slot "$agent")
    if [ -n "$label" ] && [ -n "$slot" ]; then
        result=$(curl -s -X POST "http://localhost:8300/api/label/${slot}" \
            -H "Content-Type: application/json" \
            -H "X-Session-Token: $TOKEN" \
            -d "{\"label\": \"${label}\"}")
        echo "  $slot -> $label: $result"
    else
        echo "  $agent: no rename configured"
    fi
done

get_profile() {
    # macOS Terminal.app profile for each agent
    case "$1" in
        claude)             echo "Ocean" ;;          # funky
        codex)              echo "Homebrew" ;;       # outsider
        reviewer)           echo "Red Sands" ;;      # reviewer
        racer)              echo "Grass" ;;          # racer (TBD — confirm with user)
        absolute_reviewer)  echo "Silver Aerogel" ;; # absolute-reviewer (TBD — confirm with user)
        *)                  echo "Basic" ;;
    esac
}

get_title() {
    case "$1" in
        claude)             echo "funky (NotoNote)" ;;
        codex)              echo "outsider (NotoNote)" ;;
        reviewer)           echo "reviewer (NotoNote)" ;;
        racer)              echo "racer (ARJ CRM)" ;;
        absolute_reviewer)  echo "absolute-reviewer (ARJ CRM)" ;;
        *)                  echo "$1" ;;
    esac
}

echo ""
echo "=== OPENING TERMINALS ==="
for agent in "${SORTED_AGENTS[@]}"; do
    session=$(get_tmux "$agent")
    if [ -n "$session" ] && tmux has-session -t "$session" 2>/dev/null; then
        profile=$(get_profile "$agent")
        title=$(get_title "$agent")

        # Open Terminal with the agent's profile, set title, attach to tmux
        osascript -e "
            tell application \"Terminal\"
                do script \"printf '\\\\e]0;${title}\\\\a' && tmux attach -t ${session}\"
                set current settings of front window to settings set \"${profile}\"
                activate
            end tell" 2>/dev/null
        echo "  Opened terminal for $session ($title) [${profile}]"
        sleep 1
    else
        echo "  No tmux session for $agent (looked for $session)"
    fi
done

echo ""
echo "=== STATUS ==="
curl -s "http://localhost:8300/api/status" -H "X-Session-Token: $TOKEN" | python3 -m json.tool
echo ""
echo "=== DONE ==="
echo "Web UI: http://localhost:8300"
open http://localhost:8300

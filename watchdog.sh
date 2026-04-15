#!/bin/bash
# watchdog.sh — Monitors agentchattr agents and auto-fixes issues
# Usage: sh ~/Agents/Agentchattr\ Agent/watchdog.sh claude codex
#
# Runs in a loop. Checks every 15 seconds:
#   1. Is the server up? If not, restart it.
#   2. Are expected agents connected? If not, relaunch them.
#   3. Are agent names correct? If not, rename them.
#
# Rename map (edit these):
RENAME_claude="funky"
RENAME_codex="outsider"
# Add more: RENAME_gemini="somename"

CHECK_INTERVAL=15
AGENTS=("$@")

if [ ${#AGENTS[@]} -eq 0 ]; then
    echo "Usage: sh watchdog.sh claude codex"
    exit 1
fi

get_token() {
    curl -s http://localhost:8300 2>/dev/null | grep -o 'window.__SESSION_TOKEN__="[^"]*"' | cut -d'"' -f2
}

get_status() {
    local token="$1"
    curl -s "http://localhost:8300/api/status" -H "X-Session-Token: $token" 2>/dev/null
}

rename_agent() {
    local agent="$1"
    local label="$2"
    local token="$3"
    curl -s -X POST "http://localhost:8300/api/label/${agent}" \
        -H "Content-Type: application/json" \
        -H "X-Session-Token: $token" \
        -d "{\"label\": \"${label}\"}" 2>/dev/null
}

echo "=== AGENTCHATTR WATCHDOG ==="
echo "Monitoring agents: ${AGENTS[*]}"
echo "Check interval: ${CHECK_INTERVAL}s"
echo "Press Ctrl+C to stop"
echo ""

while true; do
    # Check server
    if ! curl -s http://localhost:8300 > /dev/null 2>&1; then
        echo "[$(date +%H:%M:%S)] Server down! Restarting..."
        cd ~/agentchattr && source .venv/bin/activate && python run.py &
        sleep 5
        if ! curl -s http://localhost:8300 > /dev/null 2>&1; then
            echo "[$(date +%H:%M:%S)] Server failed to restart. Will retry."
            sleep "$CHECK_INTERVAL"
            continue
        fi
        echo "[$(date +%H:%M:%S)] Server restarted."
    fi

    TOKEN=$(get_token)
    STATUS=$(get_status "$TOKEN")

    for agent in "${AGENTS[@]}"; do
        rename_var="RENAME_${agent}"
        expected_label="${!rename_var}"

        # Check if agent is connected (by base name, numbered variant, or renamed label)
        agent_found=""
        agent_key=""
        for key in "$agent" "${agent}-2" "${agent}-3" "${agent}-4" "$expected_label"; do
            if echo "$STATUS" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    a = d.get('$key', {})
    if a.get('available', False):
        print('yes')
except: pass
" 2>/dev/null | grep -q "yes"; then
                agent_found="true"
                agent_key="$key"
                break
            fi
        done

        if [ -z "$agent_found" ]; then
            # Agent not connected — check if wrapper is running
            if ! pgrep -f "wrapper.py.*${agent}" > /dev/null 2>&1; then
                echo "[$(date +%H:%M:%S)] $agent not connected and no wrapper running. Relaunching..."
                cd ~/agentchattr/macos-linux && sh "start_${agent}.sh" 2>/dev/null &
                sleep 8
                # Open terminal
                session="agentchattr-${agent}"
                if tmux has-session -t "$session" 2>/dev/null; then
                    osascript -e "tell application \"Terminal\"
                        do script \"tmux attach -t ${session}\"
                        activate
                    end tell" 2>/dev/null
                fi
                # Re-fetch status after relaunch
                TOKEN=$(get_token)
                STATUS=$(get_status "$TOKEN")
                agent_key="$agent"
            else
                echo "[$(date +%H:%M:%S)] $agent wrapper running but not showing in status. Waiting for reconnect..."
            fi
        fi

        # Check/fix rename
        if [ -n "$expected_label" ] && [ -n "$agent_key" ]; then
            current_label=$(echo "$STATUS" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('$agent_key',{}).get('label',''))" 2>/dev/null)
            if [ "$current_label" != "$expected_label" ] && [ -n "$current_label" ]; then
                echo "[$(date +%H:%M:%S)] $agent_key labeled '$current_label', renaming to '$expected_label'..."
                result=$(rename_agent "$agent_key" "$expected_label" "$TOKEN")
                echo "[$(date +%H:%M:%S)] Rename result: $result"
            fi
        fi
    done

    sleep "$CHECK_INTERVAL"
done

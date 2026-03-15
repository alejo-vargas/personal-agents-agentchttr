# Agentchattr Status

Check the status of agentchattr server and agents.

## Instructions

Run these commands to check status:

```bash
# Check if server is running
echo "=== Server ==="
pgrep -f "python.*run.py" && echo "Server: RUNNING" || echo "Server: NOT RUNNING"

# Check tmux sessions
echo ""
echo "=== Agent Sessions ==="
tmux list-sessions 2>/dev/null | grep agentchattr || echo "No agent sessions found"

# Check ports
echo ""
echo "=== Ports ==="
lsof -i:8300 2>/dev/null | head -2 || echo "Port 8300: not in use"
lsof -i:8200 2>/dev/null | head -2 || echo "Port 8200: not in use"
```

Report the status to the user. If everything is running, remind them the web UI is at http://localhost:8300

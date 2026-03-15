# Stop Agentchattr

Stop all agentchattr processes - server and agents.

## Instructions

Run these commands to shut everything down:

```bash
# Kill all agent tmux sessions
tmux kill-session -t agentchattr-claude 2>/dev/null
tmux kill-session -t agentchattr-codex 2>/dev/null
tmux kill-session -t agentchattr-claude-2 2>/dev/null
tmux kill-session -t agentchattr-codex-2 2>/dev/null

# Kill the server
pkill -f "python.*run.py"

# Kill any processes on the ports
lsof -ti:8300,8200,8201 | xargs kill -9 2>/dev/null
```

Confirm to the user that agentchattr has been stopped.

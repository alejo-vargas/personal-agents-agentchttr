# Stop Agentchattr

Stop the agentchattr server.

## ⚠️ CRITICAL WARNING

**NEVER run `tmux kill-session` or `tmux kill-server`!**

Killing tmux sessions destroys agent context and conversation history. The user will lose all their work.

## Instructions

**To stop ONLY the server (SAFE - agents will auto-reconnect when restarted):**
```bash
pkill -f "python.*run.py"
```

**To stop everything including agents (DESTRUCTIVE - ask permission first!):**

Before running any tmux kill commands, you MUST:
1. Explicitly ask the user: "This will destroy all agent conversation history. Are you sure?"
2. Wait for explicit confirmation
3. Only then run:
```bash
tmux kill-session -t agentchattr-claude 2>/dev/null
tmux kill-session -t agentchattr-codex 2>/dev/null
pkill -f "python.*run.py"
```

Confirm to the user what was stopped.

# Start Agentchattr

Start the agentchattr server and launch agents with full auto-trigger mode.

## Instructions

1. First, kill any existing agentchattr processes:
```bash
pkill -f "python.*run.py" 2>/dev/null
tmux kill-session -t agentchattr-claude 2>/dev/null
tmux kill-session -t agentchattr-codex 2>/dev/null
sleep 1
```

2. Start the server in background:
```bash
cd ~/agentchattr/macos-linux && sh start.sh &
sleep 3
```

3. The agent launcher scripts require an interactive terminal, so tell the user to run these commands in separate terminal windows:

**For Claude:**
```
cd ~/agentchattr/macos-linux && sh start_claude.sh
```

**For Codex:**
```
cd ~/agentchattr/macos-linux && sh start_codex.sh
```

4. Open the web UI:
```bash
open http://localhost:8300
```

5. Confirm agents are online in the web UI and ready to respond to @mentions.

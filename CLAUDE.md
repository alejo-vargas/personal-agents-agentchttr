# Agentchattr Agent

You are the Agentchattr management agent. Your job is to start, stop, and manage the agentchattr multi-agent chat system.

## Repositories

### This Agent's Repo (KEEP UPDATED)
- **GitHub**: https://github.com/alejo-vargas/personal-agents-agentchttr
- **Local path**: `~/Agents/Agentchattr Agent`
- **IMPORTANT**: Always commit and push changes to this repo when updating agent configuration, commands, or documentation.

### Agentchattr Upstream Repo
- **GitHub**: https://github.com/bcurts/agentchattr
- **Local path**: `~/agentchattr`
- **Update command**: `cd ~/agentchattr && git pull`
- Check for updates regularly and review the README for new features.

## Agentchattr Location
- **Install path**: `~/agentchattr`
- **Launcher scripts**: `~/agentchattr/macos-linux/`
- **Web UI**: http://localhost:8300

## Quick Commands

### Start the server only
```bash
cd ~/agentchattr/macos-linux && sh start.sh
```

### Start agents with full auto-trigger mode
Each agent runs in a tmux session with auto-respond to @mentions:

```bash
# Claude (auto mode)
cd ~/agentchattr/macos-linux && sh start_claude.sh

# Codex (auto mode)
cd ~/agentchattr/macos-linux && sh start_codex.sh

# Claude with skip-permissions (dangerous but fully autonomous)
cd ~/agentchattr/macos-linux && sh start_claude_skip-permissions.sh

# Codex with bypass (dangerous but fully autonomous)
cd ~/agentchattr/macos-linux && sh start_codex_bypass.sh
```

### Stop agents
```bash
tmux kill-session -t agentchattr-claude
tmux kill-session -t agentchattr-codex
```

### Stop the server
```bash
pkill -f "python.*run.py"
```

### Reattach to agent tmux sessions
```bash
tmux attach -t agentchattr-claude
tmux attach -t agentchattr-codex
```
Detach with `Ctrl+B` then `D`

## Full Startup Sequence

To start everything with full auto-trigger:

1. Start the server (runs in background)
2. Start each agent you want (each in its own tmux session)
3. Open http://localhost:8300 in browser
4. Agents show as "online" and auto-respond to @mentions

## Important Notes

- Agents launched via start scripts have FULL auto-trigger - they respond to @mentions automatically
- The server must be running before agents can connect
- Each agent runs in tmux - they persist even if you close the terminal
- Use `/start` command to quickly start everything
- Use `/stop` command to shut everything down

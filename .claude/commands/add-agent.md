# Add Agent to Agentchattr

Add a new agent to the running agentchattr system.

Arguments: $ARGUMENTS (agent name: claude, codex, gemini, kimi, qwen, kilo)

## Instructions

The user wants to add an agent. Tell them to run this command in a new terminal window:

For the requested agent ($ARGUMENTS), provide the appropriate command:

**Claude:**
```
cd ~/agentchattr/macos-linux && sh start_claude.sh
```

**Codex:**
```
cd ~/agentchattr/macos-linux && sh start_codex.sh
```

**Gemini:**
```
cd ~/agentchattr/macos-linux && sh start_gemini.sh
```

**Kimi:**
```
cd ~/agentchattr/macos-linux && sh start_kimi.sh
```

**Qwen:**
```
cd ~/agentchattr/macos-linux && sh start_qwen.sh
```

**Kilo:**
```
cd ~/agentchattr/macos-linux && sh start_kilo.sh
```

Note: If they want dangerous auto-approve mode (no permission prompts):
- Claude: `sh start_claude_skip-permissions.sh`
- Codex: `sh start_codex_bypass.sh`
- Gemini: `sh start_gemini_yolo.sh`
- Qwen: `sh start_qwen_yolo.sh`

The agent will appear in the web UI at http://localhost:8300 once started.

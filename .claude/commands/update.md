# Update Agentchattr

Pull the latest changes from the upstream agentchattr repository and check for new features.

## Instructions

1. Pull latest changes from upstream:
```bash
cd ~/agentchattr && git pull
```

2. Check if there are dependency updates:
```bash
cd ~/agentchattr && source .venv/bin/activate && pip install -r requirements.txt --upgrade
```

3. Read the README to check for new features or changes:
```bash
head -100 ~/agentchattr/README.md
```

4. Report to the user:
   - What changed (if any new commits)
   - Any new features mentioned in README
   - Whether they need to restart the server to apply updates

If the server is running, remind them to restart it after updates:
```bash
pkill -f "python.*run.py"
cd ~/agentchattr/macos-linux && sh start.sh
```

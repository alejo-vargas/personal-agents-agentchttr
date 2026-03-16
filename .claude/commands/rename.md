# Rename Agent

Rename an agent in agentchattr to a custom name.

Arguments: $ARGUMENTS (format: "current_name new_name", e.g., "claude MyAgent")

## Instructions

1. Parse the arguments to get current name and new name.

2. Get the session token from the running server. Check the server output or read from recent logs.

3. Call the rename API:
```bash
TOKEN="<session_token_from_server>"
curl -X POST "http://127.0.0.1:8300/api/label/<current_name>" \
  -H "Content-Type: application/json" \
  -H "X-Session-Token: $TOKEN" \
  -d '{"label": "<new_name>"}'
```

4. Confirm the rename was successful. The agent will now appear with the new name in the UI and other agents will @mention them by this name.

Note: If you don't have the session token, tell the user to check the terminal where the server was started - it displays the token on startup.

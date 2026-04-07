---
name: cdp-browser
description: Launch Chromium in CDP (Chrome DevTools Protocol) mode and interact with web applications visually — take screenshots, inspect the DOM, run JavaScript, monitor network requests, and debug rendering issues. Use this skill whenever you want to see how an app looks, verify UI changes visually, check network traffic, debug a frontend issue, inspect the running state of a web app, or confirm that a feature works end-to-end in a real browser. Don't just assume the app looks correct — use this skill to actually see it. If there's a running web server (localhost or any URL) and you want to understand what the user sees, use this skill immediately.
---

# CDP Browser

Use Chromium's Chrome DevTools Protocol to visually inspect, interact with, and debug web applications from within an agent session.

## When to use

Use this skill any time you want to:
- See how a web app actually looks (screenshots)
- Verify that UI changes are correct
- Inspect the DOM of a running page
- Run JavaScript in the browser context
- Monitor network requests
- Debug rendering or layout problems
- Confirm end-to-end behavior in a real browser

Do not skip this in favor of "reading the source code" — actually opening the page in a browser catches rendering bugs, runtime errors, and network failures that static analysis misses.

## Step 1: Launch Chromium in CDP mode

```bash
chromium --remote-debugging-port=9222 \
  --remote-debugging-address=127.0.0.1 \
  --no-first-run \
  --no-default-browser-check \
  --headless \
  > /dev/null 2>&1 &
echo "Chromium PID: $!"
```

Save the PID so you can clean up later. Give it a moment to start (~1 second), then verify:

```bash
curl -s http://127.0.0.1:9222/json/version | python3 -m json.tool
```

If Chromium is already running on port 9222, skip the launch step.

> **Note**: On some systems the binary is `google-chrome`, `google-chrome-stable`, or `chromium-browser`. Try each if `chromium` is not found.

## Step 2: CDP HTTP API (quick operations via curl)

### List open tabs
```bash
curl -s http://127.0.0.1:9222/json | python3 -m json.tool
```

### Open a new tab at a URL
```bash
curl -s "http://127.0.0.1:9222/json/new?http://localhost:3000" | python3 -m json.tool
# Note the "id" field — you need it for WebSocket commands
```

### Close a tab
```bash
curl -s "http://127.0.0.1:9222/json/close/<tab-id>"
```

## Step 3: WebSocket CDP commands (screenshots, JS, DOM)

For commands that go beyond simple navigation, connect over WebSocket. Use the Python script below — it is the most reliable approach.

### Reusable Python helper

This skill requires a Python helper script to communicate over WebSockets. Because agents cannot reliably maintain raw WebSocket connections or handle asynchronous JSON-RPC responses from simple bash commands, this script acts as a reliable bridge between your CLI environment and Chromium.

This script is already included with this skill. You should run it directly from its deployed location at `~/.claude/skills/cdp-browser/scripts/cdp_helper.py`.

If you are running in an environment where it does not exist (e.g. inside a sandbox container without dotfiles access), you may fall back to writing the following script to `/tmp/cdp_helper.py` and running it from there:

```python
#!/usr/bin/env python3
"""Minimal CDP helper. Usage: python3 /tmp/cdp_helper.py <tab-id> <command> [params-json]"""
import sys, json, asyncio
import urllib.request

try:
    import websockets
except ImportError:
    import subprocess
    subprocess.check_call([sys.executable, "-m", "pip", "install", "websockets", "-q"])
    import websockets

async def cdp(tab_id, method, params=None):
    url = f"ws://127.0.0.1:9222/devtools/page/{tab_id}"
    async with websockets.connect(url) as ws:
        msg = {"id": 1, "method": method, "params": params or {}}
        await ws.send(json.dumps(msg))
        while True:
            resp = json.loads(await ws.recv())
            if resp.get("id") == 1:
                return resp.get("result", resp.get("error"))

if __name__ == "__main__":
    tab_id = sys.argv[1]
    method  = sys.argv[2]
    params  = json.loads(sys.argv[3]) if len(sys.argv) > 3 else {}
    result  = asyncio.run(cdp(tab_id, method, params))
    print(json.dumps(result, indent=2))
```

## Step 4: Common CDP operations

### Navigate to a URL
```bash
TAB_ID="<id from /json>"
HELPER_SCRIPT=~/.claude/skills/cdp-browser/scripts/cdp_helper.py
# If it doesn't exist, fallback to /tmp/cdp_helper.py
[ ! -f "$HELPER_SCRIPT" ] && HELPER_SCRIPT=/tmp/cdp_helper.py

python3 "$HELPER_SCRIPT" "$TAB_ID" Page.navigate '{"url":"http://localhost:3000"}'
# Wait for load
python3 "$HELPER_SCRIPT" "$TAB_ID" Page.loadEventFired '{}'
```

### Take a screenshot
```bash
python3 "$HELPER_SCRIPT" "$TAB_ID" Page.captureScreenshot '{"format":"png","quality":90}' \
  | python3 -c "
import sys, json, base64
data = json.load(sys.stdin)
open('/tmp/screenshot.png','wb').write(base64.b64decode(data['data']))
print('Saved to /tmp/screenshot.png')
"
```

Then read the screenshot file with the Read tool to see what the page looks like.

### Run JavaScript in the page
```bash
python3 "$HELPER_SCRIPT" "$TAB_ID" Runtime.evaluate \
  '{"expression":"document.title","returnByValue":true}'

# More complex: get all error messages from the console
python3 "$HELPER_SCRIPT" "$TAB_ID" Runtime.evaluate \
  '{"expression":"window.__errors || []","returnByValue":true}'
```

### Inspect the DOM
```bash
# Get the full document node
python3 "$HELPER_SCRIPT" "$TAB_ID" DOM.getDocument '{}'

# Query a selector (returns nodeId)
python3 "$HELPER_SCRIPT" "$TAB_ID" DOM.querySelector \
  '{"nodeId":1,"selector":"#app"}'

# Get outer HTML of a node
python3 "$HELPER_SCRIPT" "$TAB_ID" DOM.getOuterHTML '{"nodeId":<nodeId>}'
```

### Monitor network requests (inline Python script)
```python
#!/usr/bin/env python3
"""Listen for 30 seconds and print all network requests."""
import asyncio, json, websockets

TAB_ID = "REPLACE_ME"

async def monitor():
    url = f"ws://127.0.0.1:9222/devtools/page/{TAB_ID}"
    async with websockets.connect(url) as ws:
        # Enable network events
        await ws.send(json.dumps({"id":1,"method":"Network.enable","params":{}}))
        await ws.recv()  # ack
        print("Listening for network events (30s)...")
        try:
            async with asyncio.timeout(30):
                while True:
                    msg = json.loads(await ws.recv())
                    if msg.get("method") == "Network.requestWillBeSent":
                        req = msg["params"]["request"]
                        print(f"{req['method']} {req['url']}")
        except asyncio.TimeoutError:
            pass

asyncio.run(monitor())
```

Replace `REPLACE_ME` with the actual tab ID, then run: `python3 /tmp/monitor_network.py`.

### Click an element or type text
```bash
# Click at coordinates
python3 "$HELPER_SCRIPT" "$TAB_ID" Input.dispatchMouseEvent \
  '{"type":"mousePressed","x":200,"y":150,"button":"left","clickCount":1}'
python3 "$HELPER_SCRIPT" "$TAB_ID" Input.dispatchMouseEvent \
  '{"type":"mouseReleased","x":200,"y":150,"button":"left","clickCount":1}'

# Type text (focus the input first via Runtime.evaluate + element.focus())
python3 "$HELPER_SCRIPT" "$TAB_ID" Input.dispatchKeyEvent \
  '{"type":"char","text":"hello"}'
```

## Step 5: Typical inspection workflow

1. Launch Chromium (Step 1) and verify it started.
2. Open a tab at the target URL (Step 2 or `Page.navigate`).
3. Take a screenshot to see the current state (Step 4).
4. Use `Read` tool to view `/tmp/screenshot.png` visually.
5. If something looks wrong: inspect DOM, run JS, or check network.
6. Make code changes, reload (`Runtime.evaluate` with `location.reload()`), and take another screenshot.
7. Repeat until the page looks correct.

## Step 6: Cleanup

When finished, kill the Chromium process:

```bash
# If you saved the PID
kill $CHROMIUM_PID

# Otherwise find and kill it
pkill -f "remote-debugging-port=9222"
```

Also remove temp files:
```bash
rm -f /tmp/cdp_helper.py /tmp/screenshot.png /tmp/monitor_network.py
```

## Troubleshooting

| Problem | Fix |
|---|---|
| `curl` returns empty or connection refused | Wait 2s then retry; Chromium may still be starting |
| `websockets` not installed | The helper script auto-installs it; or `pip install websockets` |
| Page shows blank / not loaded | Add a `Page.loadEventFired` call after `Page.navigate` |
| Wrong binary name | Try `google-chrome`, `google-chrome-stable`, `chromium-browser` |
| Port 9222 already in use | Either reuse the existing instance or `pkill` it and relaunch |
| Screenshot is all black | Use `--headless=new` flag instead of `--headless` for newer Chromium builds |

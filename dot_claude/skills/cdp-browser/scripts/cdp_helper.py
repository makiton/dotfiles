#!/usr/bin/env python3
"""Minimal CDP helper. Usage: python3 cdp_helper.py <tab-id> <command> [params-json]"""
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

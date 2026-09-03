# MatterPowerBridge — Tasmota Berry Script

A Berry script for [Tasmota](https://tasmota.github.io/) that bridges a **Matter virtual device** with a network host's power state: it sends a **Wake-on-LAN magic packet** when the device receives a "Power ON" command, triggers a remote shutdown when it receives "Power OFF", and continuously reflects the host's real online/offline status back to the Matter device via ping. Useful for waking up and shutting down PCs, NAS boxes, or any WoL-capable device via Apple Home, Google Home, or any other Matter controller.

---

## How It Works

1. A Matter virtual device is registered in Tasmota.
2. When the device receives a `Power ON` command (e.g. from a smart home app), Tasmota fires a rule and the script broadcasts a **magic packet** over UDP to `255.255.255.255:9`, waking the target host.
3. When the device receives a `Power OFF` command, the script sends an HTTP `GET` request to `http://<host>:5001/secret/shutdown`, where `<host>` is the IP address or hostname of the target machine.
4. In parallel, the script pings the target host every 60 seconds via `Ping4`. When the reachability state (`Ping#<host>#Reachable`) changes, it updates the Matter device's power state via `mtrupdate` to reflect whether the host is actually online.

---

## Requirements

- Tasmota firmware with **Berry scripting** and **Matter** support (≥ v13.x recommended)
- A WoL-capable host on the same local network
- The host must have Wake-on-LAN enabled in its BIOS/firmware settings
- For remote shutdown out of the box: the target host must be a Windows PC running [Remote Shutdown Manager](https://github.com/karpach/remote-shutdown-pc), listening on port `5001` with the `/secret/shutdown` endpoint enabled (see "Adapting to other systems" below if this doesn't apply to you)
- Tasmota's `Ping4` command must be available/enabled on the device for status polling

---

## Installation

1. Copy `MatterPowerBridge.be` to your Tasmota device via the **Berry Scripting Console** or by uploading it through the file manager (`http://<device-ip>/ufb`).

2. Add a Matter virtual device in Tasmota:
   - Go to **Configuration → Matter** and add a new virtual device (as v.Relay).
   - Note the device name (e.g. `PC`).

3. On the target host, install and configure [Remote Shutdown Manager](https://github.com/karpach/remote-shutdown-pc) with a secret code, and make sure port `5001` is reachable from your Tasmota device.

4. Load and instantiate the class from `autoexec.be`, providing the target's identity — Matter device name, MAC address, and network host:

```berry
import MatterPowerBridge

var mtr_device_name = "PC"              # Matter virtual device name
var mac_address = "AA:BB:CC:DD:EE:FF"   # target's MAC address (for the magic packet)
var host = "192.168.1.2"                # target's IP address or hostname (for ping + shutdown)

_matterPowerBridge = MatterPowerBridge(mtr_device_name, mac_address, host)
```

- `mtr_device_name` — name of the Matter virtual device linked to this host (as v.Relay).
- `mac_address` — the target's network interface MAC address, used to build the WoL magic packet.
- `host` — the target's IP address or hostname on the local network, used both for the periodic reachability ping and for sending the shutdown request.

---

Once instantiated, the object listens for Matter `power==1`/`power==0` events for this host automatically and starts polling its reachability. No further configuration is needed.

---

## Adapting to Other Systems

The wake-up (magic packet) and reachability (ping) logic are generic and work for any device on the network, regardless of OS. The **shutdown** step, however, is tied to [Remote Shutdown Manager](https://github.com/karpach/remote-shutdown-pc), which is Windows-only.

To support other systems, replace `send_shutdown_request()` with a call to whatever shutdown mechanism your target host provides, for example:

- **Linux** — a small HTTP endpoint (e.g. a Flask/Python script or a `systemd`-triggered listener) that runs `systemctl poweroff` or `shutdown -h now`
- **macOS** — a similar lightweight HTTP wrapper around `shutdown -h now`, or an SSH command instead of HTTP
- **NAS (Synology/QNAP)** — most expose their own REST API for shutdown; call that directly instead of `/secret/shutdown`
- **Anything reachable over SSH** — swap the `webclient()` GET call for an SSH command execution (requires a Berry SSH client or an intermediary script)

The rest of the class (Matter rule wiring, magic packet, ping-based status) needs no changes — only `send_shutdown_request()` (and possibly the port/path) needs to match your target system.

---

## Notes

- The magic packet is sent as a UDP broadcast to `255.255.255.255` on port `9` — the standard WoL port. Some routers may require port `7` instead.
- Power state in the Matter device now reflects **actual host reachability** (via ping), not a momentary button press — it stays "ON" as long as the host responds to pings and flips to "OFF" once it stops responding.
- Out of the box (Windows), shutdown depends on a helper app running on the host (see Credits below); if the shutdown request fails (non-200), it's logged via `tasmota.log`.
- Make sure your router/switch does not block UDP broadcasts between VLANs if your Tasmota device and the target host are on different network segments.

---

## Credits

Remote shutdown functionality (on Windows) relies on [**Remote Shutdown Manager**](https://github.com/karpach/remote-shutdown-pc) by [karpach](https://github.com/karpach) — a Windows tray application that listens for HTTP GET requests and can shutdown, suspend, hibernate, restart, or lock a PC. This script simply calls its `/secret/shutdown` endpoint; all credit for the shutdown-side implementation goes to that project.

---

## License

MIT
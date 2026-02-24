# WakeOnLan — Tasmota Berry Script

A Berry script for [Tasmota](https://tasmota.github.io/) that sends a **Wake-on-LAN magic packet** when a Matter virtual device receives a "Power ON" command. Useful for waking up PCs, NAS boxes, or any WoL-capable device via Apple Home, Google Home, or any other Matter controller.

---

## How It Works

1. A Matter virtual device is registered in Tasmota.
2. When the device receives a `Power ON` command (e.g. from a smart home app), Tasmota fires a rule.
3. The script catches the rule, broadcasts a **magic packet** over UDP to `255.255.255.255:9`.
4. The Matter device status is immediately reset back to `OFF` (since it's a momentary trigger, not a toggle).

---

## Requirements

- Tasmota firmware with **Berry scripting** and **Matter** support (≥ v13.x recommended)
- A WoL-capable device on the same local network
- The target device must have Wake-on-LAN enabled in its BIOS/firmware settings

---

## Installation

1. Copy `WakeOnLan.be` to your Tasmota device via the **Berry Scripting Console** or by uploading it through the file manager (`http://<device-ip>/ufb`).

2. Add a Matter virtual device in Tasmota:
   - Go to **Configuration → Matter** and add a new virtual device (as v.Relay).
   - Note the device name (e.g. `PC`).

3. Load and instantiate the class from `autoexec.be`:

```berry
import WakeOnLan

var mtr_device_name = "PC"
var mac_address = "AA:BB:CC:DD:EE:FF"

_wakeOnLan = WakeOnLan(mtr_device_name, mac_address)
```

Replace `"PC"` with your virtual Matter device name (as v.Relay) and `"AA:BB:CC:DD:EE:FF"` with the target machine's MAC address.

---

Once instantiated, the object listens for Matter `power==1` events automatically. No further configuration is needed.

---

## Notes

- The magic packet is sent as a UDP broadcast to `255.255.255.255` on port `9` — the standard WoL port. Some routers may require port `7` instead.
- The Matter device is toggled back to `OFF` right after the packet is sent, so it acts as a **momentary button** rather than a persistent switch.
- Make sure your router/switch does not block UDP broadcasts between VLANs if your Tasmota device and target machine are on different network segments.

---

## License

MIT
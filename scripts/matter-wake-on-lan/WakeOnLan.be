import json
import string

class WakeOnLan
  var mtr_device_name
  var mac_bytes

  def init(mtr_device_name, mac)
    self.mtr_device_name = mtr_device_name
    self.mac_bytes = bytes().fromhex(string.tr(mac, ":", ""))

    # Register a Tasmota rule: triggers when the specific Matter device receives a "Power ON" command
    tasmota.add_rule(f"mtrreceived#{mtr_device_name}#power==1", / value, trigger, msg -> self.handle_event(value, trigger, msg))
  end

  def handle_event()
    self.send_magic_packet()
    self.update_status(1)
    self.update_status(0)
  end

  def send_magic_packet()
    var u = udp()
    var payload = bytes("FFFFFFFFFFFF")

    for i:1..16
      payload += self.mac_bytes
    end

    u.send("255.255.255.255", 9, payload)
    u.close()
  end

  def update_status(state)
    var msg = json.dump({"name": self.mtr_device_name, "power": state})
    tasmota.cmd(f"mtrupdate {msg}")
  end
end

return WakeOnLan
import json
import string

class MatterPowerBridge
  var mtr_device_name
  var mac_bytes
  var host
  var is_online

  def init(mtr_device_name, mac_address, host)
    self.mtr_device_name = mtr_device_name
    self.mac_bytes = bytes().fromhex(string.tr(mac_address, ":", ""))
    self.host = host
    self.is_online = false

    # Register a Tasmota rule: triggers when the specific Matter device receives a "Power ON/OFF" command
    tasmota.add_rule(f"mtrreceived#{mtr_device_name}#power==1", / value, trigger, msg -> self.handle_power_on(value, trigger, msg))
    tasmota.add_rule(f"mtrreceived#{mtr_device_name}#power==0", / value, trigger, msg -> self.handle_power_off(value, trigger, msg))
    tasmota.add_rule("Ping#" + host + "#Reachable", / value, trigger, msg -> self.handle_ping_result(value, trigger, msg))

    self.do_ping()
  end

  def handle_power_on()
    self.send_magic_packet()
  end

  def handle_power_off()
    self.send_shutdown_request()
  end

  def do_ping()
    tasmota.cmd("Ping4 " + self.host)
    tasmota.set_timer(60000, / -> self.do_ping())
  end

  def handle_ping_result(value, trigger, msg)
    var online = (value == true)
    if online != self.is_online
      self.is_online = online
      self.update_status(online ? 1 : 0)
    end
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

  def send_shutdown_request()
    # NOTE: this call is specific to Remote Shutdown Manager (Windows).
    # See "Adapting to other systems" in the README if your target host runs Linux/macOS/NAS.
    var url = f"http://{self.host}:5001/secret/shutdown"
    var wc = webclient()
    wc.begin(url)

    var rc = wc.GET()
    if rc != 200
      tasmota.log(f"Shutdown request failed, HTTP {rc}", 2)
    end

    wc.close()
  end

  def update_status(state)
    var msg = json.dump({"name": self.mtr_device_name, "power": state})
    tasmota.cmd(f"mtrupdate {msg}")
  end
end

return MatterPowerBridge
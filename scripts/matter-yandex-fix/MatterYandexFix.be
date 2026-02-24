class MatterYandexFix
  # Matter cluster IDs for sensor types that need periodic update forcing
  static SENSOR_CLUSTERS = [
    0x0402,   # Temperature Measurement
    0x0405,   # Relative Humidity Measurement
  ]

  var _counter

  def init()
    self._counter = 0
  end

  def every_second()
    self._counter += 1
    if self._counter < 55
      return
    end

    self._counter = 0

    var md = global.member('matter_device')
    if md == nil
      return
    end

    for s: md.message_handler.im.subs_shop.subs
      if s.path_list == nil
        continue
      end

      for p: s.path_list
        if self.SENSOR_CLUSTERS.find(p.cluster) != nil
          s.not_before = 0
          break
        end
      end
    end
  end
end

return MatterYandexFix
# MatterYandexFix for Tasmota

### Problem

When using [Tasmota](https://tasmota.github.io/) with Matter protocol and [Yandex Smart Home](https://yandex.ru/alice/smart-home), temperature and humidity sensors stop updating after the initial reading. Illuminance sensors work fine.

### Installation

1. Upload `MatterYandexFix.be` to your Tasmota device via **Tools → Manage File System**
2. Create or edit `autoexec.be` with the following content:

```berry
import MatterYandexFix
tasmota.add_driver(MatterYandexFix())
```

3. Restart Berry VM via console: `BrRestart`

### Requirements

- Tasmota with Matter support (tested on 15.2.0+)
- Matter device commissioned to Yandex Smart Home
- Temperature and/or humidity sensors configured as Matter endpoints

---

### Проблема

При использовании [Tasmota](https://tasmota.github.io/) с протоколом Matter и [Яндекс Умным домом](https://yandex.ru/alice/smart-home) датчики температуры и влажности перестают обновляться после первоначального чтения. Датчики освещённости при этом работают нормально.

### Установка

1. Загрузите `MatterYandexFix.be` на устройство через **Tools → Manage File System**
2. Создайте или отредактируйте файл `autoexec.be`:

```berry
import MatterYandexFix
tasmota.add_driver(MatterYandexFix())
```

3. Перезапустите Berry VM через консоль: `BrRestart`

### Требования

- Tasmota с поддержкой Matter (проверено на 15.2.0+)
- Устройство добавлено в Яндекс Умный дом через Matter
- Датчики температуры и/или влажности настроены как Matter-эндпоинты
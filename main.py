
    
import time
import network
import urequests
from machine import Pin


WIFI_SSID = "Пепи A34"
WIFI_PASS = "12345qwery"
FIREBASE_URL = "https://smartbowl-b9c86-default-rtdb.europe-west1.firebasedatabase.app"
USER_UID = "mla9qS3SQtM9HaHNbt0wzwANhjP2"


dout = Pin(21, Pin.IN)
pd_sck = Pin(22, Pin.OUT)


BASE_RAW = 141900   
FACTOR = 110.3      
OFFSET = 48         # Тв

def read_hx711():
    data = 0
    timeout = 0
    # Чакаме сензора да е готов (dout трябва да стане 0)
    while dout.value() == 1:
        timeout += 1
        if timeout > 10000: return None
    
    # Четене на 24-те бита данни
    for i in range(24):
        pd_sck.value(1)
        time.sleep_us(1)
        data = (data << 1) | dout.value()
        pd_sck.value(0)
        time.sleep_us(1)
    
    # 25-ти импулс (Gain 128)
    pd_sck.value(1)
    time.sleep_us(1)
    pd_sck.value(0)
    
    # Оправяне на знака за 24-битово число
    if data & 0x800000:
        data -= 0x1000000
    return data

def get_clean_average(samples=10):
    values = []
    for _ in range(samples):
        v = read_hx711()
        if v is not None:
            # Филтър за шум: взимаме само стойности в реални граници
            if 100000 < v < 200000:
                values.append(v)
        time.sleep_ms(10)
    
    if not values:
        return BASE_RAW
    return sum(values) / len(values)

def connect_wifi():
    wlan = network.WLAN(network.STA_IF)
    wlan.active(True)
    if not wlan.isconnected():
        print("Свързване към WiFi...")
        wlan.connect(WIFI_SSID, WIFI_PASS)
        # Изчакване до 10 секунди за връзка
        for _ in range(10):
            if wlan.isconnected(): break
            time.sleep(1)
    print("WiFi статус:", wlan.isconnected())

# --- СТАРТ ---
connect_wifi()
print("Системата стартира с корекция +{}...".format(OFFSET))

while True:
    try:
        # 1. Взимаме средно от 10 измервания
        raw_val = get_clean_average(10)
        
        # 2. Изчисляваме теглото по формула
        diff = raw_val - BASE_RAW
        weight_calculated = (diff / FACTOR) + 192
        
        # 3. Прилагаме твоята корекция
        final_weight = weight_calculated + OFFSET
        
        # 4. Смятаме процентите (192г до 366г -> общо 174г)
        percent = ((final_weight - 192) / 174) * 100
        percent = max(0, min(100, percent)) # Ограничаваме от 0 до 100%
        
        print("Raw: {:.0f} | Тегло: {:.1f}g | Ниво: {:.1f}%".format(raw_val, final_weight, percent))

        # 5. Изпращане към Firebase
        wlan = network.WLAN(network.STA_IF)
        if wlan.isconnected():
            url = "{}/users/{}/waterLevel.json".format(FIREBASE_URL, USER_UID)
            response = urequests.put(url, json=round(percent, 1))
            response.close()
            print("Изпратено успешно!")
        else:
            connect_wifi()

    except Exception as e:
        print("Грешка:", e)

    # Време между измерванията (10 секунди за тест)
    # За реална работа промени на 600 (10 минути)
    time.sleep(10)
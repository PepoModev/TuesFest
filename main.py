
import time
import machine
from hx711 import HX711
import network
import urequests
import json
from machine  import Pin

# --- КОНФИГУРАЦИЯ ---
WIFI_SSID = "Modev-ap10"      # Сложи името на твоя интернет
WIFI_PASS = "1985im1985"         # Сложи паролата за интернета

# Firebase URL (вземи го от Firebase Console -> Realtime Database)
FIREBASE_URL = "https://smartbowl-b9c86-default-rtdb.europe-west1.firebasedatabase.app"
USER_UID = "mla9qS3SQtM9HaHNbt0wzwANhjP2"    # Твоят UID от Authentication таба

# Настройки на кантара (тези ги нагласи според твоите тестове)
CALIBRATION_FACTOR = 145.0  
CUP_EMPTY = 192.0          
WATER_FULL_CAPACITY = 366.0 

# --- ИНИЦИАЛИЗАЦИЯ НА ПИНОВЕТЕ (21 и 22) ---
# DT=21, SCK=22
hx = HX711(d_out=Pin(21), pd_sck=Pin(22))
hx.set_scale(CALIBRATION_FACTOR)

# --- ФУНКЦИЯ ЗА WIFI ---
def connect_wifi():
    wlan = network.WLAN(network.STA_IF)
    wlan.active(True)
    if not wlan.isconnected():
        print('Свързване към WiFi...')
        wlan.connect(WIFI_SSID, WIFI_PASS)
        
        # Опитва се да се свърже в продължение на 10 секунди
        attempt = 0
        while not wlan.isconnected() and attempt < 10:
            time.sleep(1)
            attempt += 1
            print("Опит {}...".format(attempt))
            
    if wlan.isconnected():
        print('WiFi Свързан!')
        print('IP адрес:', wlan.ifconfig()[0])
        return True
    else:
        print('Грешка: WiFi не може да се свърже!')
        return False

def get_stable_reading(samples=100):
    """ Взима средно аритметично от 100 сигнала за стабилност """
    total = 0
    for _ in range(samples):
        total += hx.get_units(1)
        time.sleep_ms(5) # Малка пауза за по-добро четене
    return total / samples

# --- СТАРТИРАНЕ ---
print("Системата се стартира...")
connect_wifi()
print("Зануляване... Махни всичко от кантара!")
hx.tare() 

while True:
    # Проверка дали интернетът още е там
    wlan = network.WLAN(network.STA_IF)
    if not wlan.isconnected():
        connect_wifi()

    try:
        # 1. Измерване (Average 100)
        avg_weight = get_stable_reading(100)
        
        # 2. Логика за водата
        current_water_weight = avg_weight - CUP_EMPTY
        percent = (current_water_weight / WATER_FULL_CAPACITY) * 100
        percent = min(100, max(0, percent)) 
        
        print("Тегло: {:.1f}g | Процент: {:.1f}%".format(avg_weight, percent))

        # 3. Пращане към Firebase
        # Пътят е: users / UID / waterLevel
        url = "{}/users/{}/waterLevel.json".format(FIREBASE_URL, USER_UID)
        
        # Изпращаме само процента като число
        response = urequests.put(url, json=round(percent, 1))
        
        if response.status_code == 200:
            print("Изпратено успешно!")
        else:
            print("Firebase грешка:", response.status_code)
        
        response.close()

    except Exception as e:
        print("Грешка:", e)

    # Време за изчакване (10 минути = 600 сек)
    # За теста го направи на 10, после го върни на 600
    print("Спя за 10 минути...")
    time.sleep(30)
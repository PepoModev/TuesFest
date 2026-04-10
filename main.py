import network
import urequests
import time
from machine import Pin
from hx711 import HX711

# --- НАСТРОЙКИ ---
WIFI_SSID = "ivo_home1"
WIFI_PASS = "1985im1985"
# Сложи твоето UID и задължително .json накрая
FIREBASE_URL = "https://smartbowl-b9c86-default-rtdb.europe-west1.firebasedatabase.app/users/GW9BcgmrixMbtopMnjjUYogvTXn1.json"

# Твоите калибрирани стойности
CUP_EMPTY = 192.0
CUP_FULL = 366.0
CAPACITY = CUP_FULL - CUP_EMPTY

# Инициализация на датчика
hx = HX711(d_out=Pin(21), pd_sck=Pin(22))
# Увеличаваме scale, ако числата са малки. Пробвай със 705 или 420.
hx.set_scale(420) 
hx.tare()

def connect_wifi():
    wlan = network.WLAN(network.STA_IF)
    wlan.active(True)
    wlan.connect(WIFI_SSID, WIFI_PASS)
    while not wlan.isconnected():
        time.sleep(0.5)
    print("WiFi Свързан!")

connect_wifi()

while True:
    try:
        # Взимаме средно от 20 измервания за стабилност
        val = hx.get_units(20) 
        
        if val is None:
            print("Датчикът не праща данни, проверявам връзките...")
            continue

        grams = val
        if grams < 0: grams = 0
        
        # Изчисляване на процента
        water_grams = grams - CUP_EMPTY
        if water_grams < 0: water_grams = 0
        
        percentage = int((water_grams / CAPACITY) * 100)
        if percentage > 100: percentage = 100
        
        print("Стабилно тегло: {:.1f}г | Процент: {}%".format(grams, percentage))

        # Пращане към Firebase само ако има интернет
        data = {"waterLevel": percentage}
        res = urequests.patch(FIREBASE_URL, json=data)
        res.close()
        print("Данните са в Firebase!")

    except Exception as e:
        print("Грешка:", e)
        # Ако връзката прекъсне (Грешка 104), рестартираме WiFi
        connect_wifi()

    time.sleep(2)
from machine import Pin
import time

# Твоите кабели са на тези пинове:
# DT (Data) -> Pin 21
# SCK (Clock) -> Pin 22
dout = Pin(21, Pin.IN)
pd_sck = Pin(22, Pin.OUT)

def read_raw():
    # Чакаме сензора да е готов
    count = 0
    while dout.value() == 1:
        count += 1
        if count > 10000: # Защита, ако няма връзка
            return None
            
    raw = 0
    # Четем 24 бита данни от HX711
    for _ in range(24):
        pd_sck.value(1)
        raw = (raw << 1) | dout.value()
        pd_sck.value(0)
    
    # 25-ият импулс настройва усилването
    pd_sck.value(1)
    pd_sck.value(0)
    
    return raw ^ 0x800000

print("--- ТЕСТ НА КАНТАРА СТАРТИРА ---")
print("Натисни металната греда, за да видиш дали числата се променят.")

while True:
    val = read_raw()
    if val is None:
        print("ГРЕШКА: Няма връзка със сензора! Провери жиците.")
    else:
        print("Стойност:", val)
    
    time.sleep(0.5)	
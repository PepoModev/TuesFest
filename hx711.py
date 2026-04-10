# hx711.py за MicroPython
import time
from machine import Pin

class HX711:
    def __init__(self, d_out, pd_sck, gain=128):
        self.pSCK = pd_sck
        self.pOUT = d_out
        self.pSCK.init(mode=Pin.OUT)
        self.pOUT.init(mode=Pin.IN)
        self.GAIN = 0
        self.OFFSET = 0
        self.SCALE = 1
        self.set_gain(gain)

    def is_ready(self):
        return self.pOUT.value() == 0

    def set_gain(self, gain):
        if gain == 128:
            self.GAIN = 1
        elif gain == 64:
            self.GAIN = 3
        elif gain == 32:
            self.GAIN = 2
        self.pSCK.value(0)
        self.read()

    def read(self):
        while not self.is_ready():
            pass

        data = 0
        for i in range(24):
            self.pSCK.value(1)
            data = (data << 1) | self.pOUT.value()
            self.pSCK.value(0)

        # Пулс за Gain
        for i in range(self.GAIN):
            self.pSCK.value(1)
            self.pSCK.value(0)

        # 2's complement
        if data & 0x800000:
            data -= 0x1000000

        return data

    def read_average(self, times=10):
        sum = 0
        for i in range(times):
            sum += self.read()
        return sum / times

    def get_value(self, times=10):
        return self.read_average(times) - self.OFFSET

    def get_units(self, times=10):
        return self.get_value(times) / self.SCALE

    def tare(self, times=10):
        sum = self.read_average(times)
        self.set_offset(sum)

    def set_scale(self, scale):
        self.SCALE = scale

    def set_offset(self, offset):
        self.OFFSET = offset
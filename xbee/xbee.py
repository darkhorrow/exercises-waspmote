from digi.xbee.devices import XBeeDevice
from time import localtime, strftime

if __name__ == '__main__':

    device = XBeeDevice("COM6", 115200)
    device.open()
    dw = int(strftime("%w", localtime()))+1
    time = strftime(f"%Y:%m:%d:{dw}:%H:%M:%S", localtime())
    device.send_data_broadcast(time)

    device.close()
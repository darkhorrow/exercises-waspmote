from digi.xbee.devices import XBeeDevice
from time import localtime, strftime, sleep

SLEEP_TIME = 60


def receive_mote_data(xbee_message):
    address = xbee_message.remote_device.get_64bit_addr()
    data = xbee_message.data.decode("utf8")
    print("Received data from %s: \n%s" % (address, data))


def send_timestamp(xbee):
    dw = int(strftime("%w", localtime())) + 1
    time = strftime(f"%y:%m:%d:0{dw}:%H:%M:%S", localtime())
    xbee.send_data_broadcast(time)


if __name__ == '__main__':
    device = XBeeDevice("COM6", 115200)
    device.open()

    device.add_data_received_callback(receive_mote_data)

    while True:
        send_timestamp(device)
        sleep(SLEEP_TIME)
        print('Awaken!')

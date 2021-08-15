import serial
import sys

if len(sys.argv) == 3:
    file = open(sys.argv[2], "rb")
else:
    print("Usage: ./loader.py <serial port> <filename>")
    sys.exit()

ser = serial.Serial(sys.argv[1], 115200)
if ser.is_open:
    print("OK")
else:
    print("ERROR")
    ser.close()
    sys.exit()

stream = file.read()
file.close()

packet = []

for byte in range(len(stream)):
    packet.append(0x21)
    packet.append(byte % 256)
    packet.append(int(byte / 256) % 256)
    packet.append(stream[byte])

try:
    ser.write(packet)
except:
    print("ERROR...")

ser.close()

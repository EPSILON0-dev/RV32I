from argparse import ArgumentParser
from serial import Serial
from time import sleep
from math import ceil


BAUD_RATE    = 9600
WRITE_LENGTH = 8    # words
READ_LENGTH  = 128  # words


def get_args():
    parser = ArgumentParser("Firmware loader")
    parser.add_argument("filename")
    parser.add_argument("serial")
    return parser.parse_args()


def load_file(filename):
    with open(filename, 'rb') as f:
        return f.read()


def connect_serial(port: str) -> Serial:
    ser = Serial(port, BAUD_RATE, timeout=1)
    ser.write(b'\r')
    sleep(0.01)
    ser.write(b'\r')
    sleep(0.1)
    ser.read_all()
    return ser


def write_words(ser: Serial, addr: int, words: list[int]) -> None:
    cmd = f"{addr:08X}: "
    for word in words:
        cmd += f"{word:08X} "
    cmd += '\r'
    bcmd = bytes(cmd, encoding='ascii')
    ser.write(bcmd)
    sleep(len(bcmd) * 11 / BAUD_RATE)


def parse_read_data(data: str) -> list[int]:
    lines = data.split(b'\r\n')
    lines = [line for line in lines if b':' in line]
    lines = [line.split(b':')[1] for line in lines]
    lines = [line.split(b' ') for line in lines]
    nums = sum(lines, [])
    nums = [int(num, 16) for num in nums if num != b'']
    return nums


def calculate_read_timeout(words: int, baud_rate: int) -> float:
    timeout = words
    timeout *= 16                # Around 16 chars per word
    timeout *= 10                # 10 bauds per character
    timeout /= float(baud_rate)  # Divide by baudrate
    timeout *= 1.25              # Generous error margin
    return timeout


def read_words(ser: Serial, addr: int, words: int) -> list[int]:
    ser.write(b'\r')
    ser.flush()
    sleep(1)
    ser.read_all()
    cmd = bytes(f'{addr:08X}.{addr+words*4:08X}\r', encoding='ascii')
    ser.write(cmd)
    ser.timeout = calculate_read_timeout(words, BAUD_RATE)
    resp = ser.read_until('>')  # As if it worked...
    return parse_read_data(resp)


def bytes_to_words(data: bytes) -> list[int]:
    words = []
    for i in range(len(data) // 4):
        word = data[i * 4 + 3]
        word = (word << 8) + data[i * 4 + 2]
        word = (word << 8) + data[i * 4 + 1]
        word = (word << 8) + data[i * 4]
        words.append(word)
    return words


def words_to_chunks(words: list[int], chunksize: int) -> list[list[int]]:
    return [words[i:i+chunksize] for i in range(0, len(words), chunksize)]


def prepare_write_chunks(data: bytes) -> list[list[int]]:
    chunks = ceil(len(data) / WRITE_LENGTH / 4)
    print(f'File loaded: {len(data)}B, {chunks} chunks')
    padding_length = chunks * WRITE_LENGTH * 4 - len(data)
    data += bytes([0] * padding_length)
    print(f'Added padding: {padding_length}B')
    return words_to_chunks(bytes_to_words(data), WRITE_LENGTH)


def words_to_bytes(words: list[int]) -> list[int]:
    return sum([[
        (w >>  0) & 0xff,
        (w >>  8) & 0xff,
        (w >> 16) & 0xff,
        (w >> 24) & 0xff
    ] for w in words], [])


def compare(actual_bytes: list[int], expected_bytes: list[int], offset_words: int, length_words: int) -> bool:
    error = False
    try:
        for i in range(length_words * 4):
            if (actual_bytes[i] != expected_bytes[i + offset_words * 4]):
                error = True
                print(f"Mismatch on byte 0x{offset_words * 4 + i:x}")
    except IndexError:
        pass
    return error


def main():
    args = get_args()
    data = load_file(args.filename)
    ser = connect_serial(args.serial)

    write_chunks = prepare_write_chunks(data)
    write_addr = 0x8000
    for i, chunk in enumerate(write_chunks):
        print(f'\rWriting: {(i + 1) / len(write_chunks) * 100:.0f}%', end='')
        write_words(ser, write_addr, chunk)
        write_addr += len(chunk) * 4
    print('\rWriting: Done!')

    read_addr = 0x8000
    read_chunk_count = ceil(len(data) / (READ_LENGTH * 4))
    verify_error = False
    for i in range(read_chunk_count):
        print(f'\rReading: {(i + 1) / read_chunk_count * 100:.0f}%', end='')
        words = read_words(ser, read_addr, READ_LENGTH)
        bytes = words_to_bytes(words)
        verify_error |= compare(bytes, data, (i * READ_LENGTH), READ_LENGTH)
        read_addr += READ_LENGTH * 4
    print('\rReading: Done!')

    if not verify_error:
        print('Verified: Okay!')
        ser.write(b'r\r')
        print('Starting...')

    ser.close()


if __name__ == '__main__':
    main()

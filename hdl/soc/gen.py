from sys import argv, exit


def get_file(filename) -> bytes:
    with open(filename, 'rb') as f:
        b = f.read()
        if len(b) > 2048:
            print('Malformated or too big file')
            exit(1)
    while len(b) < 2048:
        b += b'\0'
    return b


def gen_data_str(b: bytes) -> str:
    s = ''
    for i in range(len(b) // 4):
        s += f"    assign rom_array[{i}] = 32'h"
        for j in range(4):
            s += f'{b[(i * 4) + (3 - j)]:02X}'
        s += ';\n'
    return s


def get_rom_file() -> list[str]:
    with open('rom.sv', 'r') as f:
        lines = f.readlines()
    return lines


def update_rom_file(lines: list[str], data_str: str) -> str:
    try:
        startindex = lines.index('// --- AUTOGEN ---\n')
        endindex = lines.index('// --/ AUTOGEN /--\n')
    except ValueError:
        print("AUTOGEN markers not found")
        exit(1)
    new_lines = lines[:startindex+1] + [data_str] + lines[endindex:]
    return ''.join(new_lines)


def save_rom_file(filedata: str) -> None:
    with open('rom.sv', 'w') as f:
        f.write(filedata)


def main():
    data_str = gen_data_str(get_file(argv[1]))
    save_rom_file(update_rom_file(get_rom_file(), data_str))


if __name__ == '__main__':
    main()

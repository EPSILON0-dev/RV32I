from subprocess import run
from pathlib import Path

PASSED = True

def load_tests() -> list[str]:
    path = Path("tests/bin")
    tests = set()
    for file in path.iterdir():
        if file.stem not in tests:
            tests.add(file.stem)
    return sorted(list(tests))

def run_test(test: str) -> int:
    command = f"./testbench/tb tests/bin/{test}.hex"
    result = run(command, capture_output=True, text=True, check=True, shell=True)
    return(int(result.stdout))

def print_test(test: str) -> None:
    code = run_test(test)
    global PASSED
    if code != 1: PASSED = False
    test_name = test.upper()
    dashes = 23 - len(test_name)
    print(' ' + test_name, '-' * dashes + ' ', end='')
    print(f"{'\033[92m' if code == 1 else '\033[91m'}{code}\033[0m")

def main():
    print(" \033[97m--- RUNNING RV32 TESTS ---\033[0m")
    tests = load_tests()
    for test in tests:
        print_test(test)
    print(f" -----  {'\033[92m' if PASSED else '\033[91m'}", end='')
    print(f'TESTS {'PASSED' if PASSED else 'FAILED'}\033[0m  -----')

if __name__ == '__main__':
    main()

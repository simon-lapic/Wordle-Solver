import serial_solver, parallel_solver

def main():
    cmd = input("Run in parallel (P) or serial (S)? ").lower()
    
    while True:
        if cmd == 'exit':
            break
        elif cmd == 'p':
            print('parallel\n')
        elif cmd == 's':
            print('serial\n')
        cmd = input("Enter 'P' for parallel or 'S' for serial: ").lower()

if __name__ == "__main__":
    main()
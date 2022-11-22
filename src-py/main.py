import serial_solver, parallel_solver
import time

def main():
    cmd = input("Run in parallel (P) or serial (S)? (type 'EXIT' to exit) ").lower()
    
    while True:
        if cmd == 'exit':
            break
        elif cmd == 'p':
            parallel_solver.main()
        elif cmd == 's':
            serial_solver.main()
        cmd = input("Enter 'P' for parallel or 'S' for serial (type 'EXIT' to exit): ").lower()

if __name__ == "__main__":
    main()
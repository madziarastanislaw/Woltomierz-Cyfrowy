import serial
import serial.tools.list_ports
import time
import sys
import termios
import matplotlib.pyplot as plt
import json
from pynput import keyboard
from datetime import datetime

fd = sys.stdin.fileno()
old_settings = termios.tcgetattr(fd)

#AMPER - 0.01A
#SERIAL_PORT = '/dev/ttyUSB0' #ls /dev/ttyUSB*
BAUD_RATE = 9600

def list_ports():
    ports = serial.tools.list_ports.comports()
    print("available ports")
    for p in ports:
        print(f"{p.device} - {p.description}")
    return [p.device for p in ports]
    
def jason(data):
    labels = list(data.keys())
    values = [float(v) for v in data.values()]

    plt.figure(figsize=(10, 6))
    plt.bar(labels, values, align='center', color='skyblue', edgecolor='navy')
    plt.xticks(rotation=45, ha='right')
    plt.ylabel('Voltage [V]')
    plt.xlabel('Timestamp [hh:mm:ss]')
    plt.title('Voltemort')
    plt.tight_layout()
    plt.show()
    
def main():
    av_ports = list_ports()
    data = {}
    FTM = '%H:%M:%S'
    if not av_ports:
        print("no available ports - exit")
        return
    if (len(av_ports) == 1):
        print("port assigned automatically - only 1 av.")
        port = av_ports[0]
    else:
        port = input("choose port: ")  
    
    i = 0.0
    
    try:
        new_settings = termios.tcgetattr(fd)
        new_settings[3] = new_settings[3] & ~termios.ECHO  # Disable echo
        termios.tcsetattr(fd, termios.TCSADRAIN, new_settings)
    
        ser = serial.Serial(port, BAUD_RATE, timeout=0.1)
        
        last_print_time = time.time()
        last_valid_voltage = ""
        
        ser.reset_input_buffer()

        events = keyboard.Events()
        events.start()

        print("-------------------")
        print("Voltage meter\nspace -> next value\nq -> exit")
        print("-------------------")
        
        c = 0
        
        while True:
            if ser.in_waiting > 0:
                try:
                    line = ser.readline().decode('ascii', errors='ignore').strip()
                    
                    if len(line) > 0 and '.' in line:
                         last_valid_voltage = line
                except Exception:
                    pass
            
            event = events.get(0.0)
            
            if event is not None and isinstance(event, keyboard.Events.Press):
                if hasattr(event.key, 'char') and event.key.char == 'q':
                    print("Exiting...")
                    break
                if event.key == keyboard.Key.space:
                    if not c:
                        start = time.strftime(FTM)
                        c+=1
                    t = time.strftime(FTM)
                    print(f"[{i}] Voltage: {last_valid_voltage} V")
                    data[i] = last_valid_voltage
                    i+=0.1
                


    except serial.SerialException:
        print(f"Cant open port: {port}.")
    finally:
        with open("voltage.json", "w") as f:
            json.dump(data, f, indent=4)
            
        #jason(data)
            
        if 'ser' in locals() and ser.is_open:
            ser.close()
        
        termios.tcsetattr(fd, termios.TCSADRAIN, old_settings)

if __name__ == "__main__":
    main()

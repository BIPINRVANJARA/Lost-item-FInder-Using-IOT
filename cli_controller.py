#!/usr/bin/env python3
"""
==============================================================================
 Smart Item Lost Finder - Interactive PC Terminal CLI Controller
 Features:
   - 5-Second Countdown Delay (Time to hold probe wires)
   - Triggers clean Double-Beep (BEEP-BEEP) then auto-stops
==============================================================================
"""

import sys
import time

def print_banner():
    print("=" * 68)
    print("   🛰️  SMART ITEM FINDER - CLI CONTROLLER (5S DELAY + 2x BEEPS)  🛰️")
    print("   Pattern: [5s Countdown] -> BEEP #1 -> PAUSE -> BEEP #2 -> STOP")
    print("=" * 68)

def countdown_delay(seconds=5):
    print(f"\n⏳ [PREPARE HANDS] Triggering in {seconds} seconds... Hold your wires on the button!")
    for i in range(seconds, 0, -1):
        print(f"   ⏱️  {i}...", end="", flush=True)
        time.sleep(1)
    print(" 💥 >>> TRIGGERING 2x BEEPS NOW! <<<\n")

def serial_mode():
    try:
        import serial
        import serial.tools.list_ports
    except ImportError:
        print("\n[!] 'pyserial' not installed. Installing automatically...")
        import subprocess
        subprocess.check_call([sys.executable, "-m", "pip", "install", "pyserial"])
        import serial
        import serial.tools.list_ports

    ports = list(serial.tools.list_ports.comports())
    if not ports:
        print("\n[!] No serial ports found. Please connect your ESP32 via USB cable.")
        return

    print("\nAvailable Serial Ports:")
    for idx, p in enumerate(ports):
        print(f"  [{idx + 1}] {p.device} - {p.description}")

    selection = input(f"\nSelect port (1-{len(ports)}) [Default 1]: ").strip()
    port_idx = int(selection) - 1 if selection.isdigit() and 1 <= int(selection) <= len(ports) else 0
    selected_port = ports[port_idx].device

    print(f"\n[+] Connecting to {selected_port} at 115200 baud...")
    try:
        ser = serial.Serial(selected_port, 115200, timeout=1)
        time.sleep(1.5)
        # Flush any startup junk
        ser.reset_input_buffer()
        ser.reset_output_buffer()
        print("[✓] Connected to ESP32 successfully!\n")
        print("------------------------------------------------------------------")
        print(" Commands:")
        print("   [ ENTER ] or [ 1 ] : ⏳ 5s Countdown -> 🔊 Double Beep (BEEP-BEEP)")
        print("   [ 2 ] or 'stop'    : Force Stop / Release Button Immediately")
        print("   [ q ] or 'quit'    : Exit CLI")
        print("------------------------------------------------------------------\n")

        while True:
            cmd = input("Command [Press ENTER for 5s countdown & Double-Beep] > ").strip().lower()
            if cmd in ["q", "quit", "exit"]:
                print("Exiting CLI. Goodbye!")
                break
            elif cmd in ["", "1", "find", "beep", "f"]:
                # 1. 5-Second countdown delay
                countdown_delay(5)
                # 2. Send single trigger command to ESP32 (ESP32 handles the exact 2 beeps + auto-stop)
                ser.write(b"1\n")
                # Wait for ESP32 sequence to complete (0.8s + 0.4s + 0.8s = 2.0s)
                time.sleep(2.2)
            elif cmd in ["2", "stop", "s"]:
                print(">>> Sending STOP command to ESP32...")
                ser.write(b"stop\n")

            # Read and print responses from ESP32
            while ser.in_waiting:
                line = ser.readline().decode("utf-8", errors="ignore").strip()
                if line:
                    print(f" [ESP32] {line}")
            print()

        ser.close()
    except Exception as e:
        print(f"\n[!] Serial Error: {e}")

def lan_mode():
    try:
        import urllib.request
    except ImportError:
        pass

    ip = input("\nEnter ESP32 IP Address (e.g. 192.168.1.100): ").strip()
    if not ip:
        ip = "192.168.1.100"

    print(f"\n[+] Controlling ESP32 via LAN at http://{ip} ...")
    print("------------------------------------------------------------------")
    print("   [ ENTER ] or [ 1 ] : ⏳ 5s Countdown -> 🔊 Double Beep (BEEP-BEEP)")
    print("   [ q ] or 'quit'    : Exit CLI")
    print("------------------------------------------------------------------\n")

    while True:
        cmd = input("Command [Press ENTER to trigger 2x BEEPS] > ").strip().lower()
        if cmd in ["q", "quit", "exit"]:
            break
        elif cmd in ["", "1", "find", "beep", "f"]:
            countdown_delay(5)
            try:
                urllib.request.urlopen(f"http://{ip}/trigger", timeout=4)
                print(" 🛑 [STOP] >>> Completed Double Beep!\n")
            except Exception as e:
                print(f" [!] Request failed: {e}")
        print()

def main():
    print_banner()
    print("Choose Control Mode:")
    print("  [ 1 ] USB Serial CLI (Recommended - Plugged into PC)")
    print("  [ 2 ] Wi-Fi / LAN HTTP Mode")
    print("  [ 3 ] Exit")

    choice = input("\nSelect (1-3) [Default 1]: ").strip()
    if choice == "2":
        lan_mode()
    elif choice == "3":
        sys.exit(0)
    else:
        serial_mode()

if __name__ == "__main__":
    main()

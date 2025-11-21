#!/bin/bash
set -e

echo "[*] Starting Metasploit Framework Server..."

# شروع SSH
echo "[*] Starting SSH service..."
service ssh start || /usr/sbin/sshd

# بررسی وضعیت SSH
sleep 2
if pgrep -x "sshd" > /dev/null; then
    echo "[+] SSH service started successfully on port 22"
else
    echo "[!] Warning: SSH service may not be running properly"
fi

# نمایش اطلاعات اتصال
echo "======================================"
echo "SSH Connection Info:"
echo "User: root or msfuser"
echo "Password: 8181"
echo "Port: 22"
echo "======================================"

# شروع metasploit console با handler در background
echo "[*] Starting Metasploit console with handlers..."
if [ -f /home/msfuser/handler.rc ]; then
    su - msfuser -c "screen -dmS msf_console msfconsole -r /home/msfuser/handler.rc" || \
    msfconsole -r /home/msfuser/handler.rc &
    echo "[+] Metasploit console started with handler configuration"
else
    su - msfuser -c "screen -dmS msf_console msfconsole" || \
    msfconsole &
    echo "[+] Metasploit console started"
fi

echo "[*] You can attach to the console with: screen -r msf_console"
echo "[*] Server is ready!"

# نگه داشتن کانتینر
tail -f /dev/null

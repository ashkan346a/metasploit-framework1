#!/bin/bash
set -e

echo "[*] Starting Metasploit Framework Server..."

# شروع SSH (Alpine style)
echo "[*] Starting SSH service..."
/usr/sbin/sshd -D &
SSH_PID=$!

sleep 2

# بررسی SSH
if ps aux | grep -v grep | grep sshd > /dev/null; then
    echo "[+] SSH service started successfully on port 22"
else
    echo "[!] Warning: SSH may not be running"
fi

# نمایش اطلاعات
echo "======================================"
echo "SSH Connection Info:"
echo "User: root or msfuser"
echo "Password: 8181"
echo "Port: 22"
echo "======================================"

# شروع Metasploit
echo "[*] Starting Metasploit console..."
if [ -f /home/msfuser/handler.rc ]; then
    screen -dmS msf_console msfconsole -r /home/msfuser/handler.rc
    echo "[+] Metasploit with handlers started"
else
    screen -dmS msf_console msfconsole
    echo "[+] Metasploit console started"
fi

echo "[*] Server ready! Use: screen -r msf_console"

# نگه داشتن container
tail -f /dev/null

#!/bin/bash
set -e

echo "[*] Starting Metasploit Framework Server..."

# شروع SSH
echo "[*] Starting SSH service..."
service ssh start

# بررسی وضعیت SSH
if [ -f /var/run/sshd.pid ]; then
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

# راه‌اندازی database برای metasploit
echo "[*] Initializing Metasploit database..."
su - msfuser -c "cd /opt/metasploit-framework && ./msfdb init" || true

# شروع metasploit console با handler در background
echo "[*] Starting Metasploit console with handlers..."
if [ -f /opt/metasploit-framework/handler.rc ]; then
    su - msfuser -c "cd /opt/metasploit-framework && screen -dmS msf_console ./msfconsole -r /opt/metasploit-framework/handler.rc"
    echo "[+] Metasploit console started with handler configuration"
else
    su - msfuser -c "cd /opt/metasploit-framework && screen -dmS msf_console ./msfconsole"
    echo "[+] Metasploit console started"
fi

echo "[*] You can attach to the console with: screen -r msf_console"
echo "[*] Server is ready!"

# نگه داشتن کانتینر
tail -f /dev/null

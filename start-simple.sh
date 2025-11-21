#!/bin/bash
set -e

echo "[*] Starting Metasploit Server..."

# شروع SSH
echo "[*] Starting SSH..."
service ssh start

sleep 2

# نمایش اطلاعات
echo "======================================"
echo "SSH: ssh -p 55001 root@crossover.proxy.rlwy.net"
echo "Password: 8181"
echo "======================================"

# راه‌اندازی handlers
echo "[*] Starting Metasploit handlers..."
if [ -f /home/msfuser/handler.rc ]; then
    msfconsole -r /home/msfuser/handler.rc > /var/log/msf.log 2>&1 &
    echo "[+] Handlers started (log: /var/log/msf.log)"
fi

echo "[*] Server ready!"
echo "[*] Use: msfconsole"

# نگه داشتن container
tail -f /dev/null

#!/bin/bash
set -e

echo "[*] Starting Metasploit Framework Server..."

# تنظیم محیط
export PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/bundle/bin
export BUNDLE_GEMFILE=/usr/src/metasploit-framework/Gemfile
export MSF_ROOT=/usr/src/metasploit-framework

# شروع SSH (Alpine style)
echo "[*] Starting SSH service..."
/usr/sbin/sshd -D &
SSH_PID=$!

sleep 2

# بررسی SSH
if ps aux | grep -v grep | grep sshd > /dev/null; then
    echo "[+] SSH service started successfully on port 443"
else
    echo "[!] Warning: SSH may not be running"
fi

# نمایش اطلاعات
echo "======================================"
echo "SSH Connection Info:"
echo "User: root or msfuser"
echo "Password: 8181"
echo "Port: 443 (mapped via Railway TCP Proxy)"
echo "Command: ssh -p 55001 root@crossover.proxy.rlwy.net"
echo "======================================"

# شروع Metasploit handlers در background
echo "[*] Starting Metasploit handlers..."
cd /usr/src/metasploit-framework

if [ -f /home/msfuser/handler.rc ]; then
    nohup /usr/local/bin/bundle exec ruby ./msfconsole -r /home/msfuser/handler.rc > /var/log/msf.log 2>&1 &
    echo "[+] Metasploit handlers started (log: /var/log/msf.log)"
else
    echo "[!] handler.rc not found"
fi

echo "[*] Server ready!"
echo "[*] To access Metasploit: cd /usr/src/metasploit-framework && /run-msf.sh"
echo "[*] Or use: bundle exec ruby ./msfconsole"

# نگه داشتن container
tail -f /dev/null

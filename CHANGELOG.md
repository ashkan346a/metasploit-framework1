# تاریخچه تغییرات

## نسخه 2.2 - 22 نوامبر 2025

### 🐛 رفع خطای gemspec
- مشکل: `cannot load such file -- rails_version_constraint`
- راه حل: کپی کامل پروژه برای دسترسی به تمام فایل‌های مورد نیاز gemspec
- بهینه‌سازی: حذف کپی‌های تکراری و ساده‌سازی Dockerfile

## نسخه 2.1 - 22 نوامبر 2025

### 🐛 رفع خطای نصب Ruby
- مشکل: PPA brightbox برای Ubuntu 22.04 در دسترس نیست (404 Not Found)
- راه حل: استفاده از base image `ruby:3.1-slim` به جای نصب دستی

### 🚀 بهبودها
- سرعت بیشتر در build (استفاده از image آماده Ruby)
- کاهش حجم نهایی image
- پایداری بیشتر در build process

## نسخه 2.0 - 22 نوامبر 2025

### 🐛 رفع خطاها
1. **خطای Syntax در Dockerfile**
   - مشکل: کامنت فارسی در همان خط `ENV` باعث خطای `can't find = in "#"` می‌شد
   - راه حل: انتقال کامنت‌ها به خط جداگانه

2. **خطای نسخه Ruby**
   - مشکل: `Ruby >= 3.1 is required` اما Ubuntu 22.04 دارای Ruby 3.0.2 است
   - راه حل: نصب Ruby 3.1 از PPA brightbox

### ✨ قابلیت‌های جدید
- SSH Server با پسورد 8181 برای دسترسی remote
- راه‌اندازی خودکار Metasploit handlers برای Windows و Android
- اسکریپت `start.sh` برای مدیریت سرویس‌ها
- فایل `handler.rc` برای پیکربندی reverse shell handlers
- پیکربندی Railway با `railway.json`

### 📝 فایل‌های جدید
- `start.sh` - اسکریپت راه‌اندازی سرویس‌ها
- `handler.rc` - کانفیگ Metasploit handlers
- `railway.json` - تنظیمات Railway deployment
- `DEPLOY.md` - راهنمای استقرار و اتصال
- `test-local.sh` - اسکریپت تست محلی
- `.env.example` - نمونه متغیرهای محیطی

### 🔧 تغییرات فنی
- بهینه‌سازی Dockerfile با multi-stage caching
- نصب Ruby 3.1 برای سازگاری با Metasploit Framework
- تنظیم SSH با PermitRootLogin و PasswordAuthentication
- کاربر msfuser با دسترسی sudo
- پورت‌های 22, 443, 4444, 8080 expose شده‌اند

## نسخه 1.0 - نسخه اولیه
- Fork اولیه از Metasploit Framework

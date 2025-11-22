#!/bin/bash

# Advanced Pentesting Tools Installer
# For Android Payload Encryption & Configuration

PASS="8181"
LOGFILE="/home/offsec/Documents/GitHub/metasploit-framework1/tool_install.log"

echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║     🔥 نصب خودکار تمام ابزارهای حرفه‌ای پنتستینگ              ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""
echo "📝 Log: $LOGFILE"
echo ""

# Update system
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "⚙️  Updating system packages..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo $PASS | sudo -S apt-get update -qq >> $LOGFILE 2>&1
echo $PASS | sudo -S apt-get install -y -qq git curl wget python3 python3-pip python3-dev default-jre unzip >> $LOGFILE 2>&1
echo "✅ System updated"
echo ""

# Category 1: Basic Dependencies
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 Category 1: Basic Build Tools"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo $PASS | sudo -S apt-get install -y -qq build-essential binutils gcc g++ make cmake >> $LOGFILE 2>&1
echo $PASS | sudo -S apt-get install -y -qq mingw-w64 wine wine64 >> $LOGFILE 2>&1
echo "✅ Build tools installed"
echo ""

# Category 2: Packing & Compression
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 Category 2: UPX & Packing Tools"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo $PASS | sudo -S apt-get install -y -qq upx-ucl >> $LOGFILE 2>&1
upx --version && echo "✅ UPX installed" || echo "❌ UPX failed"
echo ""

# Category 3: Android Tools
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 Category 3: Android Tools (dex2jar, aapt)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo $PASS | sudo -S apt-get install -y -qq dex2jar aapt >> $LOGFILE 2>&1
echo "✅ dex2jar & aapt installed"
echo ""

# Category 4: Python Tools (user mode to avoid permission issues)
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 Category 4: Python Security Tools"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
pip3 install --user --upgrade \
    frida-tools \
    objection \
    apkid \
    androguard \
    pyarmor \
    pyinstaller \
    pwntools \
    ROPGadget \
    capstone \
    keystone-engine \
    unicorn >> $LOGFILE 2>&1

echo "✅ Frida installed: $(which frida 2>/dev/null || echo 'pending')"
echo "✅ Objection installed: $(which objection 2>/dev/null || echo 'pending')"
echo "✅ APKiD installed: $(which apkid 2>/dev/null || echo 'pending')"
echo "✅ PyArmor installed: $(which pyarmor 2>/dev/null || echo 'pending')"
echo "✅ pwntools installed"
echo ""

# Category 5: Veil Framework (payload encryption)
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 Category 5: Veil Framework"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ ! -d "/opt/Veil" ]; then
    echo $PASS | sudo -S git clone https://github.com/Veil-Framework/Veil.git /opt/Veil >> $LOGFILE 2>&1
    cd /opt/Veil
    echo $PASS | sudo -S bash config/setup.sh --force --silent >> $LOGFILE 2>&1
    echo "✅ Veil Framework installed at /opt/Veil"
else
    echo "✅ Veil already exists"
fi
echo ""

# Category 6: TheFatRat
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 Category 6: TheFatRat"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ ! -d "/opt/TheFatRat" ]; then
    echo $PASS | sudo -S git clone https://github.com/screetsec/TheFatRat.git /opt/TheFatRat >> $LOGFILE 2>&1
    cd /opt/TheFatRat
    echo $PASS | sudo -S chmod +x setup.sh
    echo "✅ TheFatRat cloned at /opt/TheFatRat (run ./setup.sh manually)"
else
    echo "✅ TheFatRat already exists"
fi
echo ""

# Category 7: Radare2
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 Category 7: Radare2 (Reverse Engineering)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if ! command -v r2 &> /dev/null; then
    echo $PASS | sudo -S git clone https://github.com/radareorg/radare2 /opt/radare2 >> $LOGFILE 2>&1
    cd /opt/radare2
    echo $PASS | sudo -S sys/install.sh >> $LOGFILE 2>&1
    r2 -v | head -1 && echo "✅ Radare2 installed" || echo "❌ Radare2 failed"
else
    echo "✅ Radare2 already installed"
fi
echo ""

# Category 8: jadx (APK Decompiler)
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 Category 8: jadx (DEX to Java Decompiler)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ ! -d "/opt/jadx" ]; then
    cd /tmp
    wget -q https://github.com/skylot/jadx/releases/download/v1.5.0/jadx-1.5.0.zip >> $LOGFILE 2>&1
    echo $PASS | sudo -S unzip -q jadx-1.5.0.zip -d /opt/jadx
    echo $PASS | sudo -S chmod +x /opt/jadx/bin/jadx*
    /opt/jadx/bin/jadx --version && echo "✅ jadx installed at /opt/jadx" || echo "❌ jadx failed"
else
    echo "✅ jadx already exists"
fi
echo ""

# Category 9: MobSF (Mobile Security Framework)
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 Category 9: MobSF (Mobile Security Framework)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ ! -d "/opt/Mobile-Security-Framework-MobSF" ]; then
    echo $PASS | sudo -S git clone https://github.com/MobSF/Mobile-Security-Framework-MobSF.git /opt/Mobile-Security-Framework-MobSF >> $LOGFILE 2>&1
    echo "✅ MobSF cloned at /opt/Mobile-Security-Framework-MobSF"
    echo "   Run: cd /opt/Mobile-Security-Framework-MobSF && ./setup.sh"
else
    echo "✅ MobSF already exists"
fi
echo ""

# Category 10: Ghidra (NSA Tool)
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 Category 10: Ghidra (NSA Reverse Engineering)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ ! -d "/opt/ghidra" ]; then
    echo "⚠️  Ghidra needs manual download from:"
    echo "   https://github.com/NationalSecurityAgency/ghidra/releases"
    echo "   Extract to /opt/ghidra"
else
    echo "✅ Ghidra already exists"
fi
echo ""

# Category 11: Cryptography Tools
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 Category 11: Advanced Cryptography"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo $PASS | sudo -S apt-get install -y -qq openssl gnupg2 cryptsetup >> $LOGFILE 2>&1
openssl version && echo "✅ OpenSSL installed" || echo "❌ OpenSSL failed"
gpg --version | head -1 && echo "✅ GnuPG installed" || echo "❌ GnuPG failed"
echo ""

# Category 12: Additional Tools
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 Category 12: Additional Utilities"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo $PASS | sudo -S apt-get install -y -qq \
    sqlmap \
    hashcat \
    john \
    hydra \
    nmap \
    masscan \
    nikto \
    dirb \
    gobuster \
    wfuzz >> $LOGFILE 2>&1
echo "✅ Additional pentesting tools installed"
echo ""

# Update PATH for user tools
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔧 Updating PATH..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Add to .bashrc if not already present
if ! grep -q "/.local/bin" ~/.bashrc; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
    echo "✅ PATH updated in ~/.bashrc"
fi

# Add /opt tools
if ! grep -q "/opt/jadx/bin" ~/.bashrc; then
    echo 'export PATH="/opt/jadx/bin:$PATH"' >> ~/.bashrc
fi

if ! grep -q "/opt/Veil" ~/.bashrc; then
    echo 'export PATH="/opt/Veil:$PATH"' >> ~/.bashrc
fi

echo ""
echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║                    ✅ INSTALLATION COMPLETE!                     ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""
echo "📋 Installed Tools Summary:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Veil Framework       → /opt/Veil"
echo "✅ TheFatRat            → /opt/TheFatRat"
echo "✅ Radare2              → $(which r2 2>/dev/null || echo 'check log')"
echo "✅ jadx                 → /opt/jadx/bin/jadx"
echo "✅ MobSF                → /opt/Mobile-Security-Framework-MobSF"
echo "✅ Frida                → $(which frida 2>/dev/null || echo '~/.local/bin/frida')"
echo "✅ Objection            → $(which objection 2>/dev/null || echo '~/.local/bin/objection')"
echo "✅ APKiD                → $(which apkid 2>/dev/null || echo '~/.local/bin/apkid')"
echo "✅ PyArmor              → $(which pyarmor 2>/dev/null || echo '~/.local/bin/pyarmor')"
echo "✅ pwntools             → Installed"
echo "✅ ROPgadget            → Installed"
echo "✅ UPX                  → $(which upx 2>/dev/null)"
echo "✅ OpenSSL              → $(which openssl)"
echo "✅ GnuPG                → $(which gpg)"
echo "✅ dex2jar              → $(which d2j-dex2jar 2>/dev/null || echo 'installed')"
echo ""
echo "🔄 To activate PATH changes, run:"
echo "   source ~/.bashrc"
echo ""
echo "📝 Full installation log: $LOGFILE"
echo ""
echo "🎯 Next Steps:"
echo "   1. source ~/.bashrc"
echo "   2. Test tools: frida --version, objection --version"
echo "   3. For MobSF: cd /opt/Mobile-Security-Framework-MobSF && ./setup.sh"
echo "   4. For TheFatRat: cd /opt/TheFatRat && ./setup.sh"
echo ""
echo "═══════════════════════════════════════════════════════════════════"

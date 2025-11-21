#!/bin/bash
# اسکریپت تست محلی برای Metasploit

echo "========================================="
echo "Testing Metasploit Framework Deployment"
echo "========================================="

# رنگ‌ها برای output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "\n${YELLOW}[1] Building Docker image...${NC}"
docker build -t metasploit-local . || {
    echo -e "${RED}[!] Build failed!${NC}"
    exit 1
}

echo -e "\n${GREEN}[+] Build successful!${NC}"

echo -e "\n${YELLOW}[2] Starting containers...${NC}"
docker-compose up -d || {
    echo -e "${RED}[!] Failed to start containers!${NC}"
    exit 1
}

echo -e "\n${GREEN}[+] Containers started!${NC}"

echo -e "\n${YELLOW}[3] Waiting for services to be ready...${NC}"
sleep 10

echo -e "\n${YELLOW}[4] Checking SSH service...${NC}"
docker exec -it $(docker ps -q -f name=ms) service ssh status || echo -e "${RED}[!] SSH not running${NC}"

echo -e "\n${YELLOW}[5] Checking Metasploit console...${NC}"
docker exec -it $(docker ps -q -f name=ms) screen -ls || echo -e "${RED}[!] No screen sessions${NC}"

echo -e "\n${GREEN}=========================================${NC}"
echo -e "${GREEN}Test completed!${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""
echo "To connect via SSH:"
echo "  ssh -p 22 root@localhost"
echo "  Password: 8181"
echo ""
echo "To attach to Metasploit console:"
echo "  docker exec -it \$(docker ps -q -f name=ms) screen -r msf_console"
echo ""
echo "To view logs:"
echo "  docker logs -f \$(docker ps -q -f name=ms)"
echo ""

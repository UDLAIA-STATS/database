
\connect udlafutbolappestudiantes

CREATE OR REPLACE FUNCTION football.log_changes()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO football.audit_logs (table_name, operation, new_data)
        VALUES (TG_TABLE_NAME, TG_OP, row_to_json(NEW));
        RETURN NEW;
    ELSIF (TG_OP = 'UPDATE') THEN
        IF OLD IS DISTINCT FROM NEW THEN
            INSERT INTO football.audit_logs (table_name, operation, old_data, new_data)
            VALUES (TG_TABLE_NAME, TG_OP, row_to_json(OLD), row_to_json(NEW));
        END IF;
        RETURN NEW;
    ELSIF (TG_OP = 'DELETE') THEN
        INSERT INTO football.audit_logs (table_name, operation, old_data)
        VALUES (TG_TABLE_NAME, TG_OP, row_to_json(OLD));
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION football.set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- =========================================
-- 4.  Índices
-- =========================================
CREATE INDEX IF NOT EXISTS idx_events_player_match
ON football.player_events (player_id, match_id);
CREATE INDEX IF NOT EXISTS idx_events_match_type
ON football.player_events (match_id, event_type);
CREATE INDEX IF NOT EXISTS idx_events_metadata_gin
ON football.player_events USING GIN (metadata);

CREATE INDEX IF NOT EXISTS idx_dist_player_match
ON football.player_distance_history (player_id, match_id);

CREATE INDEX IF NOT EXISTS idx_heat_player_match
ON football.player_heatmaps (player_id, match_id);

CREATE INDEX IF NOT EXISTS idx_consol_match
ON football.player_stats_consolidated (match_id);
CREATE INDEX IF NOT EXISTS idx_consol_player_match
ON football.player_stats_consolidated (player_id, match_id);

CREATE TRIGGER trg_log_player_events
AFTER INSERT OR UPDATE OR DELETE ON football.player_events
FOR EACH ROW EXECUTE FUNCTION football.log_changes();

CREATE TRIGGER trg_log_player_distance_history
AFTER INSERT OR UPDATE OR DELETE ON football.player_distance_history
FOR EACH ROW EXECUTE FUNCTION football.log_changes();

CREATE TRIGGER trg_log_player_heatmaps
AFTER INSERT OR UPDATE OR DELETE ON football.player_heatmaps
FOR EACH ROW EXECUTE FUNCTION football.log_changes();

CREATE TRIGGER trg_log_player_stats_consolidated
AFTER INSERT OR UPDATE OR DELETE ON football.player_stats_consolidated
FOR EACH ROW EXECUTE FUNCTION football.log_changes();


CREATE TRIGGER trg_set_updated_at_player_events
BEFORE UPDATE ON football.player_events
FOR EACH ROW EXECUTE FUNCTION football.set_updated_at();

CREATE TRIGGER trg_set_updated_at_player_heatmaps
BEFORE UPDATE ON football.player_heatmaps
FOR EACH ROW EXECUTE FUNCTION football.set_updated_at();

CREATE TRIGGER trg_set_updated_at_player_stats_consolidated
BEFORE UPDATE ON football.player_stats_consolidated
FOR EACH ROW EXECUTE FUNCTION football.set_updated_at();


CREATE INDEX IF NOT EXISTS idx_events_player_match
ON football.player_events (player_id, match_id);

CREATE INDEX IF NOT EXISTS idx_events_match_type
ON football.player_events (match_id, event_type);

CREATE INDEX IF NOT EXISTS idx_events_metadata_gin
ON football.player_events USING GIN (metadata);

CREATE INDEX IF NOT EXISTS idx_dist_player_match
ON football.player_distance_history (player_id, match_id);

CREATE INDEX IF NOT EXISTS idx_heat_player_match
ON football.player_heatmaps (player_id, match_id);

CREATE INDEX IF NOT EXISTS idx_consol_match
ON football.player_stats_consolidated (match_id);

CREATE INDEX IF NOT EXISTS idx_consol_player_match
ON football.player_stats_consolidated (player_id, match_id);
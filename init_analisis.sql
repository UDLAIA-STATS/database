-- CREATE DATABASE udlafutbolanalisis;




-- CREATE INDEX idx_events_player_match
-- ON football.player_events (player_id, match_id);

-- CREATE INDEX idx_events_match_type
-- ON football.player_events (match_id, event_type);

-- CREATE INDEX idx_events_metadata_gin
-- ON football.player_events USING GIN (metadata);

-- CREATE INDEX idx_dist_player_match
-- ON football.player_distance_history (player_id, match_id);

-- CREATE INDEX idx_heat_player_match
-- ON football.player_heatmaps (player_id, match_id);

-- CREATE INDEX idx_consol_match
-- ON football.player_stats_consolidated (match_id);

-- CREATE INDEX idx_consol_player_match
-- ON football.player_stats_consolidated (player_id, match_id);
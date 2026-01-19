CREATE DATABASE udlafutbolappestudiantes;

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE SCHEMA IF NOT EXISTS football;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'event_type_enum') THEN
        CREATE TYPE football.event_type_enum AS ENUM (
          'pass',
          'shot_on_target',
          'goal',
          'foul',
          'assist',
          'interception'
        );
    END IF;
END
$$;


CREATE TABLE IF NOT EXISTS football.audit_logs (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    table_name  TEXT NOT NULL,
    operation   TEXT NOT NULL,
    changed_by  TEXT DEFAULT current_user,
    old_data    JSONB,
    new_data    JSONB,
    changed_at  TIMESTAMPTZ DEFAULT now()
);

-- CREATE TABLE IF NOT EXISTS jugador (
--     idjugador SERIAL PRIMARY KEY,
--     idbanner VARCHAR(9) NOT NULL,
--     nombrejugador VARCHAR(250) NOT NULL,
--     apellidojugador VARCHAR(250) NOT NULL,
--     numerocamisetajugador INT NOT NULL,
--     posicionjugador VARCHAR(250) NOT NULL,
--     jugadoractivo BOOLEAN NOT NULL
-- );
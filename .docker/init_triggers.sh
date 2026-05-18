#!/bin/bash
set -e

echo "🔄 Esperando a que studentservice esté completamente inicializado..."

# Esperar a que el health check del studentservice responda
sleep 60

echo "✅ Studentservice está listo!"

# Esperar un poco más para asegurar que las migraciones hayan terminado
echo "⏱️  Esperando 15 segundos adicionales para migraciones..."
sleep 15

export PGPASSWORD=${POSTGRES_PASSWORD}

# Ejecutar el archivo SQL
psql -h postgres \
     -U ${POSTGRES_USER} \
     -f /triggers/trigger_analisis.sql

psql -h postgres \
     -U ${POSTGRES_USER} \
     -f /triggers/create_instituciones.sql

echo "✅ Triggers ejecutados exitosamente!"

touch /tmp/triggers_completed
echo "🏁 Proceso de inicialización de triggers completado"
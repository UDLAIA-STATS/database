# Base de Datos PostgreSQL con Docker Compose

## Descripción del Proyecto

Este proyecto proporciona un entorno PostgreSQL 16 listo para desarrollo usando Docker Compose. La configuración incluye:

- **PostgreSQL 16** con imagen personalizada optimizada para UDLA Stats
- **Puerto personalizado**: El host expone el puerto **5440** que mapea al puerto estándar **5432** del contenedor  
- **Inicialización automática**: Scripts SQL se ejecutan automáticamente la primera vez que se crea el volumen de datos
- **Healthcheck integrado**: Verificación con `pg_isready` para asegurar disponibilidad antes de conectar
- **Datos persistentes**: Volumen Docker para mantener los datos entre reinicios del contenedor

## Prerrequisitos

Antes de comenzar, asegúrate de tener instalado:

- **Docker Desktop** (Windows/macOS) o **Docker Engine** (Linux)
- **Docker Compose v2** (comando `docker compose`) - también funciona `docker-compose` como alias
- **Puerto 5440 libre** en el host
- **1 GB de espacio libre** mínimo para imagen + volumen de datos
- **Acceso de red local** para clientes (pgAdmin, DBeaver, psql)
- *Recomendado en Windows*: WSL 2 habilitado para mejor rendimiento de volúmenes

## Configuración de Variables de Entorno

### Archivo .env

Las variables de entorno se configuran en el archivo `.env` ubicado en la raíz del proyecto (misma carpeta que `docker-compose.yml`).

Copia el archivo `.env.example` para crear tu configuración:

```powershell
Copy-Item .env.example .env
# Luego edita .env con tus valores específicos
```

**Variables disponibles:**

- `POSTGRES_USER`: Usuario administrador de PostgreSQL *(requerida)*
- `POSTGRES_PASSWORD`: Contraseña del usuario administrador *(requerida)*
- `POSTGRES_DB`: Nombre de la base de datos principal *(opcional)*

### Configuración de Seguridad

⚠️ **Importante**: 
- No subas el archivo `.env` con contraseñas reales al repositorio
- Usa contraseñas robustas en entornos de producción
- Considera rotar las contraseñas periódicamente

## Ejecución con Docker Compose

### 1. Preparación Inicial

Asegúrate de que el archivo `.env` esté configurado con las credenciales deseadas.

### 2. Descargar la Imagen desde Docker Hub

```powershell
# Descargar la imagen personalizada de PostgreSQL para UDLA Stats
docker pull dase123/udlaia-stats:udla_postgres
```

**Verificar que la imagen se descargó correctamente:**
```powershell
docker images | findstr udlaia-stats
```

### 3. Iniciar el Contenedor

```powershell
# Levantar el contenedor en segundo plano
docker compose up -d
```

### 4. Verificar Estado

```powershell
# Ver estado de los servicios
docker compose ps

# Ver logs en tiempo real
docker compose logs -f postgres
```

**Espera hasta que el estado sea `healthy` antes de intentar conectarse.**

### 5. Probar Conexión

```powershell
# Conectar con psql desde PowerShell
docker compose exec postgres psql -U $Env:POSTGRES_USER -d postgres
```

### 6. Gestión del Contenedor

```powershell
# Detener sin borrar datos
docker compose stop

# Reiniciar servicios
docker compose restart

# Apagar y borrar contenedor (mantiene volúmenes)
docker compose down

# Reset completo (elimina datos y volúmenes)
docker compose down -v
```

## Comandos Útiles de Docker Compose

### Comandos Básicos

```powershell
# Iniciar servicios en segundo plano
docker compose up -d

# Ver estado actual
docker compose ps

# Ver logs
docker compose logs -f postgres

# Ejecutar comandos dentro del contenedor
docker compose exec postgres bash
docker compose exec postgres psql -U $Env:POSTGRES_USER -d postgres
```

### Mantenimiento y Actualización

```powershell
# Actualizar imagen desde Docker Hub
docker pull dase123/udlaia-stats:udla_postgres

# Reconstruir imagen personalizada (si modificas Dockerfile)
docker compose build --no-cache postgres

# Recrear contenedor con imagen actualizada
docker compose up -d --force-recreate

# Validar configuración
docker compose config

# Listar volúmenes de Docker
docker volume ls
```

## Información de Conexión

### Parámetros de Conexión

- **Host**: `localhost`
- **Puerto**: `5440`
- **Usuario**: Valor de `POSTGRES_USER` (por defecto: `postgres`)
- **Contraseña**: Valor de `POSTGRES_PASSWORD` (configurado en .env)
- **Base de datos**: `postgres` (o valor personalizado si se define `POSTGRES_DB`)

### Cadena de Conexión

```
postgresql://postgres:TuPassword@localhost:5440/postgres
```

### Conexión con psql

```powershell
# Desde PowerShell (Windows)
psql "host=localhost port=5440 dbname=postgres user=postgres password=TuPassword sslmode=disable"

# Usando variables de entorno con Docker Compose
docker compose exec postgres psql -U $Env:POSTGRES_USER -d postgres
```

### Clientes GUI

Puedes usar cualquier cliente PostgreSQL con estos parámetros:
- **pgAdmin**
- **DBeaver** 
- **Beekeeper Studio**
- **TablePlus**

⚠️ **Importante**: Asegúrate de que el contenedor esté en estado `healthy` antes de intentar conectar.

## Solución de Problemas

### Puerto 5440 en Uso

**Síntoma**: Error al iniciar o conexión rechazada
```
Error starting userland proxy: listen tcp4 0.0.0.0:5440: bind: address already in use
```

**Solución**:
1. Identifica el proceso que usa el puerto:
   ```powershell
   netstat -ano | findstr :5440
   ```
2. Termina el proceso o cambia el puerto en `docker-compose.yml`:
   ```yaml
   ports:
     - "5441:5432"  # Cambia 5440 por otro puerto libre
   ```

### Healthcheck Falla (Estado Unhealthy)

**Síntoma**: El contenedor no pasa el healthcheck

**Soluciones**:
1. Revisar logs:
   ```powershell
   docker compose logs -f postgres
   ```
2. Verificar credenciales en `.env`
3. Si cambiaste la contraseña con datos existentes:
   ```powershell
   docker compose down -v
   docker compose up -d
   ```

### Scripts de Inicialización No Se Ejecutan

**Causa**: Los scripts SQL solo se ejecutan la primera vez que se crea el volumen de datos.

**Solución**: Forzar re-ejecución eliminando el volumen:
```powershell
docker compose down -v
docker compose up -d
```

### Imagen Corrupta u Obsoleta

**Síntoma**: Errores durante la inicialización o comportamiento inesperado

**Solución**:
```powershell
# Actualizar imagen desde Docker Hub
docker pull dase123/udlaia-stats:udla_postgres

# Reconstruir imagen local si modificaste el Dockerfile
docker compose build --no-cache postgres

# Recrear contenedor
docker compose up -d --force-recreate
```

## Estructura del Proyecto

```
usersDb/
├── docker-compose.yml          # Configuración de servicios Docker Compose
├── Dockerfile.postgres         # Imagen personalizada de PostgreSQL
├── .env                        # Variables de entorno (no commitear con secretos)
├── .env.example               # Plantilla de variables
├── .dockerignore              # Archivos ignorados por Docker
├── .gitignore                 # Archivos ignorados por Git
├── init_usuarios.sql          # Script de inicialización - Usuarios
├── init_jugadores.sql         # Script de inicialización - Jugadores  
├── init_torneos.sql           # Script de inicialización - Torneos
├── LICENSE                    # Licencia del proyecto
└── README.md                  # Guía de uso (este documento)
```

## Inicialización de Datos

El proyecto incluye tres scripts SQL que se ejecutan automáticamente al crear el contenedor por primera vez:

1. **01_init_usuarios.sql**: Configuración de usuarios y permisos
2. **02_init_jugadores.sql**: Esquema y datos de jugadores
3. **03_init_torneos.sql**: Esquema y datos de torneos

Estos scripts solo se ejecutan **una vez** cuando se crea el volumen de datos. Para volver a ejecutarlos:

```powershell
docker compose down -v  # Elimina volúmenes
docker compose up -d    # Recrea y ejecuta scripts
```

## Comandos de Backup y Restauración

### Crear Backup

```powershell
# Backup completo de todas las bases de datos
docker compose exec postgres pg_dumpall -U postgres > backup_completo.sql

# Backup de una base específica
docker compose exec postgres pg_dump -U postgres -d postgres > backup_postgres.sql
```

### Restaurar Backup

```powershell
# Restaurar backup completo
Get-Content backup_completo.sql | docker compose exec -T postgres psql -U postgres

# Restaurar base específica
Get-Content backup_postgres.sql | docker compose exec -T postgres psql -U postgres -d postgres
```

## Contacto y Soporte

**Maintainer**: David Guaman <david.guaman@udla.edu.ec>  
**Descripción**: Imagen optimizada de PostgreSQL 16 para UDLA Stats  
**Versión**: 1.0

---

*Generado para el proyecto usersDb - Universidad de las Américas (UDLA)*
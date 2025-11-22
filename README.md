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

**Estructura del archivo .env:**

```env
# Variables requeridas
POSTGRES_USER=postgres
POSTGRES_PASSWORD=0000
```

**Variables disponibles:**

- `POSTGRES_USER`: Usuario administrador de PostgreSQL *(requerida)*
- `POSTGRES_PASSWORD`: Contraseña del usuario administrador *(requerida)*
- `POSTGRES_DB`: Nombre de la base de datos principal *(opcional - si no se define, se crea una BD con el mismo nombre que POSTGRES_USER)*

### Configuración de Seguridad

⚠️ **Importante**: 
- No subas el archivo `.env` con contraseñas reales al repositorio
- Usa contraseñas robustas en entornos de producción
- Considera rotar las contraseñas periódicamente

## Ejecución Paso a Paso

### 1. Preparación Inicial

Asegúrate de que el archivo `.env` esté configurado con las credenciales deseadas.

### 2. Descargar la Imagen desde Docker Hub

Antes de ejecutar el contenedor, descarga la imagen personalizada desde Docker Hub:

```powershell
# Descargar la imagen personalizada de PostgreSQL para UDLA Stats
docker pull dase123/udlaia-stats:udla_postgres
```

**Verificar que la imagen se descargó correctamente:**
```powershell
docker images | findstr udlaia-stats
```

## Opciones de Ejecución

Tienes dos formas principales de ejecutar el contenedor PostgreSQL:

### Opción A: Usando Docker Compose (Recomendado)

### 3A. Iniciar con Docker Compose

```powershell
# Levantar el contenedor en segundo plano
docker compose up -d
```

### 4A. Verificar Estado (Docker Compose)

```powershell
# Ver estado de los servicios
docker compose ps

# Ver logs en tiempo real
docker compose logs -f postgres
```

**Espera hasta que el estado sea `healthy` antes de intentar conectarse.**

### 5A. Probar Conexión (Docker Compose)

```powershell
# Conectar con psql desde PowerShell
docker compose exec postgres psql -U $Env:POSTGRES_USER -d postgres
```

### Opción B: Usando Docker Run Directo

### 3B. Ejecutar con Docker Run

```powershell
# Opción 1: Ejecutar con variables de entorno directamente
docker run -d --name udla_postgres -p 5440:5432 -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=0000 dase123/udlaia-stats:udla_postgres
```

```powershell
# Opción 2: Ejecutar usando archivo .env (PowerShell)
# Primero cargar variables del archivo .env
Get-Content .env | ForEach-Object {
    if ($_ -match '^([^=]+)=(.*)$') {
        [Environment]::SetEnvironmentVariable($matches[1], $matches[2], "Process")
    }
}

# Luego ejecutar el contenedor con variables
```
docker run -d --name udla_postgres -p 5440:5432 -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=0000 dase123/udlaia-stats:udla_postgres
```

```powershell
# Opción 3: Una sola línea con valores del .env (alternativa)
docker run -d --name udla_postgres --restart always -p 5440:5432 -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=0000 -e POSTGRES_INITDB_ARGS="--encoding=UTF8 --locale=C" -v postgres_data:/var/lib/postgresql/data -v "${PWD}/init_usuarios.sql:/docker-entrypoint-initdb.d/01_init_usuarios.sql" -v "${PWD}/init_jugadores.sql:/docker-entrypoint-initdb.d/02_init_jugadores.sql" -v "${PWD}/init_torneos.sql:/docker-entrypoint-initdb.d/03_init_torneos.sql" dase123/udlaia-stats:udla_postgres
```

**Argumentos requeridos para `docker run`:**

| Argumento | Descripción | Valor/Ejemplo |
|-----------|-------------|---------------|
| `-d` | Ejecutar en segundo plano (detached) | - |
| `--name udla_postgres` | Nombre del contenedor | udla_postgres |
| `--restart always` | Política de reinicio automático | always |
| `-p 5440:5432` | Mapeo de puertos (host:contenedor) | 5440:5432 |
| `-e POSTGRES_USER` | Usuario administrador de PostgreSQL | postgres (o valor del .env) |
| `-e POSTGRES_PASSWORD` | Contraseña del usuario | 0000 (o valor del .env) |
| `-e POSTGRES_INITDB_ARGS` | Argumentos de inicialización de DB | "--encoding=UTF8 --locale=C" |
| `-v postgres_data:/var/lib/postgresql/data` | Volumen para datos persistentes | postgres_data |
| `-v "script.sql:/docker-entrypoint-initdb.d/"` | Scripts de inicialización | Ruta a tus scripts SQL |
| `dase123/udlaia-stats:udla_postgres` | Imagen de Docker Hub | dase123/udlaia-stats:udla_postgres |

**Variables de entorno requeridas:**
- `POSTGRES_USER`: Usuario administrador (requerida)
- `POSTGRES_PASSWORD`: Contraseña del usuario (requerida)
- `POSTGRES_INITDB_ARGS`: Configuración de inicialización (opcional)

### 4B. Verificar Estado (Docker Run)

```powershell
# Ver estado del contenedor
docker ps

# Ver logs en tiempo real
docker logs -f udla_postgres

# Verificar healthcheck (si está configurado)
docker inspect udla_postgres | findstr Health
```

### 5B. Probar Conexión (Docker Run)

```powershell
# Conectar con psql
docker exec -it udla_postgres psql -U postgres -d postgres
```

### 6A. Gestión del Contenedor (Docker Compose)

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

### 6B. Gestión del Contenedor (Docker Run)

```powershell
# Detener contenedor
docker stop udla_postgres

# Iniciar contenedor detenido
docker start udla_postgres

# Reiniciar contenedor
docker restart udla_postgres

# Eliminar contenedor (mantiene volumen)
docker rm udla_postgres

# Eliminar contenedor y volumen (reset completo)
docker rm udla_postgres
docker volume rm postgres_data
```

## Comandos Disponibles de Docker Compose

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

### Gestión de Servicios

```powershell
# Detener servicios
docker compose stop

# Iniciar servicios detenidos
docker compose start

# Reiniciar servicios
docker compose restart

# Apagar y limpiar (conserva volúmenes)
docker compose down

# Apagar y eliminar volúmenes (reset completo)
docker compose down -v
```

### Mantenimiento y Actualización

```powershell
# Actualizar imagen desde Docker Hub
docker pull dase123/udlaia-stats:udla_postgres

# Reconstruir imagen personalizada (si modificas Dockerfile)
docker compose build --no-cache postgres

# Recrear contenedor con Docker Compose
docker compose up -d --force-recreate

# Recrear contenedor con Docker Run
docker stop udla_postgres && docker rm udla_postgres
docker run -d --name udla_postgres [... argumentos completos ...]

# Validar configuración (solo Docker Compose)
docker compose config

# Listar volúmenes de Docker
docker volume ls

# Ver información detallada de la imagen
docker inspect dase123/udlaia-stats:udla_postgres
```

## Información de Conexión

### Parámetros de Conexión

- **Host**: `localhost`
- **Puerto**: `5440`
- **Usuario**: Valor de `POSTGRES_USER` (por defecto: `postgres`)
- **Contraseña**: Valor de `POSTGRES_PASSWORD` (por defecto: `0000`)
- **Base de datos**: `postgres` (o valor personalizado si se define `POSTGRES_DB`)

### Cadena de Conexión

```
postgresql://postgres:0000@localhost:5440/postgres
```

### Conexión con psql

```powershell
# Desde PowerShell (Windows)
psql "host=localhost port=5440 dbname=postgres user=postgres password=0000 sslmode=disable"

# Usando variables de entorno
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

### Problemas de Rendimiento en Windows

**Recomendación**: 
- Usa WSL 2 para mejor rendimiento
- Coloca el repositorio en el sistema de archivos de WSL
- Evita rutas con caracteres especiales o muy largas

### Autenticación Fallida

**Verificar**:
1. Valores correctos en `.env`
2. Si cambias `POSTGRES_USER` después de la inicialización, puede ser necesario recrear los datos:
   ```powershell
   docker compose down -v
   docker compose up -d
   ```

### Imagen Corrupta u Obsoleta

**Síntoma**: Errores durante la inicialización o comportamiento inesperado

**Solución con Docker Compose**:
```powershell
# Actualizar imagen desde Docker Hub
docker pull dase123/udlaia-stats:udla_postgres

# O reconstruir imagen local si modificaste el Dockerfile
docker compose build --no-cache postgres

# Recrear contenedor
docker compose up -d --force-recreate
```

**Solución con Docker Run**:
```powershell
# Actualizar imagen desde Docker Hub
docker pull dase123/udlaia-stats:udla_postgres

# Detener y eliminar contenedor actual
docker stop udla_postgres
docker rm udla_postgres

# Crear nuevo contenedor con imagen actualizada
docker run -d --name udla_postgres --restart always -p 5440:5432 -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=0000 -e POSTGRES_INITDB_ARGS="--encoding=UTF8 --locale=C" -v postgres_data:/var/lib/postgresql/data -v "${PWD}/init_usuarios.sql:/docker-entrypoint-initdb.d/01_init_usuarios.sql" -v "${PWD}/init_jugadores.sql:/docker-entrypoint-initdb.d/02_init_jugadores.sql" -v "${PWD}/init_torneos.sql:/docker-entrypoint-initdb.d/03_init_torneos.sql" dase123/udlaia-stats:udla_postgres
```

## Estructura del Proyecto

```
usersDb/
├── docker-compose.yml          # Configuración de servicios Docker Compose
├── Dockerfile.postgres         # Imagen personalizada de PostgreSQL
├── .env                        # Variables de entorno (no commitear con secretos)
├── .dockerignore              # Archivos ignorados por Docker
├── .gitignore                 # Archivos ignorados por Git
├── init_usuarios.sql          # Script de inicialización - Usuarios
├── init_jugadores.sql         # Script de inicialización - Jugadores  
├── init_torneos.sql           # Script de inicialización - Torneos
├── LICENSE                    # Licencia del proyecto
└── README.md                  # Guía de uso (este documento)
```

### Notas sobre la Estructura

- **Volumen de datos**: Se crea como volumen Docker (`postgres_data`) y no aparece como carpeta local
- **Scripts de inicialización**: Se ejecutan en orden numérico/alfabético la primera vez que se inicializa el contenedor
- **Archivo .env**: Contiene credenciales - **nunca** lo subas a repositorios públicos

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

## Notas de Seguridad y Buenas Prácticas

### Seguridad

- ✅ **No subir** archivos `.env` con contraseñas reales al repositorio
- ✅ **Usar contraseñas robustas** y rotarlas periódicamente
- ✅ **Restringir acceso** al puerto 5440 a redes confiables
- ✅ Para producción, considerar **Docker secrets** en lugar de variables de entorno

### Buenas Prácticas

- ✅ **Hacer backup regular** de los datos usando `pg_dump`
- ✅ **Monitorear logs** regularmente con `docker compose logs`
- ✅ **Actualizar imagen** periódicamente para parches de seguridad
- ✅ **Usar volúmenes nombrados** para datos persistentes (ya implementado)

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
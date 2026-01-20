# UDLA Stats - Plataforma Multi-Servicio con Docker Compose

## Descripción del Proyecto

Este proyecto proporciona un entorno completo de desarrollo para UDLA Stats usando Docker Compose con múltiples servicios:

### Servicios Incluidos

- **PostgreSQL 16**: Base de datos con imagen personalizada optimizada para UDLA Stats
  - Puerto personalizado: **5440** (mapea al puerto **5432** del contenedor)
  - Inicialización automática con scripts SQL
  - Healthcheck integrado
  - Datos persistentes mediante volúmenes Docker

- **AuthService**: Servicio de autenticación y autorización basado en Django
  - Puerto: **8010**
  - Integración con PostgreSQL
  - Gestión de usuarios y permisos
  - Creación automática de superusuario

### Características

- **Red privada compartida**: Los servicios se comunican a través de una red Docker (`app-net`)
- **Dependencias gestionadas**: AuthService espera a que PostgreSQL esté saludable antes de iniciar
- **Configuración centralizada**: Variables de entorno en archivo `.env`

## Prerrequisitos

Antes de comenzar, asegúrate de tener instalado:

- **Git**: Para clonar el repositorio
- **Docker Desktop** (Windows/macOS) o **Docker Engine** (Linux)
- **Docker Compose v2** (comando `docker compose`) - también funciona `docker-compose` como alias
- **Puertos libres**:
  - **5440**: PostgreSQL
  - **8010**: AuthService
- **3 GB de espacio libre** mínimo para imágenes y volúmenes
- **Acceso de red local** para clientes (pgAdmin, DBeaver, psql)
- *Recomendado en Windows*: WSL 2 habilitado para mejor rendimiento de volúmenes

## Instalación y Configuración

### 1. Clonar el Repositorio

```powershell
# Clonar el repositorio
git clone <URL_DEL_REPOSITORIO>
cd usersDb
```

### 2. Configurar Variables de Entorno

Crea el archivo `.env` a partir de la plantilla:

```powershell
Copy-Item .env.example .env
```

Edita el archivo `.env` y configura las siguientes variables:

#### Variables de PostgreSQL (Requeridas)

- `POSTGRES_USER`: Usuario administrador de PostgreSQL (ej: `postgres`)
- `POSTGRES_PASSWORD`: Contraseña del usuario administrador
- `POSTGRES_DB`: Nombre de la base de datos principal (ej: `udla_stats`)

#### Variables de AuthService (Requeridas)

- `DJANGO_SUPERUSER_USERNAME`: Usuario administrador de Django (ej: `admin`)
- `DJANGO_SUPERUSER_PASSWORD`: Contraseña del superusuario
- `DJANGO_SUPERUSER_EMAIL`: Email del superusuario (ej: `admin@udla.edu.ec`)
- `ALLOWED_HOSTS`: Hosts permitidos separados por comas (ej: `localhost,127.0.0.1`)
- `FRONTEND_URL`: URL del frontend (ej: `http://localhost:4321`)
- `API_PORT`: Puerto de la API (por defecto: `8010`)

#### Variables Opcionales

- `DEBUG`: Modo de depuración (`true`/`false`)

**Ejemplo de configuración mínima en `.env`:**

```env
# PostgreSQL
POSTGRES_USER=postgres
POSTGRES_PASSWORD=TuPasswordSeguro123!
POSTGRES_DB=udla_stats

# Django AuthService
DJANGO_SUPERUSER_USERNAME=admin
DJANGO_SUPERUSER_PASSWORD=AdminPass123!
DJANGO_SUPERUSER_EMAIL=admin@udla.edu.ec

# Configuración general
ALLOWED_HOSTS=localhost,127.0.0.1
FRONTEND_URL=http://localhost:4321
API_PORT=8010
DEBUG=true
```

### 3. Seguridad de las Variables

⚠️ **Importante**: 
- **NUNCA** subas el archivo `.env` con contraseñas reales al repositorio
- Usa contraseñas robustas (mínimo 12 caracteres con mayúsculas, minúsculas, números y símbolos)
- Cambia las contraseñas de ejemplo por valores seguros
- Considera rotar las contraseñas periódicamente

## Uso de Docker Compose

### 1. Descargar las Imágenes

```powershell
# Descargar las imágenes desde Docker Hub (opcional, docker compose lo hace automáticamente)
docker pull dase123/udlaia-stats:udla_postgres
docker pull dase123/udlaia-stats:authservice
```

**Verificar imágenes descargadas:**
```powershell
docker images | findstr udlaia-stats
```

### 2. Iniciar Todos los Servicios

```powershell
# Levantar todos los servicios en segundo plano
docker compose up -d
```

Esto iniciará:
1. **PostgreSQL** primero (puerto 5440)
2. **AuthService** después de que PostgreSQL esté saludable (puerto 8010)

### 3. Verificar Estado de los Servicios

```powershell
# Ver estado de todos los servicios
docker compose ps

# Ver logs de todos los servicios
docker compose logs -f

# Ver logs de un servicio específico
docker compose logs -f postgres
docker compose logs -f authservice
```

**Espera hasta que PostgreSQL esté en estado `healthy` y AuthService en `running`.**

### 4. Verificar Conectividad

#### PostgreSQL

```powershell
# Conectar a PostgreSQL con psql
docker compose exec postgres psql -U postgres -d udla_stats
```

#### AuthService

```powershell
# Verificar que AuthService está respondiendo
curl http://localhost:8010/api/

# O abrir en el navegador:
# http://localhost:8010/admin (panel de administración de Django)
```

### 5. Gestión de los Servicios

```powershell
# Detener todos los servicios sin borrar datos
docker compose stop

# Iniciar servicios detenidos
docker compose start

# Reiniciar todos los servicios
docker compose restart

# Reiniciar un servicio específico
docker compose restart authservice

# Apagar y eliminar contenedores (mantiene volúmenes/datos)
docker compose down

# Reset completo (elimina datos y volúmenes)
docker compose down -v
```

### 6. Gestión Individual de Servicios

```powershell
# Iniciar solo PostgreSQL
docker compose up -d postgres

# Iniciar AuthService (inicia PostgreSQL automáticamente si no está corriendo)
docker compose up -d authservice

# Detener solo AuthService
docker compose stop authservice

# Ver logs específicos con timestamps
docker compose logs -f -t authservice
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
# Actualizar todas las imágenes desde Docker Hub
docker pull dase123/udlaia-stats:udla_postgres
docker pull dase123/udlaia-stats:authservice

# Reconstruir imagen personalizada de PostgreSQL (si modificas Dockerfile)
docker compose build --no-cache postgres

# Recrear todos los contenedores con imágenes actualizadas
docker compose up -d --force-recreate

# Recrear solo un servicio específico
docker compose up -d --force-recreate authservice

# Validar configuración de docker-compose.yml
docker compose config

# Listar volúmenes de Docker
docker volume ls

# Inspeccionar la red compartida
docker network inspect udlaia-stats_app-net
```

## Información de Conexión

### PostgreSQL

#### Desde el Host (tu máquina)

- **Host**: `localhost`
- **Puerto**: `5440`
- **Usuario**: Valor de `POSTGRES_USER` (ej: `postgres`)
- **Contraseña**: Valor de `POSTGRES_PASSWORD`
- **Base de datos**: Valor de `POSTGRES_DB` (ej: `udla_stats`)

#### Desde otros contenedores Docker (mismo docker-compose)

- **Host**: `postgres` (nombre del servicio)
- **Puerto**: `5432` (puerto interno del contenedor)
- **Usuario**: Valor de `POSTGRES_USER`
- **Contraseña**: Valor de `POSTGRES_PASSWORD`
- **Base de datos**: Valor de `POSTGRES_DB`

### AuthService

#### API REST

- **URL Base**: `http://localhost:8010`
- **Admin Panel**: `http://localhost:8010/admin`
- **Usuario Admin**: Valor de `DJANGO_SUPERUSER_USERNAME`
- **Contraseña Admin**: Valor de `DJANGO_SUPERUSER_PASSWORD`

### Cadenas de Conexión

#### PostgreSQL desde el host

```
postgresql://postgres:TuPassword@localhost:5440/udla_stats
```

#### PostgreSQL desde contenedores Docker

```
postgresql://postgres:TuPassword@postgres:5432/udla_stats
```

### Conexión con psql

```powershell
# Desde PowerShell (Windows) - conexión al host
psql "host=localhost port=5440 dbname=udla_stats user=postgres password=TuPassword sslmode=disable"

# Usando Docker Compose
docker compose exec postgres psql -U postgres -d udla_stats
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
# Actualizar imágenes desde Docker Hub
docker pull dase123/udlaia-stats:udla_postgres
docker pull dase123/udlaia-stats:authservice

# Reconstruir imagen local si modificaste el Dockerfile
docker compose build --no-cache postgres

# Recrear contenedores
docker compose up -d --force-recreate
```

### AuthService No Puede Conectarse a PostgreSQL

**Síntoma**: AuthService muestra errores de conexión a la base de datos

**Soluciones**:
1. Verificar que PostgreSQL esté en estado `healthy`:
   ```powershell
   docker compose ps
   ```
2. Revisar logs de AuthService:
   ```powershell
   docker compose logs authservice
   ```
3. Verificar variables de entorno en `.env`:
   - `POSTGRES_USER`
   - `POSTGRES_PASSWORD`
   - `POSTGRES_DB`
4. Reiniciar AuthService:
   ```powershell
   docker compose restart authservice
   ```

### Puerto 8010 en Uso

**Síntoma**: Error al iniciar AuthService
```
Error starting userland proxy: listen tcp4 0.0.0.0:8010: bind: address already in use
```

**Solución**:
1. Identifica el proceso que usa el puerto:
   ```powershell
   netstat -ano | findstr :8010
   ```
2. Termina el proceso o cambia el puerto en `docker-compose.yml`:
   ```yaml
   services:
     authservice:
       ports:
         - "8011:8010"  # Cambia 8010 por otro puerto libre
   ```
3. Actualiza `API_PORT` en `.env` si es necesario

### Error al Crear Superusuario de Django

**Síntoma**: AuthService no puede crear el superusuario automáticamente

**Soluciones**:
1. Verificar variables en `.env`:
   - `DJANGO_SUPERUSER_USERNAME`
   - `DJANGO_SUPERUSER_PASSWORD`
   - `DJANGO_SUPERUSER_EMAIL`
2. Crear superusuario manualmente:
   ```powershell
   docker compose exec authservice python manage.py createsuperuser
   ```

### Los Servicios No Se Comunican Entre Sí

**Síntoma**: Los contenedores no pueden comunicarse a través de la red Docker

**Soluciones**:
1. Verificar que ambos servicios estén en la misma red:
   ```powershell
   docker network inspect udlaia-stats_app-net
   ```
2. Reiniciar la red completa:
   ```powershell
   docker compose down
   docker compose up -d
   ```
3. Verificar que los nombres de host sean correctos:
   - PostgreSQL: `postgres` (nombre del servicio)
   - AuthService: `authservice` (nombre del servicio)

## Arquitectura de Servicios

```mermaid
graph LR
    A[Cliente/Browser] -->|Puerto 8010| B[AuthService]
    A -->|Puerto 5440| C[PostgreSQL]
    B -->|Red interna| C
    C -->|Volumen persistente| D[postgres_data]
```

### Red Docker

Todos los servicios están conectados a una red bridge llamada `app-net` que permite:
- Comunicación interna entre servicios usando nombres de servicio
- Aislamiento de otros contenedores Docker
- Resolución DNS automática

## Estructura del Proyecto

```
usersDb/
├── docker-compose.yml          # Configuración multi-servicio
├── Dockerfile.postgres         # Imagen personalizada de PostgreSQL
├── .env                        # Variables de entorno (NO subir al repo)
├── .env.example               # Plantilla con todas las variables requeridas
├── .dockerignore              # Archivos ignorados por Docker
├── .gitignore                 # Archivos ignorados por Git
├── init_usuarios.sql          # Script SQL - Inicialización de usuarios
├── init_jugadores.sql         # Script SQL - Inicialización de jugadores  
├── init_torneos.sql           # Script SQL - Inicialización de torneos
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
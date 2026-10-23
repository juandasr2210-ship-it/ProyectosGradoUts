<<<<<<< HEAD
# ProyectosGradoUts
=======
# SIGRADO - Sistema de Gestión de Trabajos de Grado

Sistema web para la gestión completa del ciclo de vida de trabajos de grado (Ingeniería de Sistemas - UTS).

## Características
- **Roles**: Administrador, Comité, Docente (Director/Evaluador/Codirector), Estudiante.
- **Flujo de 6 fases**: Idea+Pago → Propuesta I → Propuesta II → Informe I → Informe II → Cierre/Sustentación.
- **Trazabilidad completa**: Historial de versiones, actas, decisiones, correcciones.
- **Entregas por URL**: No subida de archivos, solo enlaces HTTPS con versionado.
- **Calendario académico**: Ventanas de banco de ideas, nuevos proyectos, aprobación.
- **Multi-rol**: Un usuario puede tener varios roles y cambiar sin cerrar sesión.

## Stack
- **Backend**: JSP / Servlet (Jakarta EE / Java EE 8)
- **Servidor**: Apache Tomcat 9
- **Base de datos**: MySQL / MariaDB
- **Frontend**: CSS vanilla + SVG icons, JSP includes

## Despliegue Local (XAMPP)
1. Iniciar MySQL y Tomcat en XAMPP.
2. Importar `sql/sigrado_master.sql` en MySQL.
3. Copiar carpeta `ProyectosGradoUts` a `xampp/tomcat/webapps/`.
4. Acceder a `http://localhost:8080/ProyectosGradoUts/`.

## Despliegue en Railway (Producción)

### 1. Base de datos
- En Railway: **New → Database → MySQL**.
- Railway crea variables: `MYSQLHOST`, `MYSQLPORT`, `MYSQLDATABASE`, `MYSQLUSER`, `MYSQLPASSWORD`.

### 2. Servicio Web
- **New → GitHub Repo** → Seleccionar este repo.
- Railway detecta el `Dockerfile` y construye la imagen.
- En **Variables**, asegúrate que estén las de MySQL (se inyectan automáticamente al linkear el servicio DB).

### 3. Dominio
- Settings → Domains → Generate Domain.

## Credenciales de prueba (seed)
| Rol | Email | Pass |
|-----|-------|------|
| Admin | admin@correo.uts.edu.co | admin123 |
| Comité | comite@correo.uts.edu.co | comite123 |
| Director | director@correo.uts.edu.co | doc123 |
| Evaluador | evaluador@correo.uts.edu.co | doc123 |
| Estudiante | estudiante@correo.uts.edu.co | est123 |

## Estructura
```
├── src/main/webapp (raíz del war)
│   ├── administrador/
│   ├── comite/
│   ├── comun/
│   ├── docente/
│   ├── estudiante/
│   ├── css/, js/, img/
│   ├── WEB-INF/
│   │   ├── web.xml
│   │   ├── jspf/ (includes: conexion, guard, header, footer, iconos)
│   │   └── lib/
│   └── sql/sigrado_master.sql
├── Dockerfile
└── .gitignore
```

## Variables de entorno (Producción)
| Variable | Descripción |
|----------|-------------|
| `MYSQLHOST` | Host de MySQL (Railway la provee) |
| `MYSQLPORT` | Puerto (usualmente 3306) |
| `MYSQLDATABASE` | Nombre de la BD |
| `MYSQLUSER` | Usuario |
| `MYSQLPASSWORD` | Contraseña |

## Licencia
Uso académico - UTS 2026
>>>>>>> 596bf79 (feat: sistema completo Trabajos de Grado UTS - JSP/MySQL/Tomcat 9)

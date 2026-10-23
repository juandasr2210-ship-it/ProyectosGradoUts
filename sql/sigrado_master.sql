-- =============================================================
-- SIGRADO - Sistema de Gestion de Trabajos de Grado
-- Script maestro (segun seccion 5 del documento de requisitos)
-- BD: sigrado | Motor: InnoDB | Charset: utf8mb4
-- =============================================================
DROP DATABASE IF EXISTS sigrado;
CREATE DATABASE sigrado CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE sigrado;

-- ---------- roles ----------
CREATE TABLE roles (
  id TINYINT AUTO_INCREMENT PRIMARY KEY,
  nombre ENUM('administrador','comite','docente','estudiante') NOT NULL UNIQUE
) ENGINE=InnoDB;

INSERT INTO roles (nombre) VALUES ('administrador'),('comite'),('docente'),('estudiante');

-- ---------- usuarios ----------
CREATE TABLE usuarios (
  id INT AUTO_INCREMENT PRIMARY KEY,
  documento VARCHAR(20) NOT NULL UNIQUE,
  nombres VARCHAR(80) NOT NULL,
  apellidos VARCHAR(80) NOT NULL,
  email VARCHAR(120) NOT NULL UNIQUE,
  password_hash CHAR(64) NOT NULL,
  telefono VARCHAR(20) NULL,
  programa VARCHAR(80) NOT NULL DEFAULT 'Ingenieria de Sistemas',
  activo TINYINT(1) NOT NULL DEFAULT 1,
  fecha_registro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ---------- usuario_rol ----------
CREATE TABLE usuario_rol (
  usuario_id INT NOT NULL,
  rol_id TINYINT NOT NULL,
  PRIMARY KEY (usuario_id, rol_id),
  FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
  FOREIGN KEY (rol_id) REFERENCES roles(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ---------- periodos ----------
CREATE TABLE periodos (
  id INT AUTO_INCREMENT PRIMARY KEY,
  codigo VARCHAR(10) NOT NULL UNIQUE,
  inicio_propuestas_banco DATE NOT NULL,
  fin_propuestas_banco DATE NOT NULL,
  inicio_nuevos_proyectos DATE NOT NULL,
  fin_nuevos_proyectos DATE NOT NULL,
  fin_aprobacion_propuesta DATE NOT NULL,
  activo TINYINT(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB;

-- ---------- propuestas_banco ----------
CREATE TABLE propuestas_banco (
  id INT AUTO_INCREMENT PRIMARY KEY,
  codigo VARCHAR(15) NOT NULL UNIQUE,
  proponente_id INT NOT NULL,
  origen ENUM('Docente','Estudiante') NOT NULL DEFAULT 'Docente',
  titulo VARCHAR(255) NOT NULL,
  tipo_modalidad ENUM('Desarrollo tecnologico','Emprendimiento','Investigacion','Otro') NOT NULL DEFAULT 'Investigacion',
  objetivo_general TEXT NOT NULL,
  descripcion TEXT NULL,
  linea_investigacion VARCHAR(120) NOT NULL DEFAULT 'Ingenieria de software',
  tipo_nivel ENUM('Tecnologico','Profesional') NOT NULL DEFAULT 'Tecnologico',
  periodo_id INT NOT NULL,
  estado ENUM('Pendiente','Aprobada','Correcciones','Rechazada') NOT NULL DEFAULT 'Pendiente',
  disponible TINYINT(1) NOT NULL DEFAULT 1,
  fecha_propuesta TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  fecha_revision TIMESTAMP NULL,
  revisor_id INT NULL,
  observacion_comite TEXT NULL,
  FOREIGN KEY (proponente_id) REFERENCES usuarios(id),
  FOREIGN KEY (periodo_id) REFERENCES periodos(id),
  FOREIGN KEY (revisor_id) REFERENCES usuarios(id)
) ENGINE=InnoDB;

-- ---------- proyectos ----------
CREATE TABLE proyectos (
  id INT AUTO_INCREMENT PRIMARY KEY,
  codigo VARCHAR(15) NOT NULL UNIQUE,
  banco_id INT NULL,
  titulo VARCHAR(255) NOT NULL,
  objetivo_general TEXT NOT NULL,
  descripcion TEXT NULL,
  tipo_idea ENUM('Propia','Banco') NOT NULL DEFAULT 'Banco',
  tipo_modalidad ENUM('Desarrollo tecnologico','Emprendimiento','Investigacion','Otro') NOT NULL DEFAULT 'Investigacion',
  tipo_nivel ENUM('Tecnologico','Profesional') NOT NULL,
  linea_investigacion VARCHAR(120) NULL,
  periodo_id INT NOT NULL,
  codigo_modalidad VARCHAR(20) NULL UNIQUE,
  fase TINYINT NOT NULL DEFAULT 1,
  responsable ENUM('comite','estudiante','director','evaluador') NOT NULL DEFAULT 'comite',
  estado ENUM('En curso','Rechazado','Cancelado','Finalizado') NOT NULL DEFAULT 'En curso',
  director_id INT NULL,
  evaluador_id INT NULL,
  codirector_id INT NULL,
  fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  fecha_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (banco_id) REFERENCES propuestas_banco(id),
  FOREIGN KEY (periodo_id) REFERENCES periodos(id),
  FOREIGN KEY (director_id) REFERENCES usuarios(id),
  FOREIGN KEY (evaluador_id) REFERENCES usuarios(id),
  FOREIGN KEY (codirector_id) REFERENCES usuarios(id)
) ENGINE=InnoDB;

-- ---------- proyecto_integrantes ----------
CREATE TABLE proyecto_integrantes (
  proyecto_id INT NOT NULL,
  usuario_id INT NOT NULL,
  es_responsable TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (proyecto_id, usuario_id),
  FOREIGN KEY (proyecto_id) REFERENCES proyectos(id) ON DELETE CASCADE,
  FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ---------- documentos ----------
CREATE TABLE documentos (
  id INT AUTO_INCREMENT PRIMARY KEY,
  proyecto_id INT NOT NULL,
  fase TINYINT NOT NULL,
  tipo ENUM('SoportePago','Propuesta_FDC124','Turnitin_FDC124','Propuesta_FDC124_Firmada','Informe_FDC125','Turnitin_FDC125','Informe_FDC125_Firmado','Rejilla_FDC129','Acta_Sustentacion','Otro') NOT NULL,
  version INT NOT NULL DEFAULT 1,
  url VARCHAR(500) NOT NULL,
  titulo VARCHAR(255) NULL,
  observaciones TEXT NULL,
  subido_por INT NOT NULL,
  fecha_subida TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_doc_version (proyecto_id, tipo, version),
  FOREIGN KEY (proyecto_id) REFERENCES proyectos(id) ON DELETE CASCADE,
  FOREIGN KEY (subido_por) REFERENCES usuarios(id)
) ENGINE=InnoDB;

-- ---------- respuestas ----------
CREATE TABLE respuestas (
  id INT AUTO_INCREMENT PRIMARY KEY,
  proyecto_id INT NOT NULL,
  fase TINYINT NOT NULL,
  ronda INT NOT NULL DEFAULT 1,
  usuario_id INT NOT NULL,
  rol ENUM('comite','director','evaluador') NOT NULL,
  estado ENUM('Aprobado','Correcciones','Rechazado') NOT NULL,
  acta_numero VARCHAR(50) NULL,
  acta_fecha DATE NULL,
  comentario TEXT NULL,
  documento_id INT NULL,
  fecha TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (proyecto_id) REFERENCES proyectos(id) ON DELETE CASCADE,
  FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
  FOREIGN KEY (documento_id) REFERENCES documentos(id)
) ENGINE=InnoDB;

-- ---------- historial ----------
CREATE TABLE historial (
  id INT AUTO_INCREMENT PRIMARY KEY,
  proyecto_id INT NOT NULL,
  usuario_id INT NOT NULL,
  accion VARCHAR(100) NOT NULL,
  fase TINYINT NULL,
  acta_numero VARCHAR(50) NULL,
  comentario TEXT NULL,
  fecha TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (proyecto_id) REFERENCES proyectos(id) ON DELETE CASCADE,
  FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
) ENGINE=InnoDB;

-- ---------- sustentaciones ----------
CREATE TABLE sustentaciones (
  id INT AUTO_INCREMENT PRIMARY KEY,
  proyecto_id INT NOT NULL UNIQUE,
  fecha_hora DATETIME NOT NULL,
  lugar_enlace VARCHAR(255) NOT NULL,
  resultado VARCHAR(50) NULL,
  acta_numero VARCHAR(50) NULL,
  registrado_por INT NOT NULL,
  FOREIGN KEY (proyecto_id) REFERENCES proyectos(id) ON DELETE CASCADE,
  FOREIGN KEY (registrado_por) REFERENCES usuarios(id)
) ENGINE=InnoDB;

-- ---------- formatos ----------
CREATE TABLE formatos (
  id INT AUTO_INCREMENT PRIMARY KEY,
  codigo VARCHAR(20) NOT NULL UNIQUE,
  nombre VARCHAR(150) NOT NULL,
  url_plantilla VARCHAR(500) NOT NULL,
  activo TINYINT(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB;

-- =============================================================
-- DATOS SEMILLA (escenario de prueba 4.5)
-- Claves: admin123 / comite123 / doc123 / est123
-- =============================================================
INSERT INTO usuarios (documento,nombres,apellidos,email,password_hash,telefono) VALUES
('10000001','Admin','UTS','admin@correo.uts.edu.co',SHA2('admin123',256),'3000000001'),
('20000001','Comite','Grado','comite@correo.uts.edu.co',SHA2('comite123',256),'3000000002'),
('30000001','Elsa Patricia','Carvajal','director@correo.uts.edu.co',SHA2('doc123',256),'3000000003'),
('30000002','Julian Barney','Jaimes Rincon','evaluador@correo.uts.edu.co',SHA2('doc123',256),'3000000004'),
('40000001','Ana Maria','Perez Gomez','estudiante@correo.uts.edu.co',SHA2('est123',256),'3000000005'),
('40000002','Carlos Andres','Ruiz Diaz','estudiante2@correo.uts.edu.co',SHA2('est123',256),'3000000006');

INSERT INTO usuario_rol (usuario_id, rol_id) VALUES
(1,1),
(1,3),
(2,2),
(3,3),
(4,3),
(5,4),
(6,4);

INSERT INTO periodos (codigo,inicio_propuestas_banco,fin_propuestas_banco,inicio_nuevos_proyectos,fin_nuevos_proyectos,fin_aprobacion_propuesta,activo) VALUES
('2026-2','2026-07-01','2026-09-30','2026-07-15','2026-11-30','2026-12-15',1);

INSERT INTO formatos (codigo,nombre,url_plantilla,activo) VALUES
('F-DC-124','Propuesta de trabajo de grado','https://example.com/formatos/F-DC-124',1),
('F-DC-125','Informe final de trabajo de grado','https://example.com/formatos/F-DC-125',1),
('F-DC-129','Rejilla de evaluacion de informe final','https://example.com/formatos/F-DC-129',1),
('F-DC-131','Acta de sustentacion','https://example.com/formatos/F-DC-131',1);

-- Idea del banco propuesta por docente (aprobada, disponible)
INSERT INTO propuestas_banco (codigo,proponente_id,origen,titulo,tipo_modalidad,objetivo_general,descripcion,linea_investigacion,tipo_nivel,periodo_id,estado,disponible,revisor_id,observacion_comite) VALUES
('BAN-00001',3,'Docente','Sistema de gestion de trabajos de grado - SIGRADO','Desarrollo tecnologico','Desarrollar un sistema web para gestionar el ciclo de trabajos de grado.','Plataforma JSP/MySQL con 6 fases, roles y trazabilidad.','Ingenieria de software','Tecnologico',1,'Aprobada',1,1,'Idea aprobada. Sin comprobante de pago por ser docente.'),
('BAN-00002',3,'Docente','App movil de seguimiento academico UTS','Desarrollo tecnologico','Desarrollar una app movil para seguimiento de notas y asistencia.','App Android con backend REST.','Ingenieria de software','Profesional',1,'Aprobada',1,1,'Aprobada para el banco del periodo.');

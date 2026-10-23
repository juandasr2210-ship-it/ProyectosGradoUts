<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="WEB-INF/jspf/conexion.jspf" %>
<%
  String perCod="", f1="", f2="", f3="", f4="", f5="";
  java.util.List<String[]> formatos = new java.util.ArrayList<String[]>();
  try (Connection c = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
       Statement st = c.createStatement()) {
    try {
      ResultSet r = st.executeQuery("SELECT codigo,inicio_propuestas_banco,fin_propuestas_banco,inicio_nuevos_proyectos,fin_nuevos_proyectos,fin_aprobacion_propuesta FROM periodos WHERE activo=1 LIMIT 1");
      if (r.next()) { perCod=r.getString(1); f1=r.getString(2)+" al "+r.getString(3); f2=r.getString(4)+" al "+r.getString(5); f3=r.getString(6); }
      r.close();
    } catch (Exception e) { perCod="2026-2 (configurar periodo)"; }
    try {
      ResultSet r2 = st.executeQuery("SELECT codigo,nombre,url_plantilla FROM formatos WHERE activo=1 ORDER BY codigo");
      while (r2.next()) formatos.add(new String[]{r2.getString(1),r2.getString(2),r2.getString(3)});
      r2.close();
    } catch (Exception e) {}
  } catch (Exception e) {}
  String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="es"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Trabajos de Grado · Ingeniería de Sistemas UTS</title>
<link rel="stylesheet" href="<%=ctx%>/css/estilos.css">
<style>
  :root {
    --uts-verde: #1b4d2a;
    --uts-verde-claro: #2d6b3e;
    --uts-amarillo: #f2c200;
    --uts-amarillo-hover: #e8c000;
    --blanco: #ffffff;
    --texto-oscuro: #1a1a1a;
    --texto-claro: #f5f5f5;
  }
  body {
    background: linear-gradient(135deg, var(--uts-verde) 0%, var(--uts-verde-claro) 50%, var(--uts-verde) 100%);
    min-height: 100vh;
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
  }
  .content-wrapper { max-width: 1100px; margin: 0 auto; padding: 40px 22px; }
  .hero {
    background: var(--blanco);
    border-radius: 20px;
    padding: 40px;
    box-shadow: 0 10px 40px rgba(0,0,0,0.2);
    border-top: 5px solid var(--uts-amarillo);
  }
  .card {
    background: var(--blanco);
    border-radius: 16px;
    box-shadow: 0 4px 20px rgba(0,0,0,0.15);
    border: 1px solid rgba(0,0,0,0.05);
  }
  .card h3 { color: var(--uts-verde); }
  .tbl th { background: var(--uts-verde); color: var(--blanco); }
  .tbl tr:hover td { background: rgba(27,77,42,0.08); }
  .footer { color: rgba(255,255,255,0.85); text-align: center; padding: 30px 20px; font-size: 14px; }
  .topbar { background: rgba(27,77,42,0.98); border-bottom: 2px solid var(--uts-amarillo); }
  .topbar .titulo, .topbar .brand-fb { color: var(--blanco); }
  .brand-fb span { color: var(--uts-amarillo) !important; }
  
  /* Botones - colores explícitos para contraste */
  .btn { 
    display: inline-flex; align-items: center; justify-content: center;
    padding: 10px 20px; border-radius: 8px; font-weight: 700; 
    text-decoration: none; border: 0; cursor: pointer; font-size: 14px;
    transition: all 0.2s ease;
  }
  .btn.sm { padding: 7px 14px; font-size: 13px; }
  .btn.primary { 
    background: var(--uts-amarillo); 
    color: var(--uts-verde); 
    font-weight: 800;
    box-shadow: 0 2px 8px rgba(242,194,0,0.3);
  }
  .btn.primary:hover { 
    background: var(--uts-amarillo-hover); 
    transform: translateY(-1px);
    box-shadow: 0 4px 12px rgba(242,194,0,0.4);
  }
  .btn.secondary { 
    background: var(--blanco); 
    color: var(--uts-verde); 
    border: 2px solid var(--uts-verde);
  }
  .btn.secondary:hover { 
    background: var(--uts-verde); 
    color: var(--blanco);
  }
  .btn.ghost { 
    background: transparent; 
    color: var(--uts-verde); 
    border: 2px solid var(--uts-verde);
  }
  .btn.ghost:hover { 
    background: var(--uts-verde); 
    color: var(--blanco);
  }
  .chip { display: inline-block; padding: 4px 12px; border-radius: 20px; font-size: 12px; font-weight: 700; }
  .chip.amarillo { background: var(--uts-amarillo); color: var(--uts-verde); font-weight: 800; }
  .card h3 { margin-top: 0; }
  .grid.g3 { display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 16px; }
  .card { padding: 24px; }
  a.lnk { color: var(--uts-verde); text-decoration: underline; }
  a.lnk:hover { color: var(--uts-verde-claro); }
</style>
</head>
<body>
<div class="topbar"><a class="brand topbar-brand" href="<%=ctx%>/index.jsp"><img class="logo" src="<%=ctx%>/img/programa-logo.png" alt="Ingeniería de Sistemas UTS" style="height:38px" onload="this.nextElementSibling.style.display='none'" onerror="this.remove()"><span class="brand-fb">Ingeniería de Sistemas <span style="color:var(--uts-amarillo)">UTS</span></span></a>
<div class="userbox"><a class="btn sm primary" href="<%=ctx%>/login.jsp">Ingresar</a></div></div>
<div class="content-wrapper">
<div class="hero">
  <h1 style="margin:0 0 16px 0; color: var(--uts-verde); font-size: 28px;">Sistema de Gestión de Trabajos de Grado</h1>
  <p style="color: #444; margin-bottom: 24px; line-height: 1.6;">Ingeniería de Sistemas · Banco de ideas, inscripción con comprobante de pago, seguimiento en 6 fases, entregas por URL con historial de versiones, correcciones y cierre con sustentación. Proyectos individuales o en pareja.</p>
  <a class="btn primary" href="<%=ctx%>/login.jsp" style="padding: 14px 32px; font-size: 15px;">Ingresar con correo y contraseña</a>
  <span class="chip amarillo" style="margin-left:12px; margin-top: 12px; display: inline-block;">Periodo vigente: <%= esc(perCod) %></span>
</div>

<div class="grid g3" style="margin-top:24px">
  <div class="card"><h3><%= ICON("calendar") %> Fechas del periodo vigente (<%= esc(perCod) %>)</h3>
    <p style="color:#333; line-height: 1.8;"><b>Banco de ideas:</b> <%= esc(f1) %><br><b>Nuevos proyectos:</b> <%= esc(f2) %><br><b>Fin aprobación propuesta:</b> <%= esc(f5) %></p>
    <a class="btn sm secondary" href="<%=ctx%>/login.jsp">Ver calendario</a></div>
  <div class="card"><h3><%= ICON("file") %> Formatos de grado</h3>
    <% if (formatos.isEmpty()) { %><p style="color:#666;">Formatos por cargar (F-DC-124, F-DC-125, F-DC-129).</p><% }
       for (String[] f : formatos) { %><p style="margin: 8px 0;"><b><%= esc(f[0]) %></b> · <%= esc(f[1]) %><br><a class="lnk" href="<%= esc(f[2]) %>" target="_blank"><%= esc(f[2]) %></a></p><% } %></div>
  <div class="card"><h3><%= ICON("users") %> Roles</h3><p style="color:#333; line-height: 1.6;">Administrador · Comité · Docente · Estudiante.<br>Director, evaluador y codirector son <b>asignaciones por proyecto</b>, no roles de cuenta. Un usuario puede tener varios roles y cambiar de perfil sin cerrar sesión.</p></div>
</div>

<div class="card" style="margin-top:24px;"><h2 style="color: var(--uts-verde); margin-top:0;">Las 6 fases del proceso</h2>
<table class="tbl"><tr><th>Fase</th><th>Entrega</th><th>Decide</th><th>Si aprueba</th><th>Si hay correcciones</th></tr>
<tr><td><b>1. Idea y pago</b></td><td>Estudiante: idea + URL comprobante</td><td>Comité</td><td>Pasa a Fase 2 con director/evaluador/codirector</td><td>Vuelve al estudiante</td></tr>
<tr><td><b>2. Propuesta I</b></td><td>Estudiante: anteproyecto (URL)</td><td>Director + Turnitin</td><td>Pasa a Fase 3</td><td>Vuelve al estudiante</td></tr>
<tr><td><b>3. Propuesta II</b></td><td>Director envía a evaluador</td><td>Evaluador y Comité</td><td>Pasa a Fase 4</td><td>Vuelve a Fase 2</td></tr>
<tr><td><b>4. Informe I</b></td><td>Estudiante: informe (URL)</td><td>Director</td><td>Pasa a Fase 5</td><td>Vuelve al estudiante</td></tr>
<tr><td><b>5. Informe II</b></td><td>Director envía a evaluador</td><td>Evaluador y Comité (F-DC-125 y F-DC-129)</td><td>Pasa a Fase 6</td><td>Vuelve a Fase 4</td></tr>
<tr><td><b>6. Cierre</b></td><td>Programan sustentación</td><td>Comité verifica y finaliza</td><td>Proyecto Finalizado</td><td>Solicita faltante</td></tr>
</table>
<p style="color:#555; margin-top:16px;">Todos los documentos se entregan como enlaces <b>https</b> (no se suben archivos). Cada entrega crea una versión nueva. Código de modalidad: <b>65</b> Tecnológico y <b>125</b> Profesional + año + consecutivo (ej. 65-2026-284).</p></div>
<div class="footer">Trabajos de Grado · Ingeniería de Sistemas · UTS · 2026</div>
</div></body></html>
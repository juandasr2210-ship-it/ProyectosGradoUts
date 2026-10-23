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
  body {
    background: linear-gradient(135deg, #1b4d2a 0%, #2d6b3e 50%, #1b4d2a 100%);
    min-height: 100vh;
  }
  .content-wrapper {
    max-width: 1100px;
    margin: 0 auto;
    padding: 40px 22px;
  }
  .hero {
    background: rgba(255,255,255,0.95);
    border-radius: 20px;
    padding: 40px;
    box-shadow: 0 10px 40px rgba(0,0,0,0.2);
    border-top: 5px solid var(--amarillo);
  }
  .card {
    background: rgba(255,255,255,0.95);
    border-radius: 16px;
    box-shadow: 0 4px 20px rgba(0,0,0,0.15);
    border: 1px solid rgba(255,255,255,0.3);
  }
  .card h3 { color: #1b4d2a; }
  .tbl th { background: #1b4d2a; color: white; }
  .tbl tr:hover td { background: rgba(27,77,42,0.08); }
  .footer { color: rgba(255,255,255,0.8); text-align: center; padding: 30px 20px; font-size: 14px; }
  .topbar { background: rgba(27,77,42,0.95); border-bottom: 2px solid var(--amarillo); }
  .topbar .titulo, .topbar .brand-fb { color: white; }
  .brand-fb span { color: var(--amarillo) !important; }
  .btn.primary { background: var(--amarillo); color: #1b4d2a; }
  .btn.primary:hover { background: #e8c000; }
  .chip.amarillo { background: var(--amarillo); color: #1b4d2a; }
</style>
</head>
<body>
<div class="topbar"><a class="brand topbar-brand" href="<%=ctx%>/index.jsp"><img class="logo" src="<%=ctx%>/img/programa-logo.png" alt="Ingeniería de Sistemas UTS" style="height:38px" onload="this.nextElementSibling.style.display='none'" onerror="this.remove()"><span class="brand-fb">Ingeniería de Sistemas <span style="color:var(--amarillo)">UTS</span></span></a>
<div class="userbox"><a class="btn sm primary" href="<%=ctx%>/login.jsp">Ingresar</a></div></div>
<div class="content-wrapper">
<div class="hero">
  <h1 style="margin:0">Sistema de Gestión de Trabajos de Grado</h1>
  <p>Ingeniería de Sistemas · Banco de ideas, inscripción con comprobante de pago, seguimiento en 6 fases, entregas por URL con historial de versiones, correcciones y cierre con sustentación. Proyectos individuales o en pareja.</p>
  <a class="btn primary" href="<%=ctx%>/login.jsp">Ingresar con correo y contraseña</a>
  <span class="chip amarillo" style="margin-left:8px">Periodo vigente: <%= esc(perCod) %></span>
</div>

<div class="grid g3" style="margin-top:16px">
  <div class="card"><h3><%= ICON("calendar") %> Fechas del periodo vigente (<%= esc(perCod) %>)</h3>
    <p><b>Banco de ideas:</b> <%= esc(f1) %><br><b>Nuevos proyectos:</b> <%= esc(f2) %><br><b>Fin aprobación propuesta:</b> <%= esc(f5) %></p>
    <a class="btn sm" href="<%=ctx%>/login.jsp">Ver calendario</a></div>
  <div class="card"><h3><%= ICON("file") %> Formatos de grado</h3>
    <% if (formatos.isEmpty()) { %><p>Formatos por cargar (F-DC-124, F-DC-125, F-DC-129).</p><% }
       for (String[] f : formatos) { %><p><b><%= esc(f[0]) %></b> · <%= esc(f[1]) %><br><a class="lnk" href="<%= esc(f[2]) %>" target="_blank"><%= esc(f[2]) %></a></p><% } %></div>
  <div class="card"><h3><%= ICON("users") %> Roles</h3><p>Administrador · Comité · Docente · Estudiante.<br>Director, evaluador y codirector son <b>asignaciones por proyecto</b>, no roles de cuenta. Un usuario puede tener varios roles y cambiar de perfil sin cerrar sesión.</p></div>
</div>

<div class="card"><h2>Las 6 fases del proceso</h2>
<table class="tbl"><tr><th>Fase</th><th>Entrega</th><th>Decide</th><th>Si aprueba</th><th>Si hay correcciones</th></tr>
<tr><td><b>1. Idea y pago</b></td><td>Estudiante: idea + URL comprobante</td><td>Comité</td><td>Pasa a Fase 2 con director/evaluador/codirector</td><td>Vuelve al estudiante</td></tr>
<tr><td><b>2. Propuesta I</b></td><td>Estudiante: anteproyecto (URL)</td><td>Director + Turnitin</td><td>Pasa a Fase 3</td><td>Vuelve al estudiante</td></tr>
<tr><td><b>3. Propuesta II</b></td><td>Director envía a evaluador</td><td>Evaluador y Comité</td><td>Pasa a Fase 4</td><td>Vuelve a Fase 2</td></tr>
<tr><td><b>4. Informe I</b></td><td>Estudiante: informe (URL)</td><td>Director</td><td>Pasa a Fase 5</td><td>Vuelve al estudiante</td></tr>
<tr><td><b>5. Informe II</b></td><td>Director envía a evaluador</td><td>Evaluador y Comité (F-DC-125 y F-DC-129)</td><td>Pasa a Fase 6</td><td>Vuelve a Fase 4</td></tr>
<tr><td><b>6. Cierre</b></td><td>Programan sustentación</td><td>Comité verifica y finaliza</td><td>Proyecto Finalizado</td><td>Solicita faltante</td></tr>
</table>
<p style="color:#666">Todos los documentos se entregan como enlaces <b>https</b> (no se suben archivos). Cada entrega crea una versión nueva. Código de modalidad: <b>65</b> Tecnológico y <b>125</b> Profesional + año + consecutivo (ej. 65-2026-284).</p></div>
<div class="footer">Trabajos de Grado · Ingeniería de Sistemas · UTS · 2026</div>
</div></body></html>

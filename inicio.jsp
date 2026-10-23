<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="WEB-INF/jspf/conexion.jspf" %>
<%@ include file="WEB-INF/jspf/guard.jspf" %>
<%
  java.util.List<String> roles = (java.util.List<String>) session.getAttribute("roles");
  String rol = (String) session.getAttribute("rol");
  if (rol == null && roles != null && !roles.isEmpty()) { session.setAttribute("rol", roles.get(0)); rol = roles.get(0); }
%>
<%@ include file="WEB-INF/jspf/header.jspf" %>
<div class="card banner-inicio">
  <h2>SISTEMA - TRABAJOS DE <span class="badge-grado">GRADO</span></h2>
  <p>Bienvenido al portal de sistemas trabajo de grado, aquí podrás acceder a:</p>
</div>
<div class="grid g3">
<% if ("administrador".equals(rol)) { %>
  <a class="card modulo" href="<%=ctx%>/administrador/proyectos.jsp"><span class="ico"><%= ICON("folder") %></span><h4>Proyectos</h4><p>Gestione todos los proyectos, fases y cancelaciones.</p></a>
  <a class="card modulo" href="<%=ctx%>/administrador/propuestas_banco.jsp"><span class="ico"><%= ICON("file") %></span><h4>Propuestas Banco</h4><p>Apruebe las ideas propuestas al banco del periodo.</p></a>
  <a class="card modulo" href="<%=ctx%>/comun/formatos.jsp"><span class="ico"><%= ICON("book") %></span><h4>Base Documental</h4><p>Accede a todos los formatos institucionales de manera eficiente.</p></a>
  <a class="card modulo" href="<%=ctx%>/administrador/configuracion.jsp"><span class="ico"><%= ICON("calendar") %></span><h4>Calendario Académico</h4><p>Consulta las fechas importantes y eventos académicos.</p></a>
  <a class="card modulo" href="<%=ctx%>/administrador/usuarios.jsp"><span class="ico"><%= ICON("users") %></span><h4>Usuarios</h4><p>Cree usuarios y asigne los roles del sistema.</p></a>
  <a class="card modulo" href="<%=ctx%>/perfil.jsp"><span class="ico"><%= ICON("user") %></span><h4>Mi perfil</h4><p>Actualiza tu información de cuenta y contraseña.</p></a>
<% } else if ("comite".equals(rol)) { %>
  <a class="card modulo" href="<%=ctx%>/comite/proyectos.jsp"><span class="ico"><%= ICON("folder") %></span><h4>Proyectos</h4><p>Decida en las fases 1, 3, 5 y 6 con acta.</p></a>
  <a class="card modulo" href="<%=ctx%>/comite/propuestas_banco.jsp"><span class="ico"><%= ICON("file") %></span><h4>Propuestas Banco</h4><p>Consulte las propuestas del banco de ideas.</p></a>
  <a class="card modulo" href="<%=ctx%>/comun/formatos.jsp"><span class="ico"><%= ICON("book") %></span><h4>Base Documental</h4><p>Accede a todos los formatos de presentación institucional.</p></a>
  <a class="card modulo" href="<%=ctx%>/comun/calendario.jsp"><span class="ico"><%= ICON("calendar") %></span><h4>Calendario Académico</h4><p>Consulta las fechas importantes y eventos académicos.</p></a>
  <a class="card modulo" href="<%=ctx%>/comite/usuarios.jsp"><span class="ico"><%= ICON("users") %></span><h4>Usuarios</h4><p>Consulte los usuarios registrados en el sistema.</p></a>
  <a class="card modulo" href="<%=ctx%>/perfil.jsp"><span class="ico"><%= ICON("user") %></span><h4>Mi perfil</h4><p>Actualiza tu información de cuenta y contraseña.</p></a>
<% } else if ("docente".equals(rol)) { %>
  <a class="card modulo" href="<%=ctx%>/docente/banco.jsp"><span class="ico"><%= ICON("file") %></span><h4>Banco de ideas</h4><p>Accede al banco de ideas del periodo actual propuesto por los docentes.</p></a>
  <a class="card modulo" href="<%=ctx%>/docente/propuestas_banco.jsp"><span class="ico"><%= ICON("file") %></span><h4>Propuestas Banco</h4><p>Propone nuevas ideas de proyectos para el banco del periodo actual.</p></a>
  <a class="card modulo" href="<%=ctx%>/comun/formatos.jsp"><span class="ico"><%= ICON("book") %></span><h4>Base Documental</h4><p>Accede a toda la información documental organizada de manera eficiente.</p></a>
  <a class="card modulo" href="<%=ctx%>/comun/calendario.jsp"><span class="ico"><%= ICON("calendar") %></span><h4>Calendario Académico</h4><p>Consulta las fechas importantes y eventos académicos.</p></a>
  <a class="card modulo" href="#pqrsd" onclick="alert('Módulo de atención a consultas y sugerencias');return false;"><span class="ico"><%= ICON("alert") %></span><h4>PQRSD</h4><p>Realiza tu sugerencia, queja o consulta.</p></a>
  <a class="card modulo" href="<%=ctx%>/comun/formatos.jsp#reglamento"><span class="ico"><%= ICON("list") %></span><h4>Reglamento de trabajos de grado</h4><p>Procedimiento para elaborar un trabajo de grado.</p></a>
<% } else { %>
  <a class="card modulo" href="<%=ctx%>/estudiante/banco.jsp"><span class="ico"><%= ICON("file") %></span><h4>Banco de ideas</h4><p>Elige una idea aprobada o propone la tuya.</p></a>
  <a class="card modulo" href="<%=ctx%>/estudiante/proyecto.jsp"><span class="ico"><%= ICON("folder") %></span><h4>Mi proyecto</h4><p>Entrega documentos y sigue tu fase actual.</p></a>
  <a class="card modulo" href="<%=ctx%>/comun/formatos.jsp"><span class="ico"><%= ICON("book") %></span><h4>Base Documental</h4><p>Accede a todos los formatos institucionales.</p></a>
  <a class="card modulo" href="<%=ctx%>/comun/calendario.jsp"><span class="ico"><%= ICON("calendar") %></span><h4>Calendario Académico</h4><p>Consulta las fechas del periodo académico vigente.</p></a>
  <a class="card modulo" href="<%=ctx%>/estudiante/seguimiento.jsp"><span class="ico"><%= ICON("map") %></span><h4>Seguimiento</h4><p>Mapa de fases, decisiones y comentarios.</p></a>
  <a class="card modulo" href="<%=ctx%>/perfil.jsp"><span class="ico"><%= ICON("user") %></span><h4>Mi perfil</h4><p>Actualiza tu información de cuenta y contraseña.</p></a>
<% } %>
</div>
<% if (roles != null && roles.size() > 1) { %>
<div class="card" style="text-align: center; color: #55626d; font-size: 13.5px;">
  Su cuenta tiene varios perfiles asignados.
  <a class="btn sm primary" href="<%=ctx%>/cambiar_rol.jsp" style="margin-left: 8px;"><%= ICON("repeat") %> Cambiar de perfil</a>
</div>
<% } %>
<%@ include file="WEB-INF/jspf/footer.jspf" %>

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="WEB-INF/jspf/conexion.jspf" %>
<%@ include file="WEB-INF/jspf/guard.jspf" %>
<%
  java.util.List<String> roles = (java.util.List<String>) session.getAttribute("roles");
  if (request.getParameter("rol") != null) {
    String nr = request.getParameter("rol");
    if (roles != null && roles.contains(nr)) { session.setAttribute("rol", nr); response.sendRedirect("inicio.jsp"); return; }
  }
  String ctx = request.getContextPath();
%>
<!DOCTYPE html><html lang="es"><head><meta charset="UTF-8"><title>Elegir perfil · Trabajos de Grado</title><link rel="stylesheet" href="<%=ctx%>/css/estilos.css"></head>
<body><div style="max-width:520px;margin:40px auto;padding:0 16px"><div class="card">
<h2>Seleccione su perfil (RF-GEN-03)</h2>
<p>Su cuenta tiene varios roles. Puede cambiar de perfil sin cerrar sesión.</p>
<% if (roles != null) for (String r : roles) { %>
<p><a class="btn green" style="width:100%;text-align:center" href="elegir_rol.jsp?rol=<%= r %>"><%= esc(r) %></a></p>
<% } %>
</div></div></body></html>

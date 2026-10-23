<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true" %>
<!DOCTYPE html><html lang="es"><head><meta charset="UTF-8"><title>Error · Trabajos de Grado</title>
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/estilos.css"></head>
<body><div style="max-width:560px;margin:60px auto"><div class="card">
<h2>Ha ocurrido un error</h2>
<p><%= request.getParameter("m") != null ? request.getParameter("m").replace("<","&lt;") : (exception != null ? String.valueOf(exception.getMessage()).replace("<","&lt;") : "Página no encontrada o acceso denegado.") %></p>
<p><a class="btn primary" href="<%=request.getContextPath()%>/inicio.jsp">Volver al inicio</a>
<a class="btn" href="<%=request.getContextPath()%>/login.jsp">Ir al login</a></p>
</div></div></body></html>

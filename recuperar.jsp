<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="WEB-INF/jspf/conexion.jspf" %>
<%
  String msg = "";
  if ("POST".equals(request.getMethod())) {
    String ema = request.getParameter("email"); if (ema==null) ema="";
    String doc = request.getParameter("documento"); if (doc==null) doc="";
    String p1 = request.getParameter("pass1"), p2 = request.getParameter("pass2");
    if (p1==null||p1.length()<6) msg = "La contraseña debe tener mínimo 6 caracteres.";
    else if (!p1.equals(p2)) msg = "Las contraseñas no coinciden.";
    else {
      try (Connection c = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS)) {
        PreparedStatement ps = c.prepareStatement("UPDATE usuarios SET password_hash=? WHERE email=? AND documento=?");
        ps.setString(1, sha256(p1)); ps.setString(2, ema.trim().toLowerCase()); ps.setString(3, doc.trim());
        int n = ps.executeUpdate(); ps.close();
        if (n > 0) { response.sendRedirect("login.jsp?ok=Contraseña+actualizada.+Ingrese+nuevamente"); return; }
        else msg = "No se encontró la cuenta con ese correo y documento.";
      } catch (Exception e) { msg = e.getMessage(); }
    }
  }
  String ctx = request.getContextPath();
%>
<!DOCTYPE html><html lang="es"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Recuperar contraseña · Trabajos de Grado</title><link rel="stylesheet" href="<%=ctx%>/css/estilos.css"></head>
<body>
<div class="login-wrap">
  <div class="login-brand"><img class="logo" src="<%=ctx%>/img/programa-logo.png" alt="Ingeniería de Sistemas UTS" onload="this.nextElementSibling.style.display='none'" onerror="this.remove()"><span class="brand-fb"><span style="font-size:22px;font-weight:800">Ingeniería<br>de Sistemas <span class="uts">UTS</span></span></span></div>
  <div class="login-card">
    <h3>Recuperar <span>CONTRASEÑA</span></h3>
    <% if (!msg.isEmpty()) { %><div class="alert err"><%= esc(msg) %></div><% } %>
    <form method="post">
      <label>Correo:</label><input name="email" type="email" required>
      <label>Documento:</label><input name="documento" required>
      <label>Nueva contraseña:</label><input name="pass1" type="password" required>
      <label>Confirmar contraseña:</label><input name="pass2" type="password" required>
      <br><div style="text-align:center"><button class="btn btn-enviar">ACTUALIZAR</button></div>
    </form>
    <div class="login-links"><a href="<%=ctx%>/login.jsp">← Volver al ingreso</a><span></span></div>
  </div>
</div></body></html>

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="WEB-INF/jspf/conexion.jspf" %>
<%
  String msg = "";
  if ("POST".equals(request.getMethod())) {
    String email = request.getParameter("email");
    String pass = request.getParameter("pass");
    if (email == null) email = "";
    email = email.trim().toLowerCase();
    try (Connection c = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS)) {
      PreparedStatement ps = c.prepareStatement("SELECT id,documento,nombres,apellidos,email,password_hash,activo FROM usuarios WHERE email=?");
      ps.setString(1, email);
      ResultSet r = ps.executeQuery();
      if (r.next()) {
        if (r.getInt("activo") == 0) { msg = "Usuario inactivo. Contacte al administrador."; }
        else if (sha256(pass == null ? "" : pass).equals(r.getString("password_hash"))) {
          int uid = r.getInt("id");
          session.setAttribute("uid", uid);
          session.setAttribute("nombres", r.getString("nombres") + " " + r.getString("apellidos"));
          session.setAttribute("email", r.getString("email"));
          PreparedStatement pr = c.prepareStatement("SELECT r.nombre FROM usuario_rol ur JOIN roles r ON r.id=ur.rol_id WHERE ur.usuario_id=?");
          pr.setInt(1, uid);
          ResultSet rr = pr.executeQuery();
          java.util.List<String> roles = new java.util.ArrayList<String>();
          while (rr.next()) roles.add(rr.getString(1));
          rr.close(); pr.close();
          session.setAttribute("roles", roles);
          r.close(); ps.close();
          if (roles.size() == 1) { session.setAttribute("rol", roles.get(0)); response.sendRedirect("inicio.jsp"); return; }
          response.sendRedirect("elegir_rol.jsp"); return;
        } else { msg = "Credenciales inválidas."; }
      } else { msg = "Credenciales inválidas."; }
      r.close(); ps.close();
    } catch (Exception e) { msg = "Error de conexión: " + e.getMessage(); }
  }
  String okm = request.getParameter("ok");
  String ctx = request.getContextPath();
%>
<!DOCTYPE html><html lang="es"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Iniciar sesión · Trabajos de Grado</title><link rel="stylesheet" href="<%=ctx%>/css/estilos.css"></head>
<body>
<div class="login-wrap">
  <div class="login-brand">
    <img class="logo" src="<%=ctx%>/img/programa-logo.png" alt="Ingeniería de Sistemas UTS">
  </div>
  <div class="login-card">
    <h3>Iniciar <span class="pill-sesion">SESIÓN</span></h3>
    <% if (okm != null && !okm.isEmpty()) { %><div class="alert ok"><%= esc(okm) %></div><% } %>
    <% if (!msg.isEmpty()) { %><div class="alert err"><%= esc(msg) %></div><% } %>
    <form method="post">
      <label><%= ICON("mail") %> Correo:</label>
      <input name="email" type="email" required placeholder="Ingrese su correo institucional.">
      <label><%= ICON("lock") %> Contraseña:</label>
      <input name="pass" type="password" required placeholder="••••••••">
      <div style="margin: 12px 0 16px 0; font-size: 13px; color: #55626d; display: flex; align-items: center; gap: 8px;">
        <input type="checkbox" id="chkKeep" style="width: auto; margin: 0;">
        <label for="chkKeep" style="display: inline; margin: 0; font-weight: normal; cursor: pointer;">Mantener sesión activa</label>
      </div>
      <div style="text-align: center;">
        <button class="btn-enviar">ENVIAR</button>
      </div>
    </form>
    <div class="login-links">
      <a href="<%=ctx%>/crear_cuenta.jsp">Crear cuenta</a>
      <a href="<%=ctx%>/recuperar.jsp">¿Olvidó su contraseña?</a>
    </div>
  </div>
  <p style="text-align:center;font-size:12px;color:#888;margin-top:20px">
    Cuentas de prueba: admin@correo.uts.edu.co / admin123 · comite@correo.uts.edu.co / comite123 · director@correo.uts.edu.co / doc123 · estudiante@correo.uts.edu.co / est123
  </p>
</div></body></html>

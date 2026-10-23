<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="WEB-INF/jspf/conexion.jspf" %>
<%
  String msg = "";
  if ("POST".equals(request.getMethod())) {
    String doc = request.getParameter("documento"), nom = request.getParameter("nombres"),
           ape = request.getParameter("apellidos"), ema = request.getParameter("email"),
           tel = request.getParameter("telefono"), p1 = request.getParameter("pass1"), p2 = request.getParameter("pass2");
    if (doc==null||doc.trim().isEmpty()||nom==null||nom.trim().isEmpty()||ema==null||ema.trim().isEmpty()) msg = "Complete los campos obligatorios.";
    else if (p1==null||p1.length()<6) msg = "La contraseña debe tener mínimo 6 caracteres.";
    else if (!p1.equals(p2)) msg = "Las contraseñas no coinciden.";
    else {
      try (Connection c = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS)) {
        PreparedStatement ps = c.prepareStatement("INSERT INTO usuarios(documento,nombres,apellidos,email,password_hash,telefono) VALUES(?,?,?,?,?,?)", Statement.RETURN_GENERATED_KEYS);
        ps.setString(1, doc.trim()); ps.setString(2, nom.trim()); ps.setString(3, ape==null?"":ape.trim());
        ps.setString(4, ema.trim().toLowerCase()); ps.setString(5, sha256(p1)); ps.setString(6, tel);
        ps.executeUpdate();
        ResultSet k = ps.getGeneratedKeys(); int nid = 0; if (k.next()) nid = k.getInt(1); k.close(); ps.close();
        PreparedStatement pr = c.prepareStatement("INSERT INTO usuario_rol(usuario_id,rol_id) SELECT ?,id FROM roles WHERE nombre='estudiante'");
        pr.setInt(1, nid); pr.executeUpdate(); pr.close();
        response.sendRedirect("login.jsp?ok=Cuenta+creada.+Ingrese+con+su+correo+y+contraseña"); return;
      } catch (Exception e) { msg = "No se pudo crear la cuenta (¿documento o correo ya registrado?)."; }
    }
  }
  String ctx = request.getContextPath();
%>
<!DOCTYPE html><html lang="es"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Crear cuenta · Trabajos de Grado</title><link rel="stylesheet" href="<%=ctx%>/css/estilos.css"></head>
<body>
<div class="login-wrap" style="max-width:520px">
  <div class="login-brand"><img class="logo" src="<%=ctx%>/img/programa-logo.png" alt="Ingeniería de Sistemas UTS" onload="this.nextElementSibling.style.display='none'" onerror="this.remove()"><span class="brand-fb"><span style="font-size:22px;font-weight:800">Ingeniería<br>de Sistemas <span class="uts">UTS</span></span></span></div>
  <div class="login-card">
    <h3>Crear <span>CUENTA</span></h3>
    <% if (!msg.isEmpty()) { %><div class="alert err"><%= esc(msg) %></div><% } %>
    <form method="post">
      <div class="form-row">
        <div><label>Documento*</label><input name="documento" required maxlength="20"></div>
        <div><label>Teléfono</label><input name="telefono" maxlength="20"></div>
      </div>
      <div class="form-row">
        <div><label>Nombres*</label><input name="nombres" required></div>
        <div><label>Apellidos</label><input name="apellidos"></div>
      </div>
      <label>Correo*</label><input name="email" type="email" required placeholder="Ingrese su correo.">
      <div class="form-row">
        <div><label>Contraseña* (mín. 6)</label><input name="pass1" type="password" required></div>
        <div><label>Confirmar contraseña*</label><input name="pass2" type="password" required></div>
      </div>
      <br><div style="text-align:center"><button class="btn btn-enviar">REGISTRARME</button></div>
    </form>
    <div class="login-links"><a href="<%=ctx%>/login.jsp">← Volver al ingreso</a><span>Rol inicial: estudiante</span></div>
  </div>
</div></body></html>

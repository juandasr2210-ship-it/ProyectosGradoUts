<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="WEB-INF/jspf/conexion.jspf" %>
<%@ include file="WEB-INF/jspf/guard.jspf" %>
<%
  int uid = (Integer) session.getAttribute("uid");
  String msg = "", msgOk = "";
  try (Connection c = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS)) {
    if ("POST".equals(request.getMethod())) {
      String tel = request.getParameter("telefono");
      String p1 = request.getParameter("pass1"), p2 = request.getParameter("pass2");
      if (p1 != null && !p1.isEmpty()) {
        if (!p1.equals(p2)) msg = "Las contraseñas no coinciden.";
        else if (p1.length() < 6) msg = "La contraseña debe tener mínimo 6 caracteres.";
        else {
          PreparedStatement ps = c.prepareStatement("UPDATE usuarios SET telefono=?, password_hash=? WHERE id=?");
          ps.setString(1, tel); ps.setString(2, sha256(p1)); ps.setInt(3, uid); ps.executeUpdate(); ps.close();
          msgOk = "Perfil actualizado correctamente.";
        }
      } else {
        PreparedStatement ps = c.prepareStatement("UPDATE usuarios SET telefono=? WHERE id=?");
        ps.setString(1, tel); ps.setInt(2, uid); ps.executeUpdate(); ps.close();
        msgOk = "Información actualizada correctamente.";
      }
    }
  } catch (Exception e) { msg = e.getMessage(); }
  String doc="", nom="", ape="", ema="", tel="";
  try (Connection c = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS)) {
    PreparedStatement ps = c.prepareStatement("SELECT documento,nombres,apellidos,email,telefono FROM usuarios WHERE id=?");
    ps.setInt(1, uid); ResultSet r = ps.executeQuery();
    if (r.next()) { doc=r.getString(1); nom=r.getString(2); ape=r.getString(3); ema=r.getString(4); tel=r.getString(5); }
    r.close(); ps.close();
  } catch (Exception e) {}
%>
<%@ include file="WEB-INF/jspf/header.jspf" %>

<div class="card" style="display:flex;gap:32px;flex-wrap:wrap">
  <div style="flex:1;min-width:260px">
    <h3 style="margin-top:0">Información de perfil</h3>
    <p style="color:#666;font-size:13.5px;line-height:1.5">
      Actualice la información de su cuenta y la dirección de correo electrónico.
    </p>
    <% if (!msg.isEmpty()) { %><div class="alert err"><%= esc(msg) %></div><% } %>
    <% if (!msgOk.isEmpty()) { %><div class="alert ok"><%= esc(msgOk) %></div><% } %>
  </div>

  <div style="flex:2;min-width:320px">
    <form method="post">
      <label><%= ICON("user") %> Nombre:</label>
      <input value="<%= esc(nom + " " + ape) %>" disabled style="background:#f9f9f9;border-color:var(--amarillo)">

      <div class="form-row" style="margin-top:8px">
        <div>
          <label><%= ICON("file") %> Tipo de documento:</label>
          <select disabled style="background:#f9f9f9">
            <option>Cédula de ciudadanía</option>
            <option>Tarjeta de identidad</option>
            <option>Cédula de extranjería</option>
          </select>
        </div>
        <div>
          <label><%= ICON("user") %> N° documento:</label>
          <input value="<%= esc(doc) %>" disabled style="background:#f9f9f9">
        </div>
      </div>

      <label style="margin-top:8px"><%= ICON("mail") %> Correo:</label>
      <input value="<%= esc(ema) %>" disabled style="background:#f9f9f9">

      <label style="margin-top:8px">Teléfono:</label>
      <input name="telefono" value="<%= esc(tel==null?"":tel) %>" maxlength="20" placeholder="Ingrese su teléfono">

      <div class="form-row" style="margin-top:8px">
        <div>
          <label><%= ICON("lock") %> Nueva contraseña (opcional):</label>
          <input name="pass1" type="password" placeholder="Mínimo 6 caracteres">
        </div>
        <div>
          <label><%= ICON("lock") %> Confirmar contraseña:</label>
          <input name="pass2" type="password">
        </div>
      </div>

      <div style="text-align:right;margin-top:20px">
        <button class="btn primary" style="padding:10px 28px;font-weight:800;letter-spacing:.5px">GUARDAR</button>
      </div>
    </form>
  </div>
</div>

<%@ include file="WEB-INF/jspf/footer.jspf" %>

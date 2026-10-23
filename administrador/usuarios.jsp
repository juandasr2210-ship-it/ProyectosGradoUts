<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="../../WEB-INF/jspf/conexion.jspf" %>
<%@ include file="../../WEB-INF/jspf/guardAdministrador.jspf" %>
<%
  int uid = (Integer) session.getAttribute("uid");
  String acc = request.getParameter("acc");
  // Acciones
  try (Connection c = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS)) {
    if ("crear".equals(acc)) {
      String doc=request.getParameter("documento"), nom=request.getParameter("nombres"),
             ape=request.getParameter("apellidos"), ema=request.getParameter("email"),
             tel=request.getParameter("telefono"), pas=request.getParameter("pass");
      String[] rls = request.getParameterValues("roles");
      PreparedStatement ps = c.prepareStatement("INSERT INTO usuarios(documento,nombres,apellidos,email,password_hash,telefono) VALUES(?,?,?,?,?,?)", Statement.RETURN_GENERATED_KEYS);
      ps.setString(1, doc.trim()); ps.setString(2, nom.trim()); ps.setString(3, ape.trim());
      ps.setString(4, ema.trim().toLowerCase()); ps.setString(5, sha256(pas)); ps.setString(6, tel);
      ps.executeUpdate();
      ResultSet k = ps.getGeneratedKeys(); int nid = 0; if (k.next()) nid = k.getInt(1); k.close(); ps.close();
      if (rls != null) for (String r : rls) {
        PreparedStatement p2 = c.prepareStatement("INSERT IGNORE INTO usuario_rol(usuario_id,rol_id) SELECT ?,id FROM roles WHERE nombre=?");
        p2.setInt(1, nid); p2.setString(2, r); p2.executeUpdate(); p2.close();
      }
      response.sendRedirect("usuarios.jsp?ok=Usuario+creado+correctamente"); return;
    }
    if ("toggle".equals(acc)) {
      PreparedStatement ps = c.prepareStatement("UPDATE usuarios SET activo = 1-activo WHERE id=?");
      ps.setInt(1, Integer.parseInt(request.getParameter("id"))); ps.executeUpdate(); ps.close();
      response.sendRedirect("usuarios.jsp?ok=Estado+actualizado"); return;
    }
    if ("roles".equals(acc)) {
      int idu = Integer.parseInt(request.getParameter("id"));
      String[] rls = request.getParameterValues("roles");
      PreparedStatement del = c.prepareStatement("DELETE FROM usuario_rol WHERE usuario_id=?"); del.setInt(1, idu); del.executeUpdate(); del.close();
      if (rls != null) for (String r : rls) {
        PreparedStatement p2 = c.prepareStatement("INSERT INTO usuario_rol(usuario_id,rol_id) SELECT ?,id FROM roles WHERE nombre=?");
        p2.setInt(1, idu); p2.setString(2, r); p2.executeUpdate(); p2.close();
      }
      response.sendRedirect("usuarios.jsp?ok=Roles+actualizados"); return;
    }
    if ("editar".equals(acc)) {
      PreparedStatement ps = c.prepareStatement("UPDATE usuarios SET nombres=?,apellidos=?,telefono=? WHERE id=?");
      ps.setString(1, request.getParameter("nombres")); ps.setString(2, request.getParameter("apellidos"));
      ps.setString(3, request.getParameter("telefono")); ps.setInt(4, Integer.parseInt(request.getParameter("id")));
      ps.executeUpdate(); ps.close();
      if (request.getParameter("pass") != null && !request.getParameter("pass").isEmpty()) {
        PreparedStatement p2 = c.prepareStatement("UPDATE usuarios SET password_hash=? WHERE id=?");
        p2.setString(1, sha256(request.getParameter("pass"))); p2.setInt(2, Integer.parseInt(request.getParameter("id"))); p2.executeUpdate(); p2.close();
      }
      response.sendRedirect("usuarios.jsp?ok=Usuario+actualizado"); return;
    }
  } catch (Exception e) { response.sendRedirect("usuarios.jsp?er=" + java.net.URLEncoder.encode("Error: "+e.getMessage(),"UTF-8")); return; }

  String q = request.getParameter("q"); if (q == null) q = "";
  String frol = request.getParameter("frol"); if (frol == null) frol = "";
  int pag = 1; try { pag = Integer.parseInt(request.getParameter("pag")); } catch (Exception e) {}
  if (pag < 1) pag = 1;
  int porPag = 10;
  try { porPag = Integer.parseInt(request.getParameter("npp")); } catch (Exception e) {}
  if (porPag != 5 && porPag != 10 && porPag != 25) porPag = 10;
  int total = 0;
  java.util.List<String[]> rows = new java.util.ArrayList<String[]>();
  java.util.Map<Integer,String> rolesMap = new java.util.HashMap<Integer,String>();
  try (Connection c = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS)) {
    String where = " WHERE (u.documento LIKE ? OR u.nombres LIKE ? OR u.apellidos LIKE ? OR u.email LIKE ?) ";
    if (!frol.isEmpty()) where += " AND EXISTS(SELECT 1 FROM usuario_rol ur2 JOIN roles r2 ON r2.id=ur2.rol_id WHERE ur2.usuario_id=u.id AND r2.nombre='"+frol.replace("'","")+"') ";
    PreparedStatement pc = c.prepareStatement("SELECT COUNT(*) FROM usuarios u" + where);
    String like = "%"+q+"%"; pc.setString(1,like); pc.setString(2,like); pc.setString(3,like); pc.setString(4,like);
    ResultSet rc = pc.executeQuery(); if (rc.next()) total = rc.getInt(1); rc.close(); pc.close();
    PreparedStatement ps = c.prepareStatement("SELECT u.id,u.documento,u.nombres,u.apellidos,u.email,u.telefono,u.activo FROM usuarios u"+where+" ORDER BY u.id DESC LIMIT ?,?");
    ps.setString(1,like); ps.setString(2,like); ps.setString(3,like); ps.setString(4,like); ps.setInt(5,(pag-1)*porPag); ps.setInt(6,porPag);
    ResultSet r = ps.executeQuery();
    while (r.next()) rows.add(new String[]{r.getString(1),r.getString(2),r.getString(3),r.getString(4),r.getString(5),r.getString(6),r.getString(7)});
    r.close(); ps.close();
    Statement st = c.createStatement();
    ResultSet rr = st.executeQuery("SELECT ur.usuario_id, GROUP_CONCAT(r.nombre SEPARATOR ', ') FROM usuario_rol ur JOIN roles r ON r.id=ur.rol_id GROUP BY ur.usuario_id");
    while (rr.next()) rolesMap.put(rr.getInt(1), rr.getString(2));
    rr.close(); st.close();
  } catch (Exception e) {}
  int npag = (int) Math.ceil(total / (double) porPag); if (npag < 1) npag = 1;
%>
<%@ include file="../../WEB-INF/jspf/header.jspf" %>
<div class="card"><h2><%= ICON("users") %> Gestión de usuarios (RF-ADM-01/02)</h2>
<form class="toolbar" method="get">
<input name="q" placeholder="Buscar ID, nombre, correo" value="<%= esc(q) %>">
<select name="frol"><option value="">Todos los roles</option>
<% for (String rn : new String[]{"administrador","comite","docente","estudiante"}) { %>
<option value="<%= rn %>" <%= rn.equals(frol)?"selected":"" %>><%= rn %></option><% } %></select>
<button class="btn green">Buscar</button></form>
<div class="tbl-tools">
  <form method="get">Mostrar
    <select name="npp" onchange="this.form.submit()"><% for (int n : new int[]{5,10,25}) { %><option value="<%=n%>" <%=n==porPag?"selected":""%>><%=n%></option><% } %></select>
    registros por página
    <input type="hidden" name="q" value="<%= esc(q) %>"><input type="hidden" name="frol" value="<%= frol %>">
  </form>
  <span>Buscar por ID, nombre, correo y rol</span>
</div>
<table class="tbl"><tr><th>ID</th><th>Documento</th><th>Nombre</th><th>Correo</th><th>Roles</th><th>Estado</th><th>Acciones</th></tr>
<% for (String[] u : rows) {
     String rl = rolesMap.get(Integer.parseInt(u[0])); if (rl == null) rl = "—"; %>
<tr><td><%= u[0] %></td><td><%= esc(u[1]) %></td><td><%= esc(u[2]+" "+u[3]) %></td><td><%= esc(u[4]) %></td>
<td><span class="chip azul"><%= esc(rl) %></span></td>
<td><span class="chip <%= "1".equals(u[6])?"verde":"rojo" %>"><%= "1".equals(u[6])?"Activo":"Inactivo" %></span></td>
<td><a class="btn sm" href="usuarios.jsp?acc=toggle&id=<%= u[0] %>" onclick="return confirma('¿Activar/desactivar usuario?')">On/Off</a>
<a class="btn sm" href="#e<%= u[0] %>">Editar</a></td></tr>
<% } %></table>
<div class="pag"><span class="info">Mostrando la página <%= pag %> de <%= npag %></span><% for (int i=1;i<=npag;i++) { %><a class="<%= i==pag?"act":"" %>" href="usuarios.jsp?q=<%= esc(q) %>&frol=<%= frol %>&npp=<%= porPag %>&pag=<%= i %>"><%= i %></a><% } %></div>
</div>
<div class="card"><h3>➕ Crear usuario</h3>
<form method="post" action="usuarios.jsp?acc=crear"><div class="form-row">
<div><label>Documento*</label><input name="documento" required maxlength="20"></div>
<div><label>Nombres*</label><input name="nombres" required></div>
<div><label>Apellidos*</label><input name="apellidos" required></div>
<div><label>Email*</label><input name="email" type="email" required></div>
<div><label>Teléfono</label><input name="telefono" maxlength="20"></div>
<div><label>Contraseña*</label><input name="pass" type="password" required minlength="6"></div></div>
<label>Roles* (puede elegir varios)</label>
<label><input type="checkbox" name="roles" value="administrador" style="width:auto"> administrador</label>
<label><input type="checkbox" name="roles" value="comite" style="width:auto"> comité</label>
<label><input type="checkbox" name="roles" value="docente" style="width:auto"> docente</label>
<label><input type="checkbox" name="roles" value="estudiante" style="width:auto"> estudiante</label>
<br><button class="btn primary">Crear</button></form></div>
<% for (String[] u : rows) { %>
<div class="card" id="e<%= u[0] %>"><h3>Editar #<%= u[0] %> · <%= esc(u[2]+" "+u[3]) %></h3>
<form method="post" action="usuarios.jsp?acc=editar"><input type="hidden" name="id" value="<%= u[0] %>">
<div class="form-row"><div><label>Nombres</label><input name="nombres" value="<%= esc(u[2]) %>"></div>
<div><label>Apellidos</label><input name="apellidos" value="<%= esc(u[3]) %>"></div>
<div><label>Teléfono</label><input name="telefono" value="<%= esc(u[5]==null?"":u[5]) %>"></div>
<div><label>Nueva clave (vacío = no cambia)</label><input name="pass" type="password"></div></div>
<button class="btn green">Guardar</button></form>
<form method="post" action="usuarios.jsp?acc=roles" style="margin-top:8px"><input type="hidden" name="id" value="<%= u[0] %>">
<% String rl2 = rolesMap.get(Integer.parseInt(u[0])); if (rl2==null) rl2="";
   for (String rn : new String[]{"administrador","comite","docente","estudiante"}) { %>
<label style="display:inline;margin-right:10px"><input type="checkbox" name="roles" value="<%= rn %>" style="width:auto" <%= rl2.contains(rn)?"checked":"" %>> <%= rn %></label><% } %>
<button class="btn sm">Asignar roles</button></form></div>
<% } %>
<%@ include file="../../WEB-INF/jspf/footer.jspf" %>

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="../../WEB-INF/jspf/conexion.jspf" %>
<%@ include file="../../WEB-INF/jspf/guardAdministrador.jspf" %>
<%
  String acc = request.getParameter("acc");
  try (Connection c = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS)) {
    if ("crear".equals(acc)) {
      String url = request.getParameter("url");
      if (!esUrl(url)) { response.sendRedirect("formatos.jsp?er=La+URL+debe+iniciar+con+https://"); return; }
      PreparedStatement ps = c.prepareStatement("INSERT INTO formatos(codigo,nombre,url_plantilla,activo) VALUES(?,?,?,1)");
      ps.setString(1, request.getParameter("codigo")); ps.setString(2, request.getParameter("nombre")); ps.setString(3, url);
      ps.executeUpdate(); ps.close(); response.sendRedirect("formatos.jsp?ok=Formato+creado"); return;
    }
    if ("toggle".equals(acc)) {
      PreparedStatement ps = c.prepareStatement("UPDATE formatos SET activo=1-activo WHERE id=?");
      ps.setInt(1, Integer.parseInt(request.getParameter("id"))); ps.executeUpdate(); ps.close();
      response.sendRedirect("formatos.jsp?ok=Estado+actualizado"); return;
    }
    if ("editar".equals(acc)) {
      String url = request.getParameter("url");
      if (!esUrl(url)) { response.sendRedirect("formatos.jsp?er=La+URL+debe+iniciar+con+https://"); return; }
      PreparedStatement ps = c.prepareStatement("UPDATE formatos SET codigo=?,nombre=?,url_plantilla=? WHERE id=?");
      ps.setString(1, request.getParameter("codigo")); ps.setString(2, request.getParameter("nombre")); ps.setString(3, url);
      ps.setInt(4, Integer.parseInt(request.getParameter("id"))); ps.executeUpdate(); ps.close();
      response.sendRedirect("formatos.jsp?ok=Formato+actualizado"); return;
    }
  } catch (Exception e) { response.sendRedirect("formatos.jsp?er=" + java.net.URLEncoder.encode(e.getMessage(),"UTF-8")); return; }
  java.util.List<String[]> rows = new java.util.ArrayList<String[]>();
  try (Connection c = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS); Statement st = c.createStatement()) {
    ResultSet r = st.executeQuery("SELECT id,codigo,nombre,url_plantilla,activo FROM formatos ORDER BY codigo");
    while (r.next()) rows.add(new String[]{r.getString(1),r.getString(2),r.getString(3),r.getString(4),r.getString(5)});
    r.close();
  } catch (Exception e) {}
%>
<%@ include file="../../WEB-INF/jspf/header.jspf" %>
<div class="card"><h2><%= ICON("file") %> Formatos de grado (RF-ADM-04)</h2>
<table class="tbl"><tr><th>Código</th><th>Nombre</th><th>Plantilla (URL)</th><th>Estado</th><th>Acción</th></tr>
<% for (String[] f : rows) { %>
<tr><td><b><%= esc(f[1]) %></b></td><td><%= esc(f[2]) %></td><td><a class="lnk" target="_blank" href="<%= esc(f[3]) %>"><%= esc(f[3]) %></a></td>
<td><span class="chip <%= "1".equals(f[4])?"verde":"gris" %>"><%= "1".equals(f[4])?"Activo":"Inactivo" %></span></td>
<td><a class="btn sm" href="formatos.jsp?acc=toggle&id=<%= f[0] %>">On/Off</a></td></tr><% } %></table></div>
<div class="card"><h3>Agregar formato</h3>
<form method="post" action="formatos.jsp?acc=crear" onsubmit="return vUrl('urlF')"><div class="form-row">
<div><label>Código* (F-DC-124)</label><input name="codigo" required maxlength="20"></div>
<div><label>Nombre*</label><input name="nombre" required maxlength="150"></div>
<div><label>URL plantilla* (https)</label><input id="urlF" name="url" required placeholder="https://..."></div></div>
<br><button class="btn primary">Guardar</button></form></div>
<%@ include file="../../WEB-INF/jspf/footer.jspf" %>

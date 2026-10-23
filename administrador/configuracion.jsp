<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="../../WEB-INF/jspf/conexion.jspf" %>
<%@ include file="../../WEB-INF/jspf/guardAdministrador.jspf" %>
<%
  String acc = request.getParameter("acc");
  try (Connection c = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS)) {
    if ("crear".equals(acc)) {
      PreparedStatement ps = c.prepareStatement("INSERT INTO periodos(codigo,inicio_propuestas_banco,fin_propuestas_banco,inicio_nuevos_proyectos,fin_nuevos_proyectos,fin_aprobacion_propuesta,activo) VALUES(?,?,?,?,?,?,0)");
      ps.setString(1, request.getParameter("codigo")); ps.setString(2, request.getParameter("ipb")); ps.setString(3, request.getParameter("fpb"));
      ps.setString(4, request.getParameter("inp")); ps.setString(5, request.getParameter("fnp")); ps.setString(6, request.getParameter("fap"));
      ps.executeUpdate(); ps.close(); response.sendRedirect("configuracion.jsp?ok=Periodo+creado"); return;
    }
    if ("activar".equals(acc)) {
      Statement st = c.createStatement(); st.executeUpdate("UPDATE periodos SET activo=0"); st.close();
      PreparedStatement ps = c.prepareStatement("UPDATE periodos SET activo=1 WHERE id=?");
      ps.setInt(1, Integer.parseInt(request.getParameter("id"))); ps.executeUpdate(); ps.close();
      response.sendRedirect("configuracion.jsp?ok=Periodo+activado.+Solo+uno+activo+a+la+vez"); return;
    }
    if ("editar".equals(acc)) {
      PreparedStatement ps = c.prepareStatement("UPDATE periodos SET codigo=?,inicio_propuestas_banco=?,fin_propuestas_banco=?,inicio_nuevos_proyectos=?,fin_nuevos_proyectos=?,fin_aprobacion_propuesta=? WHERE id=?");
      ps.setString(1, request.getParameter("codigo")); ps.setString(2, request.getParameter("ipb")); ps.setString(3, request.getParameter("fpb"));
      ps.setString(4, request.getParameter("inp")); ps.setString(5, request.getParameter("fnp")); ps.setString(6, request.getParameter("fap"));
      ps.setInt(7, Integer.parseInt(request.getParameter("id"))); ps.executeUpdate(); ps.close();
      response.sendRedirect("configuracion.jsp?ok=Periodo+actualizado"); return;
    }
  } catch (Exception e) { response.sendRedirect("configuracion.jsp?er=" + java.net.URLEncoder.encode(e.getMessage(),"UTF-8")); return; }
  java.util.List<String[]> rows = new java.util.ArrayList<String[]>();
  try (Connection c = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS); Statement st = c.createStatement()) {
    ResultSet r = st.executeQuery("SELECT id,codigo,inicio_propuestas_banco,fin_propuestas_banco,inicio_nuevos_proyectos,fin_nuevos_proyectos,fin_aprobacion_propuesta,activo FROM periodos ORDER BY id DESC");
    while (r.next()) rows.add(new String[]{r.getString(1),r.getString(2),r.getString(3),r.getString(4),r.getString(5),r.getString(6),r.getString(7),r.getString(8)});
    r.close();
  } catch (Exception e) {}
%>
<%@ include file="../../WEB-INF/jspf/header.jspf" %>
<div class="card"><h2><%= ICON("calendar") %> Calendario académico · Periodos (RF-ADM-03)</h2>
<p><a class="btn sm green" href="backup.jsp"><%= ICON("download") %> Generar y descargar copia de seguridad (RF-ADM-05)</a></p>
<table class="tbl"><tr><th>Código</th><th>Banco ideas</th><th>Nuevos proyectos</th><th>Fin aprobación</th><th>Activo</th><th>Acciones</th></tr>
<% for (String[] p : rows) { %>
<tr><td><b><%= esc(p[1]) %></b></td><td><%= esc(p[2]) %> al <%= esc(p[3]) %></td><td><%= esc(p[4]) %> al <%= esc(p[5]) %></td><td><%= esc(p[6]) %></td>
<td><span class="chip <%= "1".equals(p[7])?"verde":"gris" %>"><%= "1".equals(p[7])?"Vigente":"—" %></span></td>
<td><a class="btn sm" href="configuracion.jsp?acc=activar&id=<%= p[0] %>" onclick="return confirma('¿Activar este periodo? Se desactiva el actual.')">Activar</a></td></tr><% } %></table></div>
<div class="card"><h3>Crear / editar periodo</h3>
<form method="post" action="configuracion.jsp?acc=crear"><div class="form-row">
<div><label>Código (ej. 2026-2)*</label><input name="codigo" required maxlength="10"></div>
<div><label>Inicio propuestas banco*</label><input name="ipb" type="date" required></div>
<div><label>Fin propuestas banco*</label><input name="fpb" type="date" required></div>
<div><label>Inicio nuevos proyectos*</label><input name="inp" type="date" required></div>
<div><label>Fin nuevos proyectos*</label><input name="fnp" type="date" required></div>
<div><label>Fin aprobación propuesta*</label><input name="fap" type="date" required></div></div>
<br><button class="btn primary">Guardar periodo</button></form></div>
<%@ include file="../../WEB-INF/jspf/footer.jspf" %>

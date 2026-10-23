<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="../../WEB-INF/jspf/conexion.jspf" %>
<%@ include file="../../WEB-INF/jspf/guardAdministrador.jspf" %>
<%
  String fest = request.getParameter("fest"); if (fest == null) fest = "";
  java.util.List<String[]> rows = new java.util.ArrayList<String[]>();
  try (Connection c = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS)) {
    String w = " WHERE pb.estado='Aprobada' ";
    PreparedStatement ps = c.prepareStatement("SELECT pb.id,pb.codigo,pb.titulo,pb.origen,pb.tipo_nivel,pb.estado,pb.disponible,CONCAT(u.nombres,' ',u.apellidos) FROM propuestas_banco pb JOIN usuarios u ON u.id=pb.proponente_id"+w+" ORDER BY pb.id DESC LIMIT 100");
    ResultSet r = ps.executeQuery();
    while (r.next()) rows.add(new String[]{r.getString(1),r.getString(2),r.getString(3),r.getString(4),r.getString(5),r.getString(6),r.getString(7),r.getString(8)});
    r.close(); ps.close();
  } catch (Exception e) {}
%>
<%@ include file="../../WEB-INF/jspf/header.jspf" %>
<div class="card"><h2><%= ICON("bulb") %> Banco de ideas · Aprobadas y disponibles (RF-ADM-10)</h2>
<table class="tbl"><tr><th>Código</th><th>Título</th><th>Proponente</th><th>Nivel</th><th>Disponible</th></tr>
<% for (String[] p : rows) { %>
<tr><td><b><%= esc(p[1]) %></b></td><td><%= esc(p[2]) %></td><td><%= esc(p[7]) %> (<%= esc(p[3]) %>)</td><td><%= esc(p[4]) %></td>
<td><span class="chip <%= "1".equals(p[6])?"verde":"gris" %>"><%= "1".equals(p[6])?"Sí":"Usada" %></span></td></tr><% } %></table></div>
<%@ include file="../../WEB-INF/jspf/footer.jspf" %>

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="../../WEB-INF/jspf/conexion.jspf" %>
<%@ include file="../../WEB-INF/jspf/guardComite.jspf" %>
<%
  int uid = (Integer) session.getAttribute("uid");
  String acc = request.getParameter("acc");
  String msg = "", msgOk = "";
  
  if (acc != null) {
    try (Connection c = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS)) {
      int id = Integer.parseInt(request.getParameter("id"));
      if ("aprobar".equals(acc)) {
        PreparedStatement ps = c.prepareStatement("UPDATE propuestas_banco SET estado='Aprobada', revisor_id=?, observacion_comite=?, fecha_revision=NOW(), disponible=1 WHERE id=?");
        ps.setInt(1, uid); ps.setString(2, request.getParameter("obs")); ps.setInt(3, id); ps.executeUpdate(); ps.close();
        msgOk = "Propuesta aprobada y disponible para estudiantes";
      }
      else if ("rechazar".equals(acc)) {
        PreparedStatement ps = c.prepareStatement("UPDATE propuestas_banco SET estado='Rechazada', revisor_id=?, observacion_comite=?, fecha_revision=NOW(), disponible=0 WHERE id=?");
        ps.setInt(1, uid); ps.setString(2, request.getParameter("obs")); ps.setInt(3, id); ps.executeUpdate(); ps.close();
        msgOk = "Propuesta rechazada";
      }
      else if ("eliminar".equals(acc)) {
        PreparedStatement ps = c.prepareStatement("DELETE FROM propuestas_banco WHERE id=?");
        ps.setInt(1, id); ps.executeUpdate(); ps.close();
        msgOk = "Propuesta eliminada permanentemente";
      }
      else if ("toggle_disp".equals(acc)) {
        PreparedStatement ps = c.prepareStatement("UPDATE propuestas_banco SET disponible=1-disponible WHERE id=?");
        ps.setInt(1, id); ps.executeUpdate(); ps.close();
        msgOk = "Disponibilidad actualizada";
      }
    } catch (Exception e) { msg = "Error: " + e.getMessage(); }
  }
  
  String fest = request.getParameter("fest"); if (fest == null) fest = "";
  java.util.List<String[]> rows = new java.util.ArrayList<String[]>();
  try (Connection c = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS)) {
    String w = "";
    if (!fest.isEmpty()) w = " WHERE pb.estado='" + fest.replace("'","") + "'";
    PreparedStatement ps = c.prepareStatement("SELECT pb.id, pb.codigo, pb.titulo, pb.origen, pb.tipo_nivel, pb.estado, pb.disponible, CONCAT(u.nombres,' ',u.apellidos), pb.fecha_propuesta FROM propuestas_banco pb JOIN usuarios u ON u.id=pb.proponente_id" + w + " ORDER BY pb.id DESC LIMIT 100");
    ResultSet r = ps.executeQuery();
    while (r.next()) rows.add(new String[]{r.getString(1),r.getString(2),r.getString(3),r.getString(4),r.getString(5),r.getString(6),r.getString(7),r.getString(8),r.getString(9)});
    r.close(); ps.close();
  } catch (Exception e) {}
%>
<%@ include file="../../WEB-INF/jspf/header.jspf" %>
<div class="card"><h2><%= ICON("file") %> Propuestas del banco - Gestión completa</h2>
<form class="toolbar" method="get"><select name="fest"><option value="">Todos los estados</option>
<% for (String e : new String[]{"Pendiente","Aprobada","Correcciones","Rechazada"}) { %><option <%= e.equals(fest)?"selected":"" %>><%= e %></option><% } %>
</select><button class="btn green">Filtrar</button></form>
<% if (!msg.isEmpty()) { %><div class="alert err"><%= esc(msg) %></div><% } %>
<% if (!msgOk.isEmpty()) { %><div class="alert ok"><%= esc(msgOk) %></div><% } %>
<table class="tbl"><tr><th>Código</th><th>Título / Proponente</th><th>Origen·Nivel</th><th>Estado</th><th>Disp.</th><th>Acciones</th></tr>
<% for (String[] p : rows) { %>
<tr><td><b><%= esc(p[1]) %></b></td><td><%= esc(p[2]) %><br><small><%= esc(p[7]) %> · <%= esc(p[8]) %></small></td>
<td><span class="chip gris"><%= esc(p[3]) %> · <%= esc(p[4]) %></span></td>
<td><span class="chip <%= "Aprobada".equals(p[5])?"verde":("Pendiente".equals(p[5])?"amarillo":"rojo") %>"><%= esc(p[5]) %></span></td>
<td><span class="chip <%= "1".equals(p[6])?"verde":"gris" %>"><%= "1".equals(p[6])?"Sí":"No" %></span></td>
<td>
  <a class="iconbtn" title="Ver detalle" href="#r<%= p[0] %>"><%= ICON("eye") %></a>
  <form method="post" style="display:inline" onsubmit="return confirm('¿Cambiar disponibilidad?')"><input type="hidden" name="acc" value="toggle_disp"><input type="hidden" name="id" value="<%= p[0] %>"><button class="iconbtn" type="submit" title="Toggle disponible"><%= ICON("check") %></button></form>
  <form method="post" style="display:inline" onsubmit="return confirm('¿Eliminar permanentemente?')"><input type="hidden" name="acc" value="eliminar"><input type="hidden" name="id" value="<%= p[0] %>"><button class="iconbtn" type="submit" title="Eliminar"><%= ICON("x") %></button></form>
</td></tr><% } %></table></div>
<% for (String[] p : rows) {
     String det="", obj="", desc="", lin="", mod="", obs="";
     try (Connection c = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS)) {
       PreparedStatement ps = c.prepareStatement("SELECT objetivo_general,descripcion,linea_investigacion,tipo_modalidad,observacion_comite FROM propuestas_banco WHERE id=?");
       ps.setInt(1, Integer.parseInt(p[0])); ResultSet r = ps.executeQuery(); if (r.next()){obj=r.getString(1);desc=r.getString(2);lin=r.getString(3);mod=r.getString(4);obs=r.getString(5);} r.close(); ps.close();
     } catch(Exception e){}
%>
<div class="card" id="r<%= p[0] %>"><h3><%= esc(p[1]) %> · <%= esc(p[2]) %></h3>
<p><b>Objetivo:</b> <%= esc(obj) %><br><b>Descripción:</b> <%= esc(desc==null?"—":desc) %><br>
<b>Línea:</b> <%= esc(lin) %> · <b>Modalidad:</b> <%= esc(mod) %> · <b>Observación:</b> <%= esc(obs==null?"—":obs) %></p>
<form method="post"><input type="hidden" name="id" value="<%= p[0] %>">
<label>Observación del comité</label><textarea name="obs" rows="2"></textarea>
<div class="toolbar">
<button class="btn green" name="acc" value="aprobar">✔ Aprobar (disponible para estudiantes)</button>
<button class="btn danger" name="acc" value="rechazar" onclick="return confirm('¿Rechazar?')">✖ Rechazar</button>
</div></form></div>
<% } %>
<%@ include file="../../WEB-INF/jspf/footer.jspf" %>
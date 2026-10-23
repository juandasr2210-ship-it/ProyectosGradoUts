<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="../../WEB-INF/jspf/conexion.jspf" %>
<%@ include file="../../WEB-INF/jspf/guardAdministrador.jspf" %>
<%
  // Revisar idea del banco: aprobar / correcciones / rechazar (RF-ADM-07/08/09)
  String acc = request.getParameter("acc");
  int uid = (Integer) session.getAttribute("uid");
  if (acc != null) {
    try (Connection c = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS)) {
      int id = Integer.parseInt(request.getParameter("id"));
      String obs = request.getParameter("obs"); if (obs == null) obs = "";
      if ("aprobar".equals(acc)) {
        // RF-ADM-09: si origen Estudiante exige SoportePago en proyecto? Para idea de estudiante se exige URL de pago al inscribir.
        // Aquí: si la idea es de estudiante, verificamos que exista propuesta con pago asociado: pedimos campo pago_url opcional.
        PreparedStatement v = c.prepareStatement("SELECT origen, proponente_id FROM propuestas_banco WHERE id=?");
        v.setInt(1, id); ResultSet rv = v.executeQuery(); String origen="Docente"; int prop=0;
        if (rv.next()) { origen = rv.getString(1); prop = rv.getInt(2); } rv.close(); v.close();
        String pago = request.getParameter("pago_url"); if (pago == null) pago = "";
        if ("Estudiante".equals(origen) && !esUrl(pago)) {
          response.sendRedirect("propuestas_banco.jsp?er=La+idea+de+estudiante+solo+se+aprueba+con+URL+de+comprobante+de+pago+https://"); return;
        }
        PreparedStatement ps = c.prepareStatement("UPDATE propuestas_banco SET estado='Aprobada', revisor_id=?, observacion_comite=?, fecha_revision=NOW() WHERE id=?");
        ps.setInt(1, uid); ps.setString(2, obs); ps.setInt(3, id); ps.executeUpdate(); ps.close();
        response.sendRedirect("propuestas_banco.jsp?ok=Idea+aprobada"); return;
      }
      if ("correcciones".equals(acc) || "rechazar".equals(acc)) {
        String est = "correcciones".equals(acc) ? "Correcciones" : "Rechazada";
        PreparedStatement ps = c.prepareStatement("UPDATE propuestas_banco SET estado=?, revisor_id=?, observacion_comite=?, fecha_revision=NOW() WHERE id=?");
        ps.setString(1, est); ps.setInt(2, uid); ps.setString(3, obs); ps.setInt(4, id); ps.executeUpdate(); ps.close();
        response.sendRedirect("propuestas_banco.jsp?ok=Idea+actualizada:+"+est); return;
      }
    } catch (Exception e) { response.sendRedirect("propuestas_banco.jsp?er=" + java.net.URLEncoder.encode(e.getMessage(),"UTF-8")); return; }
  }
  String fest = request.getParameter("fest"); if (fest == null) fest = "";
  int pag = 1; try { pag = Integer.parseInt(request.getParameter("pag")); } catch (Exception e) {}
  if (pag < 1) pag = 1;
  int npp = 5; try { npp = Integer.parseInt(request.getParameter("npp")); } catch (Exception e) {}
  if (npp != 5 && npp != 10 && npp != 25) npp = 5;
  int total = 0;
  java.util.List<String[]> rows = new java.util.ArrayList<String[]>();
  try (Connection c = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS)) {
    String w = "";
    if (!fest.isEmpty()) w = " WHERE pb.estado='" + fest.replace("'","") + "'";
    PreparedStatement pc = c.prepareStatement("SELECT COUNT(*) FROM propuestas_banco pb" + w);
    ResultSet rc = pc.executeQuery(); if (rc.next()) total = rc.getInt(1); rc.close(); pc.close();
    PreparedStatement ps = c.prepareStatement("SELECT pb.id,pb.codigo,pb.titulo,pb.origen,pb.tipo_nivel,pb.estado,pb.disponible,CONCAT(u.nombres,' ',u.apellidos),pb.fecha_propuesta FROM propuestas_banco pb JOIN usuarios u ON u.id=pb.proponente_id" + w + " ORDER BY pb.id DESC LIMIT ?,?");
    ps.setInt(1, (pag-1)*npp); ps.setInt(2, npp);
    ResultSet r = ps.executeQuery();
    while (r.next()) rows.add(new String[]{r.getString(1),r.getString(2),r.getString(3),r.getString(4),r.getString(5),r.getString(6),r.getString(7),r.getString(8),r.getString(9)});
    r.close(); ps.close();
  } catch (Exception e) {}
  int npag = (int) Math.ceil(total / (double) npp); if (npag < 1) npag = 1; if (pag > npag) pag = npag;
%>
<%@ include file="../../WEB-INF/jspf/header.jspf" %>
<div class="card"><h2><%= ICON("file") %> Propuestas del banco · Revisión (RF-ADM-07)</h2>
<form class="toolbar" method="get"><select name="fest"><option value="">Todos los estados</option>
<% for (String e : new String[]{"Pendiente","Aprobada","Correcciones","Rechazada"}) { %><option <%= e.equals(fest)?"selected":"" %>><%= e %></option><% } %>
</select><button class="btn green">Filtrar</button></form>
<div class="tbl-tools">
  <form method="get">Mostrar
    <select name="npp" onchange="this.form.submit()"><% for (int n : new int[]{5,10,25}) { %><option value="<%=n%>" <%=n==npp?"selected":""%>><%=n%></option><% } %></select>
    registros por página
    <input type="hidden" name="fest" value="<%= esc(fest) %>">
  </form>
  <form method="get"><input name="q" placeholder="Ingrese una clave." disabled><input type="hidden" name="fest" value="<%= esc(fest) %>"></form>
</div>
<table class="tbl"><tr><th>ID</th><th>Descripción</th><th>Estado</th><th>Acciones</th></tr>
<% for (String[] p : rows) { %>
<tr><td><b><%= esc(p[1]) %></b></td><td><%= esc(p[2]) %><br><small><%= esc(p[7]) %> · <%= esc(p[3]) %> · <%= esc(p[4]) %> · <%= esc(p[8]) %></small></td>
<td><span class="chip <%= "Aprobada".equals(p[5])?"verde":("Pendiente".equals(p[5])?"amarillo":"rojo") %>"><%= esc(p[5]) %></span></td>
<td><a class="iconbtn" href="#r<%= p[0] %>" title="Ver detalle"><%= ICON("eye") %></a></td></tr><% } %></table>
<div class="pag"><span class="info">Mostrando la página <%= pag %> de <%= npag %></span>
<a href="propuestas_banco.jsp?fest=<%= esc(fest) %>&npp=<%= npp %>&pag=1">«</a>
<% for (int i=1;i<=npag;i++) { %><a class="<%= i==pag?"act":"" %>" href="propuestas_banco.jsp?fest=<%= esc(fest) %>&npp=<%= npp %>&pag=<%= i %>"><%= i %></a><% } %>
<a href="propuestas_banco.jsp?fest=<%= esc(fest) %>&npp=<%= npp %>&pag=<%= npag %>">»</a></div></div>
<% for (String[] p : rows) {
     String det="", obj="", desc="", lin="", mod="", obs="";
     try (Connection c = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS)) {
       PreparedStatement ps = c.prepareStatement("SELECT objetivo_general,descripcion,linea_investigacion,tipo_modalidad,observacion_comite FROM propuestas_banco WHERE id=?");
       ps.setInt(1, Integer.parseInt(p[0])); ResultSet r = ps.executeQuery(); if (r.next()){obj=r.getString(1);desc=r.getString(2);lin=r.getString(3);mod=r.getString(4);obs=r.getString(5);} r.close(); ps.close();
     } catch(Exception e){}
%>
<div class="card" id="r<%= p[0] %>"><h3><%= esc(p[1]) %> · <%= esc(p[2]) %></h3>
<p><b>Objetivo:</b> <%= esc(obj) %><br><b>Descripción:</b> <%= esc(desc==null?"—":desc) %><br>
<b>Línea:</b> <%= esc(lin) %> · <b>Modalidad:</b> <%= esc(mod) %> · <b>Observación previa:</b> <%= esc(obs==null?"—":obs) %></p>
<form method="post" action="propuestas_banco.jsp">
<input type="hidden" name="id" value="<%= p[0] %>">
<label>Observación de la revisión</label><textarea name="obs" rows="2"></textarea>
<% if ("Estudiante".equals(p[3])) { %><label>URL comprobante de pago* (solo ideas de estudiante - RF-ADM-09)</label><input name="pago_url" placeholder="https://..."><% } %>
<br><div class="toolbar">
<button class="btn green" name="acc" value="aprobar" formaction="propuestas_banco.jsp?acc=aprobar"><%= ICON("check") %> Aprobar</button>
<button class="btn primary" name="acc" value="correcciones" formaction="propuestas_banco.jsp?acc=correcciones"><%= ICON("edit") %> Correcciones</button>
<button class="btn danger" name="acc" value="rechazar" formaction="propuestas_banco.jsp?acc=rechazar" onclick="return confirma('¿Rechazar idea?')"><%= ICON("x") %> Rechazar</button>
</div><p style="font-size:12px;color:#666">La idea de docente se aprueba sin comprobante (RF-ADM-08).</p></form></div>
<% } %>
<%@ include file="../../WEB-INF/jspf/footer.jspf" %>

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="../../WEB-INF/jspf/conexion.jspf" %>
<%@ include file="../../WEB-INF/jspf/guardComite.jspf" %>
<%
  String ff = request.getParameter("ff"); if (ff == null) ff = "";
  String fes = request.getParameter("fes"); if (fes == null) fes = "";
  String q = request.getParameter("q"); if (q == null) q = "";
  int pag = 1; try { pag = Integer.parseInt(request.getParameter("pag")); } catch (Exception e) {}
  if (pag < 1) pag = 1;
  int npp = 5; try { npp = Integer.parseInt(request.getParameter("npp")); } catch (Exception e) {}
  if (npp != 5 && npp != 10 && npp != 25) npp = 5;
  int total = 0;
  java.util.List<String[]> rows = new java.util.ArrayList<String[]>();
  try (Connection c = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS)) {
    String w = " WHERE (p.titulo LIKE ? OR p.codigo LIKE ?) ";
    if (!ff.isEmpty()) w += " AND p.fase=" + ff.replaceAll("[^0-9]","");
    if (!fes.isEmpty()) w += " AND p.estado='" + fes.replace("'","") + "'";
    PreparedStatement pc = c.prepareStatement("SELECT COUNT(*) FROM proyectos p" + w);
    pc.setString(1, "%"+q+"%"); pc.setString(2, "%"+q+"%");
    ResultSet rc = pc.executeQuery(); if (rc.next()) total = rc.getInt(1); rc.close(); pc.close();
    PreparedStatement ps = c.prepareStatement("SELECT p.id,p.codigo,p.titulo,p.fase,p.responsable,p.estado,p.codigo_modalidad FROM proyectos p"+w+" ORDER BY p.id DESC LIMIT ?,?");
    ps.setString(1,"%"+q+"%"); ps.setString(2,"%"+q+"%"); ps.setInt(3,(pag-1)*npp); ps.setInt(4,npp);
    ResultSet r = ps.executeQuery();
    while (r.next()) rows.add(new String[]{r.getString(1),r.getString(2),r.getString(3),r.getString(4),r.getString(5),r.getString(6),r.getString(7)});
    r.close(); ps.close();
  } catch (Exception e) {}
  int npag = (int) Math.ceil(total / (double) npp); if (npag < 1) npag = 1; if (pag > npag) pag = npag;
  String qs = "q=" + java.net.URLEncoder.encode(q,"UTF-8") + "&ff=" + ff + "&fes=" + fes + "&npp=" + npp;
%>
<%@ include file="../../WEB-INF/jspf/header.jspf" %>
<div class="card"><h2><%= ICON("folder") %> Proyectos · Comité</h2>
<p>Decide en fases 1, 3, 5 y 6. El icono de ojo muestra lo entregado y el lápiz permite responder a quien tiene el turno.</p>
<form class="toolbar" method="get">
<input name="q" placeholder="Buscar código/título" value="<%= esc(q) %>">
<select name="ff"><option value="">Todas las fases</option><% for(int i=1;i<=6;i++){ %><option value="<%=i%>" <%=String.valueOf(i).equals(ff)?"selected":""%>>Fase <%=i%></option><% } %></select>
<select name="fes"><option value="">Todos</option><% for(String s:new String[]{"En curso","Rechazado","Cancelado","Finalizado"}){ %><option <%=s.equals(fes)?"selected":""%>><%=s%></option><% } %></select>
<button class="btn green">Filtrar</button></form>
<div class="tbl-tools">
  <form method="get">Mostrar
    <select name="npp" onchange="this.form.submit()"><% for (int n : new int[]{5,10,25}) { %><option value="<%=n%>" <%=n==npp?"selected":""%>><%=n%></option><% } %></select>
    registros por página
    <input type="hidden" name="q" value="<%= esc(q) %>"><input type="hidden" name="ff" value="<%= ff %>"><input type="hidden" name="fes" value="<%= fes %>">
  </form>
  <form method="get"><input name="q" placeholder="Ingrese una clave." value="<%= esc(q) %>"><input type="hidden" name="ff" value="<%= ff %>"><input type="hidden" name="fes" value="<%= fes %>"><input type="hidden" name="npp" value="<%= npp %>"></form>
</div>
<table class="tbl"><tr><th>ID</th><th>Descripción</th><th>Estado</th><th>Acciones</th></tr>
<% for (String[] p : rows) { %>
<tr><td><b><%= esc(p[1]) %></b><br><small><%= esc(p[6]==null?"":p[6]) %> · Fase <%= p[3] %> · <%= esc(p[4]) %></small></td>
<td><%= esc(p[2]) %></td>
<td><span class="chip <%= "En curso".equals(p[5])?"amarillo":("Finalizado".equals(p[5])?"verde":"rojo") %>"><%= esc(p[5]) %></span></td>
<td><a class="iconbtn" title="Ver lo entregado" href="seguimiento.jsp?id=<%= p[0] %>"><%= ICON("eye") %></a>
<% if ("comite".equals(p[4]) && "En curso".equals(p[5])) { %> <a class="btn sm primary" title="Responder" href="seguimiento.jsp?id=<%= p[0] %>#responder"><%= ICON("edit") %></a><% } %></td></tr><% } %></table>
<div class="pag"><span class="info">Mostrando la página <%= pag %> de <%= npag %></span>
<a href="proyectos.jsp?<%= qs %>&pag=1">«</a><a href="proyectos.jsp?<%= qs %>&pag=<%= Math.max(1,pag-1) %>">‹</a>
<% for (int i=1;i<=npag;i++) { %><a class="<%= i==pag?"act":"" %>" href="proyectos.jsp?<%= qs %>&pag=<%= i %>"><%= i %></a><% } %>
<a href="proyectos.jsp?<%= qs %>&pag=<%= Math.min(npag,pag+1) %>">›</a><a href="proyectos.jsp?<%= qs %>&pag=<%= npag %>">»</a></div></div>
<%@ include file="../../WEB-INF/jspf/footer.jspf" %>

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="../../WEB-INF/jspf/conexion.jspf" %>
<%@ include file="../../WEB-INF/jspf/guardAdministrador.jspf" %>
<%
  String acc = request.getParameter("acc");
  int uid = (Integer) session.getAttribute("uid");
  if (acc != null) {
    try (Connection c = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS)) {
      if ("cancelar".equals(acc)) {
        PreparedStatement ps = c.prepareStatement("UPDATE proyectos SET estado='Cancelado' WHERE id=?");
        ps.setInt(1, Integer.parseInt(request.getParameter("id"))); ps.executeUpdate(); ps.close();
        PreparedStatement h = c.prepareStatement("INSERT INTO historial(proyecto_id,usuario_id,accion,fase,comentario) VALUES(?,?,'Proyecto cancelado',NULL,?)");
        h.setInt(1, Integer.parseInt(request.getParameter("id"))); h.setInt(2, uid); h.setString(3, request.getParameter("motivo")); h.executeUpdate(); h.close();
        response.sendRedirect("proyectos.jsp?ok=Proyecto+cancelado"); return;
      }
      if ("reasignar".equals(acc)) {
        int pid = Integer.parseInt(request.getParameter("id"));
        String d = request.getParameter("director"), e = request.getParameter("evaluador"), co = request.getParameter("codirector");
        if (d != null && d.equals(e)) { response.sendRedirect("proyectos.jsp?er=Director+y+evaluador+deben+ser+distintos"); return; }
        PreparedStatement ps = c.prepareStatement("UPDATE proyectos SET director_id=NULLIF(?,0), evaluador_id=NULLIF(?,0), codirector_id=NULLIF(?,0) WHERE id=?");
        ps.setString(1, (d==null||d.isEmpty())?null:d); ps.setString(2,(e==null||e.isEmpty())?null:e); ps.setString(3,(co==null||co.isEmpty())?null:co); ps.setInt(4,pid);
        // NULLIF con string: mejor manejo manual
        ps.close();
        PreparedStatement p2 = c.prepareStatement("UPDATE proyectos SET director_id=?, evaluador_id=?, codirector_id=? WHERE id=?");
        p2.setObject(1, (d==null||d.isEmpty())?null:Integer.parseInt(d));
        p2.setObject(2, (e==null||e.isEmpty())?null:Integer.parseInt(e));
        p2.setObject(3, (co==null||co.isEmpty())?null:Integer.parseInt(co));
        p2.setInt(4, pid); p2.executeUpdate(); p2.close();
        PreparedStatement h = c.prepareStatement("INSERT INTO historial(proyecto_id,usuario_id,accion,fase,comentario) VALUES(?,?,'Reasignacion de director/evaluador/codirector',NULL,?)");
        h.setInt(1,pid); h.setInt(2,uid); h.setString(3,"director="+d+" evaluador="+e+" codirector="+co); h.executeUpdate(); h.close();
        response.sendRedirect("proyectos.jsp?ok=Reasignacion+registrada+en+historial"); return;
      }
    } catch (Exception e) { response.sendRedirect("proyectos.jsp?er=" + java.net.URLEncoder.encode(e.getMessage(),"UTF-8")); return; }
  }
  String ff = request.getParameter("ff"); if (ff == null) ff = "";
  String fes = request.getParameter("fes"); if (fes == null) fes = "";
  String q = request.getParameter("q"); if (q == null) q = "";
  int pag=1; try{pag=Integer.parseInt(request.getParameter("pag"));}catch(Exception e){}
  int porPag=10;
  try { porPag = Integer.parseInt(request.getParameter("npp")); } catch (Exception e) {}
  if (porPag != 5 && porPag != 10 && porPag != 25) porPag = 10;
  int total=0;
  java.util.List<String[]> rows = new java.util.ArrayList<String[]>();
  String vid = request.getParameter("ver");
  String[] det = null; java.util.List<String[]> integ = new java.util.ArrayList<String[]>();
  java.util.List<String[]> docs = new java.util.ArrayList<String[]>();
  java.util.List<String[]> resp = new java.util.ArrayList<String[]>();
  try (Connection c = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS)) {
    String w = " WHERE (p.titulo LIKE ? OR p.codigo LIKE ? OR p.codigo_modalidad LIKE ?) ";
    if (!ff.isEmpty()) w += " AND p.fase=" + ff.replaceAll("[^0-9]","");
    if (!fes.isEmpty()) w += " AND p.estado='" + fes.replace("'","") + "'";
    PreparedStatement pc = c.prepareStatement("SELECT COUNT(*) FROM proyectos p" + w);
    pc.setString(1,"%"+q+"%"); pc.setString(2,"%"+q+"%"); pc.setString(3,"%"+q+"%");
    ResultSet rc = pc.executeQuery(); if (rc.next()) total = rc.getInt(1); rc.close(); pc.close();
    PreparedStatement ps = c.prepareStatement("SELECT p.id,p.codigo,p.titulo,p.fase,p.responsable,p.estado,p.codigo_modalidad,per.codigo FROM proyectos p JOIN periodos per ON per.id=p.periodo_id"+w+" ORDER BY p.id DESC LIMIT ?,?");
    ps.setString(1,"%"+q+"%"); ps.setString(2,"%"+q+"%"); ps.setString(3,"%"+q+"%"); ps.setInt(4,(pag-1)*porPag); ps.setInt(5,porPag);
    ResultSet r = ps.executeQuery();
    while (r.next()) rows.add(new String[]{r.getString(1),r.getString(2),r.getString(3),r.getString(4),r.getString(5),r.getString(6),r.getString(7),r.getString(8)});
    r.close(); ps.close();
    if (vid != null) {
      PreparedStatement pd = c.prepareStatement("SELECT p.id,p.codigo,p.titulo,p.objetivo_general,p.descripcion,p.tipo_idea,p.tipo_modalidad,p.tipo_nivel,p.linea_investigacion,p.fase,p.responsable,p.estado,p.codigo_modalidad,per.codigo,CONCAT(d.nombres,' ',d.apellidos),CONCAT(e.nombres,' ',e.apellidos),CONCAT(co.nombres,' ',co.apellidos) FROM proyectos p JOIN periodos per ON per.id=p.periodo_id LEFT JOIN usuarios d ON d.id=p.director_id LEFT JOIN usuarios e ON e.id=p.evaluador_id LEFT JOIN usuarios co ON co.id=p.codirector_id WHERE p.id=?");
      pd.setInt(1, Integer.parseInt(vid)); ResultSet rd = pd.executeQuery();
      if (rd.next()) { det = new String[17]; for (int i=0;i<17;i++) det[i]=rd.getString(i+1); }
      rd.close(); pd.close();
      PreparedStatement pi = c.prepareStatement("SELECT u.documento,CONCAT(u.nombres,' ',u.apellidos),u.email,u.telefono,pi.es_responsable FROM proyecto_integrantes pi JOIN usuarios u ON u.id=pi.usuario_id WHERE pi.proyecto_id=?");
      pi.setInt(1, Integer.parseInt(vid)); ResultSet ri = pi.executeQuery();
      while (ri.next()) integ.add(new String[]{ri.getString(1),ri.getString(2),ri.getString(3),ri.getString(4),ri.getString(5)});
      ri.close(); pi.close();
      PreparedStatement pdo = c.prepareStatement("SELECT fase,tipo,version,url,fecha_subida FROM documentos WHERE proyecto_id=? ORDER BY fase,version DESC LIMIT 30");
      pdo.setInt(1, Integer.parseInt(vid)); ResultSet rdo = pdo.executeQuery();
      while (rdo.next()) docs.add(new String[]{rdo.getString(1),rdo.getString(2),rdo.getString(3),rdo.getString(4),rdo.getString(5)});
      rdo.close(); pdo.close();
      PreparedStatement pr2 = c.prepareStatement("SELECT fase,ronda,rol,estado,acta_numero,comentario,fecha FROM respuestas WHERE proyecto_id=? ORDER BY id DESC LIMIT 20");
      pr2.setInt(1, Integer.parseInt(vid)); ResultSet rr2 = pr2.executeQuery();
      while (rr2.next()) resp.add(new String[]{rr2.getString(1),rr2.getString(2),rr2.getString(3),rr2.getString(4),rr2.getString(5),rr2.getString(6),rr2.getString(7)});
      rr2.close(); pr2.close();
    }
  } catch (Exception e) {}
  int npag = (int)Math.ceil(total/(double)porPag); if (npag<1) npag=1;
%>
<%@ include file="../../WEB-INF/jspf/header.jspf" %>
<div class="card"><h2><%= ICON("folder") %> Proyectos (RF-ADM-06) · filtros por fase, estado y periodo</h2>
<form class="toolbar" method="get">
<input name="q" placeholder="Buscar código/título" value="<%= esc(q) %>">
<select name="ff"><option value="">Todas las fases</option><% for(int i=1;i<=6;i++){ %><option value="<%=i%>" <%= String.valueOf(i).equals(ff)?"selected":"" %>>Fase <%=i%></option><% } %></select>
<select name="fes"><option value="">Todos los estados</option><% for(String s:new String[]{"En curso","Rechazado","Cancelado","Finalizado"}){ %><option <%= s.equals(fes)?"selected":"" %>><%=s%></option><% } %></select>
<button class="btn green">Filtrar</button></form>
<div class="tbl-tools">
  <form method="get">Mostrar
    <select name="npp" onchange="this.form.submit()"><% for (int n : new int[]{5,10,25}) { %><option value="<%=n%>" <%=n==porPag?"selected":""%>><%=n%></option><% } %></select>
    registros por página
    <input type="hidden" name="q" value="<%= esc(q) %>"><input type="hidden" name="ff" value="<%= ff %>"><input type="hidden" name="fes" value="<%= fes %>">
  </form>
</div>
<table class="tbl"><tr><th>Código</th><th>Título</th><th>Fase · Turno</th><th>Estado</th><th>Modalidad</th><th>Acción</th></tr>
<% for (String[] p : rows) { %>
<tr><td><b><%= esc(p[1]) %></b><br><small><%= esc(p[7]) %></small></td><td><%= esc(p[2]) %></td>
<td><span class="chip azul">Fase <%= p[3] %></span> <span class="chip amarillo"><%= esc(p[4]) %></span></td>
<td><span class="chip <%= "En curso".equals(p[5])?"verde":("Finalizado".equals(p[5])?"azul":"rojo") %>"><%= esc(p[5]) %></span></td>
<td><%= esc(p[6]==null?"—":p[6]) %></td>
<td><a class="iconbtn" href="proyectos.jsp?ver=<%= p[0] %>&q=<%= esc(q) %>" title="Ver detalle"><%= ICON("eye") %></a></td></tr><% } %></table>
<div class="pag"><span class="info">Mostrando la página <%=pag%> de <%=npag%></span><% for(int i=1;i<=npag;i++){ %><a class="<%=i==pag?"act":""%>" href="proyectos.jsp?pag=<%=i%>&q=<%=esc(q)%>&ff=<%=ff%>&fes=<%=fes%>&npp=<%=porPag%>"><%=i%></a><% } %></div></div>
<% if (det != null) { %>
<div class="card"><h3>Detalle <%= esc(det[1]) %> · <%= esc(det[2]) %></h3>
<p><b>Objetivo:</b> <%= esc(det[3]) %> · <b>Nivel:</b> <%= esc(det[7]) %> · <b>Modalidad:</b> <%= esc(det[6]) %> · <b>Periodo:</b> <%= esc(det[13]) %><br>
<b>Director:</b> <%= esc(det[14]==null?"—":det[14]) %> · <b>Evaluador:</b> <%= esc(det[15]==null?"—":det[15]) %> · <b>Codirector:</b> <%= esc(det[16]==null?"—":det[16]) %></p>
<h4>Integrantes (documento, correo, teléfono - RF-GEN-12)</h4>
<table class="tbl"><tr><th>Documento</th><th>Nombre</th><th>Correo</th><th>Teléfono</th></tr>
<% for (String[] g: integ){ %><tr><td><%= esc(g[0]) %></td><td><%= esc(g[1]) %></td><td><%= esc(g[2]) %></td><td><%= esc(g[3]==null?"—":g[3]) %></td></tr><% } %></table>
<h4>Documentos y versiones</h4>
<table class="tbl"><tr><th>Fase</th><th>Tipo</th><th>V</th><th>URL</th></tr>
<% for (String[] d: docs){ %><tr><td><%= d[0] %></td><td><%= esc(d[1]) %></td><td><%= d[2] %></td><td><a class="lnk" target="_blank" href="<%= esc(d[3]) %>"><%= esc(d[3]) %></a></td></tr><% } %></table>
<h4>Decisiones</h4>
<table class="tbl"><tr><th>Fase</th><th>Ronda</th><th>Rol</th><th>Estado</th><th>Acta</th><th>Comentario</th></tr>
<% for (String[] s: resp){ %><tr><td><%= s[0] %></td><td><%= s[1] %></td><td><%= esc(s[2]) %></td><td><%= esc(s[3]) %></td><td><%= esc(s[4]==null?"—":s[4]) %></td><td><%= esc(s[5]==null?"":s[5]) %></td></tr><% } %></table>
<h4>Cancelar proyecto con motivo (RF-ADM-06)</h4>
<form method="post" action="proyectos.jsp?acc=cancelar"><input type="hidden" name="id" value="<%= det[0] %>">
<label>Motivo</label><input name="motivo" required><br><br><button class="btn danger" onclick="return confirma('¿Cancelar proyecto?')">Cancelar proyecto</button></form>
<h4>Reasignar director / evaluador / codirector (RF-ADM-11)</h4>
<form method="post" action="proyectos.jsp?acc=reasignar"><input type="hidden" name="id" value="<%= det[0] %>">
<div class="form-row"><div><label>ID director</label><input name="director" placeholder="id usuario docente"></div>
<div><label>ID evaluador</label><input name="evaluador" placeholder="id usuario docente"></div>
<div><label>ID codirector (opcional)</label><input name="codirector" placeholder="vacío = ninguno"></div></div>
<br><button class="btn green">Reasignar</button> <small>Ver IDs en Comité → Usuarios.</small></form>
</div><% } %>
<%@ include file="../../WEB-INF/jspf/footer.jspf" %>

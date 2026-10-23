<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="../../WEB-INF/jspf/conexion.jspf" %>
<%@ include file="../../WEB-INF/jspf/guardComite.jspf" %>
<%
  int uid = (Integer) session.getAttribute("uid");
  int pid = 0; try { pid = Integer.parseInt(request.getParameter("id")); } catch (Exception e) { response.sendRedirect("proyectos.jsp?er=Proyecto+invalido"); return; }

  // ---- PROCESAR RESPUESTA DEL COMITE ----
  if ("POST".equals(request.getMethod()) && request.getParameter("decidir") != null) {
    try (Connection c = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS)) {
      PreparedStatement pl = c.prepareStatement("SELECT fase,responsable,estado,tipo_nivel FROM proyectos WHERE id=?");
      pl.setInt(1, pid); ResultSet rl = pl.executeQuery();
      int fase = 0; String resp = "", est = "", niv = "";
      if (rl.next()) { fase = rl.getInt(1); resp = rl.getString(2); est = rl.getString(3); niv = rl.getString(4); }
      rl.close(); pl.close();
      if (!"comite".equals(resp) || !"En curso".equals(est)) { response.sendRedirect("seguimiento.jsp?id="+pid+"&er=El+turno+ya+no+es+del+comite"); return; }
      String estado = request.getParameter("estado");
      String acta = request.getParameter("acta"), fechaA = request.getParameter("acta_fecha"), com = request.getParameter("comentario");
      if (acta == null || acta.trim().isEmpty()) { response.sendRedirect("seguimiento.jsp?id="+pid+"&er=El+numero+de+acta+es+obligatorio"); return; }
      // ronda
      PreparedStatement pr = c.prepareStatement("SELECT COALESCE(MAX(ronda),0)+1 FROM respuestas WHERE proyecto_id=? AND fase=?");
      pr.setInt(1, pid); pr.setInt(2, fase); ResultSet rr = pr.executeQuery(); int ronda = 1; if (rr.next()) ronda = rr.getInt(1); rr.close(); pr.close();
      PreparedStatement pd = c.prepareStatement("SELECT id FROM documentos WHERE proyecto_id=? AND fase=? ORDER BY version DESC LIMIT 1");
      pd.setInt(1, pid); pd.setInt(2, fase); ResultSet rd = pd.executeQuery(); Integer docId = null; if (rd.next()) docId = rd.getInt(1); rd.close(); pd.close();

      PreparedStatement ins = c.prepareStatement("INSERT INTO respuestas(proyecto_id,fase,ronda,usuario_id,rol,estado,acta_numero,acta_fecha,comentario,documento_id) VALUES(?,?,?,?, 'comite',?,?,?,?,?)");
      ins.setInt(1, pid); ins.setInt(2, fase); ins.setInt(3, ronda); ins.setInt(4, uid); ins.setString(5, estado);
      ins.setString(6, acta); ins.setString(7, (fechaA==null||fechaA.isEmpty())?null:fechaA); ins.setString(8, com);
      if (docId == null) ins.setNull(9, java.sql.Types.INTEGER); else ins.setInt(9, docId);
      ins.executeUpdate(); ins.close();

      String sqlUpd = null;
      if (fase == 1) {
        if ("Aprobado".equals(estado)) {
          String d = request.getParameter("director"), e = request.getParameter("evaluador"), co = request.getParameter("codirector");
          if (d==null||d.isEmpty()||e==null||e.isEmpty()) { response.sendRedirect("seguimiento.jsp?id="+pid+"&er=Debe+asignar+director+y+evaluador"); return; }
          if (d.equals(e) || d.equals(co) || (co!=null&&!co.isEmpty()&&e.equals(co))) { response.sendRedirect("seguimiento.jsp?id="+pid+"&er=Director,+evaluador+y+codirector+deben+ser+distintos"); return; }
          String pref = "Tecnologico".equals(niv) ? "65" : "125";
          int anio = java.util.Calendar.getInstance().get(java.util.Calendar.YEAR);
          PreparedStatement pc = c.prepareStatement("SELECT COUNT(*)+1 FROM proyectos WHERE codigo_modalidad LIKE ?");
          pc.setString(1, pref + "-" + anio + "-%"); ResultSet rc2 = pc.executeQuery(); int cons = 1; if (rc2.next()) cons = rc2.getInt(1); rc2.close(); pc.close();
          String codMod = pref + "-" + anio + "-" + cons;
          PreparedStatement up = c.prepareStatement("UPDATE proyectos SET codigo_modalidad=?,director_id=?,evaluador_id=?,codirector_id=?,fase=2,responsable='estudiante' WHERE id=?");
          up.setString(1, codMod); up.setInt(2, Integer.parseInt(d)); up.setInt(3, Integer.parseInt(e));
          if (co==null||co.isEmpty()) up.setNull(4, java.sql.Types.INTEGER); else up.setInt(4, Integer.parseInt(co));
          up.setInt(5, pid); up.executeUpdate(); up.close();
        } else if ("Correcciones".equals(estado)) {
          PreparedStatement up = c.prepareStatement("UPDATE proyectos SET fase=1,responsable='estudiante' WHERE id=?");
          up.setInt(1, pid); up.executeUpdate(); up.close();
        } else {
          PreparedStatement up = c.prepareStatement("UPDATE proyectos SET estado='Rechazado' WHERE id=?");
          up.setInt(1, pid); up.executeUpdate(); up.close();
        }
      } else if (fase == 3) {
        if ("Aprobado".equals(estado)) {
          PreparedStatement up = c.prepareStatement("UPDATE proyectos SET fase=4,responsable='estudiante' WHERE id=?");
          up.setInt(1, pid); up.executeUpdate(); up.close();
        } else {
          PreparedStatement up = c.prepareStatement("UPDATE proyectos SET fase=2,responsable='estudiante' WHERE id=?");
          up.setInt(1, pid); up.executeUpdate(); up.close();
        }
      } else if (fase == 5) {
        if ("Aprobado".equals(estado)) {
          PreparedStatement up = c.prepareStatement("UPDATE proyectos SET fase=6,responsable='comite' WHERE id=?");
          up.setInt(1, pid); up.executeUpdate(); up.close();
        } else if ("Correcciones".equals(estado)) {
          PreparedStatement up = c.prepareStatement("UPDATE proyectos SET fase=4,responsable='estudiante' WHERE id=?");
          up.setInt(1, pid); up.executeUpdate(); up.close();
        } else {
          PreparedStatement up = c.prepareStatement("UPDATE proyectos SET estado='Rechazado' WHERE id=?");
          up.setInt(1, pid); up.executeUpdate(); up.close();
        }
      } else if (fase == 6) {
        // Cierre: registrar sustentacion y finalizar
        String fh = request.getParameter("fecha_hora"), lug = request.getParameter("lugar"), res = request.getParameter("resultado"), actaS = request.getParameter("acta_sus");
        if (fh==null||fh.isEmpty()||lug==null||lug.isEmpty()) { response.sendRedirect("seguimiento.jsp?id="+pid+"&er=Fecha+y+lugar+de+sustentacion+obligatorios"); return; }
        PreparedStatement su = c.prepareStatement("INSERT INTO sustentaciones(proyecto_id,fecha_hora,lugar_enlace,resultado,acta_numero,registrado_por) VALUES(?,?,?,?,?,?) ON DUPLICATE KEY UPDATE fecha_hora=VALUES(fecha_hora),lugar_enlace=VALUES(lugar_enlace),resultado=VALUES(resultado),acta_numero=VALUES(acta_numero)");
        su.setInt(1, pid); su.setString(2, fh.replace("T"," ")+":00"); su.setString(3, lug); su.setString(4, res); su.setString(5, actaS); su.setInt(6, uid);
        su.executeUpdate(); su.close();
        if ("Finalizar".equals(request.getParameter("decidir"))) {
          PreparedStatement up = c.prepareStatement("UPDATE proyectos SET estado='Finalizado' WHERE id=?");
          up.setInt(1, pid); up.executeUpdate(); up.close();
        }
      }
      PreparedStatement h = c.prepareStatement("INSERT INTO historial(proyecto_id,usuario_id,accion,fase,acta_numero,comentario) VALUES(?,?,'Decision comite: ' ,?,?,?)");
      // accion concat en SQL simple: usamos texto
      h.close();
      PreparedStatement h2 = c.prepareStatement("INSERT INTO historial(proyecto_id,usuario_id,accion,fase,acta_numero,comentario) VALUES(?,?,?,?,?,?)");
      h2.setInt(1, pid); h2.setInt(2, uid); h2.setString(3, "Decision comite fase " + fase + ": " + estado);
      h2.setInt(4, fase); h2.setString(5, acta); h2.setString(6, com); h2.executeUpdate(); h2.close();
      response.sendRedirect("seguimiento.jsp?id="+pid+"&ok=Respuesta+enviada+correctamente"); return;
    } catch (Exception e) { response.sendRedirect("seguimiento.jsp?id="+pid+"&er=" + java.net.URLEncoder.encode(e.getMessage(),"UTF-8")); return; }
  }

  // ---- CARGAR DETALLE ----
  String[] p = null; java.util.List<String[]> integ = new java.util.ArrayList<String[]>();
  java.util.List<String[]> docs = new java.util.ArrayList<String[]>();
  java.util.List<String[]> resp2 = new java.util.ArrayList<String[]>();
  java.util.List<String[]> docentes = new java.util.ArrayList<String[]>();
  try (Connection c = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS)) {
    PreparedStatement ps = c.prepareStatement("SELECT p.id,p.codigo,p.titulo,p.objetivo_general,p.descripcion,p.tipo_idea,p.tipo_modalidad,p.tipo_nivel,p.linea_investigacion,p.fase,p.responsable,p.estado,p.codigo_modalidad,per.codigo,CONCAT(d.nombres,' ',d.apellidos),CONCAT(e.nombres,' ',e.apellidos),CONCAT(co.nombres,' ',co.apellidos) FROM proyectos p JOIN periodos per ON per.id=p.periodo_id LEFT JOIN usuarios d ON d.id=p.director_id LEFT JOIN usuarios e ON e.id=p.evaluador_id LEFT JOIN usuarios co ON co.id=p.codirector_id WHERE p.id=?");
    ps.setInt(1, pid); ResultSet r = ps.executeQuery();
    if (r.next()) { p = new String[17]; for (int i=0;i<17;i++) p[i]=r.getString(i+1); }
    r.close(); ps.close();
    if (p == null) { response.sendRedirect("proyectos.jsp?er=Proyecto+no+existe"); return; }
    PreparedStatement pi = c.prepareStatement("SELECT u.documento,CONCAT(u.nombres,' ',u.apellidos),u.email,u.telefono FROM proyecto_integrantes x JOIN usuarios u ON u.id=x.usuario_id WHERE x.proyecto_id=?");
    pi.setInt(1, pid); ResultSet ri = pi.executeQuery(); while (ri.next()) integ.add(new String[]{ri.getString(1),ri.getString(2),ri.getString(3),ri.getString(4)});
    ri.close(); pi.close();
    PreparedStatement pd = c.prepareStatement("SELECT fase,tipo,version,url,fecha_subida FROM documentos WHERE proyecto_id=? ORDER BY fase,version");
    pd.setInt(1, pid); ResultSet rd = pd.executeQuery(); while (rd.next()) docs.add(new String[]{rd.getString(1),rd.getString(2),rd.getString(3),rd.getString(4),rd.getString(5)});
    rd.close(); pd.close();
    PreparedStatement pr2 = c.prepareStatement("SELECT r.fase,r.ronda,r.rol,r.estado,r.acta_numero,r.acta_fecha,r.comentario,CONCAT(u.nombres,' ',u.apellidos),r.fecha FROM respuestas r JOIN usuarios u ON u.id=r.usuario_id WHERE r.proyecto_id=? ORDER BY r.id DESC");
    pr2.setInt(1, pid); ResultSet rr2 = pr2.executeQuery(); while (rr2.next()) resp2.add(new String[]{rr2.getString(1),rr2.getString(2),rr2.getString(3),rr2.getString(4),rr2.getString(5),rr2.getString(6),rr2.getString(7),rr2.getString(8),rr2.getString(9)});
    rr2.close(); pr2.close();
    Statement st = c.createStatement();
    ResultSet rd2 = st.executeQuery("SELECT u.id, CONCAT(u.nombres,' ',u.apellidos) FROM usuarios u JOIN usuario_rol ur ON ur.usuario_id=u.id JOIN roles r ON r.id=ur.rol_id WHERE r.nombre='docente' AND u.activo=1 ORDER BY u.apellidos");
    while (rd2.next()) docentes.add(new String[]{rd2.getString(1), rd2.getString(2)});
    rd2.close(); st.close();
  } catch (Exception e) { response.sendRedirect("proyectos.jsp?er=" + e.getMessage()); return; }
  int faseA = Integer.parseInt(p[9]);
  String turno = p[10];
  String[] nombres = {"","1. Idea y pago","2. Propuesta I","3. Propuesta II","4. Informe I","5. Informe II","6. Cierre"};
%>
<%@ include file="../../WEB-INF/jspf/header.jspf" %>
<div class="card"><h2><%= ICON("search") %> Seguimiento · <%= esc(p[1]) %> · <%= esc(p[2]) %></h2>
<p><span class="chip azul">Fase <%= faseA %></span> <span class="chip amarillo"><%= esc(turno) %></span>
<span class="chip verde"><%= esc(p[11]) %></span> · Modalidad: <b><%= esc(p[12]==null?"(se genera al aprobar Fase 1)":p[12]) %></b> · Periodo <%= esc(p[13]) %></p>
<div class="fases"><% for(int i=1;i<=6;i++){ %><div class="fase <%= i<=faseA?"done":"" %> <%= i==faseA?"now":"" %>">F<%=i%><br><small><%= nombres[i] %></small></div><% } %></div>
<p><b>Título:</b> <%= esc(p[2]) %> · <b>Nivel:</b> <%= esc(p[7]) %> · <b>Modalidad:</b> <%= esc(p[6]) %><br>
<b>Director:</b> <%= esc(p[14]==null?"—":p[14]) %> · <b>Evaluador:</b> <%= esc(p[15]==null?"—":p[15]) %> · <b>Codirector:</b> <%= esc(p[16]==null?"—":p[16]) %></p>
<h4>Integrantes</h4><table class="tbl"><tr><th>Documento</th><th>Nombre</th><th>Correo</th><th>Teléfono</th></tr>
<% for(String[] g:integ){ %><tr><td><%=esc(g[0])%></td><td><%=esc(g[1])%></td><td><%=esc(g[2])%></td><td><%=esc(g[3]==null?"—":g[3])%></td></tr><% } %></table>
<h4><%= ICON("eye") %> Lo entregado (documentos por URL)</h4><table class="tbl"><tr><th>Fase</th><th>Tipo</th><th>V</th><th>URL</th><th>Fecha</th></tr>
<% for(String[] d:docs){ %><tr><td><%=d[0]%></td><td><%=esc(d[1])%></td><td><%=d[2]%></td><td><a class="lnk" target="_blank" href="<%=esc(d[3])%>"><%=esc(d[3])%></a></td><td><%=d[4]%></td></tr><% } %></table>
<h4>Decisiones (responsable, fase, ronda, acta, comentarios - RF-GEN-07)</h4>
<table class="tbl"><tr><th>F</th><th>Ronda</th><th>Rol</th><th>Estado</th><th>Acta</th><th>Por</th><th>Comentario</th></tr>
<% for(String[] s:resp2){ %><tr><td><%=s[0]%></td><td><%=s[1]%></td><td><%=esc(s[2])%></td><td><%=esc(s[3])%></td><td><%=esc((s[4]==null?"":s[4])+" "+(s[5]==null?"":s[5]))%></td><td><%=esc(s[7])%></td><td><%=esc(s[6]==null?"":s[6])%></td></tr><% } %></table></div>

<% if ("comite".equals(turno) && "En curso".equals(p[11])) { %>
<div class="card" id="responder"><h3><%= ICON("edit") %> Responder como Comité · Fase <%= faseA %></h3>
<% if (faseA==1) { %>
<form method="post">
<label>Estado*</label><select id="estadoSel" name="estado" required><option>Aprobado</option><option>Correcciones</option><option>Rechazado</option></select>
<div class="form-row"><div><label>Número de acta*</label><input name="acta" required></div><div><label>Fecha de acta*</label><input name="acta_fecha" type="date" required></div></div>
<label>Comentarios</label><textarea name="comentario" rows="2"></textarea>
<div id="extraAprobado"><h4>Si aprueba (RF-COM-02): código + asignación</h4>
<p>Código de modalidad: <b><%= "Tecnologico".equals(p[7])?"65":"125" %>-año-consecutivo</b> (solo lectura, se genera solo).</p>
<div class="form-row"><div><label>Director* (docente)</label><select name="director"><option value="">—</option><% for(String[] d:docentes){ %><option value="<%=d[0]%>"><%=esc(d[1])%></option><% } %></select></div>
<div><label>Evaluador* (docente distinto)</label><select name="evaluador"><option value="">—</option><% for(String[] d:docentes){ %><option value="<%=d[0]%>"><%=esc(d[1])%></option><% } %></select></div>
<div><label>Codirector (opcional)</label><select name="codirector"><option value="">— ninguno —</option><% for(String[] d:docentes){ %><option value="<%=d[0]%>"><%=esc(d[1])%></option><% } %></select></div></div></div>
<br><button class="btn primary" name="decidir" value="1">Enviar respuesta</button></form>
<% } else if (faseA==3) { %>
<form method="post"><label>Estado*</label><select name="estado"><option>Aprobado</option><option>Correcciones</option></select>
<div class="form-row"><div><label>Acta*</label><input name="acta" required></div><div><label>Fecha*</label><input name="acta_fecha" type="date" required></div></div>
<label>Comentarios</label><textarea name="comentario" rows="2"></textarea><br><button class="btn primary" name="decidir" value="1">Enviar respuesta</button></form>
<% } else if (faseA==5) { %>
<form method="post"><label>Estado*</label><select name="estado"><option>Aprobado</option><option>Correcciones</option><option>Rechazado</option></select>
<div class="form-row"><div><label>Acta*</label><input name="acta" required></div><div><label>Fecha*</label><input name="acta_fecha" type="date" required></div></div>
<label>Comentarios</label><textarea name="comentario" rows="2"></textarea><br><button class="btn primary" name="decidir" value="1">Enviar respuesta</button></form>
<% } else if (faseA==6) { %>
<form method="post"><label>Estado*</label><select name="estado"><option>Aprobado</option></select>
<div class="form-row"><div><label>Acta*</label><input name="acta" required></div><div><label>Fecha acta*</label><input name="acta_fecha" type="date" required></div></div>
<h4>Lista de verificación + sustentación (RF-COM-06)</h4>
<div class="form-row"><div><label>Fecha y hora sustentación*</label><input name="fecha_hora" type="datetime-local" required></div>
<div><label>Lugar o enlace*</label><input name="lugar" required placeholder="Auditorio / https://..."></div>
<div><label>Resultado</label><select name="resultado"><option>Aprobado</option><option>Aplazado</option><option>Rechazado</option></select></div>
<div><label>Acta sustentación</label><input name="acta_sus"></div></div>
<label>Comentarios</label><textarea name="comentario" rows="2"></textarea><br>
<button class="btn primary" name="decidir" value="Finalizar">Verificar y Finalizar proyecto</button></form>
<% } else { %><p>Esta fase la responden director/evaluador/estudiante.</p><% } %>
</div><% } %>
<%@ include file="../../WEB-INF/jspf/footer.jspf" %>

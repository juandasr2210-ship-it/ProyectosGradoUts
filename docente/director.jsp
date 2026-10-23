<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="../../WEB-INF/jspf/conexion.jspf" %>
<%@ include file="../../WEB-INF/jspf/guardDocente.jspf" %>
<%
  int uid=(Integer)session.getAttribute("uid");
  if("POST".equals(request.getMethod())&&request.getParameter("decidir")!=null){
    try(Connection c=DriverManager.getConnection(DB_URL,DB_USER,DB_PASS)){
      int pid=Integer.parseInt(request.getParameter("pid"));
      PreparedStatement pl=c.prepareStatement("SELECT fase,responsable,estado,director_id FROM proyectos WHERE id=?");
      pl.setInt(1,pid); ResultSet rl=pl.executeQuery();
      int fase=0; String resp=""; String est=""; int dir=0;
      if(rl.next()){fase=rl.getInt(1);resp=rl.getString(2);est=rl.getString(3);dir=rl.getInt(4);}
      rl.close();pl.close();
      if(dir!=uid||!"director".equals(resp)||!"En curso".equals(est)){response.sendRedirect("director.jsp?er=No+tiene+el+turno+de+director");return;}
      String estado=request.getParameter("estado"), tur=request.getParameter("turnitin"), com=request.getParameter("comentario");
      if(tur!=null&&!tur.isEmpty()&&!esUrl(tur)){response.sendRedirect("director.jsp?er=Turnitin+debe+ser+URL+https");return;}
      String tipo=(fase==2)?"Turnitin_FDC124":"Turnitin_FDC125";
      PreparedStatement pv=c.prepareStatement("SELECT COALESCE(MAX(version),0)+1 FROM documentos WHERE proyecto_id=? AND tipo=?");
      pv.setInt(1,pid);pv.setString(2,tipo);ResultSet rvn=pv.executeQuery();int ver=1;if(rvn.next())ver=rvn.getInt(1);rvn.close();pv.close();
      Integer docId=null;
      if(tur!=null&&!tur.isEmpty()){
        PreparedStatement di=c.prepareStatement("INSERT INTO documentos(proyecto_id,fase,tipo,version,url,subido_por) VALUES(?,?,?,?,?,?)",Statement.RETURN_GENERATED_KEYS);
        di.setInt(1,pid);di.setInt(2,fase);di.setString(3,tipo);di.setInt(4,ver);di.setString(5,tur);di.setInt(6,uid);
        di.executeUpdate();ResultSet k=di.getGeneratedKeys();if(k.next())docId=k.getInt(1);k.close();di.close();
      } else {
        PreparedStatement pd=c.prepareStatement("SELECT id FROM documentos WHERE proyecto_id=? AND fase=? ORDER BY version DESC LIMIT 1");
        pd.setInt(1,pid);pd.setInt(2,fase);ResultSet rd=pd.executeQuery();if(rd.next())docId=rd.getInt(1);rd.close();pd.close();
      }
      PreparedStatement pr=c.prepareStatement("SELECT COALESCE(MAX(ronda),0)+1 FROM respuestas WHERE proyecto_id=? AND fase=?");
      pr.setInt(1,pid);pr.setInt(2,fase);ResultSet rr=pr.executeQuery();int ronda=1;if(rr.next())ronda=rr.getInt(1);rr.close();pr.close();
      String estDB="Aprobado".equals(estado)?"Aprobado":("Rechazado".equals(estado)||"No aprobado".equals(estado)?"Rechazado":"Correcciones");
      PreparedStatement ins=c.prepareStatement("INSERT INTO respuestas(proyecto_id,fase,ronda,usuario_id,rol,estado,comentario,documento_id) VALUES(?,?,?,?,'director',?,?,?)");
      ins.setInt(1,pid);ins.setInt(2,fase);ins.setInt(3,ronda);ins.setInt(4,uid);ins.setString(5,estDB);ins.setString(6,com);
      if(docId==null)ins.setNull(7,java.sql.Types.INTEGER);else ins.setInt(7,docId);
      ins.executeUpdate();ins.close();
      if("Aprobado".equals(estado)){
        int nf=(fase==2)?3:5;
        PreparedStatement up=c.prepareStatement("UPDATE proyectos SET fase=?,responsable='evaluador' WHERE id=?");
        up.setInt(1,nf);up.setInt(2,pid);up.executeUpdate();up.close();
      } else if("Correcciones".equals(estado)){
        PreparedStatement up=c.prepareStatement("UPDATE proyectos SET responsable='estudiante' WHERE id=?");
        up.setInt(1,pid);up.executeUpdate();up.close();
      } else {
        PreparedStatement up=c.prepareStatement("UPDATE proyectos SET estado='Rechazado' WHERE id=?");
        up.setInt(1,pid);up.executeUpdate();up.close();
      }
      PreparedStatement h=c.prepareStatement("INSERT INTO historial(proyecto_id,usuario_id,accion,fase,comentario) VALUES(?,?,?,?,?)");
      h.setInt(1,pid);h.setInt(2,uid);h.setString(3,"Decision director fase "+fase+": "+estado);h.setInt(4,fase);h.setString(5,com);h.executeUpdate();h.close();
      response.sendRedirect("director.jsp?ok=Respuesta+enviada+correctamente");return;
    }catch(Exception e){response.sendRedirect("director.jsp?er="+java.net.URLEncoder.encode(e.getMessage(),"UTF-8"));return;}
  }
  java.util.List<String[]> rows=new java.util.ArrayList<String[]>();
  try(Connection c=DriverManager.getConnection(DB_URL,DB_USER,DB_PASS)){
    PreparedStatement ps=c.prepareStatement("SELECT p.id,p.codigo,p.titulo,p.fase,p.responsable,p.estado FROM proyectos p WHERE p.director_id=? ORDER BY p.id DESC");
    ps.setInt(1,uid);ResultSet r=ps.executeQuery();
    while(r.next())rows.add(new String[]{r.getString(1),r.getString(2),r.getString(3),r.getString(4),r.getString(5),r.getString(6)});
    r.close();ps.close();
  }catch(Exception e){}
%>
<%@ include file="../../WEB-INF/jspf/header.jspf" %>
<div class="card"><h2><%= ICON("user") %> Docente Director (RF-DIR-01..04)</h2>
<table class="tbl"><tr><th>Código</th><th>Título</th><th>Fase · Turno</th><th>Estado</th><th>Acción</th></tr>
<%for(String[]p:rows){%><tr><td><b><%=esc(p[1])%></b></td><td><%=esc(p[2])%></td>
<td><span class="chip azul">Fase <%=p[3]%></span> <span class="chip <%= "director".equals(p[4])?"amarillo":"gris" %>"><%=esc(p[4])%></span></td>
<td><%=esc(p[5])%></td><td><a class="iconbtn" href="#d<%=p[0]%>" title="Ver / responder"><%= ICON("eye") %></a></td></tr><%} %></table></div>
<%for(String[]p:rows){
  java.util.List<String[]> docs=new java.util.ArrayList<String[]>();
  try(Connection c=DriverManager.getConnection(DB_URL,DB_USER,DB_PASS)){
    PreparedStatement pd=c.prepareStatement("SELECT fase,tipo,version,url FROM documentos WHERE proyecto_id=? ORDER BY fase,version");
    pd.setInt(1,Integer.parseInt(p[0]));ResultSet rd=pd.executeQuery();while(rd.next())docs.add(new String[]{rd.getString(1),rd.getString(2),rd.getString(3),rd.getString(4)});rd.close();pd.close();
  }catch(Exception e){}
%>
<div class="card" id="d<%=p[0]%>"><h3><%=esc(p[1])%> · <%=esc(p[2])%></h3>
<p>Documentos del estudiante:</p>
<table class="tbl"><tr><th>F</th><th>Tipo</th><th>V</th><th>URL</th></tr>
<%for(String[]d:docs){%><tr><td><%=d[0]%></td><td><%=esc(d[1])%></td><td><%=d[2]%></td><td><a class="lnk" target="_blank" href="<%=esc(d[3])%>"><%=esc(d[3])%></a></td></tr><%} %></table>
<% if("director".equals(p[4])&&"En curso".equals(p[5])&&("2".equals(p[3])||"4".equals(p[3]))){ %>
<form method="post" onsubmit="return vUrl('tur<%=p[0]%>')">
<input type="hidden" name="pid" value="<%=p[0]%>">
<label>Estado* (Fase <%=p[3]%>)</label>
<select name="estado"><option>Aprobado</option><option>Correcciones</option><option value="Rechazado">No aprobado</option></select>
<label>URL informe Turnitin* (https)</label><input id="tur<%=p[0]%>" name="turnitin" placeholder="https://...">
<label>Comentarios</label><textarea name="comentario" rows="2"></textarea>
<br><button class="btn primary" name="decidir" value="1">Enviar respuesta</button>
<small>Al aprobar Fase 2 pasa automáticamente a Fase 3 (RF-DIR-03).</small></form>
<% } %></div><%} %>
<%@ include file="../../WEB-INF/jspf/footer.jspf" %>

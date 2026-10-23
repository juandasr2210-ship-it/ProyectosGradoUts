<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="../../WEB-INF/jspf/conexion.jspf" %>
<%@ include file="../../WEB-INF/jspf/guardDocente.jspf" %>
<%
  int uid=(Integer)session.getAttribute("uid");
  if("POST".equals(request.getMethod())&&request.getParameter("decidir")!=null){
    try(Connection c=DriverManager.getConnection(DB_URL,DB_USER,DB_PASS)){
      int pid=Integer.parseInt(request.getParameter("pid"));
      PreparedStatement pl=c.prepareStatement("SELECT fase,responsable,estado,evaluador_id FROM proyectos WHERE id=?");
      pl.setInt(1,pid); ResultSet rl=pl.executeQuery();
      int fase=0; String resp=""; String est=""; int ev=0;
      if(rl.next()){fase=rl.getInt(1);resp=rl.getString(2);est=rl.getString(3);ev=rl.getInt(4);}
      rl.close();pl.close();
      if(ev!=uid||!"evaluador".equals(resp)||!"En curso".equals(est)){response.sendRedirect("evaluador.jsp?er=No+tiene+el+turno+de+evaluador");return;}
      String estado=request.getParameter("estado"), com=request.getParameter("comentario");
      String u1=request.getParameter("url1"), acta=request.getParameter("acta"), fechaA=request.getParameter("acta_fecha"), u2=request.getParameter("url2");
      if(fase==3){
        if(!esUrl(u1)){response.sendRedirect("evaluador.jsp?er=La+propuesta+firmada+F-DC-124+debe+ser+URL+https");return;}
        PreparedStatement pv=c.prepareStatement("SELECT COALESCE(MAX(version),0)+1 FROM documentos WHERE proyecto_id=? AND tipo='Propuesta_FDC124_Firmada'");
        pv.setInt(1,pid);ResultSet rvn=pv.executeQuery();int ver=1;if(rvn.next())ver=rvn.getInt(1);rvn.close();pv.close();
        PreparedStatement di=c.prepareStatement("INSERT INTO documentos(proyecto_id,fase,tipo,version,url,subido_por) VALUES(?,3,'Propuesta_FDC124_Firmada',?,?,?)",Statement.RETURN_GENERATED_KEYS);
        di.setInt(1,pid);di.setInt(2,ver);di.setString(3,u1);di.setInt(4,uid);di.executeUpdate();
        ResultSet k=di.getGeneratedKeys();int docId=0;if(k.next())docId=k.getInt(1);k.close();di.close();
        PreparedStatement pr=c.prepareStatement("SELECT COALESCE(MAX(ronda),0)+1 FROM respuestas WHERE proyecto_id=? AND fase=3");
        pr.setInt(1,pid);ResultSet rr=pr.executeQuery();int ronda=1;if(rr.next())ronda=rr.getInt(1);rr.close();pr.close();
        String estDB="Aprobado".equals(estado)?"Aprobado":"Correcciones";
        PreparedStatement ins=c.prepareStatement("INSERT INTO respuestas(proyecto_id,fase,ronda,usuario_id,rol,estado,comentario,documento_id) VALUES(?,3,?,?, 'evaluador',?,?,?)");
        ins.setInt(1,pid);ins.setInt(2,ronda);ins.setInt(3,uid);ins.setString(4,estDB);ins.setString(5,com);ins.setInt(6,docId);ins.executeUpdate();ins.close();
        if("Aprobado".equals(estado)){
          PreparedStatement up=c.prepareStatement("UPDATE proyectos SET responsable='comite' WHERE id=?");
          up.setInt(1,pid);up.executeUpdate();up.close();
        } else {
          PreparedStatement up=c.prepareStatement("UPDATE proyectos SET fase=2,responsable='estudiante' WHERE id=?");
          up.setInt(1,pid);up.executeUpdate();up.close();
        }
      } else if(fase==5){
        if(!esUrl(u1)||!esUrl(u2)){response.sendRedirect("evaluador.jsp?er="+java.net.URLEncoder.encode("Informe F-DC-125 y rejilla F-DC-129 deben ser URL https","UTF-8"));return;}
        if(acta==null||acta.isEmpty()){response.sendRedirect("evaluador.jsp?er=El+acta+es+obligatoria");return;}
        for(String[]tt:new String[][]{{u1,"Informe_FDC125_Firmado"},{u2,"Rejilla_FDC129"}}){
          PreparedStatement pv=c.prepareStatement("SELECT COALESCE(MAX(version),0)+1 FROM documentos WHERE proyecto_id=? AND tipo=?");
          pv.setInt(1,pid);pv.setString(2,tt[1]);ResultSet rvn=pv.executeQuery();int ver=1;if(rvn.next())ver=rvn.getInt(1);rvn.close();pv.close();
          PreparedStatement di=c.prepareStatement("INSERT INTO documentos(proyecto_id,fase,tipo,version,url,subido_por) VALUES(?,5,?,?,?,?)");
          di.setInt(1,pid);di.setString(2,tt[1]);di.setInt(3,ver);di.setString(4,tt[0]);di.setInt(5,uid);di.executeUpdate();di.close();
        }
        PreparedStatement pd=c.prepareStatement("SELECT id FROM documentos WHERE proyecto_id=? AND tipo='Informe_FDC125_Firmado' ORDER BY version DESC LIMIT 1");
        pd.setInt(1,pid);ResultSet rd=pd.executeQuery();int docId=0;if(rd.next())docId=rd.getInt(1);rd.close();pd.close();
        PreparedStatement pr=c.prepareStatement("SELECT COALESCE(MAX(ronda),0)+1 FROM respuestas WHERE proyecto_id=? AND fase=5");
        pr.setInt(1,pid);ResultSet rr=pr.executeQuery();int ronda=1;if(rr.next())ronda=rr.getInt(1);rr.close();pr.close();
        String estDB="Aprobado".equals(estado)?"Aprobado":("Rechazado".equals(estado)?"Rechazado":"Correcciones");
        PreparedStatement ins=c.prepareStatement("INSERT INTO respuestas(proyecto_id,fase,ronda,usuario_id,rol,estado,acta_numero,acta_fecha,comentario,documento_id) VALUES(?,5,?,?, 'evaluador',?,?,?,?,?)");
        ins.setInt(1,pid);ins.setInt(2,ronda);ins.setInt(3,uid);ins.setString(4,estDB);ins.setString(5,acta);
        ins.setString(6,(fechaA==null||fechaA.isEmpty())?null:fechaA);ins.setString(7,com);ins.setInt(8,docId);ins.executeUpdate();ins.close();
        if("Aprobado".equals(estado)){
          PreparedStatement up=c.prepareStatement("UPDATE proyectos SET responsable='comite' WHERE id=?");
          up.setInt(1,pid);up.executeUpdate();up.close();
        } else {
          PreparedStatement up=c.prepareStatement("UPDATE proyectos SET fase=4,responsable='estudiante' WHERE id=?");
          up.setInt(1,pid);up.executeUpdate();up.close();
        }
      }
      PreparedStatement h=c.prepareStatement("INSERT INTO historial(proyecto_id,usuario_id,accion,fase,comentario) VALUES(?,?,?,?,?)");
      h.setInt(1,pid);h.setInt(2,uid);h.setString(3,"Decision evaluador: "+estado);h.setInt(4,fase);h.setString(5,com);h.executeUpdate();h.close();
      response.sendRedirect("evaluador.jsp?ok=Respuesta+enviada+correctamente");return;
    }catch(Exception e){response.sendRedirect("evaluador.jsp?er="+java.net.URLEncoder.encode(e.getMessage(),"UTF-8"));return;}
  }
  java.util.List<String[]> rows=new java.util.ArrayList<String[]>();
  try(Connection c=DriverManager.getConnection(DB_URL,DB_USER,DB_PASS)){
    PreparedStatement ps=c.prepareStatement("SELECT p.id,p.codigo,p.titulo,p.fase,p.responsable,p.estado FROM proyectos p WHERE p.evaluador_id=? ORDER BY p.id DESC");
    ps.setInt(1,uid);ResultSet r=ps.executeQuery();
    while(r.next())rows.add(new String[]{r.getString(1),r.getString(2),r.getString(3),r.getString(4),r.getString(5),r.getString(6)});
    r.close();ps.close();
  }catch(Exception e){}
%>
<%@ include file="../../WEB-INF/jspf/header.jspf" %>
<div class="card"><h2><%= ICON("search") %> Docente Evaluador (RF-EVA-01..04)</h2>
<table class="tbl"><tr><th>Código</th><th>Título</th><th>Fase · Turno</th><th>Estado</th><th>Acción</th></tr>
<%for(String[]p:rows){%><tr><td><b><%=esc(p[1])%></b></td><td><%=esc(p[2])%></td>
<td><span class="chip azul">Fase <%=p[3]%></span> <span class="chip <%= "evaluador".equals(p[4])?"amarillo":"gris" %>"><%=esc(p[4])%></span></td>
<td><%=esc(p[5])%></td><td><a class="iconbtn" href="#e<%=p[0]%>" title="Ver / responder"><%= ICON("eye") %></a></td></tr><%} %></table></div>
<%for(String[]p:rows){
  java.util.List<String[]> docs=new java.util.ArrayList<String[]>();
  try(Connection c=DriverManager.getConnection(DB_URL,DB_USER,DB_PASS)){
    PreparedStatement pd=c.prepareStatement("SELECT fase,tipo,version,url FROM documentos WHERE proyecto_id=? ORDER BY fase,version");
    pd.setInt(1,Integer.parseInt(p[0]));ResultSet rd=pd.executeQuery();while(rd.next())docs.add(new String[]{rd.getString(1),rd.getString(2),rd.getString(3),rd.getString(4)});rd.close();pd.close();
  }catch(Exception e){}
%>
<div class="card" id="e<%=p[0]%>"><h3><%=esc(p[1])%> · <%=esc(p[2])%></h3>
<table class="tbl"><tr><th>F</th><th>Tipo</th><th>V</th><th>URL</th></tr>
<%for(String[]d:docs){%><tr><td><%=d[0]%></td><td><%=esc(d[1])%></td><td><%=d[2]%></td><td><a class="lnk" target="_blank" href="<%=esc(d[3])%>"><%=esc(d[3])%></a></td></tr><%} %></table>
<% if("evaluador".equals(p[4])&&"En curso".equals(p[5])&&"3".equals(p[3])){ %>
<form method="post"><input type="hidden" name="pid" value="<%=p[0]%>">
<label>Estado* Fase 3</label><select name="estado"><option>Aprobado</option><option>Correcciones</option></select>
<label>URL propuesta firmada F-DC-124* (https)</label><input name="url1" required placeholder="https://...">
<label>Comentarios</label><textarea name="comentario" rows="2"></textarea><br>
<button class="btn primary" name="decidir" value="1">Enviar respuesta</button></form>
<% } if("evaluador".equals(p[4])&&"En curso".equals(p[5])&&"5".equals(p[3])){ %>
<form method="post"><input type="hidden" name="pid" value="<%=p[0]%>">
<label>Estado* Fase 5</label><select name="estado"><option>Aprobado</option><option>Correcciones</option><option>Rechazado</option></select>
<label>URL informe firmado F-DC-125* (https)</label><input name="url1" required placeholder="https://...">
<label>URL rejilla firmada F-DC-129* (https)</label><input name="url2" required placeholder="https://...">
<div class="form-row"><div><label>Acta*</label><input name="acta" required></div><div><label>Fecha acta</label><input name="acta_fecha" type="date"></div></div>
<label>Comentarios</label><textarea name="comentario" rows="2"></textarea><br>
<button class="btn primary" name="decidir" value="1">Enviar respuesta</button></form>
<% } %></div><%} %>
<%@ include file="../../WEB-INF/jspf/footer.jspf" %>

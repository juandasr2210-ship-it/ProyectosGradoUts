<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="../../WEB-INF/jspf/conexion.jspf" %>
<%@ include file="../../WEB-INF/jspf/guardEstudiante.jspf" %>
<%
  int uid=(Integer)session.getAttribute("uid");
  // Entregas del estudiante: pago / anteproyecto F2 / informe F4 (nueva versión cada vez - RF-GEN-06)
  if("POST".equals(request.getMethod())&&request.getParameter("entregar")!=null){
    try(Connection c=DriverManager.getConnection(DB_URL,DB_USER,DB_PASS)){
      int pid=Integer.parseInt(request.getParameter("pid"));
      PreparedStatement v=c.prepareStatement("SELECT COUNT(*) FROM proyecto_integrantes WHERE proyecto_id=? AND usuario_id=?");
      v.setInt(1,pid);v.setInt(2,uid);ResultSet rv=v.executeQuery();boolean mio=false;if(rv.next())mio=rv.getInt(1)>0;rv.close();v.close();
      if(!mio){response.sendRedirect("proyecto.jsp?er=No+pertenece+a+ese+proyecto");return;}
      PreparedStatement pl=c.prepareStatement("SELECT fase,responsable,estado FROM proyectos WHERE id=?");
      pl.setInt(1,pid);ResultSet rl=pl.executeQuery();int fase=0;String resp="",est="";
      if(rl.next()){fase=rl.getInt(1);resp=rl.getString(2);est=rl.getString(3);}rl.close();pl.close();
      if(!"estudiante".equals(resp)||!"En curso".equals(est)){response.sendRedirect("proyecto.jsp?er=No+es+su+turno+de+entrega");return;}
      String url=request.getParameter("url");
      if(!esUrl(url)){response.sendRedirect("proyecto.jsp?er=La+URL+debe+iniciar+con+https://");return;}
      String tipo="SoportePago";
      if(fase==2)tipo="Propuesta_FDC124"; else if(fase==4)tipo="Informe_FDC125";
      PreparedStatement pv2=c.prepareStatement("SELECT COALESCE(MAX(version),0)+1 FROM documentos WHERE proyecto_id=? AND tipo=?");
      pv2.setInt(1,pid);pv2.setString(2,tipo);ResultSet rn=pv2.executeQuery();int ver=1;if(rn.next())ver=rn.getInt(1);rn.close();pv2.close();
      PreparedStatement di=c.prepareStatement("INSERT INTO documentos(proyecto_id,fase,tipo,version,url,subido_por) VALUES(?,?,?,?,?,?)");
      di.setInt(1,pid);di.setInt(2,fase);di.setString(3,tipo);di.setInt(4,ver);di.setString(5,url);di.setInt(6,uid);di.executeUpdate();di.close();
      String nresp=(fase==1)?"comite":"director";
      PreparedStatement up=c.prepareStatement("UPDATE proyectos SET responsable=? WHERE id=?");
      up.setString(1,nresp);up.setInt(2,pid);up.executeUpdate();up.close();
      PreparedStatement h=c.prepareStatement("INSERT INTO historial(proyecto_id,usuario_id,accion,fase,comentario) VALUES(?,?,?,?,?)");
      h.setInt(1,pid);h.setInt(2,uid);h.setString(3,"Entrega estudiante "+tipo+" v"+ver);h.setInt(4,fase);h.setString(5,url);h.executeUpdate();h.close();
      response.sendRedirect("proyecto.jsp?ok=Entrega+registrada+(version+"+ver+").+Turno+de+"+nresp);return;
    }catch(Exception e){response.sendRedirect("proyecto.jsp?er="+java.net.URLEncoder.encode(e.getMessage(),"UTF-8"));return;}
  }
  String[] p=null; java.util.List<String[]> integ=new java.util.ArrayList<String[]>();
  java.util.List<String[]> coms=new java.util.ArrayList<String[]>();
  String dirN="—", codN="—";
  try(Connection c=DriverManager.getConnection(DB_URL,DB_USER,DB_PASS)){
    PreparedStatement ps=c.prepareStatement("SELECT p.id,p.codigo,p.titulo,p.fase,p.responsable,p.estado,p.codigo_modalidad,CONCAT(d.nombres,' ',d.apellidos),CONCAT(co.nombres,' ',co.apellidos),p.tipo_nivel,p.tipo_modalidad FROM proyectos p LEFT JOIN usuarios d ON d.id=p.director_id LEFT JOIN usuarios co ON co.id=p.codirector_id WHERE p.id=(SELECT x.proyecto_id FROM proyecto_integrantes x JOIN proyectos p2 ON p2.id=x.proyecto_id WHERE x.usuario_id=? ORDER BY p2.id DESC LIMIT 1)");
    ps.setInt(1,uid);ResultSet r=ps.executeQuery();
    if(r.next()){p=new String[11];for(int i=0;i<11;i++)p[i]=r.getString(i+1);dirN=p[7]==null?"(por asignar)":p[7];codN=p[8]==null?"—":p[8];}
    r.close();ps.close();
    if(p!=null){
      PreparedStatement pi=c.prepareStatement("SELECT CONCAT(u.nombres,' ',u.apellidos) FROM proyecto_integrantes x JOIN usuarios u ON u.id=x.usuario_id WHERE x.proyecto_id=?");
      pi.setInt(1,Integer.parseInt(p[0]));ResultSet ri=pi.executeQuery();while(ri.next())integ.add(new String[]{ri.getString(1)});ri.close();pi.close();
      PreparedStatement pc=c.prepareStatement("SELECT r.fase,r.estado,r.comentario,CONCAT(u.nombres,' ',u.apellidos),r.fecha FROM respuestas r JOIN usuarios u ON u.id=r.usuario_id WHERE r.proyecto_id=? ORDER BY r.id DESC LIMIT 15");
      pc.setInt(1,Integer.parseInt(p[0]));ResultSet rc=pc.executeQuery();while(rc.next())coms.add(new String[]{rc.getString(1),rc.getString(2),rc.getString(3),rc.getString(4),rc.getString(5)});rc.close();pc.close();
    }
  }catch(Exception e){}
%>
<%@ include file="../../WEB-INF/jspf/header.jspf" %>
<% if(p==null){ %><div class="card"><h2><%= ICON("folder") %> Mi proyecto</h2><p>Aún no tiene proyecto. <a class="btn primary" href="banco.jsp">Ir al banco de ideas →</a></p></div>
<% } else {
  int f=Integer.parseInt(p[3]); String[] nn={"","1. Idea y pago","2. Propuesta I","3. Propuesta II","4. Informe I","5. Informe II","6. Cierre"};
%>
<div class="card"><h2><%= ICON("folder") %> <%=esc(p[1])%> · <%=esc(p[2])%></h2>
<p><span class="chip verde"><%=esc(p[5])%></span> <span class="chip azul">Fase <%=f%> · <%=esc(p[4])%></span> · Modalidad: <b><%=esc(p[6]==null?"—":p[6])%></b></p>
<div class="fases"><%for(int i=1;i<=6;i++){%><div class="fase <%=i<=f?"done":""%> <%=i==f?"now":""%>">F<%=i%><br><small><%=nn[i]%></small></div><%}%></div>
<p><b>Director:</b> <%=esc(dirN)%> · <b>Codirector:</b> <%=esc(codN)%> <small>(el evaluador no se muestra - RNF-04)</small><br>
<% String noms=""; for(int _i=0;_i<integ.size();_i++){ if(_i>0)noms+=", "; noms+=integ.get(_i)[0]; } %>
<b>Nivel:</b> <%=esc(p[9])%> · <b>Modalidad:</b> <%=esc(p[10])%> · <b>Integrantes:</b> <%=esc(noms)%></p>
<% if("estudiante".equals(p[4])&&"En curso".equals(p[5])){ %>
<h3>📤 Entregar (se crea versión nueva - RF-EST-08)</h3>
<form method="post" onsubmit="return vFormDoc()"><input type="hidden" name="pid" value="<%=p[0]%>">
<% if(f==1){ %><label>URL comprobante de pago* (https)</label><input id="url" name="url" required placeholder="https://..."><% }
   else if(f==2){ %><label>URL del anteproyecto F-DC-124* (Fase 2 → director)</label><input id="url" name="url" required placeholder="https://..."><% }
   else if(f==4){ %><label>URL del informe F-DC-125* (Fase 4 → director)</label><input id="url" name="url" required placeholder="https://..."><% }
   else { %><p>En esta fase debe esperar la decisión del comité/evaluador.</p><% } %>
<% if(f==1||f==2||f==4){ %><br><br><button class="btn primary" name="entregar" value="1">Registrar entrega</button><% } %></form>
<% } else { %><div class="alert ok">Turno actual: <b><%=esc(p[4])%></b>. Espere la respuesta ("Respuesta enviada correctamente").</div><% } %>
</div>
<div class="card"><h3>💬 Comentarios de cada decisión (RF-EST-08)</h3>
<table class="tbl"><tr><th>Fase</th><th>Estado</th><th>Por</th><th>Comentario</th><th>Fecha</th></tr>
<%for(String[]s:coms){%><tr><td><%=s[0]%></td><td><%=esc(s[1])%></td><td><%=esc(s[3])%></td><td><%=esc(s[2]==null?"":s[2])%></td><td><%=s[4]%></td></tr><%} %></table>
<p><a class="btn sm" href="seguimiento.jsp">Ver seguimiento completo →</a> <a class="btn sm" href="versiones.jsp">Historial de versiones →</a></p></div>
<% } %>
<%@ include file="../../WEB-INF/jspf/footer.jspf" %>

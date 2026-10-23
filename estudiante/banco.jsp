<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="../../WEB-INF/jspf/conexion.jspf" %>
<%@ include file="../../WEB-INF/jspf/guardEstudiante.jspf" %>
<%
  int uid=(Integer)session.getAttribute("uid");
  if("POST".equals(request.getMethod())&&request.getParameter("inscribir")!=null){
    try(Connection c=DriverManager.getConnection(DB_URL,DB_USER,DB_PASS)){
      PreparedStatement pv=c.prepareStatement("SELECT id FROM periodos WHERE activo=1 AND CURDATE() BETWEEN inicio_nuevos_proyectos AND fin_nuevos_proyectos");
      ResultSet rv=pv.executeQuery(); boolean okW=rv.next(); rv.close(); pv.close();
      if(!okW){ response.sendRedirect("banco.jsp?er=Fuera+de+la+ventana+de+nuevos+proyectos"); return; }
      // ¿ya tiene proyecto activo?
      PreparedStatement pa=c.prepareStatement("SELECT COUNT(*) FROM proyecto_integrantes x JOIN proyectos p ON p.id=x.proyecto_id WHERE x.usuario_id=? AND p.estado='En curso'");
      pa.setInt(1,uid); ResultSet ra=pa.executeQuery(); if(ra.next()&&ra.getInt(1)>0){ra.close();pa.close(); response.sendRedirect("proyecto.jsp?er=Ya+tiene+un+proyecto+activo"); return;} ra.close();pa.close();
      String modo=request.getParameter("modo"); // BANCO o PROPIA
      String pago=request.getParameter("pago");
      if(!esUrl(pago)){ response.sendRedirect("banco.jsp?er=La+URL+del+comprobante+de+pago+debe+iniciar+con+https://"); return; }
      String tipoPar=request.getParameter("tipo_equipo"); // INDIVIDUAL o PAREJA
      String docComp=request.getParameter("doc_comp");
      Integer compId=null;
      if("PAREJA".equals(tipoPar)){
        if(docComp==null||docComp.trim().isEmpty()){response.sendRedirect("banco.jsp?er=Indique+el+documento+del+companero");return;}
        PreparedStatement pc2=c.prepareStatement("SELECT u.id FROM usuarios u JOIN usuario_rol ur ON ur.usuario_id=u.id JOIN roles r ON r.id=ur.rol_id WHERE u.documento=? AND r.nombre='estudiante' AND u.activo=1");
        pc2.setString(1,docComp.trim()); ResultSet rc2=pc2.executeQuery();
        if(!rc2.next()){rc2.close();pc2.close();response.sendRedirect("banco.jsp?er=El+companero+no+existe+como+estudiante");return;}
        compId=rc2.getInt(1); rc2.close(); pc2.close();
        if(compId==uid){response.sendRedirect("banco.jsp?er=No+puede+inscribirse+consigo+mismo");return;}
        PreparedStatement pa2=c.prepareStatement("SELECT COUNT(*) FROM proyecto_integrantes x JOIN proyectos p ON p.id=x.proyecto_id WHERE x.usuario_id=? AND p.estado='En curso'");
        pa2.setInt(1,compId); ResultSet ra2=pa2.executeQuery(); if(ra2.next()&&ra2.getInt(1)>0){ra2.close();pa2.close();response.sendRedirect("banco.jsp?er=El+companero+ya+tiene+proyecto+activo");return;} ra2.close();pa2.close();
      }
      String titulo="", obj="", desc="", linea="Ingenieria de software", mod="Investigacion", niv="Tecnologico";
      Integer bancoId=null;
      if("BANCO".equals(modo)){
        bancoId=Integer.parseInt(request.getParameter("banco_id"));
        PreparedStatement pb=c.prepareStatement("SELECT titulo,objetivo_general,descripcion,linea_investigacion,tipo_modalidad,tipo_nivel,disponible,estado FROM propuestas_banco WHERE id=?");
        pb.setInt(1,bancoId); ResultSet rb=pb.executeQuery();
        if(!rb.next()||rb.getInt("disponible")==0||!"Aprobada".equals(rb.getString("estado"))){rb.close();pb.close();response.sendRedirect("banco.jsp?er=Idea+no+disponible");return;}
        titulo=rb.getString(1);obj=rb.getString(2);desc=rb.getString(3);linea=rb.getString(4);mod=rb.getString(5);niv=rb.getString(6);
        rb.close();pb.close();
      } else {
        titulo=request.getParameter("titulo"); obj=request.getParameter("objetivo"); desc=request.getParameter("descripcion");
        linea=request.getParameter("linea"); mod=request.getParameter("modalidad"); niv=request.getParameter("nivel");
        if(titulo==null||titulo.isEmpty()||obj==null||obj.isEmpty()){response.sendRedirect("banco.jsp?er=Titulo+y+objetivo+obligatorios+para+idea+propia");return;}
      }
      PreparedStatement pn=c.prepareStatement("SELECT COALESCE(MAX(id),0)+1 FROM proyectos");
      ResultSet rn=pn.executeQuery();int n=1;if(rn.next())n=rn.getInt(1);rn.close();pn.close();
      String cod="GRA-"+String.format("%05d",n);
      PreparedStatement ins=c.prepareStatement("INSERT INTO proyectos(codigo,banco_id,titulo,objetivo_general,descripcion,tipo_idea,tipo_modalidad,tipo_nivel,linea_investigacion,periodo_id,fase,responsable,estado) VALUES(?,?,?,?,?,?,?, ?,?,(SELECT id FROM periodos WHERE activo=1 LIMIT 1),1,'comite','En curso')",Statement.RETURN_GENERATED_KEYS);
      ins.setString(1,cod);
      if(bancoId==null)ins.setNull(2,java.sql.Types.INTEGER);else ins.setInt(2,bancoId);
      ins.setString(3,titulo);ins.setString(4,obj);ins.setString(5,desc);
      ins.setString(6,("BANCO".equals(modo))?"Banco":"Propia");ins.setString(7,mod);ins.setString(8,niv);ins.setString(9,linea);
      ins.executeUpdate(); ResultSet k=ins.getGeneratedKeys();int pid=0;if(k.next())pid=k.getInt(1);k.close();ins.close();
      PreparedStatement i1=c.prepareStatement("INSERT INTO proyecto_integrantes(proyecto_id,usuario_id,es_responsable) VALUES(?,?,1)");
      i1.setInt(1,pid);i1.setInt(2,uid);i1.executeUpdate();i1.close();
      if(compId!=null){
        PreparedStatement i2=c.prepareStatement("INSERT INTO proyecto_integrantes(proyecto_id,usuario_id,es_responsable) VALUES(?,?,0)");
        i2.setInt(1,pid);i2.setInt(2,compId);i2.executeUpdate();i2.close();
      }
      PreparedStatement d=c.prepareStatement("INSERT INTO documentos(proyecto_id,fase,tipo,version,url,subido_por) VALUES(?,1,'SoportePago',1,?,?)");
      d.setInt(1,pid);d.setString(2,pago);d.setInt(3,uid);d.executeUpdate();d.close();
      if(bancoId!=null){
        PreparedStatement ub=c.prepareStatement("UPDATE propuestas_banco SET disponible=0 WHERE id=?");
        ub.setInt(1,bancoId);ub.executeUpdate();ub.close();
      }
      PreparedStatement h=c.prepareStatement("INSERT INTO historial(proyecto_id,usuario_id,accion,fase,comentario) VALUES(?,?, 'Proyecto inscrito (Fase 1)',1,?)");
      h.setInt(1,pid);h.setInt(2,uid);h.setString(3,"Inscripcion "+cod+" pago registrado");h.executeUpdate();h.close();
      response.sendRedirect("proyecto.jsp?ok=Proyecto+inscrito:+"+cod+".+Turno+del+comite+en+Fase+1");return;
    }catch(Exception e){response.sendRedirect("banco.jsp?er="+java.net.URLEncoder.encode(e.getMessage(),"UTF-8"));return;}
  }
  java.util.List<String[]> ideas=new java.util.ArrayList<String[]>();
  try(Connection c=DriverManager.getConnection(DB_URL,DB_USER,DB_PASS);Statement st=c.createStatement()){
    ResultSet r=st.executeQuery("SELECT pb.id,pb.codigo,pb.titulo,pb.tipo_nivel,pb.tipo_modalidad FROM propuestas_banco pb JOIN periodos per ON per.id=pb.periodo_id WHERE pb.estado='Aprobada' AND pb.disponible=1 AND per.activo=1 ORDER BY pb.id DESC LIMIT 50");
    while(r.next())ideas.add(new String[]{r.getString(1),r.getString(2),r.getString(3),r.getString(4),r.getString(5)});
    r.close();
  }catch(Exception e){}
%>
<%@ include file="../../WEB-INF/jspf/header.jspf" %>
<div class="card"><h2><%= ICON("bulb") %> Banco de ideas aprobadas y disponibles (RF-EST-01)</h2>
<table class="tbl"><tr><th>Código</th><th>Título</th><th>Nivel</th><th>Modalidad</th></tr>
<%for(String[]p:ideas){%><tr><td><b><%=esc(p[1])%></b></td><td><%=esc(p[2])%></td><td><%=esc(p[3])%></td><td><%=esc(p[4])%></td></tr><%} %></table></div>
<div class="card"><h3><%= ICON("file") %> Inscribir proyecto: elegir idea del banco (individual o pareja - RF-EST-03/04)</h3>
<form method="post"><input type="hidden" name="modo" value="BANCO">
<div class="form-row"><div><label>Idea del banco*</label><select name="banco_id" required><%for(String[]p:ideas){%><option value="<%=p[0]%>"><%=esc(p[1])%> · <%=esc(p[2])%></option><%} %></select></div>
<div><label>Equipo*</label><select name="tipo_equipo"><option>INDIVIDUAL</option><option>PAREJA</option></select></div>
<div><label>Documento compañero (si pareja)*</label><input name="doc_comp" placeholder="Documento del 2do integrante"></div></div>
<label>URL comprobante de pago* (https)</label><input name="pago" required placeholder="https://...">
<br><br><button class="btn primary" name="inscribir" value="1">Inscribir proyecto</button></form></div>
<div class="card"><h3><%= ICON("bulb") %> Proponer idea propia (RF-EST-02)</h3>
<form method="post"><input type="hidden" name="modo" value="PROPIA">
<div class="form-row"><div><label>Título*</label><input name="titulo" required></div>
<div><label>Modalidad*</label><select name="modalidad"><option>Desarrollo tecnologico</option><option>Emprendimiento</option><option>Investigacion</option><option>Otro</option></select></div>
<div><label>Nivel*</label><select name="nivel"><option>Tecnologico</option><option>Profesional</option></select></div>
<div><label>Línea*</label><input name="linea" value="Ingenieria de software"></div></div>
<label>Objetivo general*</label><textarea name="objetivo" rows="2" required></textarea>
<label>Descripción</label><textarea name="descripcion" rows="2"></textarea>
<div class="form-row"><div><label>Equipo*</label><select name="tipo_equipo"><option>INDIVIDUAL</option><option>PAREJA</option></select></div>
<div><label>Documento compañero (si pareja)</label><input name="doc_comp"></div></div>
<label>URL comprobante de pago* (https)</label><input name="pago" required placeholder="https://...">
<br><br><button class="btn green" name="inscribir" value="1">Inscribir idea propia</button></form></div>
<%@ include file="../../WEB-INF/jspf/footer.jspf" %>

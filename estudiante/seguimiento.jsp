<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="../../WEB-INF/jspf/conexion.jspf" %>
<%@ include file="../../WEB-INF/jspf/guardEstudiante.jspf" %>
<% int uid=(Integer)session.getAttribute("uid");
String[] p=null; java.util.List<String[]> docs=new java.util.ArrayList<String[]>(); java.util.List<String[]> rs=new java.util.ArrayList<String[]>();
try(Connection c=DriverManager.getConnection(DB_URL,DB_USER,DB_PASS)){
PreparedStatement ps=c.prepareStatement("SELECT p.id,p.codigo,p.titulo,p.fase,p.responsable,p.estado,CONCAT(d.nombres,' ',d.apellidos),CONCAT(co.nombres,' ',co.apellidos) FROM proyectos p LEFT JOIN usuarios d ON d.id=p.director_id LEFT JOIN usuarios co ON co.id=p.codirector_id WHERE p.id=(SELECT x.proyecto_id FROM proyecto_integrantes x WHERE x.usuario_id=? ORDER BY x.proyecto_id DESC LIMIT 1)");
ps.setInt(1,uid);ResultSet r=ps.executeQuery();if(r.next()){p=new String[8];for(int i=0;i<8;i++)p[i]=r.getString(i+1);}r.close();ps.close();
if(p!=null){
PreparedStatement pd=c.prepareStatement("SELECT fase,tipo,version,url,fecha_subida FROM documentos WHERE proyecto_id=? ORDER BY fase,version");
pd.setInt(1,Integer.parseInt(p[0]));ResultSet rd=pd.executeQuery();while(rd.next())docs.add(new String[]{rd.getString(1),rd.getString(2),rd.getString(3),rd.getString(4),rd.getString(5)});rd.close();pd.close();
PreparedStatement pr=c.prepareStatement("SELECT fase,ronda,rol,estado,comentario,fecha FROM respuestas WHERE proyecto_id=? ORDER BY id DESC");
pr.setInt(1,Integer.parseInt(p[0]));ResultSet rr=pr.executeQuery();while(rr.next())rs.add(new String[]{rr.getString(1),rr.getString(2),rr.getString(3),rr.getString(4),rr.getString(5),rr.getString(6)});rr.close();pr.close();
}}catch(Exception e){} %>
<%@ include file="../../WEB-INF/jspf/header.jspf" %>
<% if(p==null){ %><div class="card"><p>Sin proyecto. <a href="banco.jsp">Ir al banco</a></p></div><% } else {
int f=Integer.parseInt(p[3]); String[] nn={"","1. Idea y pago","2. Propuesta I","3. Propuesta II","4. Informe I","5. Informe II","6. Cierre"}; %>
<div class="card"><h2><%= ICON("map") %> Seguimiento · <%=esc(p[1])%> · <%=esc(p[2])%></h2>
<div class="fases"><%for(int i=1;i<=6;i++){%><div class="fase <%=i<=f?"done":""%> <%=i==f?"now":""%>">F<%=i%><br><small><%=nn[i]%></small></div><%}%></div>
<p><b>Director:</b> <%=esc(p[6]==null?"—":p[6])%> · <b>Codirector:</b> <%=esc(p[7]==null?"—":p[7])%> (evaluador oculto)</p>
<h4>Documentos</h4><table class="tbl"><tr><th>F</th><th>Tipo</th><th>V</th><th>URL</th></tr>
<%for(String[]d:docs){%><tr><td><%=d[0]%></td><td><%=esc(d[1])%></td><td><%=d[2]%></td><td><a class="lnk" target="_blank" href="<%=esc(d[3])%>"><%=esc(d[3])%></a></td></tr><%} %></table>
<h4>Decisiones</h4><table class="tbl"><tr><th>F</th><th>Ronda</th><th>Rol</th><th>Estado</th><th>Comentario</th></tr>
<%for(String[]s:rs){%><tr><td><%=s[0]%></td><td><%=s[1]%></td><td><%=esc(s[2])%></td><td><%=esc(s[3])%></td><td><%=esc(s[4]==null?"":s[4])%></td></tr><%} %></table></div><% } %>
<%@ include file="../../WEB-INF/jspf/footer.jspf" %>

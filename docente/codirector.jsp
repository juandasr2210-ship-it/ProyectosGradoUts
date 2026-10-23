<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="../../WEB-INF/jspf/conexion.jspf" %>
<%@ include file="../../WEB-INF/jspf/guardDocente.jspf" %>
<% int uid=(Integer)session.getAttribute("uid");
java.util.List<String[]> rows=new java.util.ArrayList<String[]>();
try(Connection c=DriverManager.getConnection(DB_URL,DB_USER,DB_PASS)){
PreparedStatement ps=c.prepareStatement("SELECT p.id,p.codigo,p.titulo,p.fase,p.responsable,p.estado FROM proyectos p WHERE p.codirector_id=? ORDER BY p.id DESC");
ps.setInt(1,uid);ResultSet r=ps.executeQuery();
while(r.next())rows.add(new String[]{r.getString(1),r.getString(2),r.getString(3),r.getString(4),r.getString(5),r.getString(6)});
r.close();ps.close();}catch(Exception e){} %>
<%@ include file="../../WEB-INF/jspf/header.jspf" %>
<div class="card"><h2><%= ICON("users") %> Codirector (solo consulta + sustentación Fase 6)</h2>
<table class="tbl"><tr><th>Código</th><th>Título</th><th>Fase · Turno</th><th>Estado</th></tr>
<%for(String[]p:rows){%><tr><td><b><%=esc(p[1])%></b></td><td><%=esc(p[2])%></td>
<td><span class="chip azul">Fase <%=p[3]%></span> <span class="chip gris"><%=esc(p[4])%></span></td><td><%=esc(p[5])%></td></tr><%} %></table>
<p>Participa en la programación de la sustentación (Fase 6) junto a director y evaluador.</p></div>
<%@ include file="../../WEB-INF/jspf/footer.jspf" %>

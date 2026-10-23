<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="../../WEB-INF/jspf/conexion.jspf" %>
<%@ include file="../../WEB-INF/jspf/guardComite.jspf" %>
<% String q=request.getParameter("q"); if(q==null)q="";
java.util.List<String[]> rows=new java.util.ArrayList<String[]>();
try(Connection c=DriverManager.getConnection(DB_URL,DB_USER,DB_PASS)){
PreparedStatement ps=c.prepareStatement("SELECT u.id,u.documento,CONCAT(u.nombres,' ',u.apellidos),u.email,GROUP_CONCAT(r.nombre SEPARATOR ', ') FROM usuarios u LEFT JOIN usuario_rol ur ON ur.usuario_id=u.id LEFT JOIN roles r ON r.id=ur.rol_id WHERE (u.nombres LIKE ? OR u.email LIKE ? OR u.documento LIKE ?) GROUP BY u.id ORDER BY u.id DESC LIMIT 50");
ps.setString(1,"%"+q+"%");ps.setString(2,"%"+q+"%");ps.setString(3,"%"+q+"%");
ResultSet r=ps.executeQuery();while(r.next())rows.add(new String[]{r.getString(1),r.getString(2),r.getString(3),r.getString(4),r.getString(5)});
r.close();ps.close();}catch(Exception e){} %>
<%@ include file="../../WEB-INF/jspf/header.jspf" %>
<div class="card"><h2><%= ICON("users") %> Usuarios (consulta RF-COM-07)</h2>
<form class="toolbar" method="get"><input name="q" value="<%=esc(q)%>" placeholder="Buscar"><button class="btn green">Buscar</button></form>
<table class="tbl"><tr><th>ID</th><th>Doc</th><th>Nombre</th><th>Email</th><th>Roles</th></tr>
<%for(String[]u:rows){%><tr><td><%=u[0]%></td><td><%=esc(u[1])%></td><td><%=esc(u[2])%></td><td><%=esc(u[3])%></td><td><%=esc(u[4]==null?"":u[4])%></td></tr><%} %></table></div>
<%@ include file="../../WEB-INF/jspf/footer.jspf" %>

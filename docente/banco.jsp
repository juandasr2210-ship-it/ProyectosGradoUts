<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="../../WEB-INF/jspf/conexion.jspf" %>
<%@ include file="../../WEB-INF/jspf/guardDocente.jspf" %>
<% java.util.List<String[]> rows=new java.util.ArrayList<String[]>();
try(Connection c=DriverManager.getConnection(DB_URL,DB_USER,DB_PASS);Statement st=c.createStatement()){
ResultSet r=st.executeQuery("SELECT pb.codigo,pb.titulo,pb.tipo_nivel FROM propuestas_banco pb WHERE pb.estado='Aprobada' AND pb.disponible=1 ORDER BY pb.id DESC LIMIT 100");
while(r.next())rows.add(new String[]{r.getString(1),r.getString(2),r.getString(3)});r.close();}catch(Exception e){} %>
<%@ include file="../../WEB-INF/jspf/header.jspf" %>
<div class="card"><h2><%= ICON("bulb") %> Banco de ideas</h2>
<table class="tbl"><tr><th>Código</th><th>Título</th><th>Nivel</th></tr>
<%for(String[]p:rows){%><tr><td><b><%=esc(p[0])%></b></td><td><%=esc(p[1])%></td><td><%=esc(p[2])%></td></tr><%} %></table></div>
<%@ include file="../../WEB-INF/jspf/footer.jspf" %>

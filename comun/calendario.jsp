<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="../../WEB-INF/jspf/conexion.jspf" %>
<%@ include file="../../WEB-INF/jspf/guard.jspf" %>
<% java.util.List<String[]> rows=new java.util.ArrayList<String[]>();
try(Connection c=DriverManager.getConnection(DB_URL,DB_USER,DB_PASS);Statement st=c.createStatement()){
ResultSet r=st.executeQuery("SELECT codigo,inicio_propuestas_banco,fin_propuestas_banco,inicio_nuevos_proyectos,fin_nuevos_proyectos,fin_aprobacion_propuesta,activo FROM periodos ORDER BY id DESC");
while(r.next())rows.add(new String[]{r.getString(1),r.getString(2),r.getString(3),r.getString(4),r.getString(5),r.getString(6),r.getString(7)});r.close();}catch(Exception e){} %>
<%@ include file="../../WEB-INF/jspf/header.jspf" %>
<div class="card"><h2><%= ICON("calendar") %> Calendario académico</h2>
<table class="tbl"><tr><th>Periodo</th><th>Banco de ideas</th><th>Nuevos proyectos</th><th>Fin aprobación</th><th>Vigente</th></tr>
<%for(String[]p:rows){%><tr><td><b><%=esc(p[0])%></b></td><td><%=esc(p[1])%> al <%=esc(p[2])%></td><td><%=esc(p[3])%> al <%=esc(p[4])%></td><td><%=esc(p[5])%></td><td><span class="chip <%="1".equals(p[6])?"verde":"gris"%>"><%="1".equals(p[6])?"Sí":"—"%></span></td></tr><%} %></table>
<p style="color:#666">Las acciones respetan estas fechas: banco de ideas, nuevos proyectos y fin de aprobación (RF-GEN-11).</p></div>
<%@ include file="../../WEB-INF/jspf/footer.jspf" %>

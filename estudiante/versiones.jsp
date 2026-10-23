<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="../../WEB-INF/jspf/conexion.jspf" %>
<%@ include file="../../WEB-INF/jspf/guardEstudiante.jspf" %>
<% int uid=(Integer)session.getAttribute("uid");
java.util.List<String[]> docs=new java.util.ArrayList<String[]>();
try(Connection c=DriverManager.getConnection(DB_URL,DB_USER,DB_PASS)){
PreparedStatement pd=c.prepareStatement("SELECT d.fase,d.tipo,d.version,d.url,d.fecha_subida,p.codigo FROM documentos d JOIN proyecto_integrantes x ON x.proyecto_id=d.id*0+d.proyecto_id JOIN proyectos p ON p.id=d.proyecto_id WHERE x.usuario_id=? ORDER BY d.fase,d.tipo,d.version");
pd.setInt(1,uid);ResultSet rd=pd.executeQuery();while(rd.next())docs.add(new String[]{rd.getString(1),rd.getString(2),rd.getString(3),rd.getString(4),rd.getString(5),rd.getString(6)});rd.close();pd.close();
}catch(Exception e){} %>
<%@ include file="../../WEB-INF/jspf/header.jspf" %>
<div class="card"><h2><%= ICON("clock") %> Historial de versiones (RF-EST-10 · RF-GEN-06)</h2>
<p>Cada entrega o corrección crea una versión nueva; las anteriores se conservan.</p>
<table class="tbl"><tr><th>Proyecto</th><th>Fase</th><th>Tipo</th><th>Versión</th><th>URL</th><th>Fecha</th></tr>
<%for(String[]d:docs){%><tr><td><%=esc(d[5])%></td><td><%=d[0]%></td><td><%=esc(d[1])%></td><td><span class="chip verde">v<%=d[2]%></span></td><td><a class="lnk" target="_blank" href="<%=esc(d[3])%>"><%=esc(d[3])%></a></td><td><%=d[4]%></td></tr><%} %></table></div>
<%@ include file="../../WEB-INF/jspf/footer.jspf" %>

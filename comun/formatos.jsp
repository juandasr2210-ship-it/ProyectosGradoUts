<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="../../WEB-INF/jspf/conexion.jspf" %>
<%@ include file="../../WEB-INF/jspf/guard.jspf" %>
<%
  java.util.List<String[]> rows = new java.util.ArrayList<String[]>();
  try (Connection c = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS); Statement st = c.createStatement()) {
    ResultSet r = st.executeQuery("SELECT codigo,nombre,url_plantilla FROM formatos WHERE activo=1 ORDER BY codigo");
    while (r.next()) rows.add(new String[]{r.getString(1),r.getString(2),r.getString(3)});
    r.close();
  } catch (Exception e) {}
%>
<%@ include file="../../WEB-INF/jspf/header.jspf" %>

<div class="grid g3">
  <a class="card modulo" href="<%=ctx%>/comun/calendario.jsp">
    <span class="ico"><%= ICON("calendar") %></span>
    <h4>Calendario Académico</h4>
    <p>Consulta las fechas importantes y eventos académicos.</p>
  </a>
  <a class="card modulo" href="#formatos">
    <span class="ico"><%= ICON("book") %></span>
    <h4>Formatos institucionales</h4>
    <p>Accede a todos los formatos de presentación institucional de manera eficiente.</p>
  </a>
  <a class="card modulo" href="#propuesta">
    <span class="ico"><%= ICON("file") %></span>
    <h4>Presentación de propuesta</h4>
    <p>Procedimiento a seguir para la presentación de la propuesta.</p>
  </a>
  <a class="card modulo" href="#informe">
    <span class="ico"><%= ICON("file") %></span>
    <h4>Presentación de informe final</h4>
    <p>Procedimiento a seguir para la presentación del informe final.</p>
  </a>
  <a class="card modulo" href="#estimulos">
    <span class="ico"><%= ICON("award") %></span>
    <h4>Reglamento de estímulos</h4>
    <p>Procedimiento a obtener distinciones o estímulos en un proyecto.</p>
  </a>
  <a class="card modulo" href="#reglamento">
    <span class="ico"><%= ICON("list") %></span>
    <h4>Reglamento de trabajos de grado</h4>
    <p>Procedimiento para elaborar un trabajo de grado.</p>
  </a>
</div>

<div class="card" id="formatos">
  <h3><%= ICON("book") %> Formatos institucionales vigentes</h3>
  <table class="tbl">
    <tr><th>Código</th><th>Nombre</th><th>Plantilla</th></tr>
    <% for (String[] f : rows) { %>
      <tr>
        <td><b><%= esc(f[0]) %></b></td>
        <td><%= esc(f[1]) %></td>
        <td><a class="lnk" target="_blank" href="<%= esc(f[2]) %>"><%= esc(f[2]) %></a></td>
      </tr>
    <% } %>
  </table>
</div>

<div class="card" id="reglamento" style="display:none">
  <h3><%= ICON("list") %> Reglamento de trabajos de grado</h3>
  <p>Procedimiento institucional para la formulación, desarrollo, evaluación y sustentación de trabajos de grado en las modalidades autorizadas por la institución.</p>
</div>
<script>
  if (location.hash && document.querySelector(location.hash)) {
    document.querySelector(location.hash).style.display = 'block';
  }
</script>

<%@ include file="../../WEB-INF/jspf/footer.jspf" %>

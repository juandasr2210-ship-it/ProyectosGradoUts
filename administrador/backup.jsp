<%@ page contentType="text/plain; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="../../WEB-INF/jspf/conexion.jspf" %>
<%@ include file="../../WEB-INF/jspf/guardAdministrador.jspf" %>
<%
  response.setHeader("Content-Disposition","attachment; filename=\"trabajos_grado_backup.sql\"");
  try (Connection c = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS); Statement st = c.createStatement()) {
    out.println("-- Trabajos de Grado UTS backup " + new java.util.Date());
    String[] tablas = {"roles","usuarios","usuario_rol","periodos","propuestas_banco","proyectos","proyecto_integrantes","documentos","respuestas","historial","sustentaciones","formatos"};
    for (String t : tablas) {
      out.println("\n-- Tabla " + t);
      try {
        ResultSet rs = st.executeQuery("SELECT * FROM " + t);
        ResultSetMetaData md = rs.getMetaData();
        int n = md.getColumnCount();
        while (rs.next()) {
          StringBuilder sb = new StringBuilder("INSERT INTO " + t + " VALUES(");
          for (int i=1;i<=n;i++) {
            Object v = rs.getObject(i);
            if (v == null) sb.append("NULL");
            else sb.append("'").append(v.toString().replace("'","''")).append("'");
            if (i<n) sb.append(",");
          }
          sb.append(");");
          out.println(sb.toString());
        }
        rs.close();
      } catch (Exception e) { out.println("-- error " + t + ": " + e.getMessage()); }
    }
  } catch (Exception e) { out.println("-- ERROR: " + e.getMessage()); }
%>

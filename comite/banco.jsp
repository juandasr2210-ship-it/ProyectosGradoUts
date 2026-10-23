<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="../../WEB-INF/jspf/conexion.jspf" %>
<%@ include file="../../WEB-INF/jspf/guardComite.jspf" %>
<%
  int uid = (Integer) session.getAttribute("uid");
  String acc = request.getParameter("acc");
  String msg = "", msgOk = "";
  
  if (acc != null) {
    try (Connection c = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS)) {
      if ("crear".equals(acc)) {
        String titulo = request.getParameter("titulo");
        String modalidad = request.getParameter("modalidad");
        String nivel = request.getParameter("nivel");
        String objetivo = request.getParameter("objetivo");
        String descripcion = request.getParameter("descripcion");
        String linea = request.getParameter("linea");
        
        PreparedStatement pc = c.prepareStatement("SELECT COALESCE(MAX(id),0)+1 FROM propuestas_banco");
        ResultSet rc = pc.executeQuery(); int n = 1; if (rc.next()) n = rc.getInt(1); rc.close(); pc.close();
        String cod = "BAN-" + String.format("%05d", n);
        
        PreparedStatement ps = c.prepareStatement("INSERT INTO propuestas_banco(codigo,proponente_id,origen,titulo,tipo_modalidad,objetivo_general,descripcion,linea_investigacion,tipo_nivel,periodo_id,estado,disponible) VALUES(?,?,'Docente',?,?,?,?,?,(SELECT id FROM periodos WHERE activo=1 LIMIT 1),'Aprobada',1)");
        ps.setString(1, cod); ps.setInt(2, uid); ps.setString(3, titulo);
        ps.setString(4, modalidad); ps.setString(5, objetivo); ps.setString(6, descripcion);
        ps.setString(7, linea); ps.setString(8, nivel);
        ps.executeUpdate(); ps.close();
        msgOk = "Propuesta creada y aprobada automáticamente: " + cod;
      }
      else if ("eliminar".equals(acc)) {
        int id = Integer.parseInt(request.getParameter("id"));
        PreparedStatement ps = c.prepareStatement("DELETE FROM propuestas_banco WHERE id=?");
        ps.setInt(1, id); ps.executeUpdate(); ps.close();
        msgOk = "Propuesta eliminada correctamente";
      }
    } catch (Exception e) { msg = "Error: " + e.getMessage(); }
  }
  
  java.util.List<String[]> rows = new java.util.ArrayList<String[]>();
  try (Connection c = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS); Statement st = c.createStatement()) {
    ResultSet r = st.executeQuery("SELECT pb.id, pb.codigo, pb.titulo, pb.tipo_nivel, pb.estado, pb.disponible FROM propuestas_banco pb ORDER BY pb.id DESC");
    while (r.next()) rows.add(new String[]{r.getString(1), r.getString(2), r.getString(3), r.getString(4), r.getString(5), r.getString(6)});
    r.close();
  } catch (Exception e) {}
%>
<%@ include file="../../WEB-INF/jspf/header.jspf" %>
<div class="card">
  <h2><%= ICON("bulb") %> Banco de ideas - Gestión (Coordinador)</h2>
  <p>Aquí puedes crear nuevas propuestas para que los estudiantes las escojan, o eliminar las que ya no estén disponibles.</p>
</div>

<div class="card">
  <h3><%= ICON("plus") %> Crear nueva propuesta para el banco</h3>
  <form method="post">
    <input type="hidden" name="acc" value="crear">
    <div class="form-row">
      <div><label>Título *</label><input name="titulo" required maxlength="255"></div>
      <div><label>Modalidad *</label><select name="modalidad" required><option>Desarrollo tecnologico</option><option>Emprendimiento</option><option>Investigacion</option><option>Otro</option></select></div>
      <div><label>Nivel *</label><select name="nivel" required><option>Tecnologico</option><option>Profesional</option></select></div>
      <div><label>Línea de investigación *</label><input name="linea" required value="Ingenieria de software"></div>
    </div>
    <label>Objetivo general *</label><textarea name="objetivo" rows="2" required></textarea>
    <label>Descripción / tecnologías</label><textarea name="descripcion" rows="2"></textarea>
    <br><button class="btn primary" type="submit">Crear y aprobar</button>
  </form>
</div>

<% if (!msg.isEmpty()) { %><div class="alert err"><%= esc(msg) %></div><% } %>
<% if (!msgOk.isEmpty()) { %><div class="alert ok"><%= esc(msgOk) %></div><% } %>

<div class="card">
  <h3>Propuestas existentes</h3>
  <table class="tbl">
    <tr><th>Código</th><th>Título</th><th>Nivel</th><th>Estado</th><th>Disponible</th><th>Acciones</th></tr>
    <% for (String[] p : rows) { %>
    <tr>
      <td><b><%= esc(p[1]) %></b></td>
      <td><%= esc(p[2]) %></td>
      <td><%= esc(p[3]) %></td>
      <td><span class="chip <%= "Aprobada".equals(p[4])?"verde":("Pendiente".equals(p[4])?"amarillo":"rojo") %>"><%= esc(p[4]) %></span></td>
      <td><span class="chip <%= "1".equals(p[5])?"verde":"gris" %>"><%= "1".equals(p[5])?"Sí":"No" %></span></td>
      <td>
        <form method="post" style="display:inline" onsubmit="return confirm('¿Eliminar esta propuesta? Los estudiantes ya no podrán escogerla.')">
          <input type="hidden" name="acc" value="eliminar">
          <input type="hidden" name="id" value="<%= p[0] %>">
          <button class="iconbtn" type="submit" title="Eliminar"><%= ICON("x") %></button>
        </form>
      </td>
    </tr>
    <% } %>
  </table>
</div>
<%@ include file="../../WEB-INF/jspf/footer.jspf" %>
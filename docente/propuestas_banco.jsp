<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="../../WEB-INF/jspf/conexion.jspf" %>
<%@ include file="../../WEB-INF/jspf/guardDocente.jspf" %>
<%
  int uid = (Integer) session.getAttribute("uid");
  if ("POST".equals(request.getMethod()) && request.getParameter("proponer") != null) {
    try (Connection c = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS)) {
      PreparedStatement pv = c.prepareStatement("SELECT id FROM periodos WHERE activo=1 AND CURDATE() BETWEEN inicio_propuestas_banco AND fin_propuestas_banco");
      ResultSet rv = pv.executeQuery(); boolean okWin = rv.next(); rv.close(); pv.close();
      if (!okWin) { response.sendRedirect("propuestas_banco.jsp?er=Fuera+de+la+ventana+del+banco+de+ideas+del+periodo"); return; }
      PreparedStatement pc = c.prepareStatement("SELECT COALESCE(MAX(id),0)+1 FROM propuestas_banco");
      ResultSet rc = pc.executeQuery(); int n = 1; if (rc.next()) n = rc.getInt(1); rc.close(); pc.close();
      String cod = "BAN-" + String.format("%05d", n);
      PreparedStatement ps = c.prepareStatement("INSERT INTO propuestas_banco(codigo,proponente_id,origen,titulo,tipo_modalidad,objetivo_general,descripcion,linea_investigacion,tipo_nivel,periodo_id) VALUES(?,?,'Docente',?,?,?,?,?,(SELECT id FROM periodos WHERE activo=1 LIMIT 1))");
      ps.setString(1, cod); ps.setInt(2, uid); ps.setString(3, request.getParameter("titulo"));
      ps.setString(4, request.getParameter("modalidad")); ps.setString(5, request.getParameter("objetivo"));
      ps.setString(6, request.getParameter("descripcion")); ps.setString(7, request.getParameter("linea")); ps.setString(8, request.getParameter("nivel"));
      ps.executeUpdate(); ps.close();
      response.sendRedirect("propuestas_banco.jsp?ok=Idea+propuesta+al+banco:+"+cod); return;
    } catch (Exception e) { response.sendRedirect("propuestas_banco.jsp?er=" + java.net.URLEncoder.encode(e.getMessage(), "UTF-8")); return; }
  }

  String q = request.getParameter("q"); if (q == null) q = "";
  int pag = 1; try { pag = Integer.parseInt(request.getParameter("pag")); } catch (Exception e) {}
  if (pag < 1) pag = 1;
  int npp = 5; try { npp = Integer.parseInt(request.getParameter("npp")); } catch (Exception e) {}
  if (npp != 5 && npp != 10 && npp != 25) npp = 5;

  int total = 0;
  java.util.List<String[]> rows = new java.util.ArrayList<String[]>();
  try (Connection c = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS)) {
    String w = " WHERE proponente_id=? AND (titulo LIKE ? OR codigo LIKE ?) ";
    PreparedStatement pc = c.prepareStatement("SELECT COUNT(*) FROM propuestas_banco " + w);
    pc.setInt(1, uid); pc.setString(2, "%" + q + "%"); pc.setString(3, "%" + q + "%");
    ResultSet rc = pc.executeQuery(); if (rc.next()) total = rc.getInt(1); rc.close(); pc.close();

    PreparedStatement ps = c.prepareStatement("SELECT id,codigo,titulo,tipo_nivel,estado,observacion_comite,fecha_propuesta FROM propuestas_banco " + w + " ORDER BY id DESC LIMIT ?,?");
    ps.setInt(1, uid); ps.setString(2, "%" + q + "%"); ps.setString(3, "%" + q + "%");
    ps.setInt(4, (pag - 1) * npp); ps.setInt(5, npp);
    ResultSet r = ps.executeQuery();
    while (r.next()) rows.add(new String[]{r.getString(1), r.getString(2), r.getString(3), r.getString(4), r.getString(5), r.getString(6), r.getString(7)});
    r.close(); ps.close();
  } catch (Exception e) {}

  int npag = (int) Math.ceil(total / (double) npp); if (npag < 1) npag = 1; if (pag > npag) pag = npag;
  String qs = "q=" + java.net.URLEncoder.encode(q, "UTF-8") + "&npp=" + npp;
%>
<%@ include file="../../WEB-INF/jspf/header.jspf" %>

<div class="card">
  <div class="tbl-tools">
    <form method="get" style="display:flex;align-items:center;gap:6px">
      Mostrar
      <select name="npp" onchange="this.form.submit()">
        <% for (int n : new int[]{5, 10, 25}) { %>
          <option value="<%=n%>" <%=n==npp?"selected":""%>><%=n%></option>
        <% } %>
      </select>
      registros por página
      <input type="hidden" name="q" value="<%= esc(q) %>">
    </form>

    <form method="get">
      <div class="search-box">
        <span style="color:#8a99a4;font-size:13px;margin-right:4px">Buscar:</span>
        <input name="q" placeholder="Ingrese una clave." value="<%= esc(q) %>">
        <input type="hidden" name="npp" value="<%= npp %>">
      </div>
    </form>
  </div>

  <table class="tbl">
    <thead>
      <tr>
        <th style="width:130px">ID <span style="font-size:10px;color:#888">▼</span></th>
        <th>Descripción</th>
        <th style="width:130px">Estado</th>
        <th style="width:100px;text-align:center">Acciones</th>
      </tr>
    </thead>
    <tbody>
      <% if (rows.isEmpty()) { %>
        <tr><td colspan="4" style="text-align:center;color:#888;padding:24px">No hay propuestas registradas en esta página.</td></tr>
      <% } %>
      <% for (String[] p : rows) { %>
        <tr>
          <td><b><%= esc(p[1]) %></b></td>
          <td><%= esc(p[2]) %><br><small style="color:#777">Nivel: <%= esc(p[3]) %></small></td>
          <td>
            <span class="chip <%= "Aprobada".equals(p[4]) ? "verde" : ("Pendiente".equals(p[4]) ? "amarillo" : "rojo") %>">
              <%= esc(p[4]) %>
            </span>
          </td>
          <td style="text-align:center">
            <a class="iconbtn" title="Ver detalle" href="#det<%= p[0] %>">
              <%= ICON("eye") %>
            </a>
          </td>
        </tr>
      <% } %>
    </tbody>
  </table>

  <div class="pag">
    <span class="info">Mostrando la página <%= pag %> de <%= npag %></span>
    <a href="propuestas_banco.jsp?<%= qs %>&pag=1">«</a>
    <a href="propuestas_banco.jsp?<%= qs %>&pag=<%= Math.max(1, pag - 1) %>">‹</a>
    <% for (int i = 1; i <= npag; i++) { %>
      <a class="<%= i == pag ? "act" : "" %>" href="propuestas_banco.jsp?<%= qs %>&pag=<%= i %>"><%= i %></a>
    <% } %>
    <a href="propuestas_banco.jsp?<%= qs %>&pag=<%= Math.min(npag, pag + 1) %>">›</a>
    <a href="propuestas_banco.jsp?<%= qs %>&pag=<%= npag %>">»</a>
  </div>
</div>

<div class="card">
  <h3><%= ICON("file") %> Proponer nueva idea al banco de ideas institucional</h3>
  <form method="post">
    <div class="form-row">
      <div><label>Título de la idea*</label><input name="titulo" required maxlength="255"></div>
      <div><label>Modalidad*</label><select name="modalidad"><option>Desarrollo tecnologico</option><option>Emprendimiento</option><option>Investigacion</option><option>Otro</option></select></div>
      <div><label>Nivel*</label><select name="nivel"><option>Tecnologico</option><option>Profesional</option></select></div>
      <div><label>Línea de investigación*</label><input name="linea" required value="Ingenieria de software"></div>
    </div>
    <label>Objetivo general*</label>
    <textarea name="objetivo" rows="2" required placeholder="Describa el objetivo general del proyecto."></textarea>
    <label>Descripción y tecnologías</label>
    <textarea name="descripcion" rows="2" placeholder="Detalles, tecnologías a emplear..."></textarea>
    <div style="margin-top:14px;text-align:right">
      <button class="btn primary" name="proponer" value="1">ENVIAR PROPUESTA</button>
    </div>
  </form>
</div>

<% for (String[] p : rows) { %>
  <div class="card" id="det<%= p[0] %>" style="display:none">
    <h3>Detalle de la propuesta <%= esc(p[1]) %></h3>
    <p><b>Título:</b> <%= esc(p[2]) %><br>
    <b>Estado:</b> <%= esc(p[4]) %><br>
    <b>Observación del comité:</b> <%= esc(p[5] == null ? "Sin observaciones" : p[5]) %></p>
    <button class="btn sm" onclick="document.getElementById('det<%= p[0] %>').style.display='none'">Cerrar</button>
  </div>
<% } %>

<script>
  window.addEventListener('hashchange', function() {
    if (location.hash && document.querySelector(location.hash)) {
      document.querySelector(location.hash).style.display = 'block';
    }
  });
</script>

<%@ include file="../../WEB-INF/jspf/footer.jspf" %>

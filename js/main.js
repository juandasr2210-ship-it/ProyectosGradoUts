// main.js: validaciones cliente (RF-GEN-05 URL https, confirmaciones)
function vUrl(id){
  var e=document.getElementById(id); if(!e) return true;
  var v=e.value.trim();
  if(v==='' ) return true;
  if(!v.startsWith('https://')){ alert('La URL debe iniciar con https://'); e.focus(); return false; }
  return true;
}
function vFormDoc(){ return vUrl('url'); }
function confirma(msg){ return confirm(msg||'¿Confirmar acción?'); }
function toggleComite(sel){
  var extra=document.getElementById('extraAprobado');
  if(!extra) return;
  extra.style.display = (sel.value==='Aprobado') ? 'block':'none';
}
document.addEventListener('DOMContentLoaded',function(){
  var s=document.getElementById('estadoSel'); if(s){ toggleComite(s); s.addEventListener('change',function(){toggleComite(s);}); }
});

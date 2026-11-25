// Custom bootstrap (Flutter fills in the two {{...}} tokens at build time).
//
// Why custom: the default one registers a service worker, which caches the
// old app so visitors keep seeing the previous version after you upload.
// Here we call load() WITHOUT serviceWorkerSettings -> no service worker.
{{flutter_js}}
{{flutter_build_config}}

// Hide the CSS splash from index.html once Flutter has drawn something.
window.addEventListener('flutter-first-frame', function () {
  var s = document.getElementById('splash');
  if (!s) return;
  s.style.opacity = '0';
  setTimeout(function () { s.remove(); }, 300);
});

// If an old service worker exists from an earlier deploy, remove it.
if ('serviceWorker' in navigator) {
  navigator.serviceWorker.getRegistrations().then(function (regs) {
    regs.forEach(function (r) { r.unregister(); });
  });
}

_flutter.loader.load();

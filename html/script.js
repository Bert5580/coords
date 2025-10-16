(function () {
  const app = document.getElementById('app');
  const coordBox = document.getElementById('coordBox');
  const status = document.getElementById('status');
  const btnCopy = document.getElementById('btnCopy');
  const btnRefresh = document.getElementById('btnRefresh');
  const btnClose = document.getElementById('btnClose');
  const version = document.getElementById('version');

  function show() { app.classList.remove('hidden'); }
  function hide() { app.classList.add('hidden'); }

  window.addEventListener('message', (e) => {
    const data = e.data || {};
    if (data.type === 'open') {
      version.textContent = 'v' + (data.payload?.version || '0.0.0');
      status.textContent = 'UI opened. Press Copy to capture current coords.';
      show();
    }
    if (data.type === 'coords') {
      const t = data.payload?.text || '';
      coordBox.textContent = t;
      if (data.payload?.copied) {
        status.textContent = 'Copied to clipboard.';
        copyToClipboard(t);
      } else {
        status.textContent = 'Coords refreshed.';
      }
    }
    if (data.type === 'error') {
      status.textContent = data.payload?.text || 'Error';
    }
    if (data.type === 'close') {
      hide();
    }
  });

  function post(name, payload) {
    fetch(`https://${GetParentResourceName()}/${name}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json; charset=UTF-8' },
      body: JSON.stringify(payload || {})
    });
  }

  function copyToClipboard(text) {
    if (!text) return;
    try {
      navigator.clipboard.writeText(text);
    } catch (e) {
      // Fallback
      const el = document.createElement('textarea');
      el.value = text;
      document.body.appendChild(el);
      el.select();
      document.execCommand('copy');
      el.remove();
    }
  }

  btnCopy.addEventListener('click', () => post('copy'));
  btnRefresh.addEventListener('click', () => post('copy')); // refresh by re-capturing
  btnClose.addEventListener('click', () => post('close'));

  document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
      post('close');
    }
  });
})();

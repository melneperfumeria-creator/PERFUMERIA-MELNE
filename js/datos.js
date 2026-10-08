// Conexión a Supabase y utilidades compartidas por la tienda y el panel de administración.
window.MELNE = (function () {
    const cfg = window.MELNE_CONFIG || {};
    const url = (cfg.supabaseUrl || '').trim();
    const key = (cfg.supabaseKey || '').trim();
    const datosValidos = /^https:\/\//.test(url) && key && !key.startsWith('PEGA_');

    let cliente = null;
    if (datosValidos && window.supabase && window.supabase.createClient) {
        cliente = window.supabase.createClient(url, key);
    }

    const formatoCOP = (n) => '$' + Number(n || 0).toLocaleString('es-CO');

    // Minúsculas y sin tildes, para que "citrico" encuentre "Cítrico".
    const normalizar = (t) => String(t || '')
        .normalize('NFD').replace(/[̀-ͯ]/g, '')
        .toLowerCase().trim();

    const escapar = (t) => String(t ?? '')
        .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;').replace(/'/g, '&#39;');

    const leerLocal = (clave) => {
        try { return JSON.parse(localStorage.getItem(clave)); } catch (e) { return null; }
    };
    const guardarLocal = (clave, valor) => {
        try { localStorage.setItem(clave, JSON.stringify(valor)); } catch (e) { /* sin almacenamiento */ }
    };

    return {
        cliente,
        configurado: Boolean(cliente),
        config: cfg,
        formatoCOP,
        normalizar,
        escapar,
        leerLocal,
        guardarLocal
    };
})();

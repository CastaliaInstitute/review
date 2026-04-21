/**
 * Injects Castalia platform header + footer from same-origin fragments (GitHub Pages).
 */
;(function () {
  function baseUrl() {
    var el = document.currentScript
    if (el && el.src) {
      try {
        return new URL('.', el.src).href
      } catch (_) {}
    }
    return '/castalia-chrome/'
  }

  function inject() {
    var base = baseUrl()
    function load(path) {
      return fetch(base + path).then(function (r) {
        if (!r.ok) throw new Error(path + ' ' + r.status)
        return r.text()
      })
    }
    Promise.all([
      load('header-fragment.html'),
      load('footer-fragment.html'),
    ])
      .then(function (parts) {
        document.body.insertAdjacentHTML('afterbegin', parts[0])
        document.body.insertAdjacentHTML('beforeend', parts[1])
      })
      .catch(function (e) {
        console.warn('[castalia-chrome]', e)
      })
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', inject)
  } else {
    inject()
  }
})()

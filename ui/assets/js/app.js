// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import '../css/app.scss'

import Alpine from 'alpinejs'
import 'phoenix_html'
import { Socket } from 'phoenix'
import NProgress from 'nprogress'
import { LiveSocket } from 'phoenix_live_view'
import PhoenixCustomEvent from 'phoenix-custom-event-hook'

import '@polymer/paper-slider/paper-slider'
Array.from(document.getElementsByTagName('paper-slider')).map((el) => {
  el.addEventListener('value-change', () =>
    el.fire('new-value', { value: el.value })
  )
  const customStyles = document.createElement('style')
  customStyles.innerHTML =
    '' +
    '.slider-input {width: 75px;}' +
    '.slider-knob {transform: scale(1.5);}'
  el.shadowRoot.appendChild(customStyles)
})

import 'color-picker-element'
Array.from(document.getElementsByTagName('color-picker')).map((el) => {
  el.addEventListener('change', () =>
    el.dispatchEvent(
      new CustomEvent('new-value', { detail: { value: el.value } })
    )
  )
})

import '@polymer/paper-dialog'

import '@fooloomanzoo/datetime-picker/time-picker'
Array.from(document.getElementsByTagName('time-picker')).map((el) => {
  const normalizeTime = (date) =>
        new Date(
          new Date(new Date(date.toISOString()).setDate(1)).setMonth(0)
        ).setFullYear(1970)
  el.addEventListener('input-picker-closed', () =>
    el.dispatchEvent(
      new CustomEvent('new-value', {
        detail: { value: normalizeTime(el.valueAsDate) }
      })
    )
  )
})

Array.from(
  document.querySelectorAll('input[type="radio"][name="audio_file"]')
).map((el) =>
  el.addEventListener('change', (e) =>
    e.target.dispatchEvent(
      new CustomEvent('new-value', { detail: { value: e.target.value } })
    )
  )
)

import '@polymer/paper-toast/paper-toast.js'

let Hooks = {}
Hooks.PhoenixCustomEvent = PhoenixCustomEvent
Hooks.SaveButton = {
  mounted() {
    this.handleEvent('saved', () => {
      document.getElementById('saved-toast').open()
    })
  }
}
let csrfToken = document
    .querySelector("meta[name='csrf-token']")
    .getAttribute('content')
let liveSocket = new LiveSocket('/live', Socket, {
  dom: {
    onBeforeElUpdated(from, to) {
      if (from.__x) Alpine.clone(from.__x, to)
    }
  },
  hooks: Hooks,
  params: { _csrf_token: csrfToken }
})

// Show progress bar on live navigation and form submits
window.addEventListener('phx:page-loading-start', (info) => NProgress.start())
window.addEventListener('phx:page-loading-stop', (info) => NProgress.done())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

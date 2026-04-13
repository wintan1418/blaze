import { Controller } from "@hotwired/stimulus"
import { Chart, registerables } from "chart.js"

Chart.register(...registerables)

// Thin wrapper around Chart.js driven by data-* attributes.
// Usage:
//   <div data-controller="chart"
//        data-chart-type-value="line"
//        data-chart-data-value='<%= { labels: [...], datasets: [...] }.to_json %>'>
//     <canvas data-chart-target="canvas"></canvas>
//   </div>
//
// Types supported: line, bar, column (→ bar), pie, doughnut, area (→ line with fill)
export default class extends Controller {
  static targets = ["canvas"]
  static values  = {
    type:    { type: String, default: "line" },
    data:    { type: Object, default: {} },
    options: { type: Object, default: {} }
  }

  connect() {
    const type = this.typeValue === "area" ? "line"
               : this.typeValue === "column" ? "bar"
               : this.typeValue

    this.chart = new Chart(this.canvasTarget.getContext("2d"), {
      type,
      data: this.buildData(),
      options: this.buildOptions(type)
    })
  }

  disconnect() {
    this.chart?.destroy()
  }

  buildData() {
    const data = JSON.parse(JSON.stringify(this.dataValue || {}))
    if (this.typeValue === "area" && data.datasets) {
      data.datasets = data.datasets.map((ds) => ({
        ...ds,
        fill: true,
        tension: 0.35,
        pointRadius: 0,
        borderWidth: 2,
        backgroundColor: ds.backgroundColor || this.withAlpha(ds.borderColor, 0.2)
      }))
    }
    return data
  }

  buildOptions(type) {
    const isPie = type === "pie" || type === "doughnut"
    const gridColor = "rgba(255,255,255,0.05)"
    const tickColor = "rgba(255,255,255,0.5)"
    const labelColor = "rgba(255,255,255,0.8)"

    const base = {
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: { labels: { color: labelColor, padding: 18, usePointStyle: true } },
        tooltip: {
          backgroundColor: "rgba(10,10,11,0.95)",
          borderColor: "rgba(232,52,26,0.5)",
          borderWidth: 1,
          padding: 12,
          titleColor: "white",
          bodyColor: "rgba(255,255,255,0.85)",
          callbacks: {
            label: (ctx) => {
              const v = ctx.parsed?.y ?? ctx.parsed ?? ctx.raw
              const label = ctx.dataset.label || ctx.label || ""
              return `${label}: ₦${Number(v).toLocaleString()}`
            }
          }
        }
      },
      scales: isPie ? {} : {
        x: { grid: { color: gridColor, drawBorder: false }, ticks: { color: tickColor, maxRotation: 0, autoSkipPadding: 20 } },
        y: { grid: { color: gridColor, drawBorder: false }, ticks: { color: tickColor, callback: (v) => "₦" + Number(v).toLocaleString() } }
      }
    }

    if (isPie) {
      base.plugins.legend.position = "bottom"
    }

    return this.mergeDeep(base, this.optionsValue || {})
  }

  withAlpha(hex, alpha) {
    if (!hex || typeof hex !== "string") return `rgba(232,52,26,${alpha})`
    const h = hex.replace("#", "")
    const r = parseInt(h.substring(0, 2), 16)
    const g = parseInt(h.substring(2, 4), 16)
    const b = parseInt(h.substring(4, 6), 16)
    return `rgba(${r},${g},${b},${alpha})`
  }

  mergeDeep(target, source) {
    const out = { ...target }
    for (const key of Object.keys(source || {})) {
      if (source[key] && typeof source[key] === "object" && !Array.isArray(source[key])) {
        out[key] = this.mergeDeep(target[key] || {}, source[key])
      } else {
        out[key] = source[key]
      }
    }
    return out
  }
}

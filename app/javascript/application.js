// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./controllers"

// Chartkick + Chart.js — the chart.esm.js entry has no default export
// but registers window.Chartkick as a side-effect. Just import for side effects.
import "chartkick/chart.js"

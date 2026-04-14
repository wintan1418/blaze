module ReferenceHelper
  # Renders a click-to-copy reference badge.
  #   <%= copyable_reference("BLZ-ABCD1234") %>
  def copyable_reference(value, label: nil)
    return "" if value.blank?
    content_tag(:button,
      type: "button",
      class: "inline-flex items-center gap-2 px-4 py-2 rounded-full bg-blaze-smoke border border-white/10 font-mono text-sm text-white hover:border-blaze-red/40 hover:bg-blaze-red/10 transition cursor-pointer",
      data: {
        controller: "clipboard",
        "clipboard-value-value": value,
        action: "click->clipboard#copy"
      }) do
      [
        content_tag(:span, (label || value), data: { "clipboard-target": "label" }),
        content_tag(:span, "Copied ✓", class: "hidden text-emerald-300", data: { "clipboard-target": "confirm" }),
        content_tag(:svg, content_tag(:path, "", "d" => "M8 4v12a2 2 0 002 2h8a2 2 0 002-2V7.5L16.5 2H10a2 2 0 00-2 2zM16 2v6h6").html_safe,
          xmlns: "http://www.w3.org/2000/svg", class: "w-4 h-4 text-white/50", fill: "none",
          stroke: "currentColor", "stroke-width" => "2", "stroke-linecap" => "round", "stroke-linejoin" => "round", viewBox: "0 0 24 24")
      ].join.html_safe
    end
  end
end

module ApplicationHelper
  include Pagy::Frontend

  def page_title(title = nil)
    if title
      content_for(:page_title, title)
    else
      content_for?(:page_title) ? "#{content_for(:page_title)} · Blaze Cafe" : "Blaze Cafe — Where Good Times Come Alive"
    end
  end

  def flash_class(level)
    case level.to_s
    when "notice" then "bg-emerald-500/10 text-emerald-300 border-emerald-500/30"
    when "alert", "error" then "bg-red-500/10 text-red-300 border-red-500/30"
    else "bg-zinc-500/10 text-zinc-200 border-zinc-500/30"
    end
  end

  # Custom pagy nav that matches the Blaze dark theme.
  # Returns an HTML-safe nav with prev / numbered pages / next.
  def blaze_pagy_nav(pagy)
    return "".html_safe if pagy.pages <= 1

    base_cls = "inline-flex items-center justify-center min-w-10 h-10 px-3 rounded-xl text-sm font-medium transition"
    link_cls = "#{base_cls} bg-white/5 border border-white/10 text-white/70 hover:bg-blaze-red hover:border-blaze-red hover:text-white"
    active_cls = "#{base_cls} bg-blaze-red border border-blaze-red text-white shadow-lg shadow-blaze-red/30"
    gap_cls = "#{base_cls} text-white/30"
    disabled_cls = "#{base_cls} bg-white/5 border border-white/5 text-white/20 cursor-not-allowed"

    parts = []
    # Prev
    if pagy.prev
      parts << link_to(pagy_prev_label, pagy_url_for(pagy, pagy.prev), class: link_cls, aria: { label: "Previous page" })
    else
      parts << content_tag(:span, pagy_prev_label, class: disabled_cls)
    end

    # Page series
    pagy.series.each do |item|
      parts << case item
               when Integer
                 link_to(item, pagy_url_for(pagy, item), class: link_cls, aria: { label: "Page #{item}" })
               when String
                 content_tag(:span, item, class: active_cls, aria: { current: "page" })
               when :gap
                 content_tag(:span, "…", class: gap_cls)
               end
    end

    # Next
    if pagy.next
      parts << link_to(pagy_next_label, pagy_url_for(pagy, pagy.next), class: link_cls, aria: { label: "Next page" })
    else
      parts << content_tag(:span, pagy_next_label, class: disabled_cls)
    end

    content_tag(:nav, parts.join.html_safe, class: "flex flex-wrap items-center gap-2", aria: { label: "Pagination" })
  end

  def pagy_prev_label
    content_tag(:svg, content_tag(:path, "", "d" => "M15 18l-6-6 6-6").html_safe,
      xmlns: "http://www.w3.org/2000/svg", class: "w-4 h-4", fill: "none", stroke: "currentColor",
      "stroke-width" => "2.5", "stroke-linecap" => "round", "stroke-linejoin" => "round",
      viewBox: "0 0 24 24")
  end

  def pagy_next_label
    content_tag(:svg, content_tag(:path, "", "d" => "M9 18l6-6-6-6").html_safe,
      xmlns: "http://www.w3.org/2000/svg", class: "w-4 h-4", fill: "none", stroke: "currentColor",
      "stroke-width" => "2.5", "stroke-linecap" => "round", "stroke-linejoin" => "round",
      viewBox: "0 0 24 24")
  end
end

module ChartHelper
  # Renders a Chart.js chart driven by the Stimulus chart_controller.
  #
  # type  — :line, :bar, :column, :pie, :doughnut, :area
  # data  — for line/bar/area charts: Array of { name:, data: {label => value} }
  #         for pie/doughnut: Hash { label => value }
  #         for column/bar (single-series): Hash { label => value }
  # height — CSS height string
  def blaze_chart(type, data, height: "240px")
    config = normalize_chart_data(type, data)

    content_tag(:div,
      content_tag(:canvas, "", data: { chart_target: "canvas" }),
      class: "relative w-full",
      style: "height: #{height}",
      data: {
        controller: "chart",
        "chart-type-value": type.to_s,
        "chart-data-value": config.to_json
      })
  end

  private

  def normalize_chart_data(type, data)
    case type.to_sym
    when :pie, :doughnut
      labels = data.keys.map(&:to_s)
      values = data.values
      {
        labels: labels,
        datasets: [ {
          data: values,
          backgroundColor: pie_palette(labels.size),
          borderColor: "rgba(10,10,11,0.9)",
          borderWidth: 2
        } ]
      }
    when :bar, :column
      # Single series hash → use as one dataset
      if data.is_a?(Hash)
        {
          labels: data.keys.map(&:to_s),
          datasets: [ {
            label: "Count",
            data: data.values,
            backgroundColor: "rgba(232,52,26,0.55)",
            borderColor: "#E8341A",
            borderWidth: 1,
            borderRadius: 6
          } ]
        }
      else
        # Multi-series array
        labels = data.first[:data].keys.map(&:to_s)
        palette = line_palette(data.size)
        {
          labels: labels,
          datasets: data.each_with_index.map do |series, i|
            {
              label: series[:name],
              data: series[:data].values,
              backgroundColor: palette[i],
              borderColor: palette[i],
              borderWidth: 1,
              borderRadius: 6
            }
          end
        }
      end
    when :line, :area
      palette = line_palette(data.size)
      labels = data.first[:data].keys.map(&:to_s)
      {
        labels: labels,
        datasets: data.each_with_index.map do |series, i|
          {
            label: series[:name],
            data: series[:data].values,
            borderColor: palette[i]
          }
        end
      }
    else
      {}
    end
  end

  def line_palette(count)
    base = [ "#E8341A", "#F5A623", "#8B5CF6", "#38BDF8", "#10B981", "#FB7185" ]
    Array.new(count) { |i| base[i % base.length] }
  end

  def pie_palette(count)
    base = [ "#E8341A", "#8B5CF6", "#38BDF8", "#F5A623", "#10B981", "#FB7185" ]
    Array.new(count) { |i| base[i % base.length] }
  end
end

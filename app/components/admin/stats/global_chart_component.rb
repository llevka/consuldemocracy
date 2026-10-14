class Admin::Stats::GlobalChartComponent < ApplicationComponent

  def initialize(from: nil, to: nil)
    @from = from
    @to = to
  end

  private

    def event_names
      Ahoy::Chart.active_event_names
    end

    def chart_tag
      tag.div("data-graph": data_points.to_json)
    end

    def data_points
      Ahoy::Chart.active_events_data_points(
        from: (@from.presence || "2025-01-01"),
        to: (@to.presence || Date.current.to_s)
      )
    end

    def title
      t("admin.stats.graph.title")
    end
end

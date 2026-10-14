module Ahoy
  class Chart
    attr_reader :event_name
    delegate :count, to: :records
    delegate :t, to: "ApplicationController.helpers"

    def initialize(event_name)
      @event_name = event_name
    end

    def self.active_event_names
      event_names_with_collections.select { |name, collection| collection.any? }.keys.sort_by do |event_name|
        new(event_name).title
      end
    end

    def self.event_names_with_collections
      {
        #budget_investment_created: Budget::Investment.with_hidden,
        user_created: User.with_hidden,
        debate_created: Debate.with_hidden,
        #legislation_annotation_created: Legislation::Annotation.with_hidden,
        legislation_answer_created: Legislation::Answer.with_hidden,
        level_3_user: User.with_hidden.level_three_verified,
        proposal_created: Proposal.with_hidden
      }
    end

#    def self.active_events_data_points
#      Ahoy::DataSource.build do |data_source|
#        active_event_names.map { |event_name| new(event_name) }.each do |chart|
#          data_source.add chart.title, chart.data
#        end
#      end
#    end

    def self.active_events_data_points(from: nil, to: nil)
      Ahoy::DataSource.build do |data_source|
        active_event_names.map { |event_name| new(event_name) }.each do |chart|
          data_source.add chart.title, chart.data(from: from, to: to)
        end
      end
    end

    def data_points
      Ahoy::DataSource.build do |data_source|
        data_source.add title, data
      end
    end

    def title
      t("admin.stats.graph.#{event_name}")
    end

#    def data
#      records_by_day.count
#    end

    def data(from: nil, to: nil)
      scoped_records = records

      if from.present?
        scoped_records = scoped_records.where(date_field => Date.parse(from)..)
      end

      if to.present?
        scoped_records = scoped_records.where(date_field => ..Date.parse(to).end_of_day)
      end

#      records_by_day(scoped_records).count
      records_by_day(scoped_records, from: from, to: to).count
    end


    private

      def records
        case event_name.to_sym
        when :budget_investment_supported
          Vote.where(votable_type: "Budget::Investment")
        when :visits
          Visit.all
        else
          self.class.event_names_with_collections[event_name.to_sym]
        end
      end

      def records_by_day(scoped_records = records, from: nil, to: nil)
        raise "Unknown event #{event_name}" unless scoped_records.respond_to?(:group_by_day)

        if event_name.to_sym == :user_created
          range_start = from.present? ? Date.parse(from).beginning_of_month : scoped_records.minimum(date_field)
          range_end = to.present? ? Date.parse(to).end_of_month : scoped_records.maximum(date_field)

          scoped_records.group_by_month(
            date_field,
            range: range_start..range_end
          )
        else
          scoped_records.group_by_day(date_field)
        end
      end

      def date_field
        if event_name.to_sym == :level_3_user
          :verified_at
        else
          :created_at
        end
      end
  end
end

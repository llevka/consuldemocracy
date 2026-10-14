class Polls::Results::QuestionComponent < ApplicationComponent

  # TODO check
# <<<<<<< HEAD
#   attr_reader :question, :list_text_answers
# =======
  attr_reader :question
  delegate :number_to_stats_percentage, to: :helpers
# >>>>>>> 2.6.0

  def initialize(question, list_text_answers = false)
    @question = question
    @list_text_answers = list_text_answers
  end

  def option_styles(option)
    "win" if most_voted_option?(option)
  end

  def most_voted_option?(option)
    option.id == question.most_voted_option_id
  end

  def number_with_percentage(number, percentage)
    safe_join([number, "(#{number_to_stats_percentage(percentage)})"], " ")
  end
end

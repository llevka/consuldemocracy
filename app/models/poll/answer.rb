class Poll::Answer < ApplicationRecord
  belongs_to :question, -> { with_hidden }, inverse_of: :answers
  belongs_to :option, class_name: "Poll::Question::Option"
  belongs_to :author, -> { with_hidden }, class_name: "User", inverse_of: :poll_answers

  delegate :poll, :poll_id, to: :question

  validates :question, presence: true
  validates :author, presence: true
  validates :answer, presence: true,
                     if: ->(poll_answer) { poll_answer.question&.open? }
  validates :answer, length: { maximum: ->(*) { Poll::Answer.answer_max_length }}
  validates :option, uniqueness: { scope: :author_id }, allow_nil: true
  validates :option, presence: true, if: ->(poll_answer) { poll_answer.question&.accepts_options? }

  scope :by_question, ->(question_id) { where(question_id: question_id) }

  def self.answer_max_length
    1000
  end
  
  private
    def max_votes
      return if !question || !author || persisted?

      if question.answers.by_author(author).count >= question.max_votes
        errors.add(:answer, "Maximum number of votes per user exceeded")
      end
    end
end

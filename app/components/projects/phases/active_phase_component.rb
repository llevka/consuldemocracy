class Projects::Phases::ActivePhaseComponent < ApplicationComponent
  include Header
  delegate :wysiwyg, :auto_link_already_sanitized_html, to: :helpers
  attr_reader :project_phase

  def initialize(project_phase)
    @project_phase = project_phase
    @project = project_phase.project
  end

  private
  
    def title
       @project_phase.title
    end
end

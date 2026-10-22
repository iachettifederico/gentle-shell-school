module Api
  class LabsController < BaseController
    def index
      render json: { labs: labs_system.labs(locale: requested_locale).map { |lab| summary_json(lab) } }
    end

    def show
      lab = labs_system.find_lab(params[:slug], locale: requested_locale)
      return render json: { error: "Lab not found" }, status: :not_found unless lab

      render json: detail_json(lab)
    end

    private

    def labs_system
      @labs_system ||= Course::LabsSystem.new(
        repository: Course::FileLabRepository.new(directory: Rails.configuration.x.labs_directory)
      )
    end

    def summary_json(lab)
      { slug: lab.slug, lesson: lab.lesson_slug, title: lab.title, locale: lab.locale }
    end

    def detail_json(lab)
      summary_json(lab).merge(
        brief: lab.brief, check: lab.check, rubric: lab.rubric, files: labs_system.files_for(lab.slug)
      )
    end
  end
end

module Admin
  class CasesController < BaseController
    before_action :set_case, only: %i[show edit update]
    before_action :load_analysts, only: %i[new create edit update]

    def index
      @cases = Case.includes(:evidences).order(opened_at: :desc)
    end

    def show
      @evidences = @case.evidences.includes(:evidence_type, :current_custodian).order(:code)
    end

    def new
      @case = Case.new(status: :open, opened_at: Time.current)
    end

    def create
      @case = Case.new(case_params)
      if @case.save
        redirect_to admin_case_path(@case), notice: "Caso creado correctamente."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @case.update(case_params)
        redirect_to admin_case_path(@case), notice: "Caso actualizado correctamente."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def set_case
      @case = Case.find(params[:id])
    end

    def load_analysts
      @analysts = User.active.analyst.order(:name)
    end

    def case_params
      params.require(:case).permit(:code, :title, :description, :status, :opened_at, :closed_at, analyst_ids: [])
    end
  end
end

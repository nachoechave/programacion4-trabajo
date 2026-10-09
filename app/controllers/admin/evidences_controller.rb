module Admin
  class EvidencesController < BaseController
    before_action :set_evidence, only: %i[show edit update report pdf]
    before_action :load_form_options, only: %i[new create edit update]

    def index
      @evidences = Evidence.includes(:case, :evidence_type, :current_custodian).order(:code)
    end

    def show
      @movements = custody_movements
    end

    def report
      @movements = custody_movements
    end

    def pdf
      movements = custody_movements
      document = EvidencePdfReport.new(evidence: @evidence, movements:).render

      send_data document,
                filename: "#{@evidence.code}-informe.pdf",
                type: "application/pdf",
                disposition: "attachment"
    end

    def new
      @evidence = Evidence.new(status: :registered, collected_at: Time.current)
    end

    def create
      @evidence = Evidence.new(create_params)
      EvidenceRegistrationService.call(evidence: @evidence, performed_by: current_admin)
      redirect_to admin_evidence_path(@evidence), notice: "Evidencia registrada correctamente."
    rescue ActiveRecord::RecordInvalid => error
      error.record.errors.full_messages.each { |message| @evidence.errors.add(:base, message) } unless error.record == @evidence
      render :new, status: :unprocessable_entity
    end

    def edit; end

    def update
      if @evidence.update(update_params)
        redirect_to admin_evidence_path(@evidence), notice: "Evidencia actualizada correctamente."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def set_evidence
      @evidence = Evidence.find(params[:id])
    end

    def custody_movements
      @evidence.custody_movements
               .includes(:from_user, :to_user, :performed_by)
               .order(:transferred_at, :id)
    end

    def load_form_options
      @cases = Case.open.order(:code)
      @evidence_types = EvidenceType.order(:name)
      @custodians = User.active.analyst.order(:name)
    end

    def create_params
      params.require(:evidence).permit(
        :code, :name, :description, :case_id, :evidence_type_id,
        :current_custodian_id, :status, :collected_at, :location, files: []
      )
    end

    def update_params
      params.require(:evidence).permit(
        :name, :description, :evidence_type_id, :status, :collected_at, :location
      )
    end
  end
end

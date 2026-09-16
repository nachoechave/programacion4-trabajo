module Admin
  class TransfersController < BaseController
    before_action :set_evidence
    before_action :load_custodians

    def new; end

    def create
      EvidenceTransferService.call(
        evidence: @evidence,
        to_user: User.find_by(id: transfer_params[:to_user_id]),
        reason: transfer_params[:reason],
        notes: transfer_params[:notes],
        performed_by: current_admin
      )
      redirect_to admin_evidence_path(@evidence), notice: "Custodia transferida correctamente."
    rescue EvidenceTransferService::TransferError, ActiveRecord::RecordInvalid => error
      @error = error.message
      render :new, status: :unprocessable_entity
    end

    private

    def set_evidence
      @evidence = Evidence.includes(:case, :current_custodian).find(params[:evidence_id])
    end

    def load_custodians
      @custodians = User.active.analyst.where.not(id: @evidence.current_custodian_id).order(:name)
    end

    def transfer_params
      params.require(:transfer).permit(:to_user_id, :reason, :notes)
    end
  end
end

module Admin
  class EvidenceTypesController < BaseController
    before_action :set_evidence_type, only: %i[show edit update destroy]

    def index
      @evidence_types = EvidenceType.order(:name)
    end

    def show; end

    def new
      @evidence_type = EvidenceType.new
    end

    def create
      @evidence_type = EvidenceType.new(evidence_type_params)
      if @evidence_type.save
        redirect_to admin_evidence_type_path(@evidence_type), notice: "Tipo de evidencia creado correctamente."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @evidence_type.update(evidence_type_params)
        redirect_to admin_evidence_type_path(@evidence_type), notice: "Tipo de evidencia actualizado correctamente."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @evidence_type.destroy
        redirect_to admin_evidence_types_path, notice: "Tipo de evidencia eliminado."
      else
        redirect_to admin_evidence_type_path(@evidence_type), alert: @evidence_type.errors.full_messages.to_sentence
      end
    end

    private

    def set_evidence_type
      @evidence_type = EvidenceType.find(params[:id])
    end

    def evidence_type_params
      params.require(:evidence_type).permit(:name, :description)
    end
  end
end

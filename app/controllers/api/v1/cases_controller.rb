module Api
  module V1
    class CasesController < BaseController
      def index
        cases = Case.order(opened_at: :desc)
        render json: cases.as_json(only: %i[id code title description status opened_at closed_at])
      end

      def show
        case_record = Case.includes(:analysts, :evidences).find(params[:id])
        render json: case_record.as_json(
          only: %i[id code title description status opened_at closed_at],
          include: {
            analysts: { only: %i[id name email] },
            evidences: { only: %i[id code name status current_custodian_id] }
          }
        )
      end
    end
  end
end

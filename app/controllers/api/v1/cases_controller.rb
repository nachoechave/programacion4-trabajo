module Api
  module V1
    class CasesController < BaseController
      before_action :require_api_admin!, only: :create

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

      def create
        case_record = Case.new(case_params)

        if case_record.save
          render json: case_record.as_json(
            only: %i[id code title description status opened_at closed_at]
          ), status: :created
        else
          render json: { errors: case_record.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def case_params
        params.require(:case).permit(:code, :title, :description, :status, :opened_at, :closed_at)
      end
    end
  end
end

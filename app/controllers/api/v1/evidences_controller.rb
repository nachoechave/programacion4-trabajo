module Api
  module V1
    class EvidencesController < BaseController
      def index
        evidences = accessible_evidences.includes(:case, :evidence_type, :current_custodian).order(:code)
        render json: evidences.map { |evidence| serialize(evidence) }
      end

      def show
        evidence = accessible_evidences.includes(:case, :evidence_type, :current_custodian).find(params[:id])
        render json: serialize(evidence)
      end

      private

      def accessible_evidences
        current_api_user.admin? ? Evidence.all : Evidence.where(case_id: current_api_user.assigned_cases.select(:id))
      end

      def serialize(evidence)
        {
          id: evidence.id,
          code: evidence.code,
          name: evidence.name,
          description: evidence.description,
          status: evidence.status,
          collected_at: evidence.collected_at,
          location: evidence.location,
          case: evidence.case.slice(:id, :code, :title),
          evidence_type: evidence.evidence_type.slice(:id, :name),
          current_custodian: evidence.current_custodian.slice(:id, :name, :email)
        }
      end
    end
  end
end

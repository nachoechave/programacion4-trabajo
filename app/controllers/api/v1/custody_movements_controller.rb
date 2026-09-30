module Api
  module V1
    class CustodyMovementsController < BaseController
      def index
        evidence = Evidence.find(params[:evidence_id])
        movements = evidence.custody_movements
                            .includes(:from_user, :to_user, :performed_by)
                            .order(:transferred_at, :id)

        render json: {
          evidence: evidence.slice(:id, :code, :name),
          custody_movements: movements.map { |movement| serialize(movement) }
        }
      end

      private

      def serialize(movement)
        {
          id: movement.id,
          from_user: movement.from_user&.slice(:id, :name, :email),
          to_user: movement.to_user.slice(:id, :name, :email),
          performed_by: movement.performed_by.slice(:id, :name, :email),
          transferred_at: movement.transferred_at,
          reason: movement.reason,
          notes: movement.notes
        }
      end
    end
  end
end

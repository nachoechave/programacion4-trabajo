module Admin
  class CustodyMovementsController < BaseController
    def index
      @movements = CustodyMovement.includes(:evidence, :from_user, :to_user, :performed_by)
                                  .order(transferred_at: :desc, id: :desc)
    end

    def show
      @movement = CustodyMovement.includes(:evidence, :from_user, :to_user, :performed_by).find(params[:id])
    end
  end
end

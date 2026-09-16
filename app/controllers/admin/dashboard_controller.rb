module Admin
  class DashboardController < BaseController
    def index
      @open_cases_count = Case.open.count
      @evidences_count = Evidence.count
      @under_analysis_count = Evidence.under_analysis.count
      @active_users_count = User.active.count
      @recent_movements = CustodyMovement.includes(:evidence, :from_user, :to_user)
                                            .order(transferred_at: :desc)
                                            .limit(5)
    end
  end
end

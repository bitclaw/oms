class CampaignQuery
  def initialize(merchant, params = {})
    @merchant = merchant
    @params   = params
  end

  def campaigns
    scope = @merchant.campaigns.includes(:card_sends).order(created_at: :desc)
    scope = scope.where(status: @params[:status])               if @params[:status]
    scope = scope.where(campaign_type: @params[:campaign_type]) if @params[:campaign_type]
    scope.map { |c| CampaignPresenter.new(c) }
  end
end

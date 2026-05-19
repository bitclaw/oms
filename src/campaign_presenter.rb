class CampaignPresenter
  CARD_FORMAT_LABELS = {
    "postcard_4x6"  => "4x6",
    "postcard_6x9"  => "6x9",
    "postcard_6x11" => "6x11",
    "handwritten"   => "Handwritten",
    "cardalog"      => "Cardalog",
  }.freeze

  def initialize(campaign)
    @campaign = campaign
  end

  def name          = @campaign.name
  def campaign_type = @campaign.campaign_type
  def status        = @campaign.status
  def created_at    = @campaign.created_at

  def card_format_label
    CARD_FORMAT_LABELS.fetch(@campaign.card_format, @campaign.card_format.gsub("_", " ").capitalize)
  end

  def total_cards
    # #size returns loaded array length when association is eager-loaded (no extra query)
    @total_cards ||= @campaign.card_sends.size
  end

  def delivered_count
    @delivered_count ||= @campaign.card_sends.count { |cs| cs.status == "delivered" }
  end

  def delivery_rate
    return "N/A" if total_cards.zero?

    "#{(delivered_count.to_f / total_cards * 100).round(1)}%"
  end

  # Performance metrics (cost, ROAS) live in an external analytics service, not in this DB.
  # Before implementing, I'd clarify with the team:
  #   - Which service owns this data? (internal event pipeline, third-party attribution tool?)
  #   - Freshness requirement? (real-time per request vs. cached daily rollup)
  #   - Sync API call on page load, or pre-aggregated into a local read table?
  #
  # Likely implementation: PerformanceMetricsService.fetch_for_campaigns(campaign_ids) →
  # hash keyed by campaign_id, fetched once per dashboard load with a short cache TTL.
  # Stub returned here so the view renders a placeholder without raising.
  def performance_metrics
    { cost: nil, roas: nil }
  end
end

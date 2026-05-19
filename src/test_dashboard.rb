require "minitest/autorun"
require "minitest/reporters"
require_relative "setup"
require_relative "campaign_presenter"
require_relative "campaign_query"

Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

module DashboardTestHelper
  def setup
    CardSend.delete_all
    Campaign.delete_all
    Merchant.delete_all
    @merchant = Merchant.create!(name: "Test Merchant", plan: "growth")
  end

  def build_campaign(attrs = {})
    Campaign.create!({
      merchant:      @merchant,
      name:          "Test Campaign",
      campaign_type: "acquisition",
      status:        "active",
      card_format:   "postcard_4x6",
    }.merge(attrs))
  end
end

# ---------------------------------------------------------------------------
# CampaignPresenter — metric calculations
# ---------------------------------------------------------------------------
class CampaignPresenterTest < Minitest::Test
  include DashboardTestHelper

  def test_total_cards_includes_returned
    campaign = build_campaign
    CardSend.create!(campaign: campaign, status: "delivered")
    CardSend.create!(campaign: campaign, status: "returned")
    CardSend.create!(campaign: campaign, status: "shipped")

    assert_equal 3, CampaignPresenter.new(campaign).total_cards
  end

  def test_delivered_count_only_counts_delivered_status
    campaign = build_campaign
    2.times { CardSend.create!(campaign: campaign, status: "delivered") }
    CardSend.create!(campaign: campaign, status: "shipped")
    CardSend.create!(campaign: campaign, status: "returned")

    assert_equal 2, CampaignPresenter.new(campaign).delivered_count
  end

  def test_delivery_rate_percentage
    campaign = build_campaign
    3.times { CardSend.create!(campaign: campaign, status: "delivered") }
    CardSend.create!(campaign: campaign, status: "shipped")

    assert_equal "75.0%", CampaignPresenter.new(campaign).delivery_rate
  end

  def test_delivery_rate_is_na_when_no_cards
    campaign = build_campaign
    assert_equal "N/A", CampaignPresenter.new(campaign).delivery_rate
  end

  def test_delivery_rate_rounds_to_one_decimal
    campaign = build_campaign
    2.times { CardSend.create!(campaign: campaign, status: "delivered") }
    CardSend.create!(campaign: campaign, status: "shipped")

    assert_equal "66.7%", CampaignPresenter.new(campaign).delivery_rate
  end

  def test_card_format_label_postcard
    assert_equal "6x9",  CampaignPresenter.new(build_campaign(card_format: "postcard_6x9")).card_format_label
    assert_equal "4x6",  CampaignPresenter.new(build_campaign(card_format: "postcard_4x6")).card_format_label
    assert_equal "6x11", CampaignPresenter.new(build_campaign(card_format: "postcard_6x11")).card_format_label
  end

  def test_card_format_label_non_postcard
    assert_equal "Handwritten", CampaignPresenter.new(build_campaign(card_format: "handwritten")).card_format_label
    assert_equal "Cardalog",    CampaignPresenter.new(build_campaign(card_format: "cardalog")).card_format_label
  end
end

# ---------------------------------------------------------------------------
# CampaignQuery — filtering
# ---------------------------------------------------------------------------
class CampaignQueryTest < Minitest::Test
  include DashboardTestHelper

  def query(params = {})
    CampaignQuery.new(@merchant, params).campaigns
  end

  def test_no_filter_returns_all_campaigns
    build_campaign(name: "A", status: "active",    campaign_type: "acquisition")
    build_campaign(name: "B", status: "draft",     campaign_type: "retention")
    build_campaign(name: "C", status: "completed", campaign_type: "retargeting")

    assert_equal 3, query.count
  end

  def test_filter_by_status
    build_campaign(name: "Active", status: "active")
    build_campaign(name: "Draft",  status: "draft")

    results = query(status: "active")
    assert_equal 1, results.count
    assert_equal "Active", results.first.name
  end

  def test_filter_by_campaign_type
    build_campaign(name: "Acq", campaign_type: "acquisition")
    build_campaign(name: "Ret", campaign_type: "retention")

    results = query(campaign_type: "retention")
    assert_equal 1, results.count
    assert_equal "Ret", results.first.name
  end

  def test_filter_by_status_and_type_combined
    build_campaign(name: "Match",    status: "active", campaign_type: "retention")
    build_campaign(name: "NoMatch1", status: "draft",  campaign_type: "retention")
    build_campaign(name: "NoMatch2", status: "active", campaign_type: "acquisition")

    results = query(status: "active", campaign_type: "retention")
    assert_equal 1, results.count
    assert_equal "Match", results.first.name
  end

  def test_filter_returns_empty_when_no_match
    build_campaign(status: "active")

    assert_empty query(status: "completed")
  end

  def test_results_are_campaign_presenters
    build_campaign

    assert_instance_of CampaignPresenter, query.first
  end
end

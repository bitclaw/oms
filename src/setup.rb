# setup.rb — DO NOT MODIFY THIS FILE
# This file sets up the database, defines models, and loads sample data.

require "active_record"

# ---------------------------------------------------------------------------
# Database connection (in-memory SQLite)
# ---------------------------------------------------------------------------
ActiveRecord::Base.establish_connection(
  adapter: "sqlite3",
  database: ":memory:"
)

ActiveRecord::Schema.verbose = false

# ---------------------------------------------------------------------------
# Schema
# ---------------------------------------------------------------------------
ActiveRecord::Schema.define do
  create_table :merchants do |t|
    t.string :name, null: false
    t.string :plan, null: false
    t.timestamps
  end

  create_table :campaigns do |t|
    t.references :merchant, null: false, foreign_key: true
    t.string :name, null: false
    t.string :campaign_type, null: false
    t.string :status, null: false
    t.string :card_format, null: false
    t.timestamps
  end

  create_table :card_sends do |t|
    t.references :campaign, null: false, foreign_key: true
    t.string :status, null: false
    t.timestamps
  end
end

# ---------------------------------------------------------------------------
# Models
# ---------------------------------------------------------------------------
class Merchant < ActiveRecord::Base
  has_many :campaigns
end

class Campaign < ActiveRecord::Base
  belongs_to :merchant
  has_many :card_sends
end

class CardSend < ActiveRecord::Base
  belongs_to :campaign
end

# ---------------------------------------------------------------------------
# Seed data
# ---------------------------------------------------------------------------
merchant = Merchant.create!(name: "Brew & Bloom Coffee Co.", plan: "pro")

# Campaign 1: Active acquisition campaign with a mix of send statuses
c1 = Campaign.create!(
  merchant: merchant,
  name: "Spring Acquisition Blast",
  campaign_type: "acquisition",
  status: "active",
  card_format: "postcard_6x9",
  created_at: Time.new(2025, 3, 1)
)
80.times { CardSend.create!(campaign: c1, status: "delivered") }
15.times { CardSend.create!(campaign: c1, status: "shipped") }
5.times  { CardSend.create!(campaign: c1, status: "returned") }

# Campaign 2: Completed retention campaign
c2 = Campaign.create!(
  merchant: merchant,
  name: "Holiday Win-Back 2024",
  campaign_type: "retention",
  status: "completed",
  card_format: "handwritten",
  created_at: Time.new(2024, 11, 15)
)
120.times { CardSend.create!(campaign: c2, status: "delivered") }
25.times  { CardSend.create!(campaign: c2, status: "shipped") }
5.times   { CardSend.create!(campaign: c2, status: "returned") }

# Campaign 3: Paused retargeting campaign
c3 = Campaign.create!(
  merchant: merchant,
  name: "Cart Abandonment Follow-Up",
  campaign_type: "retargeting",
  status: "paused",
  card_format: "postcard_4x6",
  created_at: Time.new(2025, 1, 10)
)
30.times { CardSend.create!(campaign: c3, status: "delivered") }
10.times { CardSend.create!(campaign: c3, status: "printed") }
5.times  { CardSend.create!(campaign: c3, status: "pending") }

# Campaign 4: Draft campaign with zero sends
c4 = Campaign.create!(
  merchant: merchant,
  name: "Summer VIP Postcards",
  campaign_type: "retention",
  status: "draft",
  card_format: "postcard_6x11",
  created_at: Time.new(2025, 4, 1)
)

# Campaign 5: Active retention campaign
c5 = Campaign.create!(
  merchant: merchant,
  name: "Loyalty Reactivation Q1",
  campaign_type: "retention",
  status: "active",
  card_format: "cardalog",
  created_at: Time.new(2025, 2, 14)
)
45.times { CardSend.create!(campaign: c5, status: "delivered") }
30.times { CardSend.create!(campaign: c5, status: "shipped") }
10.times { CardSend.create!(campaign: c5, status: "pending") }
5.times  { CardSend.create!(campaign: c5, status: "returned") }

# Campaign 6: Completed acquisition campaign
c6 = Campaign.create!(
  merchant: merchant,
  name: "New Year Prospecting",
  campaign_type: "acquisition",
  status: "completed",
  card_format: "postcard_6x9",
  created_at: Time.new(2025, 1, 2)
)
200.times { CardSend.create!(campaign: c6, status: "delivered") }
10.times  { CardSend.create!(campaign: c6, status: "returned") }

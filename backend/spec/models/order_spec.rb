# frozen_string_literal: true

require "rails_helper"

RSpec.describe Order, type: :model do
  describe "STATUSES" do
    it "contains the expected lifecycle values" do
      expect(Order::STATUSES).to eq(%w[pending completed cancelled])
    end
  end

  describe "validations" do
    subject { build(:order) }

    it { is_expected.to validate_presence_of(:customer_name) }
    it { is_expected.to validate_presence_of(:product) }
    it { is_expected.to validate_presence_of(:amount_cents) }
    it { is_expected.to validate_presence_of(:status) }

    it {
      is_expected.to validate_numericality_of(:amount_cents)
        .only_integer
        .is_greater_than(0)
    }

    it {
      is_expected.to validate_inclusion_of(:status)
        .in_array(Order::STATUSES)
    }
  end

  describe ".ordered" do
    it "returns orders newest first" do
      older = create(:order, created_at: 2.days.ago)
      newer = create(:order, created_at: 1.day.ago)

      expect(Order.ordered.to_a).to eq([ newer, older ])
    end
  end
end

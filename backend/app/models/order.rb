# frozen_string_literal: true

class Order < ApplicationRecord
  STATUSES = %w[pending completed cancelled].freeze

  validates :customer_name, presence: true
  validates :product,       presence: true
  validates :amount_cents,  presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :status,        presence: true, inclusion: { in: STATUSES }

  scope :ordered, -> { order(created_at: :desc) }
end

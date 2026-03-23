# frozen_string_literal: true

FactoryBot.define do
  factory :order do
    customer_name { "Daniel Chavez" }
    product       { "Product 1" }
    amount_cents  { 4999 }
    status        { "pending" }
  end
end

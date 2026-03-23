# frozen_string_literal: true

class CreateOrders < ActiveRecord::Migration[7.2]
  def change
    create_table :orders, comment: "Stores customer orders placed through the OMS" do |t|
      t.column :customer_name, :string,  null: false, comment: "Full name of the customer placing the order"
      t.column :product,       :string,  null: false, comment: "Name or description of the product ordered"
      t.column :amount_cents,  :integer, null: false, comment: "Order total in cents to avoid floating-point precision issues"
      t.column :status,        :string,  null: false, default: "pending", comment: "Lifecycle status of the order: pending, completed, cancelled"

      t.timestamps
    end

    add_index :orders, :status, comment: "Supports filtering orders by status"
  end
end

# Preview all emails at http://localhost:3000/rails/mailers/order_mailer
class OrderMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/order_mailer/order_created
  def order_created
    order = Order.first || Order.new(
      id: 0,
      customer_name: "Alice Smith",
      product: "Widget Pro",
      amount_cents: 4999,
      status: "pending"
    )
    OrderMailer.order_created(order)
  end
end

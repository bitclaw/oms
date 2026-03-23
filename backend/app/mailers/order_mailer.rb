# frozen_string_literal: true

class OrderMailer < ApplicationMailer
  def order_created(order)
    @order = order

    mail(
      to: "orders@aceup.com",
      subject: t(".subject", order_id: order.id, product: order.product)
    )
  end
end

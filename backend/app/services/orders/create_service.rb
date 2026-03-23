# frozen_string_literal: true

module Orders
  class CreateService
    Result = Struct.new(:success, :order, :errors, keyword_init: true) do
      def success? = success
    end

    def initialize(params)
      @params = params
    end

    def call
      order = Order.new(@params)

      if order.save
        OrderMailer.order_created(order).deliver_now
        Result.new(success: true, order: order, errors: [])
      else
        Result.new(success: false, order: nil, errors: order.errors.full_messages)
      end
    end
  end
end

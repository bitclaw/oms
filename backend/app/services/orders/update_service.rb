# frozen_string_literal: true

module Orders
  class UpdateService
    Result = Struct.new(:success, :order, :errors, keyword_init: true) do
      def success? = success
    end

    def initialize(order, params)
      @order = order
      @params = params
    end

    def call
      if @order.update(@params)
        Result.new(success: true, order: @order, errors: [])
      else
        Result.new(success: false, order: nil, errors: @order.errors.full_messages)
      end
    end
  end
end

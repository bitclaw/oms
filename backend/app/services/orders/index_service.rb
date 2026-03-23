# frozen_string_literal: true

module Orders
  class IndexService
    Result = Struct.new(:orders, keyword_init: true)

    def call
      Result.new(orders: Order.ordered)
    end
  end
end

# frozen_string_literal: true

module Api
  module V1
    class OrdersController < ApplicationController
      def index
        result = Orders::IndexService.new.call
        render json: result.orders, status: :ok
      end

      def create
        result = Orders::CreateService.new(order_params).call

        if result.success?
          render json: result.order, status: :created
        else
          render json: { errors: result.errors }, status: :unprocessable_entity
        end
      end

      private

      def order_params
        params.require(:order).permit(:customer_name, :product, :amount_cents)
      end
    end
  end
end

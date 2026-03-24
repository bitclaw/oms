# frozen_string_literal: true

module Api
  module V1
    class OrdersController < ApplicationController
      before_action :set_order, only: [ :show, :update ]

      def index
        result = Orders::IndexService.new.call
        render json: result.orders, status: :ok
      end

      def show
        render json: @order, status: :ok
      end

      def update
        result = Orders::UpdateService.new(@order, order_params).call

        if result.success?
          render json: result.order, status: :ok
        else
          render json: { errors: result.errors }, status: :unprocessable_entity
        end
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

      def set_order
        @order = Order.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Order not found" }, status: :not_found
      end

      def order_params
        params.require(:order).permit(:customer_name, :product, :amount_cents, :status)
      end
    end
  end
end

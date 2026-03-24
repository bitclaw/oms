# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Api::V1::Orders", type: :request do
  describe "GET /api/v1/orders" do
    context "when orders exist" do
      before { create_list(:order, 3) }

      it "returns 200" do
        get "/api/v1/orders"
        expect(response).to have_http_status(:ok)
      end

      it "returns all orders as JSON" do
        get "/api/v1/orders"
        expect(json_body.length).to eq(3)
      end
    end

    context "when no orders exist" do
      it "returns an empty array" do
        get "/api/v1/orders"
        expect(response).to have_http_status(:ok)
        expect(json_body).to eq([])
      end
    end
  end

  describe "GET /api/v1/orders/:id" do
    let(:order) { create(:order) }

    context "when the order exists" do
      it "returns 200" do
        get "/api/v1/orders/#{order.id}"
        expect(response).to have_http_status(:ok)
      end

      it "returns the order" do
        get "/api/v1/orders/#{order.id}"
        expect(json_body[:id]).to eq(order.id)
        expect(json_body[:customer_name]).to eq(order.customer_name)
      end
    end

    context "when the order does not exist" do
      it "returns 404" do
        get "/api/v1/orders/0"
        expect(response).to have_http_status(:not_found)
      end

      it "returns an error message" do
        get "/api/v1/orders/0"
        expect(json_body[:error]).to eq("Order not found")
      end
    end
  end

  describe "PATCH /api/v1/orders/:id" do
    let(:order) { create(:order, status: "pending") }

    context "with valid params" do
      it "returns 200" do
        patch "/api/v1/orders/#{order.id}", params: { order: { status: "completed" } }, as: :json
        expect(response).to have_http_status(:ok)
      end

      it "updates the order" do
        patch "/api/v1/orders/#{order.id}", params: { order: { status: "completed" } }, as: :json
        expect(json_body[:status]).to eq("completed")
      end
    end

    context "with invalid params" do
      it "returns 422" do
        patch "/api/v1/orders/#{order.id}", params: { order: { amount_cents: -1 } }, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns an errors array" do
        patch "/api/v1/orders/#{order.id}", params: { order: { amount_cents: -1 } }, as: :json
        expect(json_body[:errors]).to be_an(Array)
        expect(json_body[:errors]).not_to be_empty
      end
    end

    context "when the order does not exist" do
      it "returns 404" do
        patch "/api/v1/orders/0", params: { order: { status: "completed" } }, as: :json
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "DELETE /api/v1/orders/:id" do
    let!(:order) { create(:order) }

    context "when the order exists" do
      it "returns 204" do
        delete "/api/v1/orders/#{order.id}"
        expect(response).to have_http_status(:no_content)
      end

      it "deletes the order" do
        expect {
          delete "/api/v1/orders/#{order.id}"
        }.to change(Order, :count).by(-1)
      end
    end

    context "when the order does not exist" do
      it "returns 404" do
        delete "/api/v1/orders/0"
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "POST /api/v1/orders" do
    let(:valid_params) do
      {
        order: {
          customer_name: "Daniel Chavez",
          product:       "Product 1",
          amount_cents:  4999
        }
      }
    end

    context "with valid params" do
      it "returns 201" do
        post "/api/v1/orders", params: valid_params, as: :json
        expect(response).to have_http_status(:created)
      end

      it "creates the order" do
        expect {
          post "/api/v1/orders", params: valid_params, as: :json
        }.to change(Order, :count).by(1)
      end

      it "returns the created order" do
        post "/api/v1/orders", params: valid_params, as: :json
        expect(json_body[:customer_name]).to eq("Daniel Chavez")
        expect(json_body[:amount_cents]).to eq(4999)
      end
    end

    context "with invalid params" do
      let(:invalid_params) { { order: { customer_name: "", product: "", amount_cents: -1 } } }

      it "returns 422" do
        post "/api/v1/orders", params: invalid_params, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns an errors array" do
        post "/api/v1/orders", params: invalid_params, as: :json
        expect(json_body[:errors]).to be_an(Array)
        expect(json_body[:errors]).not_to be_empty
      end

      it "does not create an order" do
        expect {
          post "/api/v1/orders", params: invalid_params, as: :json
        }.not_to change(Order, :count)
      end
    end
  end
end

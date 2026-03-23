require "rails_helper"

RSpec.describe OrderMailer, type: :mailer do
  describe "#order_created" do
    let(:order) { create(:order) }
    let(:mail)  { OrderMailer.order_created(order) }

    it "sends to the orders address" do
      expect(mail.to).to eq([ "orders@aceup.com" ])
    end

    it "sends from the noreply address" do
      expect(mail.from).to eq([ "noreply@aceup.com" ])
    end

    it "includes the order ID and product in the subject" do
      expect(mail.subject).to eq("Order ##{order.id} confirmed — #{order.product}")
    end

    it "includes the customer name in the body" do
      expect(mail.body.encoded).to include(order.customer_name)
    end

    it "includes the formatted amount in the body" do
      expect(mail.body.encoded).to include("$49.99")
    end
  end
end

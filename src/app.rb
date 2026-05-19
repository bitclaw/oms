require_relative "setup"
require_relative "campaign_presenter"
require "erb"

# ============================================================================
# Campaign Dashboard
# ============================================================================

# Simulate request parameters (change these to test filtering)
params = {}
# params = { status: "active" }
# params = { campaign_type: "retention" }
# params = { status: "active", campaign_type: "retention" }

merchant = Merchant.find(1)

scope = merchant.campaigns.includes(:card_sends).order(created_at: :desc)
scope = scope.where(status: params[:status])               if params[:status]
scope = scope.where(campaign_type: params[:campaign_type]) if params[:campaign_type]

campaigns = scope.map { |c| CampaignPresenter.new(c) }

active_filters = params.slice(:status, :campaign_type)

# ============================================================================
# Dashboard View
# ============================================================================

template = ERB.new(<<-'HTML', trim_mode: '-')
<!DOCTYPE html>
<html>
<head>
  <title>Campaign Dashboard</title>
  <style>
    body { font-family: Arial, sans-serif; margin: 20px; }
    table { border-collapse: collapse; width: 100%; }
    th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
    th { background-color: #f5f5f5; }
    .status-active    { color: green;  font-weight: bold; }
    .status-paused    { color: orange; font-weight: bold; }
    .status-draft     { color: gray; }
    .status-completed { color: #333; }
    .filters { margin-bottom: 16px; font-size: 0.9em; color: #555; }
    .no-results { padding: 16px; color: #888; }
    .perf-placeholder { color: #aaa; font-style: italic; font-size: 0.85em; }
  </style>
</head>
<body>
  <h1><%= merchant.name %></h1>
  <p>Plan: <%= merchant.plan.upcase %> | Campaigns shown: <%= campaigns.count %></p>

  <% if active_filters.any? %>
    <div class="filters">
      Filters:
      <% active_filters.each do |key, value| %>
        <strong><%= key.to_s.gsub("_", " ").capitalize %>:</strong> <%= value %> &nbsp;
      <% end %>
    </div>
  <% end %>

  <% if campaigns.empty? %>
    <p class="no-results">No campaigns match the selected filters.</p>
  <% else %>
    <table>
      <thead>
        <tr>
          <th>Campaign Name</th>
          <th>Type</th>
          <th>Status</th>
          <th>Card Format</th>
          <th>Total Cards</th>
          <th>Delivered</th>
          <th>Delivery Rate</th>
          <th>Performance</th>
          <th>Created</th>
        </tr>
      </thead>
      <tbody>
      <% campaigns.each do |campaign| %>
        <tr>
          <td><%= campaign.name %></td>
          <td><%= campaign.campaign_type.capitalize %></td>
          <td>
            <span class="status-<%= campaign.status %>"><%= campaign.status.upcase %></span>
          </td>
          <td><%= campaign.card_format_label %></td>
          <td><%= campaign.total_cards %></td>
          <td><%= campaign.delivered_count %></td>
          <td><%= campaign.delivery_rate %></td>
          <td>
            <% perf = campaign.performance_metrics %>
            <% if perf[:cost] || perf[:roas] %>
              Cost: <%= perf[:cost] %> | ROAS: <%= perf[:roas] %>
            <% else %>
              <span class="perf-placeholder">Pending analytics integration</span>
            <% end %>
          </td>
          <td><%= campaign.created_at.strftime("%B %d, %Y") %></td>
        </tr>
      <% end %>
      </tbody>
    </table>
  <% end %>

</body>
</html>
HTML

puts template.result(binding)

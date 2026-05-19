Campaign Dashboard Refactor
Time Limit: 60 minutes
AI Tools: Enabled
You may use AI coding assistants during this assessment. You are responsible for understanding and being able to explain all code you submit.

Background
You are working at a direct mail marketing platform for e-commerce brands. Merchants use the platform to create campaigns that send physical postcards and cards to their customers. Each campaign targets a specific goal — acquiring new customers, retargeting website visitors, or retaining and reactivating existing customers.

You are working on the merchant-facing campaign dashboard. This is the main page where merchants view and manage all of their campaigns.

Your Task
The current dashboard code works, but it has grown messy over time. Business logic is mixed into the view templates, queries are inefficient, and the code is difficult to extend.

Your job is to:

Refactor the existing code to improve its structure, readability, and maintainability. The existing code has quality and correctness issues — fix any problems you find in the code you are working with.

Add filtering functionality so merchants can filter their campaign list by status and by campaign type. Filters should work together (a merchant can filter by both status AND type at the same time).

Data Model
The application has three main models:

Merchant

id — unique identifier
name — business name
plan — subscription tier ("growth" or "pro")
Campaign

id — unique identifier
merchant_id — the merchant who owns this campaign
name — campaign name (e.g., "Spring Win-Back 2025")
campaign_type — one of: "acquisition", "retargeting", "retention"
status — one of: "draft", "active", "paused", "completed"
card_format — one of: "postcard_4x6", "postcard_6x9", "postcard_6x11", "handwritten", "cardalog"
created_at — when the campaign was created
CardSend

id — unique identifier
campaign_id — which campaign this card belongs to
status — one of: "pending", "printed", "shipped", "delivered", "returned"
created_at — when the card send was created
Business Rules for Filtering
When no filters are applied, show all campaigns for the merchant.
When a status filter is provided, show only campaigns with that status.
When a campaign_type filter is provided, show only campaigns of that type.
When both filters are provided, show only campaigns that match BOTH.
Filter values come from query parameters: params[:status] and params[:campaign_type].
Business Rules for Campaign Metrics
Each campaign should display the following metrics in the dashboard:

Total cards — the total number of CardSend records for that campaign.
Cards delivered — the number of CardSend records with status "delivered".
Delivery rate — cards delivered divided by total cards, displayed as a percentage. If total cards is zero, the delivery rate should display as "N/A".
One Intentionally Open-Ended Requirement
The product team has requested that the dashboard also show a "Campaign Performance" section for each campaign, displaying metrics like total cost and return on ad spend (ROAS).

However, this data is not available in the CardSend table. It would come from a separate analytics service that is not part of this codebase.

There is no single correct way to handle this. You may:

Implement a stub or placeholder and explain in a comment how you would integrate the real data
Leave a comment describing what you would need to clarify with the team before implementing
Both approaches are valid. We are interested in how you think about this problem, not whether you guess the "right" answer.

Files
src/setup.rb — Do not modify. This sets up the database, defines the models, and loads sample data.
src/app.rb — This is the file you will modify. It contains the controller logic and the view template. This is the messy code you are refactoring. You may also create additional files if you wish.
instructions.md — This file.
To run the dashboard, use: bundle exec ruby src/app.rb

Your refactored code should still produce a working dashboard when run.

What We Are Evaluating
We will evaluate your submission on:

Does it work? Do the filters, metrics, and display function correctly?
Code organization. Did you separate concerns cleanly? Is business logic out of the view? Are methods small and focused?
Readability. Would a new team member understand your code without explanation? Are names clear and consistent?
Judgment. How did you handle the open-ended performance metrics requirement? Did you demonstrate awareness of system boundaries?
Quality improvements. Did you identify and fix issues in the existing code beyond what was explicitly asked?
Getting Started
Read through src/app.rb to understand the current code.
Run bundle exec ruby src/app.rb to see the current output.
Refactor and extend the code to meet the requirements above.
Run your code to confirm it works.
Make sure your code is clean and ready for review before submitting.
Good luck.


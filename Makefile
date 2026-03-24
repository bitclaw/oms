env.setup:
	cp .env.example .env

build:
	docker-compose -f docker-compose.yml up -d db redis backend frontend

bundle.update:
	docker-compose run --rm --no-deps backend bundle update

start:
	docker-compose up

stop:
	docker-compose down

rails.c:
	docker-compose run --rm backend rails c

sh:
	docker-compose run --rm backend sh

frontend.sh:
	docker-compose run --rm frontend sh

db.init:
	docker-compose run --rm backend bundle exec rake db:create db:migrate db:seed

db.migrate:
	docker-compose run --rm backend bundle exec rake db:migrate

db.reset:
	docker-compose run --rm backend bundle exec rake db:drop db:create db:migrate db:seed

db.rollback:
	docker-compose run --rm backend bundle exec rake db:rollback

test:
	docker-compose run --rm -e RAILS_ENV=test backend bundle exec rspec

rubocop:
	docker-compose run --rm --no-deps backend bundle exec rubocop

rubocop.fix:
	docker-compose run --rm --no-deps backend bundle exec rubocop -a

lint.frontend:
	docker-compose run --rm frontend sh -c "npm ci && npm run lint"

lint.frontend.fix:
	docker-compose run --rm frontend sh -c "npm ci && npm run lint -- --fix"

logs:
	docker-compose logs -f

ps:
	docker-compose ps
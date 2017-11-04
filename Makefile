release: dep assets
	MIX_ENV=prod mix release --env=prod --executable

docker:
	docker build . -t robinmonjo/coincoin
	docker push robinmonjo/coincoin

test: dep
	mix format --check-formatted
	mix test

dep:
	mix local.hex --force
	mix local.rebar --force
	mix deps.get

assets:
	cd apps/blockchain_web && MIX_ENV=prod mix phx.digest

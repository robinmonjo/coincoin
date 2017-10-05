release: shared
	MIX_ENV=prod mix release --env=prod --executable

docker: shared
	docker build . -t coincoin

shared:
	cd apps/blockchain_web && MIX_ENV=prod mix phx.digest

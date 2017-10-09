release: shared
	MIX_ENV=prod mix release --env=prod --executable

docker: shared
	docker build . -t robinmonjo/coincoin
	docker push robinmonjo/coincoin

shared:
	cd apps/blockchain_web && MIX_ENV=prod mix phx.digest

release:
	cd apps/blockchain_web && MIX_ENV=prod mix phx.digest
	MIX_ENV=prod mix release --env=prod
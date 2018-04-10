keybase_users = `keybase team list-members $(keybase_team) | awk '{print $$3}' | xargs`

production.env:
	keybase decrypt < production.env.encrypted > production.env

staging.env:
	keybase decrypt < staging.env.encrypted > staging.env

development.env:
	keybase decrypt < development.env.encrypted > development.env

production.env.encrypted:
	keybase encrypt $(keybase_users) < production.env > production.env.encrypted
	rm production.env

staging.env.encrypted:
	keybase encrypt $(keybase_users) < staging.env > staging.env.encrypted
	rm staging.env

development.env.encrypted:
	keybase encrypt $(keybase_users) < development.env > development.env.encrypted
	rm development.env

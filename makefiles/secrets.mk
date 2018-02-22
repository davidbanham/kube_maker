production.env:
	keybase decrypt < production.env.encrypted > production.env

staging.env:
	keybase decrypt < staging.env.encrypted > staging.env

development.env:
	keybase decrypt < development.env.encrypted > development.env

production.env.encrypted:
	keybase encrypt $(keybase_team) < production.env > production.env.encrypted

staging.env.encrypted:
	keybase encrypt $(keybase_team) < staging.env > staging.env.encrypted

development.env.encrypted:
	keybase encrypt $(keybase_team) < development.env > development.env.encrypted

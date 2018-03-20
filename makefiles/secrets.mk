keybase_users = `keybase team list-members $(keybase_team) | awk '{print $$3}' | xargs`

production.env: production.env.encrypted
	-cp production.env backup.production.env
	keybase decrypt < production.env.encrypted > production.env

staging.env: staging.env.encrypted
	-cp staging.env backup.staging.env
	keybase decrypt < staging.env.encrypted > staging.env

development.env: staging.env.encrypted
	-cp development.env backup.development.env
	keybase decrypt < development.env.encrypted > development.env

.PHONY: secrets
secrets: production.env staging.env development.env production.env.encrypted staging.env.encrypted development.env.encrypted

.PHONY: encrypt_env_secrets
encrypt_env_secrets: remove_encrypted_env_secrets production.env.encrypted staging.env.encrypted development.env.encrypted

.PHONY: remove_encrypted_env_secrets
remove_encrypted_env_secrets: areyousure
	rm production.env.encrypted staging.env.encrypted development.env.encrypted

production.env.encrypted:
	keybase encrypt $(keybase_users) < production.env > production.env.encrypted

staging.env.encrypted:
	keybase encrypt $(keybase_users) < staging.env > staging.env.encrypted

development.env.encrypted:
	keybase encrypt $(keybase_users) < development.env > development.env.encrypted

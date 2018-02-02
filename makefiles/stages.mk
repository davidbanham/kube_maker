.PHONY: stage_production stage_staging stage_development

stage_production:
	$(eval stage=production)

stage_staging:
	$(eval stage=staging)

stage_development:
	$(eval stage=development)

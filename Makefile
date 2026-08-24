.PHONY: fmt init validate shellcheck test

TERRAFORM ?= terraform

fmt:
	$(TERRAFORM) -chdir=terraform fmt -check -recursive

init:
	$(TERRAFORM) -chdir=terraform init -backend=false -input=false

validate:
	$(TERRAFORM) -chdir=terraform validate -no-color

shellcheck:
	find api_helpers -type f -name '*.sh' -exec bash -n {} +

test: fmt init validate shellcheck

TFDIR   := starter/terraform
TF      := terraform -chdir=$(TFDIR)

# valeurs backend (memes que la CI)
BACKEND := \
  -backend-config="resource_group_name=mpetitRG" \
  -backend-config="storage_account_name=ststatemelvinpetit" \
  -backend-config="container_name=tfstate" \
  -backend-config="key=melvin-petit.terraform.tfstate"

.PHONY: test-ci test-cd

test-ci:
	$(TF) fmt -check -recursive -diff
	$(TF) init $(BACKEND)
	$(TF) validate
	$(TF) plan

test-cd:
	$(TF) fmt -check -recursive -diff
	$(TF) init $(BACKEND)
	$(TF) validate
	$(TF) plan
	$(TF) apply

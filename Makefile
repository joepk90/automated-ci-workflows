LOCAL_DOCKER_IMAGE_NAME=hello-world-docker-example
local-docker-build:
	docker build -t $(LOCAL_DOCKER_IMAGE_NAME) .

local-docker-run:
	docker run -p 8080:8080 $(LOCAL_DOCKER_IMAGE_NAME)




### CI COMMANDS
# CI_DOCKER_IMAGE_NAME=hello-world-example # This must be set dynamically
DOCKER_REPOSITORY=$(DOCKER_REGISTRY)/$(CI_DOCKER_IMAGE_NAME)
CI_GOOGLE_REPOSITORY=${TF_SA_GOOGLE_AR_REPO_URL}/${TF_SA_GOOGLE_PROJECT_ID}/${TF_SA_GOOGLE_AR_REPO_NAME}/$(CI_DOCKER_IMAGE_NAME)
TF_SA_GOOGLE_AR_REPO_LOCATION=us-central1
TF_SA_GOOGLE_AR_REPO_NAME=containers
TF_SA_GOOGLE_AR_REPO_PKG=docker.pkg.dev
TF_SA_GOOGLE_AR_REPO_URL=${TF_SA_GOOGLE_AR_REPO_LOCATION}-${TF_SA_GOOGLE_AR_REPO_PKG}
TF_SA_GOOGLE_REPOSITORY=${TF_SA_GOOGLE_AR_REPO_URL}/${TF_SA_GOOGLE_PROJECT_ID}/${TF_SA_GOOGLE_AR_REPO_NAME}/$(CI_DOCKER_IMAGE_NAME)

TF_SA_DOCKER_REPOSITORY=$(TF_SA_DOCKER_REGISTRY)/$(CI_DOCKER_IMAGE_NAME)
TF_SA_LATEST_TAG=latest

ci-docker-auth:
	@echo "Logging in to $(TF_SA_DOCKER_REGISTRY) as $(TF_SA_DOCKER_ID)"
	@docker login -u $(TF_SA_DOCKER_ID) -p $(TF_SA_DOCKER_PASSWORD)

ci-docker-build:
	# docker build -t $(TF_SA_DOCKER_REPOSITORY):$(COMMIT_SHA) ./
	docker build -t $(TF_SA_DOCKER_REPOSITORY):$(TF_SA_LATEST_TAG) ./
	# @echo "Created new tagged image: $(TF_SA_DOCKER_REPOSITORY):$(COMMIT_SHA)"
	@echo "Created new tagged image: $(TF_SA_DOCKER_REPOSITORY):$(TF_SA_LATEST_TAG)"

ci-gcr-build:
	# docker build -t $(TF_SA_GOOGLE_REPOSITORY):$(COMMIT_SHA) ./
	docker build -t ${TF_SA_GOOGLE_REPOSITORY}:$(TF_SA_LATEST_TAG) ./
	# @echo "Created new tagged image: $(TF_SA_GOOGLE_REPOSITORY):$(COMMIT_SHA)"
	@echo "Created new tagged image: $(TF_SA_GOOGLE_REPOSITORY):$(TF_SA_LATEST_TAG)"

ci-docker-push: ci-docker-auth
	# docker push $(TF_SA_DOCKER_REPOSITORY):$(COMMIT_SHA)
	docker push $(TF_SA_DOCKER_REPOSITORY):$(TF_SA_LATEST_TAG)
	# @echo "Deployed tagged image: $(TF_SA_DOCKER_REPOSITORY):$(COMMIT_SHA)"
	@echo "Deployed tagged image: $(TF_SA_DOCKER_REPOSITORY):$(TF_SA_LATEST_TAG)"

ci-gcloud-configure-docker:
	gcloud auth configure-docker -q ${TF_SA_GOOGLE_AR_REPO_URL}
	@echo "configured gcloud for docker"

# push to google container registry
ci-gcr-push: ci-gcloud-configure-docker ci-gcr-build
	docker push ${TF_SA_GOOGLE_REPOSITORY}:$(TF_SA_LATEST_TAG)
	@echo "Deployed tagged image: $(TF_SA_GOOGLE_REPOSITORY):$(TF_SA_LATEST_TAG)"

# alternatively - this could could be setup in terraform? The concern is if it gets deleted on destory/change
ci-check-create-repository:
	@echo "Checking if repository exists..."
	@REPO_EXISTS=$(shell gcloud artifacts repositories describe $(TF_SA_GOOGLE_AR_REPO_NAME) --location=$(TF_SA_GOOGLE_AR_REPO_LOCATION) --format="value(name)" || echo "not_found") ; \
	if [ "$$REPO_EXISTS" = "not_found" ]; then \
		echo "Repository $(TF_SA_GOOGLE_AR_REPO_NAME) does not exist. Creating it..."; \
		gcloud artifacts repositories create $(TF_SA_GOOGLE_AR_REPO_NAME) --repository-format=docker --location=$(TF_SA_GOOGLE_AR_REPO_LOCATION) --description="Docker repository for ${TF_SA_GOOGLE_AR_REPO_NAME} CI/CD images"; \
	else \
		echo "Repository $(TF_SA_GOOGLE_AR_REPO_NAME) already exists."; \
	fi

LOCAL_DOCKER_IMAGE_NAME=hello-world-docker-example
local-docker-build:
	docker build -t $(LOCAL_DOCKER_IMAGE_NAME) .

local-docker-run:
	docker run -p 8080:8080 $(LOCAL_DOCKER_IMAGE_NAME)


# REPO VARS
# TF_SA_DOCKER_IMAGE_NAME

# REPO SECRETS
# TF_SA_DOCKER_ID
# TF_SA_DOCKER_PASSWORD
# TF_SA_DOCKER_REGISTRY
# TF_SA_GOOGLE_PROJECT_ID

### CI VARS
TF_SA_GOOGLE_AR_REPO_LOCATION=us-central1
TF_SA_GOOGLE_AR_REPO_NAME=containers
TF_SA_GOOGLE_AR_REPO_PKG=docker.pkg.dev
TF_SA_GOOGLE_AR_REPO_URL=${TF_SA_GOOGLE_AR_REPO_LOCATION}-${TF_SA_GOOGLE_AR_REPO_PKG}
TF_SA_GOOGLE_REPOSITORY=${TF_SA_GOOGLE_AR_REPO_URL}/${TF_SA_GOOGLE_PROJECT_ID}/${TF_SA_GOOGLE_AR_REPO_NAME}/$(TF_SA_DOCKER_IMAGE_NAME)

TF_SA_DOCKER_REPOSITORY=$(TF_SA_DOCKER_REGISTRY)/$(TF_SA_DOCKER_IMAGE_NAME)
TF_SA_LATEST_TAG=latest

### CI COMMANDS
ci-docker-auth:
	@echo "Logging in to $(TF_SA_DOCKER_REGISTRY) as $(TF_SA_DOCKER_ID)"
	@docker login -u $(TF_SA_DOCKER_ID) -p $(TF_SA_DOCKER_PASSWORD)

ci-docker-build:
	docker build -t $(TF_SA_DOCKER_REPOSITORY) ./
	@echo "Created new image: $(TF_SA_DOCKER_REPOSITORY)"

ci-docker-tag:
	docker tag $(TF_SA_DOCKER_REPOSITORY) $(TF_SA_DOCKER_REPOSITORY):$(TF_SA_LATEST_TAG)
	docker tag $(TF_SA_DOCKER_REPOSITORY) $(TF_SA_DOCKER_REPOSITORY):$(COMMIT_SHA)
	@echo "Created new tagged image: $(TF_SA_DOCKER_REPOSITORY):$(TF_SA_LATEST_TAG)"
	@echo "Created new tagged image: $(TF_SA_DOCKER_REPOSITORY):$(COMMIT_SHA)"

ci-docker-push: ci-docker-auth
	docker push $(TF_SA_DOCKER_REPOSITORY):$(COMMIT_SHA)
	docker push $(TF_SA_DOCKER_REPOSITORY):$(TF_SA_LATEST_TAG)
	@echo "Deployed tagged image: $(TF_SA_DOCKER_REPOSITORY):$(COMMIT_SHA)"
	@echo "Deployed tagged image: $(TF_SA_DOCKER_REPOSITORY):$(TF_SA_LATEST_TAG)"

# we only use latest for GCP because storing images in the artifact registry isn't free
ci-gcr-tag:
	docker tag $(TF_SA_DOCKER_REPOSITORY) $(TF_SA_GOOGLE_REPOSITORY):$(TF_SA_LATEST_TAG)
	@echo "Created new tagged image: $(TF_SA_GOOGLE_REPOSITORY):$(TF_SA_LATEST_TAG)"

ci-gcr-push: ci-gcloud-configure-docker ci-docker-build
	docker push ${TF_SA_GOOGLE_REPOSITORY}:$(TF_SA_LATEST_TAG)
	@echo "Deployed tagged image: $(TF_SA_GOOGLE_REPOSITORY):$(TF_SA_LATEST_TAG)"

ci-gcloud-configure-docker:
	gcloud auth configure-docker -q ${TF_SA_GOOGLE_AR_REPO_URL}
	@echo "configured gcloud for docker"

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

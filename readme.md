# Automated CI Workflows

The primary purpose of this repository is to manage workflows that can easily be reused across other projects.

This project is highly related to the [joepk90/terraform ](https://github.com/joepk90/terraform)project, and relied on some of the infrastructure set up in that repository. Due to the Terraform Project's use of a dedicated Service Account and a Workload Identity Provider, all deployments can be managed through a reusable workflow defined within this repository.

# Setup Guide
*During these steps, links to this repositories workflows will be provided as examples*

### Step 1: Configure Repository Settings
In the GitHub repository you want to integrate with the Serverless Apps project and its automated workflows, add the required Secrets and Variables. Example links:
- [Secrets](https://github.com/joepk90/automated-ci-workflows/settings/secrets/actions)
- [Variables](https://github.com/joepk90/automated-ci-workflows/settings/variables/actions)

*For details about the required secrets and variables, refer to the Automated CI Workflows project documentation in Google Drive.*


### Step 2: Set Up the Workflow
In the target repository, configure the automated deployment workflow using the provided example file:
- [Example Workflow File](https://github.com/joepk90/automated-ci-workflows/blob/main/.github/workflows/example.yaml.disabled)


At the root of your project, run the following commands to add the workflow and rename it to deploy.yaml:
```
mkdir -p .github/workflows
curl -L -o .github/workflows/deploy.yaml https://raw.githubusercontent.com/joepk90/automated-ci-workflows/main/.github/workflows/example.yaml.disabled
```


**⚠️ Important:**  
Before enabling the Deploy step in the workflow, make sure the service has been created via Terraform. If the service is deployed by GitHub Actions first, Terraform may fail to create it due to resource conflicts. If this happens, the service can be manually deleted using either the GCP GUI or using the `gcloud` CLI:
- [GCP Cloud Run](https://console.cloud.google.com/run)


**Note:**  
*Although the deployment may succeed without the service having been initally setup in Terraform, required permissions, such as allowing unauthenticated access - won’t be configured automatically. This must be handled separately via Terraform.*


### Step 3
Create the Cloud Run service using Terraform. A simple example can be seen here:
- [hello_world_example.tf](https://github.com/joepk90/terraform/blob/main/src/projects/serverless-apps/hello_world_example.tf)



### Step 4
Once the service has been set up in Terraform, you can safely enable the Deploy step in the workflow.

---

The setup should now be complete!

A service should setup in Terraform, and the CI/CI workflow should be publishing images and updating deployments automatically.

## Required Secrets and Variables

| **Variable Name**                        | **Description**                                                                |
|------------------------------------------|--------------------------------------------------------------------------------|
| `TF_SA_DOCKER_IMAGE_NAME`                | Name of the Docker image to be built and pushed.                               |
| `TF_SA_GOOGLE_CLOUD_RUN_SERVICE_NAME`    | Name of the Google Cloud Run service to be deployed.                           |


| **Secret Name**                          | **Description**                                                                |
|------------------------------------------|--------------------------------------------------------------------------------|
| `TF_SA_DOCKER_ID`                        | Docker ID used for authentication.                                             |
| `TF_SA_DOCKER_PASSWORD`                  | Password for the Docker ID.                                                    |
| `TF_SA_DOCKER_REGISTRY`                  | Docker registry URL where images are stored.                                   |
| `TF_SA_GOOGLE_PROJECT_ID`                | Google Cloud Project ID associated with the deployment.                        |
| `TF_SA_GOOGLE_PROJECT_NUMBER`            | Google Cloud Project Number for the associated project.                        |
| `TF_SA_GOOGLE_SERVICE_ACCOUNT_EMAIL_USER_NAME` | Email username of the Google Service Account used for authentication.    |
| `TF_SA_GOOGLE_WORKLOAD_IDENTITY_POOL_ID` | ID of the Workload Identity Pool used for authentication.                      |
| `TF_SA_GOOGLE_WORKLOAD_IDENTITY_PROVIDER`| Provider name for the Workload Identity Pool.                                  |


---


# Considerations
Potentially these workflows should be moved to the Terraform project? And then perhaps the example `publish` and `deploy` workflows should be added to the github actions examples project?

Potentilaly this repository shouldn't exist and the the workflows should be moved somewhere more relevent. For now this will do...


## The `TF_SA_` Prefix
The `TF_SA_` prefix stands for **Terraform Serverlas Apps**.

To prevent conflicts with existing variables when other projects import these workflows into their CI/CD pipelines, I have prefixed all variables in this project with `TF_SA_`. This ensures that the variables in this project do not collide with others that may be defined in different repositories.

While the prefix might seem verbose, it helps avoid confusion and ensures clarity, especially when managing variables and secrets within the repository settings. This clear distinction indicates which variables/secrets are specifically for this project's workflow setup.

*Note: Ideally we can work out a way of defining these variables in one place, at which point the `TF_SA_` prefix will become irrelivent.*


## Makefile Handling (Maintaining the original projects Makefile)
The build process has been specifically designed to avoid overwriting the original projects existing Makefile, allowing for debugging (perhaps on the server?). However, this approach might be unnecessary, and we could consider replacing the project's Makefile with this project's version and build the image using the Makefile from this repository...
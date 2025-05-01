# Serverless Apps CI Workflows

This repository is specifically designed for handling publishing images and deployments for the Terraform Project Serverless Apps.

Because the Terraform Project uses a specific Service Account and Workload Identity Provider, all the deployments can be managed using a single reusable workflow.


# The `TF_SA_` Prefix
The `TF_SA_` prefix stands for Terraform Serverlas Apps.

When other projects import these workflows into their CI/CD pipelines, we don't want to the existing variables to conflict. For this reason I have prefixed all the variables in this project with: `TF_SA_`.
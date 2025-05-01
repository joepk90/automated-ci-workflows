# Serverless Apps CI Workflows

This repository is specifically designed for handling publishing images and deployments for the Terraform Project Serverless Apps.

Because the Terraform Project uses a specific service and account and Workload Identity Provider, all the deployments can be managed using a single reusable workflow.


# The `TF_SA_` Prefix
The `TF_SA_` prefix stands for Terraform Serverlas Apps. These are global environment variables that all my (`joepk90`) repositories have access too.
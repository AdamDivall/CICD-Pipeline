# CICD Pipeline

## Background
The files in this repository came about based on a requirement I had to build a Pipeline for Route-to-Live for Infrastructure Deployment. The Infrastructure itself was predominantly Lambda based but also had Fargate for a particular requirement.

The CloudFormation Files that are stored in this repository provide the ability to create a Cross-Account Deployment from a Tooling Account :
*   Create IAM Roles that are required for a CodePipeline to carry out a Cross Account Deployment using CloudFormation.
*   Create an ECR Repository and S3 Bucket that allows Cross Account Access for the Resource Accounts (Dev, Test and Prod) to be able to access for Images and Lambda Deployment Files.
*   Create the Pipelines themselve and the supporting items such as CodeCommit, CodeBuild & EventBridge etc.

## What is CodeCommit used for?
3 CodeCommit Repositories are used:
1.  **Infrastructure-Deployment**: For Infrastructure Files such as the CloudFormation YAML, CloudFormation Parameter JSON Files per environment, shell scripts used by CodeBuild to trigger AWS CLI Commands and the Lambda Source Code.
2.  **ECS-Container-Build**: For the Files that are used to build a Docker Image.
3.  **ECS-Container-Deployment**: For the `appspec.yaml` and `taskdef.json` files that are used for CodeDeploy to conduct Blue/Green Deployments.


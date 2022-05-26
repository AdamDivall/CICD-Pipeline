# CI/CD Pipeline

## Background
The files in this repository came about based on a requirement I had to build a Pipeline for Route-to-Live for Infrastructure Deployment. The Infrastructure itself was predominantly Lambda based but also had Fargate for a particular requirement.

The CloudFormation Files that are stored in this repository provide the ability to create a Cross-Account Deployment from a Tooling Account :
*   Create IAM Roles that are required for a CodePipeline to carry out a Cross Account Deployment using CloudFormation.
*   Create an ECR Repository and S3 Bucket that allows Cross Account Access for the Resource Accounts (Dev, Test and Prod) to be able to access for Images and Lambda Deployment Files.
*   Create the Pipelines themselve and the supporting items such as CodeCommit, CodeBuild & EventBridge etc.

## How does is all work?
There are 3 CodeCommit Repositories that are used:
1.  **ECS-Container-Build**: For the files that are used to build a docker image.
2.  **Infrastructure-Deployment**: For infrastructure files such as the CloudFormation YAML, CloudFormation parameter JSON Files per environment, shell scripts used by CodeBuild to trigger AWS CLI commands and the Lambda source code.
3.  **ECS-Container-Deployment**: For the `appspec.yaml` and `taskdef.json` files that are used for CodeDeploy to conduct blue/green deployments.

On a commit of code to the `ECS-Container-Build` repository this triggers the `ECS-Container-Build` pipeline.  This pipeline does the following:
*   Takes the contents of the repository as a source artifact and then executes a CodeBuild project that builds a docker image, tags the image with 2 tags (latest and the build-id) and then pushes it to the ECR repository.

On a commit of code to the `Infrastructure-Deployment` repository this triggers the `Infrastructure-Deployment` pipeline. This pipeline does the following:
*   Takes the contents of the repository as a source artifact and then executes a CodeBuild project that then executes a script that loops through all subfolder of `/lambda` and creates a Lambda deployment zip file which it then copies to an S3 Bucket.  
*   Once this stage is successful another CodeBuild project is triggered that executes a script which runs linting and security checks on the CloudFormation YAML using cfn-lint and cfn-nag.  
*   The pipeline will assume a role into the development account and deploy the CloudFormation stack.  
*   The pipeline then triggers another CodeBuild project that will assume a role back into the development account and update the Lambda functions with the latest version of code.  CloudFormation doesn't know when the contents of a Lambda deployment file has changed hence why this has been added in to cater for any changes to the functions code post deployment.
*   A manual approval is then required in order to allow progress into the test account.
*   The pipeline will assume a role into the test account and deploy the CloudFormation stack.  
*   The pipeline then triggers another CodeBuild project that will assume a role back into the test account and update the Lambda functions with the latest version of code.  CloudFormation doesn't know when the contents of a Lambda deployment file has changed hence why this has been added in to cater for any changes to the functions code post deployment.
*   A manual approval is then required in order to allow progress into the production account.
*   The pipeline will assume a role into the production account and deploy the CloudFormation stack.  
*   The pipeline then triggers another CodeBuild project that will assume a role back into the production account and update the Lambda functions with the latest version of code.  CloudFormation doesn't know when the contents of a Lambda deployment file has changed hence why this has been added in to cater for any changes to the functions code post deployment.

On a commit of code to either the `ECS-Container-Deployment` repository or a new image being pushed to the ECR Repository this triggers the `ECS-Container-Deployment` pipeline. This pipeline does the following:
*   Takes the contents of the repository as a source artifact and then pipeline will assume a role into the development account and initiate a CodeDeploy deployment to carry out a blue/green.  This will provision a new task definition, start a new container using that task defintion, associate it with the ECS Service and then register it with a different load balancer target group.  Once the container has passed the health checks for the target group, CodeDeploy will then switch the target group that is registered with Application Load Balancer so that the newly associated target group receives the incoming traffic whilst the previous target group drains its connections.  Once the connections are completely drained then the orginal container is removed from the ECS Service, the container is stopped and terminated.
*   A manual approval is then required in order to allow progress into the test account.
*   The pipeline will assume a role into the test account and initiate a CodeDeploy deployment to carry out a blue/green.  This will provision a new task definition, start a new container using that task defintion, associate it with the ECS Service and then register it with a different load balancer target group.  Once the container has passed the health checks for the target group, CodeDeploy will then switch the target group that is registered with Application Load Balancer so that the newly associated target group receives the incoming traffic whilst the previous target group drains its connections.  Once the connections are completely drained then the orginal container is removed from the ECS Service, the container is stopped and terminated.
*   A manual approval is then required in order to allow progress into the production account.
*   The pipeline will assume a role into the production account and initiate a CodeDeploy deployment to carry out a blue/green.  This will provision a new task definition, start a new container using that task defintion, associate it with the ECS Service and then register it with a different load balancer target group.  Once the container has passed the health checks for the target group, CodeDeploy will then switch the target group that is registered with Application Load Balancer so that the newly associated target group receives the incoming traffic whilst the previous target group drains its connections.  Once the connections are completely drained then the orginal container is removed from the ECS Service, the container is stopped and terminated.
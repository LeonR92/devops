Okay, here is a step-by-step plan for the Advanced Level project (Containers, IaC with Bicep, Key Vault) without providing the code snippets, focusing on the process suitable for AZ-400 preparation.

Goal: Containerize the intermediate Flask app, define Azure resources (ACR, Key Vault, App Service for Containers) using Bicep, push the container image to ACR via Azure Pipelines, deploy the container to App Service, and securely inject a secret from Key Vault into the running application.

Prerequisites:

Completed Intermediate Level project (or have the code ready).
Azure Account (Free Tier sufficient for App Service Plan, but ACR/Key Vault have minor costs).
Azure DevOps Organization and Project.
Azure CLI installed and logged in (az login).
Git installed locally.
Docker Desktop installed and running locally (for potential local testing, though not strictly required for the pipeline).
VS Code (recommended) with Azure, Bicep, Python, and Docker extensions.
Phase 1: Local Project Modifications & Containerization

Update Flask App (app.py):
Modify the app to retrieve a sensitive value (e.g., APP_SECRET) from an environment variable.
Ensure the app listens on the port specified by the PORT environment variable (default to 8000, as expected by App Service for Containers). Gunicorn will handle the binding.
Remove the if **name** == '**main**': block if Gunicorn will be the entry point via Docker CMD.
Update Template (templates/index.html):
Modify the HTML template to display the secret value retrieved in the Flask app (for verification purposes only - be careful displaying real secrets).
Create Dockerfile:
Define a multi-stage build (optional but good practice) or a single-stage build.
Start from a suitable Python base image (e.g., python:3.9-slim).
Set the working directory.
Copy requirements.txt and install dependencies (pip install).
Copy the rest of the application code.
Set environment variables like PORT=8000.
Expose the correct port (EXPOSE 8000).
Define the CMD or ENTRYPOINT to run the application using gunicorn (e.g., gunicorn --bind 0.0.0.0:$PORT app:app).
Update .gitignore: Ensure Docker-related files or build contexts aren't unnecessarily committed if applicable.
Commit Changes: Add the Dockerfile and modified Python/HTML files to Git and commit them.
Phase 2: Infrastructure Definition (Bicep)

Create Bicep File (infrastructure/main.bicep):
Define parameters: location, base name for resources, SKU for ACR (use 'Basic'), SKU for App Service Plan (use 'F1' for Free Tier Linux), pipeline Service Principal Object ID (for Key Vault access policy).
Define resources:
Azure Container Registry (ACR): Basic SKU, admin user enabled (can be disabled later if using RBAC correctly).
Azure Key Vault: Standard SKU, enable RBAC authorization (recommended) or access policies.
App Service Plan: Linux, Free Tier (F1).
App Service (Web App for Containers): Configure for Linux, link to the App Service Plan, enable System Assigned Managed Identity. Do not configure the image source here yet, as the pipeline will do that.
Configure Key Vault Access: Add an access policy (or RBAC role assignment) granting the App Service's Managed Identity permissions to 'Get' secrets. Add another policy granting your pipeline's Service Principal permissions to 'Set' secrets (or your user ID if adding manually initially).
Define Outputs: Output the ACR login server name, Web App name, Key Vault name, and potentially the Resource Group name.
Add Secret to Key Vault (Manual or Bicep):
Option 1 (Manual): Deploy Bicep once, then manually add a secret (e.g., MyFlaskSecret) to the created Key Vault via the Azure Portal or CLI.
Option 2 (Bicep): Define the secret resource within Bicep using a secure parameter for the value.
Commit Bicep File: Add the infrastructure directory and main.bicep file to Git and commit.
Phase 3: Azure DevOps Pipeline Enhancement

Modify azure-pipelines.yml:
Add Infrastructure Stage (Optional but Recommended):
Create a new initial stage (e.g., DeployInfrastructure).
Use the AzureCLI@2 or AzureResourceManagerTemplateDeployment@3 task to deploy the main.bicep file.
Pass necessary parameters (like the Service Principal Object ID). You might need to run az ad sp list --display-name <YourServiceConnectionName> locally to find the ID, or use dynamic methods in more complex pipelines. Store Bicep outputs in pipeline variables using logging commands (e.g., echo "##vso[task.setvariable variable=acrLoginServer;isOutput=true]$acrLoginServer").
Modify Build Stage:
Rename to something like BuildAndPushImage.
Remove Python installation/testing steps if they are handled within the Docker build (or keep them as pre-checks).
Add a Docker@2 task to log in to your ACR (using the Service Connection and ACR name/output from the IaC stage).
Add a Docker@2 task to build the Docker image using the Dockerfile. Tag the image appropriately (e.g., with the ACR login server and Build.BuildId).
Add a Docker@2 task to push the tagged image to your ACR.
Remove the ArchiveFiles and PublishBuildArtifacts tasks used for zip deployment.
Modify Deploy Stage:
Rename to DeployContainerApp.
Ensure it depends on the BuildAndPushImage stage (and potentially the DeployInfrastructure stage if separate).
Use the AzureWebAppContainer@1 task.
Configure inputs:
azureSubscription: Your service connection.
appName: The name of the Web App (use pipeline variable from IaC stage output).
imageName: The full image name pushed to ACR (e.g., $(acrLoginServer)/<your-repo-name>:$(Build.BuildId)).
appSettings: Include any non-secret settings (-CUSTOM_GREETING "Hello from Container") AND the Key Vault reference for your secret: -APP_SECRET "@Microsoft.KeyVault(SecretUri=https://$(kvName).vault.azure.net/secrets/MyFlaskSecret/)" (replace $(kvName) with the variable holding the Key Vault name and MyFlaskSecret with your secret name).
Ensure the task uses the correct service connection which has permissions on the Web App.
Phase 4: Execution and Verification

Obtain Pipeline Service Principal Object ID: Run az ad sp list --display-name <YourAzureDevOpsServiceConnectionName> --query "[].id" -o tsv locally to get the Object ID needed for the Bicep keyVaultAdminObjectId parameter. Update the azure-pipelines.yml variable or pass it during the run.
Run Initial Bicep Deployment (If needed): If you haven't added the IaC stage to the pipeline yet, run the Bicep deployment manually using az deployment group create --resource-group <your-rg> --template-file infrastructure/main.bicep --parameters keyVaultAdminObjectId=<your-sp-object-id>. Ensure you add the secret to Key Vault if not done via Bicep.
Trigger Pipeline: Push all committed changes (Dockerfile, updated app.py/index.html, main.bicep, updated azure-pipelines.yml) to your Azure Repos main branch.
Monitor Pipeline: Observe the stages: IaC deployment (if added), Docker build, Docker push, and App Service deployment. Check logs for errors.
Verify Azure Resources:
Check ACR: Confirm the new image tag exists.
Check Key Vault: Confirm the secret exists and the access policies/RBAC roles for the App Service Managed Identity and Pipeline SP are correct.
Check App Service:
Go to Deployment Center: Verify it's configured to use the correct ACR image.
Go to Configuration -> Application settings: Verify the APP_SECRET setting exists and its value is the Key Vault reference. Verify CUSTOM_GREETING is set.
Go to Identity: Verify System Assigned Managed Identity is 'On'.
Test Application: Browse to the Web App URL (https://<your-app-name>.azurewebsites.net). Verify the updated greeting message and that the secret value fetched from Key Vault is displayed correctly.
This plan provides a structured approach to building the advanced scenario, touching upon key AZ-400 concepts like container workflows, IaC, secret management integration, and advanced pipeline configurations.

/azure-flask-containerized-app
│
├── app/
│ ├── init.py # Flask app factory
│ ├── app.py # Entrypoint
│ ├── requirements.txt # Python dependencies
│ └── templates/
│ └── index.html # Simple HTML template
│
├── infrastructure/
│ ├── main.bicep # Main Bicep orchestrator
│ ├── modules/ # (Optional) Bicep modules if you split ACR, KV, Web App
│ │ ├── acr.bicep
│ │ ├── keyvault.bicep
│ │ └── webapp.bicep
│ └── parameters.json # (Optional) default param values
│
├── pipelines/
│ └── azure-pipelines.yml # Azure DevOps multi-stage pipeline
│
├── tests/
│ └── test_app.py # Pytest unit tests for Flask app
│
├── .gitignore # Ignore Python, Docker, VS Code artifacts
├── Dockerfile # Multi-stage or single-stage Docker build
├── README.md # Project documentation
└── LICENSE # (Optional) Open Source License (MIT, etc.)

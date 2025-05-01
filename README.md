# [Project Name] - Flask Backend on Azure Functions

## Overview

This repository contains the source code for the **[Project Name]** backend service. It's a Python application built using the Flask microframework and deployed as a containerized Azure Function. The infrastructure required to run the application in Azure is defined using Bicep (Infrastructure as Code), and the continuous integration and deployment (CI/CD) process is managed through Azure DevOps Pipelines.

The primary goal of this project is to provide [briefly describe the main purpose of the application, e.g., a set of APIs for managing user data, processing specific tasks, etc.].

## Features

- **[Feature 1]:** [Brief description, e.g., User authentication and authorization]
- **[Feature 2]:** [Brief description, e.g., RESTful API endpoints for resource management]
- **[Feature 3]:** [Brief description, e.g., Asynchronous task processing]
- Containerized deployment via Docker.
- Infrastructure provisioned via Bicep.
- Automated CI/CD pipeline using Azure DevOps.
- Code quality ensured by Ruff linting.
- Unit and integration testing with Pytest.
- Secure configuration management using Azure DevOps Variable Groups.
- Structured development workflow with Git Branch Policies and Azure Boards.

## Architecture

The application follows a modern cloud-native architecture:

1.  **Application:** A Python Flask application serving API endpoints.
2.  **Containerization:** The Flask app is packaged into a Docker container for consistent deployment.
3.  **Hosting:** The Docker container runs within an Azure Function App configured with the "Custom Container" runtime. This provides a serverless execution environment managed by Azure.
4.  **Infrastructure (IaC):** Azure resources (Function App, required Storage Account, Azure Container Registry) are defined declaratively using Bicep templates located in the `/infra` directory.
5.  **CI/CD:** Azure DevOps Pipelines (`azure-pipelines.yml`) automates the following:
    - **Trigger:** On pushes/merges to the `main` branch (or other configured branches).
    - **Lint & Test:** Runs Ruff and Pytest to ensure code quality and correctness.
    - **Build:** Builds the Docker image based on the `Dockerfile`.
    - **Push:** Tags and pushes the built Docker image to the project's Azure Container Registry (ACR).
    - **Deploy:** Updates the Azure Function App to use the newly pushed image from ACR.
6.  **Source Control:** Git is used for version control, hosted in Azure Repos (or GitHub/other). Strict branch policies (e.g., requiring pull requests, successful builds, and reviewer approvals for merges into `main`) are enforced.
7.  **Work Tracking:** Azure Boards is used for managing user stories, tasks, bugs, and tracking project progress.
8.  **Configuration:** Environment variables and secrets (like database connection strings, API keys) are securely managed using Azure DevOps Variable Groups, which are linked to the CI/CD pipeline.

```mermaid
graph TD
    subgraph "Development Workflow"
        A[Developer] -- Pushes code --> B(Git Repository);
        B -- Triggers --> C{Azure DevOps Pipeline};
        D[Azure Boards] -- Tracks Work --> A;
        B -- Enforces --> E[Branch Policies];
    end

    subgraph "CI/CD Pipeline (Azure DevOps)"
        C -- 1. Lint & Test --> F[Ruff & Pytest];
        F -- 2. Build --> G[Docker Build];
        G -- 3. Push --> H(Azure Container Registry);
        H -- 4. Deploy --> I(Azure Function App);
        J[Variable Groups] -- Provides Config --> C;
    end

    subgraph "Azure Infrastructure (Managed by Bicep)"
        I -- Runs Container --> H;
        I -- Uses --> K(Azure Storage Account);
        L[Bicep Files] -- Defines --> I;
        L -- Defines --> H;
        L -- Defines --> K;
    end

    style H fill:#f9f,stroke:#333,stroke-width:2px
    style I fill:#ccf,stroke:#333,stroke-width:2px
    style K fill:#ccf,stroke:#333,stroke-width:2px
    style C fill:#f80,stroke:#333,stroke-width:2px
```

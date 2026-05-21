# HEIC to JPG Converter

A serverless HEIC to JPG converter using Azure Functions, FastAPI, Azure infra with Terraform.

## Architecture

- **FastAPI app** (`api/`) Basic WebUI and API sending/retrieving the HEIC/JPG file from Azure 
- **Azure Function** (`functions/`) is triggered by Event Grid when a file lands in storage, converts it to JPG.
- **Terraform** (`infrastructure/`) provisions all Azure resources.

## Setup

Coming soon.

# Install and configure the Google Cloud CLI tool

## Introduction
This simple scenario explains how to install and configure the Google Cloud CLI tool.  It summarizes the instructions located here:

https://cloud.google.com/sdk/docs/install

## Prerequisites
1. A valid GCP account and credentials

## Scenario

### Windows
Download and run the installer from:

https://dl.google.com/dl/cloudsdk/channels/rapid/GoogleCloudSDKInstaller.exe

"gcloud init" should launch automatically.

### Ubuntu
From a bash shell run:

                sudo apt-get update
                sudo apt-get install apt-transport-https ca-certificates gnupg curl
                curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
                echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
                sudo apt-get update && sudo apt-get install google-cloud-cli
                gcloud init


### Configure gcloud
After "gcloud init" launches, follow the instructions to enter your credentials and defaults.
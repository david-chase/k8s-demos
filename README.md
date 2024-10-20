# Kubernetes Demos

## Introduction
This repo contains a number of simple scenarios that help demonstrate Kubernetes concepts and tools.  See the README file in each subdirectory for more information on running each scenario.

## Prerequisites
All scenarios in this repo require PowerShell Core, as this allows you to run them on either Windows or Linux.

## List of scenarios by function

### Getting Started

| Folder | Description
|---|---|
| install-aws-cli | Install and configure the AWS CLI tool.  This is required for any scenarios specific to EKS. |
| install-azure-cli | Install and configure the Azure CLI tool.  This is required to create and manage an AKS cluster. |
| install-gcloud-cli | Install and configure the Google CLI tool.  This is required to create and manage a GKE cluster. |
| install-eksctl | Install the EKSCTL utility.  This is used to create and manage an EKS cluster. |
| export-kubeconfig | Recreate your kubeconfig file if it becomes corrupted or is pointing to the wrong cluster.  kubeconfig is used by kubectl to connect to your cluster. |
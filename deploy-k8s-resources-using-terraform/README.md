# Deploy Kubernetes resources using Terraform

## Introduction
This is a simple scenario that demonstrates how to deploy Kubernetes resources, defined in a YAML file, using Terraform or OpenTofu.

## Prerequisites
1. Any functional Kubernetes cluster
2. PowerShell Core
3. Terraform or OpenTofu CLI installed
4. [tfk8s tool](https://github.com/jrhouston/tfk8s?tab=readme-ov-file#install) installed 

If you are running this scenario with OpenTofu instead of Terraform, simply replace "terraform" in your command lines with "tofu".

## Scenario
1. Verify your testing namespace is empty

        kubectl get po -n testing

1. First we must convert our YAML manifest into a Terraform file using the tfk8s tool

        tfk8s -f .\php-apache.yaml -o .\php-apache.tf

If you review the file php-apache.tf you'll find it's very similar to a YAML manifest, but not quite the same.

2. Edit main.tf

        terraform {
          required_providers {
            kubernetes = {
              source = "hashicorp/kubernetes"
            }
          }
        }

        provider "kubernetes" {
          config_path = "~/.kube/config"
        }

You'll see that it simply tells Terraform that we'll be using a plug-in provider named "kubernetes" and to look for its configuration in the default kubeconfig location.

3. Initialize Terraform.  You can't use the Terraform files in this folder until after you've initialized Terraform.  This will download any providers and create files and folders to track current state of your environment.

        terraform init -upgrade

4. Create a Terraform plan and apply it.  This will parse all Terraform-format files in the current directory (main.tf and php-apache.tf) and apply them to your infrastructure.

        terraform apply -auto-approve

5. Check the status of your deployment

        kubectl get po -n testing

You'll see there are now 3 replicas of our php-apache pod running.

6. When you're done, roll back youur changes

        terraform apply -destroy -auto-approve

One of the many great benefits of Terraform is that it tracks what it creates as part of your plan.  When you roll back the plan, it has the intelligence to roll back everything that was part of the plan.

This concludes the scenario.
# Export kubeconfig for AKS, EKS, GKE, and minikube

## Introduction
This simple scenario explains how to export your cluster config to the default kubeconfig location.  Use this as a quick fix when kubectl is pointing to the wrong cluster or an invalid one.


## AKS
                az aks get-credentials --resource-group <RESOURCE_GROUP> --name <CLUSTER_NAME>

## EKS
                aws eks update-kubeconfig --region <REGION> --name <CLUSTER_NAME>

## GKE
                gcloud container clusters get-credentials <CLUSTER_NAME>

## Minikube
Minikube regenerates the kubeconfig file every time you execute "minikube start".
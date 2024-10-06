# Kubernetes Policy with Gatekeeper & OPA

## Introduction
This is a simple scenario that demonstrates enforcing container request and limit specifications using Gatekeeper.  This scenario is based on the Gatekeeper introduction found here:

https://medium.com/spacelift/kubernetes-with-open-policy-agent-opa-gatekeeper-3052c3a8bbd5

## Prerequisites
1. Any functional Kubernetes cluster
2. PowerShell Core
3. Helm

## Scenario
1. Deploy invalid-deploy.yaml

        kubectl apply -f invalid-deploy.yaml

If you inspect the contents of this YAML file you will notice this deployment doesn't specify any resource requests or limits.  The deployment should be successful, as we have no policies in place to prevent it.

2. Delete the deployment

        kubectl delete -f invalid-deploy.yaml

3. Run Install-Gatekeeper.ps1
This will install Gatekeeper in your cluster and setup a sample policy that blocks Deployments that do not have CPU and memory Requests and Limits specified.  Alternately you can run each command separately:

        # Add the Gatekeeper Helm repo
        helm repo add gatekeeper https://open-policy-agent.github.io/gatekeeper/charts
        helm repo update

        # Install the Helm chart
        helm install gatekeeper/gatekeeper `
          --name-template gatekeeper `
          --namespace gatekeeper-system `
          --create-namespace

        # Create a Constraint Template
        kubectl apply -f constraint-template.yaml
        # Create an instance of the Constraint Template
        kubectl apply -f constraint.yaml

At this point we've installed Gatekeeper in our cluster and deployed a policy that blocks any Deployments that don't have requests and limits set for both CPU and Memory.

4. Deploy invalid-deploy.yaml

        kubectl apply -f invalid-deploy.yaml

You will receive an error message trying to deploy this manifest as there are no requests or limits specified:

        Error from server (Forbidden): error when creating ".\\invalid-deploy.yaml": admission webhook "validation.gatekeeper.sh"

5. Deploy valid-deploy.yaml

        kubectl apply -f valid-deploy.yaml

This will succeed as the deployment specifies requests and limits.

6. Run Uninstall-Gatekeeper.ps1
This will return your cluster to the state it was in before the demo.
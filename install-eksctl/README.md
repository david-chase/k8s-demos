# Install eksctl

## Introduction
This simple scenario explains how to install eksctl.  Eksctl is a simple utility for managing EKS clusters in AWS.  This scenario sumarizes the instructions found here:

https://eksctl.io/installation/

## Prerequisites
1. AWS CLI installed and configured

## Scenario

### Windows
Download eksctl from the following link:

https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_windows_amd64.zip

Extract eksctl.exe into a folder within your PATH

### Linux
From a bash shell run:

    # for ARM systems, set ARCH to: `arm64`, `armv6` or `armv7`
    ARCH=amd64
    PLATFORM=$(uname -s)_$ARCH
    
    curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz"
    
    # (Optional) Verify checksum
    curl -sL "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_checksums.txt" | grep $PLATFORM | sha256sum --check
    
    tar -xzf eksctl_$PLATFORM.tar.gz -C /tmp && rm eksctl_$PLATFORM.tar.gz
    
    sudo mv /tmp/eksctl /usr/local/bin

For information on using eksctl to provision an EKS cluster see the "eks-test-cluster" scenario in this repo:

https://github.com/dbc13543/k8s-demos/tree/master/eks-cluster-demo

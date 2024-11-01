# Install and configure the AWS CLI tool

## Introduction
This simple scenario explains how to install and configure the OCI CLI tool.  It summarizes the instructions located here:

https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm

## Prerequisites
1. A valid OCI cloud account and credentials

## Scenario

### Windows
Download and install the latest CLI from Github:

    https://github.com/oracle/oci-cli/releases

### Linux
From a bash shell run:

    bash -c "$(curl -L https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh)"

This will start the installation script.  In most cases you can accept the defaults.  

### Configure the OCI CLI
1. Verify the CLI is installed correctly

        oci --version

2. Get your Tenancy OCID by logging into the Oracle Cloud Console at https://www.oracle.com/cloud/sign-in.html.  Click the "Profile" icon in the top right of the screen, then "Tenancy: xxxxxxxxx"  Click on "Copy" next to the OCID field and paste this value somewhere handy.  You will need it to configure the CLI.


3. Get your User OCID by once again clicking the "Profile" icon in the top right of the screen, then "My Profile".  Click on "Copy" next to the OCID field and paste this value somewhere handy.  You will need it to configure the CLI.

4. Start the OCI CLI setup process

        oci setup config

Enter your User OCID and Tenant OCID when promted, as well as the home region for your account.  Select Yes when asked if you want to generate a new API Signing RSA key pair.  

5. When the setup process completes it will create your config and write your public and private keys.  Near the end of the output you should see a line similar to this:

    Private key written to: C:\Users\<username>\.oci\oci_api_key.pem

Note the *folder* where this file has been saved.  This is the folder containing your public key.

6. Upload your public key to the OCI Console by clicking the Profile icon in the top-right of the screen, then "My Profile.  On the left side of the screen, under "Resources" click "API Keys", then click "Add API Key".  Click the "Choose Public API Key file" radio button, then slect the file oci_api_key_public.pem from the folder we noted in the previous step.

7. Verify the CLI is connected to your cloud account

        oci iam compartment list --all

If you receive a warning about the permissions to your public key being open, you can suppress it by typing

        $Env:OCI_CLI_SUPPRESS_FILE_PERMISSIONS_WARNING="True"

If the prior command returns data with no other errors, then your CLI is successfully installed and configured.
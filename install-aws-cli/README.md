# Install and configure the AWS CLI tool

## Introduction
This simple scenario explains how to install and configure the AWS CLI tool.  It summarizes the instructions located here:

https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
https://docs.aws.amazon.com/cli/latest/userguide/getting-started-quickstart.html

## Prerequisites
1. A valid AWS account and credentials

## Scenario

### Windows
From the command-line run:

    msiexec.exe /i https://awscli.amazonaws.com/AWSCLIV2.msi

### Linux
From a bash shell run:

    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install

### Generate access credentials
If you already have an AWS Access Key ID and AWS Secret Access Key you may skip to the next section.  If not, follow these steps to generate these values:

1. Login to the AWS console
2. Go to IAM --> Users --> Your user ID
3. Select the "Security credentials" tab and then click "Create Access Key"
4. Select "Command Line Interface (CLI)" then Next, then "Create Access Key"
5. Write down the AWS Access Key ID and AWS Secret Access Key or download it in CSV format.  YOU WILL NOT BE SHOWN THE SECRET ACCESS KEY AGAIN.
6. Click "Done"

### Configure AWS CLI
Verify the installation was successful:

    aws --version

Now configure the AWS CLI:

    aws configure

Enter your information when prompted:

>AWS Access Key ID [None]: <Your AWS Access Key ID>

>AWS Secret Access Key [None]: <Your AWS Secret Access Key>

>Default region name [None]: us-east-2

>Default output format [None]: json

You have now installed and configured the AWS CLI and can stop the scenario here if you only have one set of AWS credentials.

### Managing multiple credentials using profiles

If you have multiple AWS credentials to manage you can do this with profiles.  In this scenario we will imagine we have one set of credentials in an AWS account called "daas" and another set of credentials in an AWS account called "salesdemo".

You can create multiple profiles by editing ~/.aws/credentials with a text editor.  Create a section for each of your desired profiles with the appropriate credentials specified:

    [default]
    aws_access_key_id = <Your AWS Access Key ID>
    aws_secret_access_key = <Your AWS Secret Access Key>
    
    [salesdemo]
    aws_access_key_id = <Your AWS Access Key ID>
    aws_secret_access_key = <Your AWS Secret Access Key>
    
    [daas]
    aws_access_key_id = <Your AWS Access Key ID>
    aws_secret_access_key = <Your AWS Secret Access Key>

Now edit ~/.aws/config to include the same profiles:

    [default]
    output = json
    region = us-east-2
    
    [profile salesdemo]
    region = us-east-2
    output = json
    
    [profile daas]
    region = us-east-2
    output = json

To list the profiles you've created run the following command:

    aws configure list-profiles

You can switch between profiles easily simply by running the following command:

    aws configure --profile salesdemo
    aws configure --profile daas
    aws configure --profile <profile name>
     

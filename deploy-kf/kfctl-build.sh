#!/bin/bash
# Shell Script to install and build kfctl
# Sreya Vangara, Jan 2020
# Final Result: Use kfctl to deploy Kubeflow on Azure

# Clone the kfctl source code from GitHub. 
git clone https://github.com/kubeflow/kfctl.git

# Check go version
go version
# If version is below 1.12, need to upgrade. Following line removes existing go and installs 1.13.6
sudo apt-get remove -y gccgo-go && wget http://golang.org/dl/go1.13.6.linux-amd64.tar.gz && sudo apt-get -y install gcc && sudo tar -C /usr/local -xzf go1.13.6.linux-amd64.tar.gz && echo "export PATH=\$PATH:/usr/local/go/bin" >> ~/.bashrc
# Add go installation location to paths
export GOPATH=/usr/local/go/bin
export PATH=$PATH:/usr/local/go/bin

# Add location of kfctl source code repo to GIT_KUBEFLOW env variable
export GIT_KUBEFLOW=$(pwd)

# Move into repository
cd ${GIT_KUBEFLOW}/kfctl

# Fetch Dependencies
GO111MODULE=on
export GO111MODULE
# Give go permissions to install dependencies
sudo chmod -R 777 /usr/local/go
# Download dependencies, note that the mod command does not exist in earlier versions of Go
go mod download

# Build the binary file
make

# Add kfctl binary to path
export PATH=$PATH:/${GIT_KUBEFLOW}/kfctl/bin/linux

# Run kfctl command to check for proper build
kfctl

# Leave KF repo, create new folder to deploy app to
cd ${GIT_KUBEFLOW}
cd ..
mkdir kfapp
cd kfapp
export KFAPP=$(pwd)

# Make folder to put URI dependencies in, move into folder
mkdir uri
cd uri

# Download config dependencies to folder
wget "https://raw.githubusercontent.com/kubeflow/manifests/v0.7-branch/kfdef/kfctl_k8s_istio.0.7.1.yaml"
wget "https://github.com/kubeflow/manifests/archive/v0.7-branch.tar.gz"

# Edit config .yaml to download repo from local filesystem
vim kfctl_k8s_istio.0.7.1.yaml
# Edit line 300 to the following:
# uri: file:${KFAPP}/uri/v0.7-branch.tar.gz
# Notes: press 'i' to insert, 'esc' to escape insertion mode, ':q!' to exit without saving, ':wq' to save and exit

# Point the config env var to the local file
export CONFIG_URI="${KFAPP}/uris/kfctl_k8s_istio.0.7.1.yaml"

# Generate and deploy Kubeflow
kfctl apply -V -f ${CONFIG_URI}

# Azure side requirements: get the cluster set up and attached

# Login
az login

# Create a resource group, skip if already existing
az group create -n <RESOURCE_GROUP_NAME> -l <LOCATION>

# Create a cluster on your desired resource group, skip if already existing
az aks create -g <RESOURCE_GROUP_NAME> -n <NAME> -s <AGENT_SIZE> -c <AGENT_COUNT> -l <LOCATION> --generate-ssh-keys

# Get credentials for cluster
az aks get-credentials -n <NAME> -g <RESOURCE_GROUP_NAME>

#Back to KF

# Check resources and apps deployed
kubectl get all -n kubeflow

# Change ingress gateway to view Kubernates Dashboard over external IP
kubectl edit -n istio-system svc/istio-ingressgateway
# Change line 78, type to 'LoadBalancer'

# Get external IP for dashboard
kubectl get -w -n istio-system svc/istio-ingressgateway

# Visit http://[external ip] to see dashboard




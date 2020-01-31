#!/bin/bash
# Bash Script Guide to pass authentication arguments to Kubeflow
# Sreya Vangara, Jan 2020
# Final Result: Store Azure authentication arguments and secrets in Kubeflow secrets
# Prerequisites: Existing Azure credentials

#Please refer to 'https://www.kubeflow.org/docs/fairing/azure/' for more detail

# Set environment variables to desired credentials

export AZ_CLIENT_ID=<service-principal-client-id>
export AZ_CLIENT_SECRET=<service-principal-client-secret>
export AZ_TENANT_ID=<tenant-id>
export AZ_SUBSCRIPTION_ID=<subscription-id>
export TARGET_NAMESPACE=<target-namespace e.g. kubeflow-anonymous>
export ACR_NAME=<acr-name>

# Create a Kubeflow secret

kubectl create secret generic -n ${TARGET_NAMESPACE} azcreds \
--from-literal=AZ_CLIENT_ID=${AZ_CLIENT_ID} \
--from-literal=AZ_CLIENT_SECRET=${AZ_CLIENT_SECRET} \
--from-literal=AZ_TENANT_ID=${AZ_TENANT_ID} \
--from-literal=AZ_SUBSCRIPTION_ID=${AZ_SUBSCRIPTION_ID}

# This secret can be accessed with the argument 'azcreds'
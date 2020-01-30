

# Install kubectl
curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl

# Make kubectl executable
chmod +x ./kubectl

# Add binary to path

sudo mv ./kubectl /usr/local/bin/kubectl

# Check version

kubectl version --client

# Install azcli

curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Install Docker

sudo yum install docker-engine -y

# Azure side requirements: get the cluster set up and attached

# Login

echo Please enter the Application ID
read -n 1 -p $APP_ID

echo Please enter the Application Password
read $PASSWORD

echo Please enter the Tenant ID
read $TENANT_ID

az login --service-principal --username $APP_ID --password $PASSWORD --tenant $TENANT_ID

#az login

# Create a resource group, skip if already existing
#az group create -n <RESOURCE_GROUP_NAME> -l <LOCATION>

echo Please enter the Resource Group Name
read $RESOURCE_GROUP_NAME

echo Please enter the name of your cluster
read $NAME

echo Does this cluster already exist? Y/N
read $EXIST

if [$EXIST = "N"]
then 
    echo Where should this cluster be? ex. eastus2
    read $LOCATION
    az aks create -g $RESOURCE_GROUP_NAME -n $NAME -s Standard_DS13_v2 -c 2 -l $LOCATION --generate-ssh-keys

# Create a cluster on your desired resource group, skip if already existing
#az aks create -g <RESOURCE_GROUP_NAME> -n <NAME> -s <AGENT_SIZE> -c <AGENT_COUNT> -l <LOCATION> --generate-ssh-keys

# Get credentials for cluster
az aks get-credentials -n $NAME -g $RESOURCE_GROUP_NAME

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
#wget "https://raw.githubusercontent.com/kubeflow/manifests/v0.7-branch/kfdef/kfctl_k8s_istio.0.7.1.yaml"
wget "https://raw.githubusercontent.com/SreyaV/kf-azure/master/deploy-kf/kfctl_k8s_istio.0.7.1.yml"
wget "https://github.com/kubeflow/manifests/archive/v0.7-branch.tar.gz"

# Edit config .yaml to download repo from local filesystem --> no need to do if you use the SreyaV .yml URI
#vim kfctl_k8s_istio.0.7.1.yaml
# Edit line 300 to the following:
# uri: file:${KFAPP}/uri/v0.7-branch.tar.gz
# Notes: press 'i' to insert, 'esc' to escape insertion mode, ':q!' to exit without saving, ':wq' to save and exit

# Point the config env var to the local file
export CONFIG_URI="${KFAPP}/uris/kfctl_k8s_istio.0.7.1.yaml"

# Generate and deploy Kubeflow
kfctl apply -V -f ${CONFIG_URI}

# Check resources and apps deployed
kubectl get all -n kubeflow

# Change ingress gateway to view Kubernates Dashboard over external IP
#kubectl edit -n istio-system svc/istio-ingressgateway
# Change line 78, type to 'LoadBalancer'

#This line auto changes without the need of vim
kubectl -n istio-system get svc/istio-ingressgateway -o yaml | sed "s/type: NodePort/type: LoadBalancer/g" | kubectl replace -f -

echo Visit http://[external ip] to see dashboard

# Get external IP for dashboard
kubectl get -w -n istio-system svc/istio-ingressgateway

# Visit http://[external ip] to see dashboard

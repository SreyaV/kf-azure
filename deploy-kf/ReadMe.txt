Hey there! This folder contains shell scripts and guides for how to deploy Kubeflow on Azure! 
These installation instructions are modeled after 'https://www.kubeflow.org/docs/azure/deploy/install-kubeflow/'
However, these contain fixes to several pertinent bugs

Descriptions of files:

deploy-kf-runnable.sh :
    This is a standalone, full installation and setup Bash script. It takes a few user inputs, but does not require leaving the shell.
    Run this file as 'sudo bash deploy-kf-runnable.sh'

deploy-kf-full.sh:
    This is intended as a full installation and setup guide, with guiding comments and fill-in Bash commands. 

kfctl-build.sh:
    This is an installation and setup guide only for kfctl, with guiding comments and fill-in Bash Commands. It assumes an installation of Kubectl and Docker. 

kfctl_k8s_istio.0.7.1.yml:
    This is a modified uri for use with deploy-kf-runnable.sh.

Note: These scripts are meant to run on Linux Ubuntu, and were tested on Ubuntu 18.04

Please see 'https://www.kubeflow.org/docs/azure/azureendtoend/#deploy-kubeflow' for the rest of the instructions on creating an Azure pipeline on Kubeflow.
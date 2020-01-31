Hey there! This folder contains pipeline code samples for use with Azure Pipelines on Kubeflow
Each subdirectory contains the necessities for a Docker image. Use:
docker build . -t ${REGISTRY_PATH}/training:${VERSION_TAG}
docker push ${REGISTRY_PATH}/training:${VERSION_TAG}
To build and upload these images to Azure.

The pipeline.py script directs a Kubeflow pipeline. Each step is encapsulated in a dsl ContainerOp, which takes an image and a Bash command.
As of Jan 31st, 2020, the pipeline.py script only contains one step: training.

The 'privacy' directory contains a model created by the Differential Privacy externs in January 2020 (train.py). 

The 'training' directory contains a sample skLearn model. 

The 'authentication-tests' directory contains training files that check the environment variables of the Kubeflow cluster, to see if the Azure credentials were saved.

The config.json must be filled in with the arguments given by your workspace.

Run 'python pipeline.py' to generate the pipeline.py.tar.gz file used by Kubeflow. 

'authentication.sh' must be executed first, before any training, to prepopulate environment variables in Kubeflow with Azure credentials.

'pipelineWrapper' in each directory monkey patches Kubeflow to use Azure. 
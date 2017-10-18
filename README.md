# Data Platform Demo

Data platform demonstration. This repository contains `Dockerfile`s and Kubernetes configuration files to deploy several componenents of the Linkedin data platform.

## Installation

1. Install Docker (https://www.docker.com/)
2. Install Kubernetes (https://kubernetes.io/)
3. Install minikube (https://github.com/kubernetes/minikube)
4. Configure minikube to use more memory: `minikube config set memory 8000`
5. Start minikube: `minikube start`
6. Open the Kubernetes dashboard: `minikube dashboard`
7. Start everything: `kubectl apply -R -f data-platform`
8. Once everything shows up as good in the Kubernetes dashboard, `kubectl port-forward -n data-platform pinot-controller-0 10000:9000` and go to http://localhost:10000/

## Credits

- Kafka k8s configuration mostly comes from https://github.com/Reposoft/kubernetes-kafka-small (Apache license)

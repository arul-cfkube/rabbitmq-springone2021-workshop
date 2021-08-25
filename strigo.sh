#!/bin/bash
cd /home/ubuntu
export HOME=/home/ubuntu
export USER=ubuntu
sudo apt-get update
sudo snap install docker
sudo chown -R ubuntu:ubuntu /var/run/docker.sock
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.11.1/kind-linux-amd64
chmod +x ./kind
mv ./kind /usr/local/bin/kind
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
mv ./kubectl /usr/local/bin/kubectl
sudo chown -R ubuntu:ubuntu /var/run/docker.sock
cat << EOF > kind.yml
# three node (workers) cluster config
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
- role: worker
- role: worker
EOF
sudo -u ubuntu kind create cluster --name=springone2021 --config=kind.yml
sudo cp -r /root/.kube /$HOME/.kube
sudo chown -R $USER $HOME/.kube
while [[ $(kubectl get node -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do echo "waiting for Nodes to get Ready" && sleep 1; done
kubectl get nodes
kubectl get pods
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.2.0/cert-manager.yaml
while [[ $(kubectl get pods -n cert-manager -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True True True" ]]; do echo "Checking for cert-manager pods" && sleep 1; done
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install my-release bitnami/spring-cloud-dataflow
kubectl create secret docker-registry scdf-image-regcred --docker-server=registry.pivotal.io --docker-username=avannala@pivotal.io --docker-password=1@Universe9
#kubectl create ns gemfire-system
#kubectl create secret docker-registry image-pull-secret --namespace=gemfire-system --docker-server=registry.pivotal.io --docker-username=avannala@pivotal.io --docker-password=$dockerpasss
#kubectl create secret docker-registry image-pull-secret --docker-server=registry.pivotal.io --docker-username=avannala@pivotal.io --docker-password=$dockerpasss
#export HELM_EXPERIMENTAL_OCI=1
#helm registry login -u myuser registry.pivotal.io -u avannala@pivotal.io -p $dockerpasss
#helm repo update
#helm chart pull registry.pivotal.io/tanzu-gemfire-for-kubernetes/gemfire-operator:1.0.1
#helm chart export registry.pivotal.io/tanzu-gemfire-for-kubernetes/gemfire-operator:1.0.1
#helm install gemfire-operator gemfire-operator --namespace gemfire-system
#while [[ $(kubectl get po -n gemfire-system -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do echo "waiting for podes to get Ready" && sleep 1; done
#helm ls --namespace gemfire-system
#cat << EOF > gemfire.yml
#apiVersion: gemfire.tanzu.vmware.com/v1
#kind: GemFireCluster
#metadata:
#  name: gemfire1
#spec:
#  image: registry.pivotal.io/tanzu-gemfire-for-kubernetes/gemfire-k8s:1.0.1
#EOF
#kubectl apply -f gemfire.yml
kubectl get ns
kubectl get pods -A

# K3S Setup

## database

```bash
docker run --restart=always -p  5432:5432  --name postgres -e POSTGRES_USER=postgres  -e POSTGRES_PASSWORD=pass@1234  -v ~/data/postgres/data:/var/lib/postgresql/data  -d postgres
```

```bash
CREATE DATABASE k3s;
CREATE USER k3s WITH ENCRYPTED PASSWORD 'k3spass';
GRANT ALL PRIVILEGES ON DATABASE k3s TO k3s;
```

## install k3s

```bash
#use sqllite
#curl -sfL http://aima.hyitec.com/install.sh | sh -s - --bind-address 0.0.0.0 --write-kubeconfig-mode
#use postgres
export db_ip=127.0.0.1
curl -sfL http://aima.hyitec.com/install.sh | sh -s - --bind-address 0.0.0.0 --write-kubeconfig-mode --storage-endpoint="postgres://k3s:k3spass@${db_ip}:5432/k3s?sslmode=disable"
mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown -R 1000:1000 ~/.kube
```

## install storage

```bash
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/master/deploy/local-path-storage.yaml
kubectl get storageclass
```

## Create tiller service account

```bash
sudo kubectl -n kube-system create serviceaccount tiller
```

## Create cluster role binding for tiller

```bash
sudo kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller
```

## init helm

```bash

helm init --client-only --stable-repo-url http://mirror.azure.cn/kubernetes/charts/
helm repo add incubator http://mirror.azure.cn/kubernetes/charts-incubator/
helm repo add stable  http://mirror.azure.cn/kubernetes/charts/
helm repo add bitnami https://charts.bitnami.com/bitnami


helm repo update

mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config

sudo kubectl delete deployment.apps/tiller-deploy service/tiller-deploy  -n kube-system

 sudo  helm init  --service-account tiller

 sudo kubectl get all --all-namespaces

###sudo helm install --name kubeapps --namespace kubeapps bitnami/kubeapps
```

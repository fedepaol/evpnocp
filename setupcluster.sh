#!/bin/bash
set -e

wait_for_pods() {
  local namespace=$1
  local selector=$2
  local attempts=0
  local max_attempts=30
  local sleep_time=10

  while [[ -z $(kubectl get pods -n "$namespace" -l "$selector" 2>/dev/null) ]]; do
    echo "pods in $namespace not found"
    sleep $sleep_time
    attempts=$((attempts+1))
    if [ $attempts -eq $max_attempts ]; then
      echo "failed to wait for pods to appear"
      exit 1
    fi
    echo "pods in $namespace found"
  done
}

export KUBECONFIG=/home/fpaoline/.kcli/clusters/fedecluster/auth/kubeconfig
kubectl apply -f metallbdeploy/install-resources.yaml
kubectl patch networks.operator.openshift.io cluster --type json  -p '[{"op": "add", "path": "/spec/defaultNetwork/ovnKubernetesConfig/gatewayConfig/ipForwarding", "value": Global}]'
kubectl patch networks.operator.openshift.io cluster --type json  -p '[{"op": "add", "path": "/spec/defaultNetwork/ovnKubernetesConfig/gatewayConfig/routingViaHost", "value": true}]'

sleep 5

wait_for_pods "metallb-system" "control-plane=controller-manager"

NEXT_WAIT_TIME=0
until (( NEXT_WAIT_TIME == 5 )) || kubectl apply -f metallbdeploy/metallb_frrk8s.yaml; do
    sleep "$(( NEXT_WAIT_TIME++ ))"
done
(( NEXT_WAIT_TIME < 5 ))

wait_for_pods "metallb-system" "app=frr-k8s"


kubectl -n metallb-system wait --for=condition=Ready --all pods --timeout 300s

kcli scp ./ocp/setup.sh fedecluster-ctlplane-0:/tmp
kcli ssh fedecluster-ctlplane-0 /tmp/setup.sh 

kubectl label node fedecluster-ctlplane-0.karmalabs.corp k8s.ovn.org/egress-assignable=""
kubectl apply -f crds/workload.yaml



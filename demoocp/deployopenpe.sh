#!/bin/bash

kubectl apply -f deployopenpe.yaml
kubectl apply -f macvlan.yaml

oc adm policy add-scc-to-user privileged -n openperouter-system -z openperouter-controller
oc adm policy add-scc-to-user privileged -n openperouter-system -z openperouter-perouter

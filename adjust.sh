#!/bin/bash
oc adm policy add-scc-to-user privileged -n openperouter-system -z openperouter-controller
oc adm policy add-scc-to-user privileged -n openperouter-system -z openperouter-perouter
oc label ns openperouter-system pod-security.kubernetes.io/enforce=privileged

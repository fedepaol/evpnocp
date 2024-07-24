#!/bin/bash
kcli delete -y plan fede
kcli create plan -f plan.yaml fede
#kcli create cluster openshift --paramfile config.yaml openshift-node
# TODO flip routing via HOst
# host 192.168.10.3 - 192.168.10.2 leaf 192.168.1.2 - 192.168.1.3 spine 192.168.2.3 - 192.168.2.2 leaf2 192.168.11.2 - 192.168.11.3

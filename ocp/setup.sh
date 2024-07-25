#!/bin/bash

sudo podman run --name frr --privileged -v /etc/frr:/etc/frr -d registry.redhat.io/openshift4/frr-rhel9@sha256:fc948f574d62e6f6cd39357380c7076787d78e95256069418d26ffb17b73d43d

sleep 1s
NAMESPACE=$(basename $(sudo podman inspect -f '{{.NetworkSettings.SandboxKey}}' frr))

ip link add frr0 type veth peer name frr1
ip link set frr0 up
ip link set dev ens4 netns $NAMESPACE
ip link set frr1 netns $NAMESPACE

sleep 2s

ip addr add dev frr0 192.169.10.0/24

podman exec frr /etc/frr/setup.sh

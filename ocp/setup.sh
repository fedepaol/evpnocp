#!/bin/bash

sudo podman run --name frr --privileged -v /etc/frr:/etc/frr -d registry.redhat.io/openshift4/frr-rhel9@sha256:c6289e7967e223182da97bac8bf278843cacf3437c1fa015b4e43a01a903c649

sleep 1s
NAMESPACE=$(basename $(sudo podman inspect -f '{{.NetworkSettings.SandboxKey}}' frr))

sudo ip link add frr0 type veth peer name frr1
sudo ip link set frr0 up
sudo ip link set dev ens4 netns $NAMESPACE
sudo ip link set frr1 netns $NAMESPACE

sleep 2s

sudo ip addr add dev frr0 192.169.10.0/24

sudo podman exec frr /etc/frr/setup.sh

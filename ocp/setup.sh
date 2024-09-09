#!/bin/bash

sudo podman run --name frr --privileged -v /etc/frr:/etc/frr -d registry.redhat.io/openshift4/frr-rhel9@sha256:22b0c5198ecad10226487f8e398dbe07008c1c4f561681e0f894aa229e8b5787

sleep 1s
NAMESPACE=$(basename $(sudo podman inspect -f '{{.NetworkSettings.SandboxKey}}' frr))

sudo ip link add frrred-0 type veth peer name frrred-1
sudo ip link set frrred-0 up
sudo ip link set frrred-1 netns $NAMESPACE

sudo ip link add frrgreen-0 type veth peer name frrgreen-1
sudo ip link set frrgreen-0 up
sudo ip link set frrgreen-1 netns $NAMESPACE
sudo ip link set dev ens4 netns $NAMESPACE

sleep 2s

sudo ip addr add dev frrred-0 192.169.10.0/24
sudo ip addr add dev frrgreen-0 192.169.11.0/24

sudo podman exec frr /etc/frr/setup.sh

#!/bin/bash

sudo podman run --name frr --privileged -v /etc/frr:/etc/frr -d registry.redhat.io/openshift4/frr-rhel9@sha256:439d8075d41a72f53f1002a982326c3880272412a0f5d83adc3ac0872f983688

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

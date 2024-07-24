#!/bin/bash

sudo podman run --name frr --privileged -v /frr:/tmp/frr -d quay.io/frrouting/frr:9.0.0

NAMESPACE=$(basename $(sudo podman inspect -f '{{.NetworkSettings.SandboxKey}}' frr))

ip link add frr0 type veth peer name frr1
ip link set frr0 up
ip link set dev eth1 netns $NAMESPACE
ip link set frr1 netns $NAMESPACE

sleep 2s

ip addr add dev frr0 192.169.10.0/24

podman exec frr /etc/frr/setup.sh

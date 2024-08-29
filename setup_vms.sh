#!/bin/bash
kcli delete -y plan fede
kcli create plan -f plan.yaml fede
kcli create cluster openshift --paramfile config.yaml --force fedecluster


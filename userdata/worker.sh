#!/bin/bash
# worker.sh — Worker Node: Common packages only (join is manual)
set -euxo pipefail

exec > >(tee /var/log/kubeadm-bootstrap.log) 2>&1

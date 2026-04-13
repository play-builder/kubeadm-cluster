#!/bin/bash
kubectl get pods -A --field-selector spec.nodeName=wk1 \
    -o custom-columns='NAME:.metadata.name,HOST_NET:.spec.hostNetwork,IP:.status.podIP'

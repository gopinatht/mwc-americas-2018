#!/bin/bash

#CD to the helm-charts directory
helm dep update xos-core
helm install xos-core -n xos-core

helm dep update xos-profiles/base-kubernetes
helm install xos-profiles/base-kubernetes -n base-kubernetes
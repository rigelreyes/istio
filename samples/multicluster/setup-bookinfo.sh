#!/bin/bash

# Copyright Istio Authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -o errexit

install() {
  for CONTEXT in $(kubectl config get-contexts -o name); do
    kc() { kubectl --context "${CONTEXT}" "$@"; }

    # enable automatic sidecar injection on the default namespace
    kc label namespace default istio-injection=enabled --overwrite

    # install the bookinfo service and expose it through the ingress gateway
    kc apply -f ../bookinfo/platform/kube/bookinfo.yaml
    kc apply -f ../bookinfo/networking/bookinfo-gateway.yaml
  done
}

uninstall() {
  for CONTEXT in $(kubectl config get-contexts -o name); do
    kc() { kubectl --context "${CONTEXT}" "$@"; }

    # install the bookinfo service and expose it through the ingress gateway
    kc delete -f ../bookinfo/platform/kube/bookinfo.yaml --ignore-not-found
    kc delete -f ../bookinfo/networking/bookinfo-gateway.yaml --ignore-not-found
  done
}

usage() {
  echo "Usage: $0 install | uninstall

install
  Install the sample bookinfo application in all clusters.
uninstall
  Remove the sample bookinfo application from all clusters.
"
}

case $1 in
  install)
    install
    ;;
  uninstall)
    uninstall
    ;;
  *)
    usage
    exit 127
esac

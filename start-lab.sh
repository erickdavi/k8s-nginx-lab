#!/usr/bin/env bash
set -euo pipefail

echo "Criando cluster kind..."
kind create cluster --config infra/kind-lab.yaml

echo "Instalando ingress-nginx..."
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

echo "Aguardando ingress-nginx controller ficar pronto..."
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=180s

echo "Instalando MetalLB..."
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.5/config/manifests/metallb-native.yaml

echo "Aguardando MetalLB ficar pronto..."
kubectl rollout status deployment/controller -n metallb-system --timeout=180s
kubectl rollout status daemonset/speaker -n metallb-system --timeout=180s

echo "Aplicando config MetalLB..."
kubectl apply -f infra/metallb-config.yaml

echo "Instalando app de teste..."
kubectl apply -f app/hello-deployment.yaml
kubectl apply -f app/hello-ingress.yaml

echo "Validando status dos pods e ingress..."
kubectl get nodes
kubectl get pods -A
kubectl get svc -n default hello
kubectl get ingress -n default

echo "Lab pronto! Acesse: http://hello.local:8080"

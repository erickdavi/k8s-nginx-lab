#!/usr/bin/env bash
set -euo pipefail

echo "Removendo cluster kind 'lab'..."
kind delete cluster --name lab

echo "Limpeza final de redes Docker não utilizadas..."
docker network prune -f

echo "Lab destruído."

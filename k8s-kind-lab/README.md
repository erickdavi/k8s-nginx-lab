# Kubernetes Kind Lab

Laboratório Kubernetes local para estudos de DevOps/SRE usando **kind + ingress-nginx + MetalLB**.

## Arquitetura do laboratório

Este lab cria:

- 1 cluster Kubernetes com kind (`lab`)
- 1 nó `control-plane`
- 2 nós `worker`
- `ingress-nginx` instalado automaticamente
- `MetalLB` instalado automaticamente
- Aplicação de teste `nginxdemos/hello` no namespace `default`
- Ingress com host `hello.local` acessível via `http://hello.local:8080`

Fluxo de tráfego:

1. Requisição para `hello.local:8080`
2. Porta 8080 do host mapeada para porta 80 do nó control-plane (kind)
3. Ingress NGINX roteia para Service `hello`
4. Service encaminha para Pod da app `nginxdemos/hello`

## Pré-requisitos

No Windows com WSL2:

- Docker Desktop (com integração WSL habilitada)
- WSL2
- `kubectl`
- `kind`

Validação rápida:

```bash
docker --version
kubectl version --client
kind version
```

## Estrutura do repositório

```text
k8s-kind-lab/
├── app/
│   ├── hello-deployment.yaml
│   └── hello-ingress.yaml
├── infra/
│   ├── kind-lab.yaml
│   └── metallb-config.yaml
├── start-lab.sh
├── destroy-lab.sh
└── README.md
```

## Como iniciar o laboratório

A partir da pasta `k8s-kind-lab`:

```bash
chmod +x start-lab.sh
./start-lab.sh
```

O script executa automaticamente:

- criação do cluster kind
- instalação do ingress-nginx
- instalação do MetalLB
- aplicação da configuração do MetalLB
- deploy da aplicação de exemplo
- criação do Ingress
- validação básica de status (nós/pods/ingress)

## Configuração do arquivo hosts

### Windows

Edite o arquivo:

`C:\Windows\System32\drivers\etc\hosts`

Adicione:

```text
127.0.0.1 hello.local
```

### WSL/Linux (opcional para testes locais)

```bash
sudo sh -c 'echo "127.0.0.1 hello.local" >> /etc/hosts'
```

## Acessar a aplicação

```text
http://hello.local:8080
```

## Como destruir o laboratório

A partir da pasta `k8s-kind-lab`:

```bash
chmod +x destroy-lab.sh
./destroy-lab.sh
```

O script remove o cluster kind e faz limpeza de redes Docker não utilizadas.

## Troubleshooting básico

### Verificar pods

```bash
kubectl get pods -A
```

### Verificar ingress

```bash
kubectl get ingress -A
kubectl describe ingress hello -n default
```

### Logs do ingress-nginx

```bash
kubectl logs -n ingress-nginx deploy/ingress-nginx-controller
```

### Verificar nós

```bash
kubectl get nodes -o wide
```

### Verificar MetalLB

```bash
kubectl get pods -n metallb-system
kubectl get ipaddresspools,l2advertisements -n metallb-system
```

### Testar resolução de nome

```bash
ping -c 1 hello.local
```

## Comandos úteis kubectl

```bash
kubectl config current-context
kubectl get all -n default
kubectl get svc,ingress -n default
kubectl describe pod -n default -l app=hello
kubectl rollout status deploy/hello -n default
```

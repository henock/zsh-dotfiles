# Kubernetes
export KUBECONFIG=~/.kube/dev:~/.kube/sandbox:~/.kube/test:~/.kube/uat:~/.kube/prod1:~/.kube/prod2

alias setup-minikube='eval $(minikube docker-env)'
alias start-docker='minikube start --driver=virtualbox --embed-certs && eval $(minikube docker-env)'


alias k=kubectl

# Pod management.
alias kgp='kubectl get pods'
alias kgpa='kubectl get pods --all-namespaces'
alias kgpw='kgp --watch'
alias kgpwide='kgp -o wide'
alias kep='kubectl edit pods'
alias kdp='kubectl describe pods'
alias kdelp='kubectl delete pods'
alias kgpall='kubectl get pods --all-namespaces -o wide'



# Logs
alias kl='kubectl logs'
alias kl1h='kubectl logs --since 1h'
alias kl1m='kubectl logs --since 1m'
alias kl1s='kubectl logs --since 1s'
alias klf='kubectl logs -f'
alias klf1h='kubectl logs --since 1h -f'
alias klf1m='kubectl logs --since 1m -f'
alias klf1s='kubectl logs --since 1s -f'

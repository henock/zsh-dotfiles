# Kubernetes
export KUBECONFIG=~/.kube/dev:~/.kube/sandbox:~/.kube/test:~/.kube/uat:~/.kube/prod1:~/.kube/prod2

alias setup-minikube='eval $(minikube docker-env)'
alias start-minikube='minikube start --driver=virtualbox --embed-certs && eval $(minikube docker-env)'



# Pod management.
alias kgp='kubectl get pods'
alias kgpwide='kgp -o wide'
alias kdp='kubectl  describe pods'

alias kga='kubectl  get all'
alias ckga='clear && k get all'
alias kaf='kubectl  apply -f '
alias kd='kubectl  describe '


alias kep='kubectl  edit pods'
alias kgpwide='kubectl get pods -o wide'
alias kdelp='kubectl  delete pods'
alias kgpa='kubectl get pods --all-namespaces'
alias kgpall='kubectl get pods --all-namespaces -o wide'



# Logs
alias kl='kubectl logs'
alias klf='kubectl logs -f'
alias kl1h='kubectl logs --since 1h'
alias kl1m='kubectl logs --since 1m'
alias kl1s='kubectl logs --since 1s'
alias klf1h='kubectl logs --since 1h -f'
alias klf1m='kubectl logs --since 1m -f'
alias klf1s='kubectl logs --since 1s -f'

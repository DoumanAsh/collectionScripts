
export def --wrapped kube_get_pods [...args: string] {
  kubectl get pods --all-namespaces -o custom-columns=NODE:.spec.nodeName,NAME:.metadata.name,NAMESPACE:.metadata.namespace,STATUS:.status.phase,IP:.status.podIP,RESTARTS:.status.containerStatuses[0].restartCount,CPU:.spec.containers[0].resources.requests.cpu,MEM:.spec.containers[0].resources.requests.memory
  | lines
  | each {|| split column -c  ' '}
  | flatten
  | headers
  | sort-by NODE
}

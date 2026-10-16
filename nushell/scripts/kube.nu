# Wrapper command to output kubernetes pods information
export def --wrapped kube_get_pods [
  --help (-h),      # Show help message
  --ip,             # Include ip address of individual pods within output
  --resources (-r), # Include container resources requests into output
  ...args: string
] {
  if $help {
    help kube_get_pods
    return
  }

  let include_resources = if $resources {
    ",CPU:.spec.containers[0].resources.requests.cpu,MEM:.spec.containers[0].resources.requests.memory"
  } else {
    ""
  }

  let include_ip = if $ip {
    ",IP:.status.podIP"
  } else {
    ""
  }
  let columns_list = $"NODE:.spec.nodeName,NAME:.metadata.name,NAMESPACE:.metadata.namespace,STATUS:.status.phase($include_ip)($include_resources),IMAGE:.spec.containers[0].image,REST:.status.containerStatuses[0].restartCount"
  kubectl get pods --all-namespaces -o custom-columns=($columns_list)
  | lines
  | each {|| split column -c  ' '}
  | flatten
  | headers
  | update IMAGE {|row| $row.IMAGE | split row '/' -n 2 | last }
  | sort-by NODE
}

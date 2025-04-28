#/bin/bash

echo "## Downloading podman binaries..."

curl -fsSL -o podman-linux-amd64.tar.gz https://github.com/mgoltzsche/podman-static/releases/latest/download/podman-linux-amd64.tar.gz
tar -xzf podman-linux-amd64.tar.gz

echo "## Copy into root... Asking for root perms"
sudo cp --verbose -r podman-linux-amd64/usr podman-linux-amd64/etc /
rm -rf podman-linux-amd64.tar.gz  podman-linux-amd64

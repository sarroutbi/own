#!/bin/bash
# 1 - Requirement 1: Install podman-bootc
sudo dnf -y install 'dnf-command(copr)'
sudo dnf -y copr enable gmaglione/podman-bootc
sudo dnf -y install podman-bootc
# # 2 - Requirement 2: have podman machine installed and started:
podman machine init --rootful --now
podman machine start
# # 3 - Export DOCKER_HOST as dumped by previous command:
export DOCKER_HOST='unix:///run/user/4202331/podman/podman-machine-default-api.sock'
# # 4 - Create container image:
cat > Containerfile <<END
FROM fedora-bootc:latest
RUN dnf install -y git
RUN echo "hello world"
END
# 5 - Build:
podman build -fContainerfile 
# 6 - Run (remember to provide file system):
podman-bootc run --filesystem xfs registry.fedoraproject.org/fedora-bootc:latest || {
  id=$(podman-bootc list | grep registry.fedoraproject.org/fedora-bootc:latest | awk  '{print $1}' | tail -1 | tr -d ' ')
  podman-bootc ssh "${id}"
}

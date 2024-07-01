---
layout: page_with_comment
title: "Replace Docker Desktop with Lima-vm; 用Lima vm替代Docker Desktop"
date: "2024-03-19"
tags: 
  - "docker"
  - "lima"
  - "vm"
---

In this article, Docker refers to Docker Engine, an open source containerization technology for building and containerizing your application. Docker is based on Linux container technology, an OS-level virtualization method for running multiple isolated Linux systems, a.k.a. containers , on a control host using a single Linux kernel.

> 本文所指的Docker，指的是Docker Engine，一种开源的容器技术。我们使用容器构建并打包应用。Docker基于Linux容器技术。Linux容器是一种操作系统层面的虚拟化技术，我们可以在一台Linux机器上运行多个相互隔离的Linux系统，每一个互相隔离的Linux系统即为容器，且这些容器共用一个Linux内核。

Since Docker is based on Linux container, we cannot natively run Docker on Windows and Mac, instead, many people use [Docker Desktop](https://www.docker.com/products/docker-desktop/), an out-of-box software provided by Docker Inc. Internally, Docker Desktop creates a Virtual Machine (VM) and lets users to run docker client inside Mac/windows and call Docker server in VM. As Docker Inc revised its license agreement and begin charging Docker Desktop for commercial use, many companies are moving away from Docker Desktop. Alternatives are [Podman Desktop](https://podman-desktop.io/), [Rancher Desktop](https://rancherdesktop.io/), etc.

> 由于Docker基于Linux容器技术，我们无法在Windows和Mac上原生运行Docker。一种解决方案是，使用Docker Inc提供的[Docker Desktop](https://www.docker.com/products/docker-desktop/)。Docker Desktop在Mac/Windows上创建了一个Linux虚拟机，以便用户在Mac/Windows上执行docker命令，而docker命令再与虚拟机通信，在虚拟机之中执行操作。随着Docker Inc修改了Docker Desktop的条款，并开始对Docker Desktop商业化使用收费，许多公司开始寻找替代方案，如[Podman Desktop](https://podman-desktop.io/), [Rancher Desktop](https://rancherdesktop.io/)。

When I check Rancher Desktop, I find that it use [lima-vm](https://github.com/lima-vm) to create virtual machine. Good news is that lima-vm will [handle port forwarding and volume mounts](https://lima-vm.io/docs/), which is the most valuable feature provided by Docker Desktop for developers. I immediately decide to switch to lima-vm and docker cli.

> 我看到Rancher Desktop的时候，发现它使用了[lima-vm](https://github.com/lima-vm)来创建虚拟机。而lima-vm支持[自动端口转发和文件共享](https://lima-vm.io/docs/)。在我看来，对于开发者而言，这是Docker Desktop最有价值的功能了。于是，我决定立即使用docker cli和lima-vm。

I am running macOS Sonoma 14 on a M2 Max MacBook Pro with 64GB ram. I am using [macports](https://www.macports.org/). So the installation of lima-vm is pretty straightforward.

> 我使用的是M2 Max 64GB内存的MacBook Pro，操作系统为macOS Sonoma 14。同时，我是用[macports](https://www.macports.org/)。我是用以下命令即安装好了lima-vm

```
% sudo port install lima
```

Then I create the following docker-lima.yml under my home directory `~/`. If you do not need customization like me, you can just use `limactl create --name=default template://docker` to create a virtual machine. It is not required to create docker-lima.yml. 

> 接下来，我创建了`~/docker-lima.yml`，该文件内容如下。如果你不需要像我下面进行一些定制，那么，你可以直接使用`limactl create --name=default template://docker`创建虚拟机，而不需要创建docker-lima.yml文件。

```yml

vmType: "vz"
os: "Linux"

arch: "aarch64"

images:
# Try to use release-yyyyMMdd image if available. Note that release-yyyyMMdd will be removed after several months.
- location: "https://cloud-images.ubuntu.com/releases/22.04/release-20240308/ubuntu-22.04-server-cloudimg-amd64.img"
  arch: "x86_64"
  digest: "sha256:42dcf9757e75c3275486b397a752fb535c7cd8e5232ee5ee349554b7a55f1702"
- location: "https://cloud-images.ubuntu.com/releases/22.04/release-20240308/ubuntu-22.04-server-cloudimg-arm64.img"
  arch: "aarch64"
  digest: "sha256:0f5f68b9b74686b8a847024364031e2b95e4d3855e5177a99b33d7c55e45907f"
# Fallback to the latest release image.
# Hint: run `limactl prune` to invalidate the cache
- location: "https://cloud-images.ubuntu.com/releases/22.04/release/ubuntu-22.04-server-cloudimg-amd64.img"
  arch: "x86_64"
- location: "https://cloud-images.ubuntu.com/releases/22.04/release/ubuntu-22.04-server-cloudimg-arm64.img"
  arch: "aarch64"

cpus: 8
memory: "16GiB"
disk: "200GiB"


mounts:
- location: "~"
  writable: true # by default, lima will not mount ~ writable, I need ~ to be writable
- location: "/Volumes/ExternalDrive"  # I also need to mount an external drive
  writable: true
- location: "/tmp/lima"
  writable: true
# containerd is managed by Docker, not by Lima, so the values are set to false here.
containerd:
  system: false
  user: false
provision:
- mode: system
  # This script defines the host.docker.internal hostname when hostResolver is disabled.
  # It is also needed for lima 0.8.2 and earlier, which does not support hostResolver.hosts.
  # Names defined in /etc/hosts inside the VM are not resolved inside containers when
  # using the hostResolver; use hostResolver.hosts instead (requires lima 0.8.3 or later).
  script: |
    #!/bin/sh
    sed -i 's/host.lima.internal.*/host.lima.internal host.docker.internal/' /etc/hosts
- mode: system
  script: |
    #!/bin/bash
    set -eux -o pipefail
    command -v docker >/dev/null 2>&1 && exit 0
    if [ ! -e /etc/systemd/system/docker.socket.d/override.conf ]; then
      mkdir -p /etc/systemd/system/docker.socket.d
      # Alternatively we could just add the user to the "docker" group, but that requires restarting the user session
      cat <<-EOF >/etc/systemd/system/docker.socket.d/override.conf
      [Socket]
      SocketUser={{.User}}
    EOF
    fi
    export DEBIAN_FRONTEND=noninteractive
    curl -fsSL https://get.docker.com | sh
probes:
- script: |
    #!/bin/bash
    set -eux -o pipefail
    if ! timeout 30s bash -c "until command -v docker >/dev/null 2>&1; do sleep 3; done"; then
      echo >&2 "docker is not installed yet"
      exit 1
    fi
    if ! timeout 30s bash -c "until pgrep dockerd; do sleep 3; done"; then
      echo >&2 "dockerd is not running"
      exit 1
    fi
  hint: See "/var/log/cloud-init-output.log". in the guest
hostResolver:
  # hostResolver.hosts requires lima 0.8.3 or later. Names defined here will also
  # resolve inside containers, and not just inside the VM itself.
  hosts:
    host.docker.internal: host.lima.internal
portForwards:
- guestSocket: "/run/user/{{.UID}}/docker.sock"
  hostSocket: "{{.Dir}}/sock/docker.sock"
message: |
  To run `docker` on the host (assumes docker-cli is installed), run the following commands:
  ------
  docker context create lima-{{.Name}} --docker "host=unix://{{.Dir}}/sock/docker.sock"
  docker context use lima-{{.Name}}
  docker run hello-world
  ------
```

Then I create a `default` machine based on the `~/docker-lima.yml` file

> 接下来，我执行如下命令创建了一个`default`的lima虚拟机

```
% limactl create --name=default ~/docker-lima.yml

% limactl start default
...
...
INFO[0047] Message from the instance "default":
To run `docker` on the host (assumes docker-cli is installed), run the following commands:
------
docker context create lima-default --docker "host=unix:///Users/user/.lima/default/sock/docker.sock"
docker context use lima-default
docker run hello-world
------
```

Then, I follow the message from limactl to create a docker context and I can use docker seamlessly on macOS as if it is running natively. Port forwarding is automatically handled by lima-vm, directories are automatically mounted so that I can access files both in host and in container.
>接下来，我根据上述limactl命令最后给出的提示，创建了docker context，我于是可以在macOS上使用docker了，无论在host还是在容器里，我都可以访问macOS上的文件，同时lima-vm也自动进行了端口转发。


If you are like me who wants the port forwarding and auto directory mount features from Docker Desktop, I would suggest you use docker cli and lima-vm in your personal desktop and in company. It is 100% compatible with Docker, gives you seamlessly experience and you wouldn't need to worry about compatibility issues and similar Docker Desktop license issues. 

> 如果你像我一样，最需要Docker Desktop提供的端口转发和目录装在功能，那么我建议你使用docker cli和lima-vm。无论是个人使用，还是在公司内部使用，你都可以确保100% docker兼容，与原生Docker非常接近的体验，同时也无需担心Docker Desktop的授权问题。
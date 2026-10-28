#!/bin/bash

# 1. 시스템 업데이트 및 필수 패키지 설치
echo ">>> Updating system and installing prerequisites..."
sudo apt-get update -y && sudo apt-get upgrade -y
sudo apt-get install -y git curl net-tools ntp apt-transport-https ca-certificates software-properties-common gnupg2

# 2. 방화벽 해제 및 Swap 비활성화 (K8s 권장사항)
echo ">>> Disabling Firewall and Swap..."
sudo ufw disable
sudo swapoff -a
sudo sed -i '/swap/s/^/#/' /etc/fstab  # swap 포함된 라인 주석 처리 (더 안전한 방식)

# 3. 커널 모듈 로드 및 네트워크 커널 매개변수 설정
echo ">>> Configuring kernel modules and networking..."
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# sysctl 설정 통합
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sudo sysctl --system

# 4. Docker 및 Containerd 설치
echo ">>> Installing Docker and Containerd..."
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 5. Containerd 설정 (SystemdCgroup 활성화)
echo ">>> Configuring Containerd..."
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml > /dev/null
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml
sudo systemctl restart containerd

# 6. Docker 데몬 설정 및 권한 부여
echo ">>> Configuring Docker Daemon..."
cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
     "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

sudo usermod -aG docker $USER # 현재 사용자를 그룹에 추가
sudo systemctl daemon-reload
sudo systemctl enable --now docker

echo ">>> Setup complete. The system will reboot now."
sudo reboot

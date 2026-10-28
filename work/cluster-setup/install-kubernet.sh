#!/bin/bash
# 1. 환경 변수 설정 (버전 변경 시 여기만 수정)
K8S_VERSION="v1.28"
MASTER_IP="192.168.56.10"
NODE01_IP="192.168.56.101"
NODE02_IP="192.168.56.102"
echo ">>> Setting up Kubernetes $K8S_VERSION tools..."
# 2. Kubernetes 레포지토리 및 키링 등록
sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/$K8S_VERSION/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/$K8S_VERSION/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
# 3. 패키지 설치
echo ">>> Installing kubelet, kubeadm, and kubectl..."
sudo apt-get update -y
sudo apt-get install -y kubelet kubeadm kubectl
# 버전 고정 (자동 업데이트 방지)
sudo apt-mark hold kubelet kubeadm kubectl
# 4. Kubelet 활성화
echo ">>> Enabling Kubelet service..."
sudo systemctl daemon-reload
sudo systemctl enable --now kubelet
# 5. /etc/hosts 설정 (클러스터 내부 통신용)
echo ">>> Configuring /etc/hosts..."
# 기존에 동일한 설정이 있는지 확인 후 추가 (중복 방지)
sudo sed -i '/k8s-master\|k8s-node/d' /etc/hosts # 기존 k8s 관련 설정 삭제 후 갱신
cat <<EOF | sudo tee -a /etc/hosts > /dev/null
$MASTER_IP k8s-master
$NODE01_IP k8s-node01
$NODE02_IP k8s-node02
EOF
echo ">>> All tools installed and hosts configured successfully!"

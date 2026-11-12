#!/bin/bash
# =====================================================================
# BƯỚC 1 – Chạy trên CẢ 3 MÁY (cp, worker1, worker2)
# Cài containerd + kubeadm + kubelet + kubectl
#
# Cách chạy (đăng nhập bằng root):
#   bash 1-setup-node.sh
# =====================================================================
set -euo pipefail

K8S_VERSION="v1.37"

echo ">>> [1/6] Tắt swap (Kubernetes yêu cầu) và tường lửa trong máy"
# Tường lửa đã do Cloud Firewall của DigitalOcean lo, tắt ufw để không chặn các cổng của Kubernetes
ufw disable 2>/dev/null || true
swapoff -a
sed -i '/ swap / s/^/#/' /etc/fstab

echo ">>> [2/6] Bật module mạng và cho phép chuyển tiếp gói tin"
cat > /etc/modules-load.d/k8s.conf <<EOF
overlay
br_netfilter
EOF
modprobe overlay
modprobe br_netfilter

cat > /etc/sysctl.d/k8s.conf <<EOF
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
sysctl --system > /dev/null

echo ">>> [3/6] Cài containerd (chương trình chạy container)"
apt-get update -q
apt-get install -y -q containerd apt-transport-https ca-certificates curl gpg
mkdir -p /etc/containerd
containerd config default > /etc/containerd/config.toml
# Kubernetes dùng systemd để quản lý tài nguyên -> containerd cũng phải dùng systemd
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
systemctl restart containerd
systemctl enable containerd

echo ">>> [4/6] Cài kubeadm, kubelet, kubectl (${K8S_VERSION})"
mkdir -p /etc/apt/keyrings
curl -fsSL "https://pkgs.k8s.io/core:/stable:/${K8S_VERSION}/deb/Release.key" \
  | gpg --dearmor --yes -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/${K8S_VERSION}/deb/ /" \
  > /etc/apt/sources.list.d/kubernetes.list
apt-get update -q
apt-get install -y -q kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl   # không cho tự động nâng cấp

echo ">>> [5/6] Cho kubelet dùng IP nội bộ (VPC) thay vì IP public"
PRIVATE_IP=$(curl -s --max-time 3 http://169.254.169.254/metadata/v1/interfaces/private/0/ipv4/address || true)
if [ -z "$PRIVATE_IP" ]; then
  PRIVATE_IP=$(ip -4 -o addr show eth1 | awk '{print $4}' | cut -d/ -f1)
fi
echo "KUBELET_EXTRA_ARGS=--node-ip=${PRIVATE_IP}" > /etc/default/kubelet
systemctl enable kubelet

echo ">>> [6/6] Kiểm tra"
echo "  Hostname   : $(hostname)"
echo "  IP nội bộ  : ${PRIVATE_IP}"
echo "  containerd : $(containerd --version | awk '{print $3}')"
echo "  kubeadm    : $(kubeadm version -o short)"
echo
echo "XONG! Máy $(hostname) đã sẵn sàng."

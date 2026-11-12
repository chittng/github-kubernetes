#!/bin/bash
# =====================================================================
# BƯỚC 2 – Chỉ chạy trên máy cp (control plane)
# Khởi tạo cluster + cài plugin mạng Flannel
#
# Cách chạy (đăng nhập bằng root):
#   bash 2-init-cp.sh
# =====================================================================
set -euo pipefail

PRIVATE_IP=$(sed -n 's/.*--node-ip=\([0-9.]*\).*/\1/p' /etc/default/kubelet)
PRIVATE_IFACE=$(ip -4 -o addr show | awk -v ip="$PRIVATE_IP" '$4 ~ "^"ip"/" {print $2}')

echo ">>> [1/4] Khởi tạo cluster (mất khoảng 1-2 phút)"
kubeadm init \
  --apiserver-advertise-address="${PRIVATE_IP}" \
  --pod-network-cidr=10.244.0.0/16

echo ">>> [2/4] Cấu hình để dùng được lệnh kubectl"
mkdir -p "$HOME/.kube"
cp /etc/kubernetes/admin.conf "$HOME/.kube/config"

echo ">>> [3/4] Cài plugin mạng Flannel (CNI), dùng card mạng nội bộ ${PRIVATE_IFACE}"
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
kubectl -n kube-flannel set env daemonset/kube-flannel-ds FLANNELD_IFACE="${PRIVATE_IFACE}"

echo ">>> [4/4] Lệnh để 2 worker gia nhập cluster:"
echo
echo "================ COPY LỆNH DƯỚI ĐÂY, CHẠY TRÊN worker1 VÀ worker2 ================"
kubeadm token create --print-join-command
echo "================================================================================="

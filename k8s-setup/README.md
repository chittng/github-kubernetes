# Dựng cluster Kubernetes trên DigitalOcean

Cluster gồm 3 máy: `cp` (control plane), `worker1`, `worker2`.

```
                Internet (trình duyệt)
                        │ cổng 30000-32767 (NodePort)
   ┌────────────────────┼──────────────────────────┐
   │   VPC nội bộ của DigitalOcean (Singapore)      │
   │                                                │
   │   ┌──────────┐                                 │
   │   │    cp    │  control plane: quản lý cluster │
   │   └────┬─────┘                                 │
   │        │                                       │
   │   ┌────┴─────┐          ┌──────────┐           │
   │   │ worker1  │◄────────►│ worker2  │           │
   │   │ chạy pod │ Flannel  │ chạy pod │           │
   │   └──────────┘          └──────────┘           │
   └────────────────────────────────────────────────┘
```

- Hệ điều hành: Ubuntu 24.04, Kubernetes v1.37, containerd 2.x, plugin mạng Flannel
- Các máy nói chuyện với nhau qua **IP nội bộ (VPC)**, không đi qua Internet

---

## Bước 0 – Tạo Cloud Firewall (làm 1 lần)

**Networking → Firewalls → Create Firewall**

- Name: `k8s-firewall`
- **Inbound Rules** (xoá rule mặc định rồi thêm):

| Type | Protocol | Port | Sources |
|---|---|---|---|
| SSH | TCP | 22 | All IPv4, All IPv6 |
| Custom | TCP | 30000-32767 | All IPv4, All IPv6 |
| All TCP | TCP | All ports | gõ tag `k8s` |
| All UDP | UDP | All ports | gõ tag `k8s` |
| ICMP | ICMP | | gõ tag `k8s` |

- **Outbound Rules**: giữ mặc định (cho phép tất cả)
- **Apply to Droplets**: gõ tag `k8s`
- Bấm **Create Firewall**

> Nghĩa là: từ Internet chỉ vào được SSH và trang web; còn 3 máy có tag `k8s` thì thông nhau hoàn toàn.

## Bước 1 – Tạo 3 Droplet

**Create → Droplets**, tạo **3 lần** (hoặc 1 lần với Quantity = 3 rồi đổi tên):

| Mục | Chọn |
|---|---|
| Region | **Singapore** (cả 3 máy cùng region) |
| Image | **Ubuntu 24.04 (LTS) x64** |
| Size | Basic → Regular |
| | `cp`: **2 vCPU / 2 GB** (bắt buộc ≥ 2 vCPU) |
| | `worker1`, `worker2`: **1 vCPU / 2 GB** |
| Authentication | **Password** – đặt mật khẩu root (nhớ kỹ) |
| Hostname | đúng tên: `cp`, `worker1`, `worker2` |
| Tags | `k8s` |

Ghi lại IP public của 3 máy.

## Bước 2 – Cài đặt trên cả 3 máy

Vào từng Droplet → bấm **Console** (mở terminal ngay trên trình duyệt), chạy:

```bash
curl -fsSL https://raw.githubusercontent.com/chittng/github-kubernetes/main/k8s-setup/1-setup-node.sh | bash
```

Mất khoảng 2-3 phút. Cuối cùng thấy `XONG! Máy ... đã sẵn sàng.` là được.
**Có thể mở 3 tab Console và chạy song song cho nhanh.**

## Bước 3 – Khởi tạo cluster (chỉ trên `cp`)

```bash
curl -fsSL https://raw.githubusercontent.com/chittng/github-kubernetes/main/k8s-setup/2-init-cp.sh | bash
```

Cuối cùng script in ra lệnh `kubeadm join ...` – **copy lại lệnh đó**.

## Bước 4 – Cho 2 worker gia nhập (trên `worker1` và `worker2`)

Dán lệnh `kubeadm join ...` vừa copy, dạng:

```bash
kubeadm join 10.104.0.x:6443 --token xxxxx --discovery-token-ca-cert-hash sha256:xxxxx
```

## Bước 5 – Kiểm tra (trên `cp`)

```bash
kubectl get nodes -o wide
```

Chờ khoảng 1 phút, kết quả mong đợi (**chụp màn hình cho báo cáo**):

```
NAME      STATUS   ROLES           AGE   VERSION   INTERNAL-IP
cp        Ready    control-plane   5m    v1.37.x   10.104.0.2
worker1   Ready    <none>          2m    v1.37.x   10.104.0.3
worker2   Ready    <none>          2m    v1.37.x   10.104.0.4
```

Kiểm tra thêm các pod hệ thống đều `Running`:

```bash
kubectl get pods -A
```

---

## Xử lý lỗi thường gặp

| Hiện tượng | Cách xử lý |
|---|---|
| Node `NotReady` lâu | `kubectl get pods -n kube-flannel` xem Flannel có `Running` không |
| Lệnh join báo token hết hạn | Trên `cp` chạy `kubeadm token create --print-join-command` để lấy lệnh mới |
| Muốn làm lại từ đầu trên 1 máy | `kubeadm reset -f` rồi chạy lại bước tương ứng |

## Chi phí – QUAN TRỌNG

- DigitalOcean **vẫn tính tiền khi Droplet đã tắt (Power Off)**. Muốn dừng tính tiền phải **Destroy**.
- 3 máy theo cấu hình trên ~ **$0.06/giờ** (~$1.5/ngày). $5 dùng được khoảng **3 ngày** nếu để chạy liên tục.
- Xong bài (sau khi demo) nhớ **Destroy cả 3 Droplet**.

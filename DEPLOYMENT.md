# 🚀 Kubernetes Deployment Guide (K3s on EC2)

Panduan lengkap untuk deploy aplikasi Passkey Tutorial menggunakan K3s (Lightweight Kubernetes) di EC2.

---

## 📋 Prerequisites

Sebelum mulai, pastikan Anda sudah:

- ✅ Punya EC2 instance (minimal t3.small, 2GB RAM)
- ✅ EC2 running Ubuntu 22.04 LTS
- ✅ Security Group allow port: 22 (SSH), 80, 443, 30080
- ✅ SSH key (.pem file)
- ✅ Code sudah di-clone dari GitHub ke server

---

## 🎯 Step-by-Step Deployment

### **STEP 1: SSH ke Server**

Dari laptop Anda:

```powershell
# Fix permissions file .pem
icacls "path\to\your-key.pem" /inheritance:r
icacls "path\to\your-key.pem" /grant:r "$($env:USERNAME):(R)"

# SSH ke server
ssh -i "path\to\your-key.pem" ubuntu@YOUR_EC2_PUBLIC_IP
```

---

### **STEP 2: Verify Clone Repository**

Di server, pastikan code sudah ada:

```bash
cd ~
ls -la

# Jika belum clone, clone dulu:
# git clone https://github.com/YOUR_USERNAME/passkey-tutorial.git

# Masuk ke folder project
cd passkey-tutorial
```

---

### **STEP 3: Install K3s**

Install K3s (Lightweight Kubernetes):

```bash
# Run install script dengan sudo
sudo bash install-k3s.sh
```

Script ini akan:
- Update sistem
- Install Docker
- Install K3s
- Setup kubectl
- Configure permissions

⏱️ Proses ini memakan waktu **5-10 menit**.

**Tunggu sampai muncul:**
```
========================================
K3s Installation Complete!
========================================
```

**Logout dan login lagi** untuk apply group changes:
```bash
exit
# SSH lagi
ssh -i "your-key.pem" ubuntu@YOUR_EC2_PUBLIC_IP
cd passkey-tutorial
```

---

### **STEP 4: Verify K3s Installation**

Test apakah K3s sudah jalan:

```bash
# Check K3s status
sudo systemctl status k3s

# Check nodes (harus ada 1 node dengan status Ready)
sudo k3s kubectl get nodes

# Expected output:
# NAME       STATUS   ROLES                  AGE   VERSION
# ip-xxx     Ready    control-plane,master   1m    v1.xx.x+k3s1
```

---

### **STEP 5: Deploy Aplikasi**

Jalankan deployment script:

```bash
# Run deploy script
bash deploy.sh
```

Script ini akan:
1. ✅ Build Docker image dari source code
2. ✅ Import image ke K3s
3. ✅ Update configuration dengan Public IP Anda
4. ✅ Deploy MySQL database
5. ✅ Deploy aplikasi (2 replicas)

⏱️ Proses ini memakan waktu **3-5 menit**.

**Tunggu sampai muncul:**
```
========================================
Deployment Complete!
========================================

Access your application at:
  http://YOUR_PUBLIC_IP:30080
```

---

### **STEP 6: Verify Deployment**

Check semua pods running:

```bash
# List all pods
sudo k3s kubectl get pods -n passkey-tutorial

# Expected output:
# NAME                           READY   STATUS    RESTARTS   AGE
# mysql-xxxxxxxxx-xxxxx          1/1     Running   0          2m
# passkey-app-xxxxxxxxx-xxxxx    1/1     Running   0          1m
# passkey-app-yyyyyyyyy-yyyyy    1/1     Running   0          1m

# Check services
sudo k3s kubectl get svc -n passkey-tutorial

# Expected output:
# NAME          TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
# mysql         ClusterIP  None            <none>        3306/TCP       2m
# passkey-app   NodePort   10.43.xxx.xxx   <none>        80:30080/TCP   1m
```

Semua pods harus status **Running** dan **READY 1/1**.

---

### **STEP 7: Update Security Group**

Pastikan port 30080 terbuka di AWS Security Group:

1. AWS Console → EC2 → Instances
2. Pilih instance Anda → Tab **Security**
3. Click Security Group link
4. **Edit inbound rules** → **Add rule**
5. Settings:
   ```
   Type: Custom TCP
   Port: 30080
   Source: 0.0.0.0/0
   Description: K3s NodePort for passkey app
   ```
6. **Save rules**

---

### **STEP 8: Access Aplikasi**

Buka browser dan akses:

```
http://YOUR_EC2_PUBLIC_IP:30080
```

Anda akan lihat halaman Passkey Tutorial! 🎉

**Test fitur:**
1. Register user baru dengan passkey
2. Login dengan passkey
3. Akan redirect ke Circle Calculator
4. Test hitung luas dan keliling lingkaran

---

## 📊 Management Commands

### **Monitor Aplikasi**

```bash
# Watch pods status real-time
watch sudo k3s kubectl get pods -n passkey-tutorial

# View app logs
sudo k3s kubectl logs -f deployment/passkey-app -n passkey-tutorial

# View MySQL logs
sudo k3s kubectl logs -f deployment/mysql -n passkey-tutorial

# Describe pod untuk troubleshooting
sudo k3s kubectl describe pod <pod-name> -n passkey-tutorial
```

### **Restart Aplikasi**

```bash
# Restart app deployment
sudo k3s kubectl rollout restart deployment/passkey-app -n passkey-tutorial

# Restart MySQL
sudo k3s kubectl rollout restart deployment/mysql -n passkey-tutorial
```

### **Scale Aplikasi**

```bash
# Scale to 3 replicas
sudo k3s kubectl scale deployment/passkey-app --replicas=3 -n passkey-tutorial

# Scale back to 2
sudo k3s kubectl scale deployment/passkey-app --replicas=2 -n passkey-tutorial
```

### **Update Code (Redeploy)**

Setelah update code di GitHub:

```bash
# Pull latest code
cd ~/passkey-tutorial
git pull origin main

# Redeploy
bash deploy.sh
```

---

## 🔧 Troubleshooting

### **Problem: Pods tidak Running**

```bash
# Check pod details
sudo k3s kubectl describe pod <pod-name> -n passkey-tutorial

# Common issues:
# - Image pull error → Build ulang: bash deploy.sh
# - MySQL not ready → Wait longer atau restart MySQL
# - Resource limits → Scale down atau upgrade EC2
```

### **Problem: Cannot access http://IP:30080**

1. Check Security Group (port 30080 harus terbuka)
2. Check service: `sudo k3s kubectl get svc -n passkey-tutorial`
3. Check pods: `sudo k3s kubectl get pods -n passkey-tutorial`

### **Problem: Passkey Registration Failed**

Check RP_ID dan ORIGIN di deployment:
```bash
sudo k3s kubectl get deployment/passkey-app -n passkey-tutorial -o yaml | grep -A 2 RP_ID
```

Harus sesuai dengan Public IP EC2 Anda.

### **Problem: MySQL Connection Error**

```bash
# Check MySQL pod
sudo k3s kubectl get pods -l app=mysql -n passkey-tutorial

# Check MySQL logs
sudo k3s kubectl logs deployment/mysql -n passkey-tutorial

# Restart MySQL
sudo k3s kubectl rollout restart deployment/mysql -n passkey-tutorial
```

---

## 🗑️ Uninstall / Cleanup

### **Delete Application Only**

```bash
# Delete namespace (ini akan hapus semua resources)
sudo k3s kubectl delete namespace passkey-tutorial
```

### **Uninstall K3s Completely**

```bash
# Run K3s uninstall script
sudo /usr/local/bin/k3s-uninstall.sh
```

---

## 💰 Cost Estimate

**EC2 t3.small** (recommended):
- Instance: ~$15/month
- Storage: ~$3/month
- Data transfer: ~$5/month
- **Total: ~$25-30/month**

**EC2 t2.micro** (free tier):
- FREE for 12 months pertama
- After that: ~$10/month

---

## 🎓 Next Steps

1. **Setup Domain & SSL**
   - Point domain ke EC2 Public IP
   - Install cert-manager di K3s
   - Setup Let's Encrypt SSL

2. **Setup Monitoring**
   - Install Prometheus + Grafana
   - Setup alerting

3. **Setup CI/CD**
   - GitHub Actions untuk auto-deploy
   - Automated testing

4. **Backup Database**
   - Setup automated MySQL backup
   - Store di S3

---

## 📚 Useful Resources

- K3s Documentation: https://docs.k3s.io/
- Kubernetes Docs: https://kubernetes.io/docs/
- kubectl Cheat Sheet: https://kubernetes.io/docs/reference/kubectl/cheatsheet/

---

## ❓ Need Help?

Jika ada masalah, jalankan diagnostic:

```bash
# System info
uname -a
docker --version
sudo k3s kubectl version

# K3s status
sudo systemctl status k3s

# All resources
sudo k3s kubectl get all -n passkey-tutorial

# Events
sudo k3s kubectl get events -n passkey-tutorial --sort-by='.lastTimestamp'
```

Paste output di atas untuk troubleshooting! 🔍

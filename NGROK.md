# 🚀 Ngrok Setup Guide

Panduan setup Ngrok untuk akses HTTPS ke aplikasi Passkey Tutorial.

---

## 🎯 Kenapa Butuh Ngrok?

WebAuthn/Passkey **hanya bisa jalan di secure context**:
- ✅ `https://` (production)
- ✅ `localhost` (development)
- ❌ `http://IP-address` (tidak bisa!)

Ngrok memberikan instant HTTPS tunnel ke aplikasi Anda.

---

## 📋 Prerequisites

- ✅ K3s dan aplikasi sudah deployed
- ✅ Pods running di K3s
- ✅ Akun Ngrok (free tier cukup)

---

## 🚀 Setup Ngrok (Step-by-Step)

### **STEP 1: Sign Up Ngrok**

1. Buka https://ngrok.com
2. Click **Sign Up** (FREE)
3. Login dengan Google/GitHub atau email
4. Setelah login, buka: https://dashboard.ngrok.com/get-started/your-authtoken
5. **Copy authtoken** Anda (format: `2a...xyz`)

---

### **STEP 2: SSH ke Server**

Dari laptop:

```powershell
ssh -i "D:\Hanan\Kowan\uas\uas-kowan.pem" ubuntu@3.235.222.237
cd passkey-tutorial
```

---

### **STEP 3: Pull Latest Code**

```bash
git pull origin main
```

---

### **STEP 4: Run Ngrok Setup Script**

```bash
bash setup-ngrok.sh
```

Script akan tanya authtoken:
```
Enter your Ngrok authtoken: 
```

**Paste authtoken** Anda yang sudah dicopy tadi, lalu Enter.

⏱️ **Tunggu 10-20 detik** sampai muncul:
```
Ngrok Setup Complete!

Your Ngrok URL: https://xxxx-xxxx-xxxx.ngrok-free.app
```

**PENTING:** Copy URL ini!

---

### **STEP 5: Update Deployment dengan Ngrok URL**

```bash
bash update-ngrok-url.sh
```

Script akan:
1. Detect Ngrok URL otomatis
2. Update environment variables di K8s
3. Restart pods dengan config baru

⏱️ **Tunggu 30-60 detik** sampai pods restart.

---

### **STEP 6: Verify Deployment**

```bash
# Check pods running
sudo k3s kubectl get pods -n passkey-tutorial

# Check environment variables
sudo k3s kubectl get deployment/passkey-app -n passkey-tutorial -o yaml | grep -A 2 RP_ID
```

Output harus showing:
```yaml
- name: RP_ID
  value: "xxxx-xxxx-xxxx.ngrok-free.app"
- name: ORIGIN
  value: "https://xxxx-xxxx-xxxx.ngrok-free.app"
```

---

### **STEP 7: Access Aplikasi**

Buka browser dan akses Ngrok URL Anda:

```
https://xxxx-xxxx-xxxx.ngrok-free.app
```

**Ngrok free tier akan show warning page:**
- Click **Visit Site** untuk continue

Sekarang aplikasi bisa diakses dengan HTTPS! 🎉

---

## ✅ Test Passkey

1. **Register User:**
   - Masukkan username
   - Click **Register**
   - Gunakan passkey (fingerprint/face ID/PIN)
   - Harus sukses ✅

2. **Login:**
   - Masukkan username yang sama
   - Click **Login**
   - Gunakan passkey
   - Akan redirect ke Circle Calculator ✅

3. **Test Calculator:**
   - Masukkan radius (misal: 5)
   - Click **Calculate**
   - Akan tampil area dan circumference ✅

---

## 🔄 Jika Ngrok URL Berubah

**Ngrok free tier URL berubah setiap restart!**

Jika Ngrok restart atau URL berubah:

```bash
# Di server
bash update-ngrok-url.sh
```

Script akan otomatis detect URL baru dan update deployment.

---

## 📊 Monitoring Ngrok

### **Check Ngrok Status**

```bash
# Service status
sudo systemctl status ngrok

# Live logs
sudo journalctl -u ngrok -f

# Get current URL
curl -s http://localhost:4040/api/tunnels | grep public_url
```

### **Ngrok Web Dashboard**

Buka di browser (dari SSH tunnel):

```bash
# Di laptop (PowerShell baru)
ssh -i "D:\Hanan\Kowan\uas\uas-kowan.pem" -L 4040:localhost:4040 ubuntu@3.235.222.237
```

Lalu buka: http://localhost:4040

Dashboard ini showing:
- Current tunnel URL
- Request/response logs
- Traffic statistics

---

## 🛠️ Troubleshooting

### **Problem: "Could not get Ngrok URL"**

```bash
# Check if ngrok running
sudo systemctl status ngrok

# Check ngrok API
curl http://localhost:4040/api/tunnels

# Restart ngrok
sudo systemctl restart ngrok
sleep 5
bash update-ngrok-url.sh
```

### **Problem: "Ngrok tunnel not found"**

Check authtoken valid:
```bash
ngrok config check

# Re-add authtoken
ngrok config add-authtoken YOUR_TOKEN
sudo systemctl restart ngrok
```

### **Problem: WebAuthn masih error**

1. **Check RP_ID dan ORIGIN:**
   ```bash
   sudo k3s kubectl get deployment/passkey-app -n passkey-tutorial -o yaml | grep -A 2 RP_ID
   ```

2. **Check pods restarted:**
   ```bash
   sudo k3s kubectl get pods -n passkey-tutorial
   # AGE harus recent (beberapa menit)
   ```

3. **Check logs:**
   ```bash
   sudo k3s kubectl logs -f deployment/passkey-app -n passkey-tutorial
   ```

### **Problem: Ngrok service tidak start**

```bash
# Check logs
sudo journalctl -u ngrok -n 50

# Manual start untuk testing
ngrok http 30080

# Jika jalan, stop (Ctrl+C) dan restart service
sudo systemctl restart ngrok
```

---

## 💡 Tips

### **Permanent URL (Paid Feature)**

Ngrok free tier URL berubah setiap restart. Untuk permanent URL:
- Upgrade ke Ngrok paid ($8/bulan)
- Dapat custom subdomain: `myapp.ngrok.io`
- URL tidak berubah

### **Alternative ke Ngrok**

Jika tidak mau pakai Ngrok, alternatives:
- **LocalTunnel** (free, similar to ngrok)
- **Cloudflare Tunnel** (free, more complex)
- **Buy domain + Let's Encrypt** (permanent solution)

---

## 🔒 Security Notes

⚠️ **Ngrok URL bersifat public!** Siapa saja yang punya URL bisa akses.

Untuk production:
- Gunakan proper domain + SSL
- Implement authentication/authorization
- Use firewall rules
- Monitor access logs

---

## 📝 Useful Commands

```bash
# Get current Ngrok URL
curl -s http://localhost:4040/api/tunnels | grep -o '"public_url":"https://[^"]*' | cut -d'"' -f4

# Restart Ngrok
sudo systemctl restart ngrok

# Stop Ngrok
sudo systemctl stop ngrok

# Update deployment after Ngrok restart
bash update-ngrok-url.sh

# View Ngrok logs
sudo journalctl -u ngrok -f

# Uninstall Ngrok
sudo systemctl stop ngrok
sudo systemctl disable ngrok
sudo rm /etc/systemd/system/ngrok.service
sudo apt remove ngrok
```

---

## ✅ Success Checklist

Deployment berhasil jika:
- ✅ Ngrok service running: `sudo systemctl status ngrok`
- ✅ Ngrok URL dapat diakses: `https://xxxx.ngrok-free.app`
- ✅ Pods running dengan RP_ID correct
- ✅ Bisa register user dengan passkey
- ✅ Bisa login dengan passkey
- ✅ Circle calculator berfungsi

---

## 🎓 Next Steps

Setelah Ngrok jalan:
1. Test semua fitur aplikasi
2. Share URL ke teman untuk demo
3. Consider upgrade ke paid plan untuk permanent URL
4. Atau setup proper domain + SSL untuk production

---

Enjoy your HTTPS-enabled Passkey app! 🚀🔒

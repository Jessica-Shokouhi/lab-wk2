# **README.md**

# **lab-wk2 — Nginx Install & HTML Deployment**

## **Group Members**
- **Jessica**
- **Partner Name**
- **Partner Name**

---

## **AWS Region**
`us-west-2`

---

# **Part 1 — SSH Key Creation**

### **SSH Key Generation Command**

```bash
ssh-keygen -t ed25519 -f ~/.ssh/wkone
```

### **Explanation of Options**
- **`ssh-keygen`** — Generates a new SSH key pair.  
- **`-t ed25519`** — Specifies the key type using the Ed25519 elliptic‑curve algorithm.  
- **`-f ~/.ssh/wkone`** — Sets the output filename for the private key. The public key becomes `wkone.pub`.

After generating the key, the public key was added to the AWS console under:

**IAM → Security Credentials → SSH Keys**

---

# **Part 2 — EC2 Instance Setup**

A Debian EC2 instance was created using:

- **Instance type:** `t2.micro`  
- **AMI:** Debian  
- **SSH key:** `wkone`  
- **Security group:** Allowed **SSH (22)** and **HTTP (80)**  
---

# **Part 3 — Scripts & Environment Variables**

All scripts were executed **from the local development environment**, not from the EC2 instance.

---

# **Environment Variables File — `env-vars`**

This file is sourced using:

```bash
source env-vars
```

### **env-vars**
```bash
USERNAME="admin"
IP_ADDRESS="54.202.91.139"
SSH_KEY_PATH="$HOME/.ssh/wkone"
```

---

# **Script 1 — `nginx-install`**

### **Description**
Installs Nginx on the remote Debian EC2 instance, then starts and enables the service.

### **nginx-install**
```bash
#!/bin/bash
# This script installs nginx on the remote EC2 instance
# and enables and starts the nginx service.

source ./env.sh

ssh -i "$SSH_KEY" "$USERNAME@$SERVER_IP" << 'EOF'
sudo apt update
sudo apt install -y nginx
sudo systemctl start nginx
sudo systemctl enable nginx
EOF
```

---

# **Script 2 — `document-write`**

### **Description**
This script:

- Gets today’s date from the **local machine**
- Uses a heredoc to overwrite `/var/www/html/index.html`
- Reloads Nginx

### **document-write**
```bash
#!/bin/bash
# This script writes an HTML document to the nginx web directory
# The date is generated locally and sent to the remote server.

source ./env.sh

TODAY=$(date +"%d/%m/%Y")

ssh -i "$SSH_KEY" "$USERNAME@$SERVER_IP" << EOF
sudo tee /var/www/html/index.html > /dev/null << HTML
<!DOCTYPE html>
<html lang='en'>
<head>
  <meta charset='UTF-8'>
  <meta name='viewport' content='width=device-width, initial-scale=1.0'>
  <title>Hello World</title>
</head>
<body>
  <h1>Hello World!</h1>
  <p>Today's date is: $TODAY</p>
</body>
</html>
HTML

sudo systemctl reload nginx
EOF

```

---

# **Testing the Server**

After running both scripts:

```bash
./nginx-install
./document-write
```

Visit:

```
http://54.202.91.139/
```
---

# **Screenshot of Working Server**

*(Insert your screenshot here)*

---

# **Repository Link**

Provide your public GitHub repo URL:

```
https://github.com/your-username/your-repo-name
```



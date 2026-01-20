# lab-wk2 — Nginx Install & HTML Deployment

## Group Members
- Jessica
- Cole
- Kyle

## AWS Region
`us-west-2`

---

## Part 1 — SSH Key Creation

### SSH Key Generation Command
```bash
ssh-keygen -t ed25519 -f ~/.ssh/wkone
````

### Explanation of Options

* `ssh-keygen` — Generates a new SSH key pair.
* `-t ed25519` — Specifies the key type using the Ed25519 elliptic‑curve algorithm.
* `-f ~/.ssh/wkone` — Sets the output filename for the private key. The public key becomes `wkone.pub`.

After generating the key, the public key was added to the AWS console under:
`IAM → Security Credentials → SSH Keys`

---

## Part 2 — EC2 Instance Setup

A Debian EC2 instance was created using:

* **Instance type:** t2.micro
* **AMI:** Debian
* **SSH key:** wkone
* **Security group:** Allowed SSH (22) and HTTP (80)

---

## Part 3 — Scripts & Environment Variables

All scripts were executed from the local development environment, **not** from the EC2 instance.

### Environment Variables File — `env.sh`

This file is sourced using:

```bash
source ./env.sh
```

Contents of `env.sh`:

```bash
export USERNAME="admin"
export SERVER_IP="54.202.91.139"
export SSH_KEY="$HOME/.ssh/wkone"
```

---

### Script 1 — `nginx-install`

**Description:** Installs Nginx on the remote Debian EC2 instance, then starts and enables the service.

```bash
#!/bin/bash
# This script installs nginx on the remote EC2 instance and enables and starts the nginx service.

source ./env.sh

ssh -i "$SSH_KEY" "$USERNAME@$SERVER_IP" << 'EOF'
sudo apt update
sudo apt install -y nginx
sudo systemctl enable --now nginx
EOF
```

---

### Script 2 — `document-write`

**Description:** This script:

1. Gets today’s date from the local machine
2. Uses a heredoc to overwrite `/var/www/html/index.html`
3. Reloads Nginx

```bash
#!/usr/bin/env bash
source ./env.sh

now=$(date "+%d/%m/%Y")

ssh -i "$SSH_KEY" "$USERNAME@$SERVER_IP" <<EOF
sudo bash << END
cat > /var/www/html/index.html <<HTML
<!DOCTYPE html>
<html>
<head>
    <title>Nginx</title>
</head>
<body>
    <h1>Nginx is running!</h1>
    <p>Today's date is $now</p>
</body>
</html>
HTML
sudo systemctl reload nginx
END
EOF
```

---

## Testing the Server

After running both scripts:

```bash
source ./env.sh
./nginx-install
./document-write
```

Visit: [http://54.202.91.139/](http://54.202.91.139/)

---

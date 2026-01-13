#!/usr/bin/env bash
# The date is generated locally and sent to the remote server.
source ./ec2.env
now=$(date "+%d/%m/%Y")
ssh -i "$SSH_KEY_PATH" "$USERNAME@$IP_ADDRESS" <<EOF
sudo bash << END
cat > /var/www/html/index.html
<!DOCTYPE html>
<html>
<head>
    <title>Nginx</title>
</head>
<body>
    <h1>Nginx is running!</h1>
    <p>Today's date is $now</p>
<boday>
</html>
END

sudo systemctl reload nginx
EOF

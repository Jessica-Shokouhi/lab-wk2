#!/bin/bash
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

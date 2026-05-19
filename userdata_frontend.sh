#!/bin/bash
# ─────────────────────────────────────────────────────────────
# Frontend User Data Script
# Runs on the single frontend EC2 in the public subnet
# ─────────────────────────────────────────────────────────────
set -e

echo " Starting frontend setup..."

# ── System updates & dependencies ────────────────────────────
sudo apt-get update -y
sudo apt-get install -y git curl nginx

# ── Node.js 18 ───────────────────────────────────────────────
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt-get install -y nodejs
echo "Node $(node -v) installed"

# ── Angular CLI ───────────────────────────────────────────────
npm install -g @angular/cli@19
echo "Angular CLI installed"

# ── Clone frontend repo ───────────────────────────────────────
if [ -n "${github_token}" ]; then
  REPO_URL="https://${github_token}@${github_frontend_repo}.git"
else
  REPO_URL="https://${github_frontend_repo}.git"
fi

git clone "$REPO_URL" /home/ubuntu/client
cd /home/ubuntu/client
echo "Frontend repo cloned"

# ── Inject real ALB DNS into environment.prod.ts ─────────────
# Vérifier si le dossier environments existe, sinon le créer
if [ ! -d "src/environments" ]; then
    echo "Creating src/environments directory"
    mkdir -p src/environments
fi

# Vérifier si le fichier environment.prod.ts existe, sinon le créer
if [ ! -f "src/environments/environment.prod.ts" ]; then
    echo "Creating environment.prod.ts file"
    cat > src/environments/environment.prod.ts <<'EOF'
export const environment = {
  production: true,
  apiUrl: 'REPLACE_API_URL'
};
EOF
fi

# Afficher le contenu avant modification
echo "Before sed:"
cat src/environments/environment.prod.ts

# Remplacer le placeholder
sed -i "s|REPLACE_API_URL|http://${alb_dns_name}/api|g" src/environments/environment.prod.ts # /users
# Afficher le contenu après modification
echo "After sed:"
cat src/environments/environment.prod.ts
echo "API URL set to: http://${alb_dns_name}/api" #/users

# ── Install packages & build for production ───────────────────
echo "Installing npm packages..."
npm install

echo "Building Angular app..."
ng build --configuration production
echo "Angular build complete"

# Afficher la structure du build pour déboguer
echo " Build structure:"
ls -la dist/
if [ -d "dist/client" ]; then
    echo "dist/client exists:"
    ls -la dist/client/
fi

# ── Deploy to nginx ───────────────────────────────────────────
rm -rf /var/www/html/*

# Trouver le bon chemin du build
if [ -d "dist/client/browser" ]; then
    echo "Copying from dist/client/browser"
    cp -r dist/client/browser/* /var/www/html/
elif [ -d "dist/browser" ]; then
    echo "Copying from dist/browser"
    cp -r dist/browser/* /var/www/html/
elif [ -d "dist" ]; then
    echo "Copying from dist"
    cp -r dist/* /var/www/html/
else
    echo "ERROR: Build directory not found!"
    ls -la dist/
    exit 1
fi

# Vérifier que index.html a été copié
if [ -f "/var/www/html/index.html" ]; then
    echo "index.html successfully deployed"
else
    echo "index.html not found in /var/www/html/"
    exit 1
fi

# nginx config — handles Angular routing (all routes → index.html)
cat > /etc/nginx/sites-available/default <<'NGINXCONF'
server {
    listen 80;
    server_name _;
    root /var/www/html;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }
}
NGINXCONF

systemctl enable nginx
systemctl restart nginx

echo "nginx configured and started"
echo "Frontend setup complete — app is live on port 80"
# AI House Planner — Production Deployment Guide

This guide covers deploying AI House Planner to production using three different infrastructure options, plus common post-deployment tasks like SSL setup, monitoring, and backups.

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Environment Variables for Production](#environment-variables-for-production)
3. [AWS Deployment (ECS + RDS)](#aws-deployment-ecs--rds)
4. [DigitalOcean App Platform](#digitalocean-app-platform)
5. [Manual VPS Deployment](#manual-vps-deployment)
6. [SSL/TLS with Let's Encrypt](#ssltls-with-lets-encrypt)
7. [Database Migrations](#database-migrations)
8. [Monitoring Setup](#monitoring-setup)
9. [Backup Strategy](#backup-strategy)
10. [Rollback Procedure](#rollback-procedure)

---

## Prerequisites

Before deploying, ensure you have:

- A domain name (e.g. `houseplanner.ai`) with DNS access
- An OpenAI API key (or Gemini API key as fallback)
- A SendGrid API key (or SMTP credentials) for email
- AWS account or DigitalOcean account (depending on deployment target)
- Docker 24+ and Docker Compose 2.20+ on your local machine for building images

---

## Environment Variables for Production

Create a `backend/.env.production` file (never commit this to git):

```env
# Server
NODE_ENV=production
PORT=3000
FRONTEND_URL=https://houseplanner.ai
ADMIN_URL=https://admin.houseplanner.ai

# Database (use RDS endpoint in AWS, managed DB in DigitalOcean)
DB_HOST=your-rds-or-managed-db-endpoint
DB_PORT=5432
DB_NAME=house_planner_db
DB_USER=postgres
DB_PASSWORD=very_secure_random_password_here
DB_SSL=true
DB_POOL_MIN=2
DB_POOL_MAX=10

# Redis (use ElastiCache in AWS, or Redis Cloud)
REDIS_URL=rediss://your-redis-endpoint:6380
REDIS_PASSWORD=redis_password_here

# JWT (use a 64-char random hex string)
JWT_SECRET=64_character_random_hex_string_generated_with_openssl_rand_hex_32
JWT_EXPIRES_IN=7d
JWT_REFRESH_EXPIRES_IN=30d

# AI
OPENAI_API_KEY=sk-prod-...
OPENAI_MODEL=gpt-4o
OPENAI_MAX_TOKENS=4096
GEMINI_API_KEY=AIza...

# Email
EMAIL_PROVIDER=sendgrid
SENDGRID_API_KEY=SG.xxx
EMAIL_FROM_NAME=AI House Planner
EMAIL_FROM_ADDRESS=noreply@houseplanner.ai

# File Storage (S3)
STORAGE_PROVIDER=s3
AWS_ACCESS_KEY_ID=AKIA...
AWS_SECRET_ACCESS_KEY=xxx
AWS_S3_BUCKET=houseplanner-prod-uploads
AWS_S3_REGION=us-east-1
AWS_CLOUDFRONT_URL=https://cdn.houseplanner.ai

# OAuth
GOOGLE_CLIENT_ID=xxx.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=GOCSPX-xxx

# Currency
EXCHANGE_RATE_API_KEY=your_key_here

# Security
CORS_ORIGINS=https://houseplanner.ai,https://admin.houseplanner.ai
RATE_LIMIT_WINDOW_MS=60000
RATE_LIMIT_MAX=100
BCRYPT_ROUNDS=12

# Logging
LOG_LEVEL=info
LOG_FORMAT=json
SENTRY_DSN=https://xxx@sentry.io/xxx
```

---

## AWS Deployment (ECS + RDS)

### Architecture Overview

```
Internet
    |
[Route 53] ─── DNS
    |
[ACM Certificate]
    |
[Application Load Balancer]
    |           |
[ECS Service] [ECS Service]
[Backend API] [Admin Dashboard]
    |
[RDS PostgreSQL 16]
    |
[ElastiCache Redis]
    |
[S3 Bucket] (uploads + reports)
    |
[CloudFront CDN]
```

### Step 1: Create Infrastructure

#### RDS PostgreSQL

```bash
aws rds create-db-instance \
  --db-instance-identifier houseplanner-prod \
  --db-instance-class db.t3.medium \
  --engine postgres \
  --engine-version 16.2 \
  --master-username postgres \
  --master-user-password "$(openssl rand -base64 32)" \
  --allocated-storage 50 \
  --storage-type gp3 \
  --multi-az \
  --backup-retention-period 7 \
  --deletion-protection \
  --db-name house_planner_db \
  --vpc-security-group-ids sg-xxxxxxxx \
  --db-subnet-group-name houseplanner-subnet-group
```

#### ElastiCache Redis

```bash
aws elasticache create-replication-group \
  --replication-group-id houseplanner-redis \
  --replication-group-description "House Planner Redis" \
  --cache-node-type cache.t3.micro \
  --engine redis \
  --engine-version 7.1 \
  --num-cache-clusters 2 \
  --at-rest-encryption-enabled \
  --transit-encryption-enabled \
  --security-group-ids sg-xxxxxxxx
```

#### S3 Bucket

```bash
aws s3api create-bucket \
  --bucket houseplanner-prod-uploads \
  --region us-east-1

aws s3api put-bucket-versioning \
  --bucket houseplanner-prod-uploads \
  --versioning-configuration Status=Enabled

aws s3api put-bucket-encryption \
  --bucket houseplanner-prod-uploads \
  --server-side-encryption-configuration '{
    "Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}]
  }'
```

### Step 2: Build and Push Docker Images

```bash
# Authenticate to ECR
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin \
  123456789.dkr.ecr.us-east-1.amazonaws.com

# Build and push backend
docker build -t houseplanner-backend ./backend
docker tag houseplanner-backend:latest \
  123456789.dkr.ecr.us-east-1.amazonaws.com/houseplanner-backend:latest
docker push 123456789.dkr.ecr.us-east-1.amazonaws.com/houseplanner-backend:latest

# Build and push admin dashboard
docker build -t houseplanner-admin ./admin_dashboard
docker tag houseplanner-admin:latest \
  123456789.dkr.ecr.us-east-1.amazonaws.com/houseplanner-admin:latest
docker push 123456789.dkr.ecr.us-east-1.amazonaws.com/houseplanner-admin:latest
```

### Step 3: ECS Task Definitions

Create `ecs-backend-task.json`:

```json
{
  "family": "houseplanner-backend",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "512",
  "memory": "1024",
  "containerDefinitions": [
    {
      "name": "backend",
      "image": "123456789.dkr.ecr.us-east-1.amazonaws.com/houseplanner-backend:latest",
      "portMappings": [{ "containerPort": 3000 }],
      "environment": [
        { "name": "NODE_ENV", "value": "production" }
      ],
      "secrets": [
        { "name": "DB_PASSWORD",     "valueFrom": "arn:aws:secretsmanager:..." },
        { "name": "JWT_SECRET",      "valueFrom": "arn:aws:secretsmanager:..." },
        { "name": "OPENAI_API_KEY",  "valueFrom": "arn:aws:secretsmanager:..." }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/houseplanner-backend",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "ecs"
        }
      },
      "healthCheck": {
        "command": ["CMD-SHELL", "wget -qO- http://localhost:3000/api/health || exit 1"],
        "interval": 30,
        "timeout": 10,
        "retries": 3
      }
    }
  ]
}
```

```bash
aws ecs register-task-definition --cli-input-json file://ecs-backend-task.json
```

### Step 4: Run Database Migrations

Run the schema migrations as a one-off ECS task before starting the services:

```bash
aws ecs run-task \
  --cluster houseplanner-prod \
  --task-definition houseplanner-backend \
  --overrides '{
    "containerOverrides": [{
      "name": "backend",
      "command": ["node", "src/database/migrate.js"]
    }]
  }'
```

---

## DigitalOcean App Platform

### Step 1: Push your code to GitHub

```bash
git remote add origin https://github.com/your-org/ai-house-planner.git
git push -u origin main
```

### Step 2: Create App from GitHub

1. Go to [DigitalOcean Apps](https://cloud.digitalocean.com/apps)
2. Click **Create App** → select your GitHub repository
3. DigitalOcean will detect the `Dockerfile` in each service directory

### Step 3: Configure Services

Create a `.do/app.yaml` in the repository root:

```yaml
name: houseplanner
region: nyc

databases:
  - name: houseplanner-db
    engine: PG
    version: "16"
    size: db-s-1vcpu-1gb
    num_nodes: 1

services:
  - name: backend
    source_dir: /backend
    dockerfile_path: /backend/Dockerfile
    http_port: 3000
    instance_count: 2
    instance_size_slug: professional-xs
    routes:
      - path: /api
    envs:
      - key: NODE_ENV
        value: production
      - key: DB_HOST
        value: ${houseplanner-db.HOSTNAME}
      - key: DB_PORT
        value: ${houseplanner-db.PORT}
      - key: DB_NAME
        value: ${houseplanner-db.DATABASE}
      - key: DB_USER
        value: ${houseplanner-db.USERNAME}
      - key: DB_PASSWORD
        value: ${houseplanner-db.PASSWORD}
      - key: JWT_SECRET
        value: "your-64-char-secret"
        type: SECRET
      - key: OPENAI_API_KEY
        value: "sk-prod-..."
        type: SECRET
    health_check:
      http_path: /api/health

  - name: admin-dashboard
    source_dir: /admin_dashboard
    dockerfile_path: /admin_dashboard/Dockerfile
    http_port: 80
    routes:
      - path: /
    instance_count: 1
    instance_size_slug: basic-xxs
```

### Step 4: Deploy

```bash
doctl apps create --spec .do/app.yaml
```

---

## Manual VPS Deployment

Suitable for a single Ubuntu 22.04 LTS server (minimum 2 vCPU, 4 GB RAM).

### Step 1: Server Setup

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER
newgrp docker

# Install Docker Compose
sudo apt install -y docker-compose-plugin

# Install Nginx (for reverse proxy)
sudo apt install -y nginx certbot python3-certbot-nginx

# Create application directory
sudo mkdir -p /opt/houseplanner
sudo chown $USER:$USER /opt/houseplanner
```

### Step 2: Deploy Application

```bash
# Clone repository
git clone https://github.com/your-org/ai-house-planner.git /opt/houseplanner
cd /opt/houseplanner

# Configure environment
cp backend/.env.example backend/.env
nano backend/.env   # fill in production values

# Create .env for docker-compose
cat > .env << 'EOF'
DB_PASSWORD=your_very_secure_password
REDIS_PASSWORD=your_redis_password
BACKEND_PORT=3000
ADMIN_PORT=3001
EOF

# Start services
docker compose -f docker-compose.yml up -d

# Check status
docker compose ps
docker compose logs -f backend
```

### Step 3: Configure Nginx Reverse Proxy

Create `/etc/nginx/sites-available/houseplanner`:

```nginx
server {
    listen 80;
    server_name houseplanner.ai www.houseplanner.ai;

    location / {
        return 301 https://$host$request_uri;
    }
}

server {
    listen 443 ssl http2;
    server_name houseplanner.ai www.houseplanner.ai;

    # SSL configured by certbot

    location /api {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto https;
        proxy_read_timeout 120s;
        client_max_body_size 20M;
    }

    location / {
        proxy_pass http://127.0.0.1:3001;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}

server {
    listen 80;
    server_name admin.houseplanner.ai;
    return 301 https://$host$request_uri;
}
```

```bash
sudo ln -s /etc/nginx/sites-available/houseplanner /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx
```

---

## SSL/TLS with Let's Encrypt

```bash
# Obtain certificates
sudo certbot --nginx \
  -d houseplanner.ai \
  -d www.houseplanner.ai \
  -d admin.houseplanner.ai \
  --email admin@houseplanner.ai \
  --agree-tos \
  --non-interactive

# Verify auto-renewal
sudo certbot renew --dry-run

# Certbot installs a cron job automatically; verify it exists:
sudo systemctl status certbot.timer
```

---

## Database Migrations

### Initial setup (first deploy)

```bash
# Run schema (creates all tables, indexes, triggers)
docker compose exec postgres psql -U postgres -d house_planner_db -f /docker-entrypoint-initdb.d/01-schema.sql

# Run seed data (optional — skip in production if you don't want demo data)
docker compose exec postgres psql -U postgres -d house_planner_db -f /docker-entrypoint-initdb.d/02-seed.sql
```

### Applying new migrations

All schema changes after initial deployment should be in numbered migration files under `backend/migrations/`:

```bash
# Run a specific migration
docker compose exec backend node src/database/migrate.js --file 003_add_team_collaboration.sql

# Run all pending migrations
docker compose exec backend npm run migrate
```

### Rolling back

```bash
docker compose exec backend npm run migrate:rollback
```

---

## Monitoring Setup

### Application Metrics with PM2 (VPS only)

```bash
npm install -g pm2
pm2 start src/app.js --name houseplanner-api -i max
pm2 save
pm2 startup
```

### Health Check Endpoint

The backend exposes `GET /api/health` which returns:

```json
{
  "status": "ok",
  "timestamp": "2025-06-09T12:00:00.000Z",
  "uptime": 86400,
  "services": {
    "database": "healthy",
    "redis": "healthy",
    "ai_provider": "healthy"
  },
  "version": "1.0.0"
}
```

Configure your uptime monitor (e.g. UptimeRobot, Better Uptime, Datadog) to poll this endpoint every 60 seconds.

### Sentry Error Tracking

1. Create a project at [sentry.io](https://sentry.io)
2. Add your DSN to `backend/.env`:
   ```
   SENTRY_DSN=https://xxx@o123456.ingest.sentry.io/xxx
   ```

### Log Aggregation

For AWS, logs are streamed to CloudWatch automatically via the ECS task definition.

For VPS deployments, ship logs to a service like Papertrail or Logtail:

```bash
# Install log shipper
curl -s https://toolbelt.heroku.com/install-ubuntu.sh | sh
echo "*.* @logs.papertrailapp.com:XXXXX" | sudo tee /etc/rsyslog.d/99-papertrail.conf
sudo systemctl restart rsyslog
```

---

## Backup Strategy

### Database Backups

#### AWS RDS
Automated daily snapshots are enabled with 7-day retention when you set `--backup-retention-period 7` during creation.

Manual snapshot before a major release:
```bash
aws rds create-db-snapshot \
  --db-instance-identifier houseplanner-prod \
  --db-snapshot-identifier houseplanner-pre-release-$(date +%Y%m%d)
```

#### VPS / Self-managed PostgreSQL

Create `/opt/houseplanner/scripts/backup-db.sh`:

```bash
#!/bin/bash
BACKUP_DIR="/backups/postgres"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/house_planner_db_$TIMESTAMP.sql.gz"
RETENTION_DAYS=14

mkdir -p "$BACKUP_DIR"

docker compose -f /opt/houseplanner/docker-compose.yml exec -T postgres \
  pg_dump -U postgres house_planner_db | gzip > "$BACKUP_FILE"

# Upload to S3 for off-site storage
aws s3 cp "$BACKUP_FILE" s3://houseplanner-backups/postgres/

# Remove old local backups
find "$BACKUP_DIR" -name "*.sql.gz" -mtime +$RETENTION_DAYS -delete

echo "Backup completed: $BACKUP_FILE"
```

```bash
chmod +x /opt/houseplanner/scripts/backup-db.sh

# Schedule daily at 2 AM
(crontab -l 2>/dev/null; echo "0 2 * * * /opt/houseplanner/scripts/backup-db.sh >> /var/log/db-backup.log 2>&1") | crontab -
```

### Restore from Backup

```bash
# Download backup
aws s3 cp s3://houseplanner-backups/postgres/house_planner_db_20250609_020000.sql.gz /tmp/

# Restore
gunzip -c /tmp/house_planner_db_20250609_020000.sql.gz | \
  docker compose exec -T postgres psql -U postgres house_planner_db
```

---

## Rollback Procedure

### Docker Compose (VPS)

```bash
# Tag a release before deploying
docker tag houseplanner-backend:latest houseplanner-backend:v1.0.0

# If new deployment fails, roll back
docker compose stop backend
docker tag houseplanner-backend:v1.0.0 houseplanner-backend:latest
docker compose up -d backend
```

### AWS ECS

```bash
# List recent task definition revisions
aws ecs list-task-definitions --family-prefix houseplanner-backend

# Update the service to use a previous revision
aws ecs update-service \
  --cluster houseplanner-prod \
  --service houseplanner-backend \
  --task-definition houseplanner-backend:12  # previous revision number
```

### Database Rollback

If a migration needs to be undone:
```bash
docker compose exec backend npm run migrate:rollback --steps 1
```

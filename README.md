#  Full-Stack AWS Deployment — Cloud Project 2025/2026

A production-grade cloud infrastructure built from scratch on AWS, deploying a full-stack web application with a resilient, secure, and scalable architecture. No Elastic Beanstalk — every component is manually configured.

---

##  Architecture Overview

```
Internet
   │
   ▼
[EC2 Frontend] ──────────────────── Public Subnet (AZ-A)
   │
   ▼
[Application Load Balancer] ──────── Public Subnets (AZ-A + AZ-B)
   │
   ▼
[Auto Scaling Group]
  ├── [EC2 Backend Instance] ──────── Private Subnet (AZ-A)
  └── [EC2 Backend Instance] ──────── Private Subnet (AZ-B)
         │
         ▼
      [Amazon RDS] ─────────────────── Private Subnets (AZ-A + AZ-B)
```

---

## Infrastructure Components

### 1. VPC & Networking

| Resource | Configuration |
|---|---|
| VPC | CIDR: `10.0.0.0/16` |
| Public Subnet AZ-A | `10.0.1.0/24` |
| Public Subnet AZ-B | `10.0.2.0/24` |
| Private Subnet AZ-A | `10.0.3.0/24` |
| Private Subnet AZ-B | `10.0.4.0/24` |
| Internet Gateway | Attached to VPC |
| NAT Gateway | Placed in Public Subnet AZ-A |
| Route Tables | Public → IGW / Private → NAT GW |

### 2. Backend — EC2 + ALB + Auto Scaling Group

- **Application Load Balancer (ALB)** — deployed across both public subnets
- **Target Group** — health check on `GET /health` → `200 OK`
- **Launch Template** — User Data script installs and starts the backend automatically on every new instance
- **Auto Scaling Group** — min: 2 / desired: 2 / max: 4 — spread across both private subnets
- **Scaling Policy** — scale out when CPU > 70%

### 3. Frontend — EC2 (Public Subnet)

- Single EC2 instance in a public subnet serving static HTML/CSS/JS
- Web server: **nginx** (or Apache)
- All API calls go through the **ALB DNS name** — never directly to a backend EC2 IP

### 4. Database — Amazon RDS

| Setting | Value |
|---|---|
| Engine | MySQL / PostgreSQL |
| Instance type | `db.t3.micro` (Free Tier) |
| Placement | DB Subnet Group (both private subnets) |
| Public access |   Disabled |
| Credentials | Via environment variables — never hardcoded |

---

## Security Groups

| Layer | Inbound Rule |
|---|---|
| **ALB** | HTTP (port 80) from `0.0.0.0/0` |
| **EC2 Backend** | Port 80/3000/8080 from **ALB Security Group only** |
| **RDS** | Port 3306 / 5432 from **EC2 Backend Security Group only** |
| **EC2 Frontend** | HTTP (port 80) from `0.0.0.0/0` — SSH (port 22) for debug only |

>  No rule uses `0.0.0.0/0` on database or backend ports. All layers follow the principle of least privilege.

---

## 🌐 Accessing the Application

| Endpoint | URL |
|---|---|
| Frontend | `http://<frontend-ec2-public-ip>` |
| Backend API (via ALB) | `http://<alb-dns-name>` |
| Health Check | `http://<alb-dns-name>/health` |

---

## 🧪 Resilience Testing

- Terminate one backend EC2 instance → the ASG automatically replaces it
- The ALB routes traffic only to healthy instances (health check must pass)
- The application remains available throughout

---

##  Environment Variables

| Variable | Description |
|---|---|
| `DB_HOST` | RDS endpoint URL |
| `DB_PASS` | Database password |
| `DB_USER` | Database username |
| `DB_NAME` | Database name |

> Never commit credentials to the repository. Use environment variables or AWS Secrets Manager.

---

##  Checklist

- [x] VPC with 4 subnets across 2 AZs
- [x] Internet Gateway + NAT Gateway + Route Tables
- [x] ALB in public subnets with Target Group and health check
- [x] Launch Template with User Data
- [x] Auto Scaling Group (min 2 / desired 2 / max 4)
- [x] CPU-based scaling policy (> 70%)
- [x] Frontend EC2 in public subnet
- [x] RDS in private subnets via DB Subnet Group
- [x] Security Groups following least-privilege rules
- [x] No hardcoded credentials

# 🖥️ Monitor Server | Infrastructure Telemetry

A real-time monitoring system designed to track distributed Virtual Machines (VMs). This project provides a central dashboard for visualizing CPU, RAM, and Disk usage via a custom agent setup script.

---

### 🚀 Tech Stack

| Component | Technology |
| --- | --- |
| **Frontend** | Next.js 16 (App Router), Tailwind CSS, Recharts, Shadcn UI |
| **Backend** | Node.js, TypeScript, Express |
| **ORM & DB** | Prisma with PostgreSQL |
| **Reverse Proxy** | Nginx |
| **DevOps** | Docker, Docker Compose, GitHub Actions (CI/CD) |

---

### 🏗️ Architecture

The system follows a containerized microservices architecture.

* **Nginx Gateway:** Acts as the entry point (Port 80), routing `/api` traffic to the backend and all other requests to the Next.js frontend.
* **Service Discovery:** Services communicate internally via Docker’s DNS (e.g., backend connects to `db:5432`).
* **Agent Flow:** Remote VMs run a generated `setup-agent.sh` which pings the central server with authenticated telemetry data.

---

### 🛠️ Local Development

#### 1. Clone & Install

```bash
git clone https://github.com/Harsh-cyber005/monitor-server.git
cd monitor-server

```

#### 2. Environment Setup

Create a `.env` file in the `backend/` directory based on `.env.example`:

```env
DATABASE_URL="postgresql://monitor_user:monitor_password@db:5432/monitor_db?schema=public"
PORT=5000
NODE_ENV="prod"

```

#### 3. Run with Docker Compose

```bash
docker compose up -d --build

```

---

### 📦 CI/CD Pipeline

The project utilizes GitHub Actions for automated building and deployment to OCI.

#### Required GitHub Secrets:

* `DOCKERHUB_USERNAME`: Your Docker Hub handle.
* `DOCKERHUB_TOKEN`: Personal Access Token (PAT).
* `RSSH_SERVER_IP`: Public IP of your OCI Instance.
* `ORACLE_PEM`: Your SSH Private Key.
* `ENV`: Full content of the backend `.env` file.
* `SETUP_SCRIPT`: The shell script for remote VM monitoring.

---

### 🛡️ Security & Observability

* **Prisma Studio:** Accessible securely via SSH Tunnel at `http://localhost:51212`.
* **Signature Auth:** Remote agents must sign payloads using a `vmSecret` and `HMAC-SHA256`.
* **Cleanup Jobs:** A built-in cron job deletes telemetry data older than 7 days at midnight.

> **Note:** The `setup-agent.sh` is dynamically generated for each VM and injected into the backend container via a Docker bind mount.

---

### 📊 Directory Structure

```text
.github/workflows/deploy.yaml   # CI/CD Pipeline
backend/                        # Node.js API
├── prisma/                     # Database Schema
├── scripts/                    # Agent Setup Logic
└── src/                        # Express Controllers & Routes
frontend/                       # Next.js Dashboard
nginx/                          # Proxy Configurations
docker-compose.yml              # Orchestration

```

---

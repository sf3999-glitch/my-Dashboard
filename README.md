# AI House Planner

> Generate professional floor plans, construction cost estimates, and material reports powered by AI — in seconds.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Node.js](https://img.shields.io/badge/Node.js-20-green.svg)](https://nodejs.org)
[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue.svg)](https://flutter.dev)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-blue.svg)](https://postgresql.org)
[![Docker](https://img.shields.io/badge/Docker-ready-blue.svg)](https://docker.com)

---

## Overview

**AI House Planner** is a cross-platform application that transforms simple plot dimensions and preferences into detailed, architect-quality floor plans with itemized cost estimates and material lists — all powered by large language models.

Users enter their plot size, number of floors, room requirements, and style preferences; within seconds they receive:

- An SVG floor plan with labeled rooms and dimensions
- A complete cost breakdown by construction category
- A material list with quantities and current market prices
- AI optimization suggestions for better space utilization

---

## Architecture

```
                         ┌─────────────────────────────────────────┐
                         │              Clients                    │
                         │  ┌──────────┐       ┌──────────────┐   │
                         │  │  Flutter │       │    Admin     │   │
                         │  │  Mobile  │       │  Dashboard   │   │
                         │  │  & Web   │       │  (React)     │   │
                         │  └────┬─────┘       └──────┬───────┘   │
                         └───────┼─────────────────────┼───────────┘
                                 │  HTTPS / REST        │  HTTPS / REST
                         ┌───────▼─────────────────────▼───────────┐
                         │           Backend API (Node.js)          │
                         │  ┌─────────────────────────────────────┐ │
                         │  │   Express Routes & Middleware        │ │
                         │  │  (Auth · Rate Limit · Validation)    │ │
                         │  └──────────────────┬──────────────────┘ │
                         │                     │                     │
                         │  ┌──────────┐  ┌────▼────────┐  ┌──────┐│
                         │  │  AI Svc  │  │  PDF/SVG    │  │ File ││
                         │  │ (OpenAI/ │  │  Generator  │  │ Stor ││
                         │  │ Gemini)  │  └─────────────┘  └──────┘│
                         │  └──────────┘                            │
                         └───────────────┬─────────────────────────┘
                                         │
                         ┌───────────────▼─────────────────────────┐
                         │              Data Layer                  │
                         │  ┌────────────────┐  ┌───────────────┐  │
                         │  │  PostgreSQL 16  │  │   Redis 7     │  │
                         │  │  (Primary DB)   │  │  (Cache/      │  │
                         │  └────────────────┘  │   Sessions)   │  │
                         │                      └───────────────┘  │
                         └─────────────────────────────────────────┘
```

---

## Features

### Core
- **AI Floor Plan Generation** — Intelligent room layout based on plot dimensions and requirements
- **Cost Estimation** — Region-aware construction cost breakdown covering 15+ categories
- **Material Reports** — Itemized material lists with quantities and current market prices
- **AI Optimization** — Smart suggestions for improving space efficiency and cost savings
- **Multi-currency** — Real-time currency conversion for 50+ currencies
- **Multi-language** — UI available in English, Arabic, Hindi, Spanish, French, and more

### Floor Plan
- SVG export with dimensions, room labels, and compass bearing
- PDF export with full report (floor plan + cost + materials)
- Interactive room resizing and repositioning (web/desktop)
- Multiple floor support for multi-story buildings

### User Features
- Email / Google / Apple sign-in
- Project dashboard with history and status tracking
- Public sharing via unique link
- Download reports as PDF or SVG
- Dark / light theme

### Admin Dashboard
- User management (CRUD, role assignment, ban/unban)
- Project analytics (total, by status, by country)
- AI usage and cost monitoring
- Feedback management
- System settings editor

---

## Tech Stack

| Layer            | Technology                                    |
|------------------|-----------------------------------------------|
| Mobile / Web App | Flutter 3.x (iOS, Android, Web)              |
| Admin Dashboard  | React 18, TypeScript, Tailwind CSS, Vite      |
| Backend API      | Node.js 20, Express 5, TypeScript             |
| Database         | PostgreSQL 16                                 |
| Cache / Sessions | Redis 7                                       |
| AI Provider      | OpenAI GPT-4o (primary) / Gemini Pro (fallback)|
| Auth             | JWT + refresh tokens, Google OAuth 2.0        |
| PDF Generation   | Puppeteer / PDFKit                            |
| SVG Generation   | Custom SVG engine                             |
| File Storage     | Local (dev) / AWS S3 (production)             |
| Email            | SendGrid / Nodemailer                         |
| Containerization | Docker + Docker Compose                       |
| CI/CD            | GitHub Actions                                |

---

## Quick Start (Docker)

### Prerequisites
- [Docker](https://docs.docker.com/get-docker/) 24+
- [Docker Compose](https://docs.docker.com/compose/install/) 2.20+

### 1. Clone the repository

```bash
git clone https://github.com/your-org/ai-house-planner.git
cd ai-house-planner
```

### 2. Configure environment variables

```bash
cp backend/.env.example backend/.env
```

Edit `backend/.env` and set at minimum:
```
OPENAI_API_KEY=sk-...
JWT_SECRET=your_super_secret_jwt_key_32_chars_min
DB_PASSWORD=your_secure_db_password
```

### 3. Start all services

```bash
docker compose up -d
```

This will:
- Start PostgreSQL 16 and run schema + seed migrations automatically
- Build and start the backend API on port **3000**
- Build and start the admin dashboard on port **3001**
- Start Redis 7 on port **6379**

### 4. Verify everything is running

```bash
docker compose ps
curl http://localhost:3000/api/health
```

### 5. Access

| Service          | URL                           | Credentials               |
|------------------|-------------------------------|---------------------------|
| Backend API      | http://localhost:3000/api     | —                         |
| Admin Dashboard  | http://localhost:3001         | admin@houseplanner.ai / Admin@12345 |
| API Docs         | http://localhost:3000/api/docs| —                         |

---

## Manual Setup

### Prerequisites
- Node.js 20+
- PostgreSQL 16+
- Redis 7+
- Flutter SDK 3.x (for mobile/web app)

### Backend

```bash
cd backend
cp .env.example .env          # fill in your values
npm install
npm run migrate               # run schema migrations
npm run seed                  # (optional) insert sample data
npm run dev                   # start with hot-reload
```

The API will be available at `http://localhost:3000`.

### Admin Dashboard

```bash
cd admin_dashboard
npm install
npm run dev                   # start Vite dev server on :5173
```

### Flutter App

See [docs/FLUTTER_SETUP.md](docs/FLUTTER_SETUP.md) for the full Flutter setup guide including Android, iOS, and Web targets.

---

## Environment Variables

All backend configuration lives in `backend/.env`. Key variables:

```env
# Server
NODE_ENV=development
PORT=3000
FRONTEND_URL=http://localhost:5173

# Database
DB_HOST=localhost
DB_PORT=5432
DB_NAME=house_planner_db
DB_USER=postgres
DB_PASSWORD=your_password

# Redis
REDIS_URL=redis://localhost:6379

# JWT
JWT_SECRET=your_32_char_minimum_secret_key
JWT_EXPIRES_IN=7d
JWT_REFRESH_EXPIRES_IN=30d

# AI
OPENAI_API_KEY=sk-...
OPENAI_MODEL=gpt-4o
GEMINI_API_KEY=AIza...        # optional fallback

# Email
EMAIL_PROVIDER=sendgrid       # or nodemailer
SENDGRID_API_KEY=SG.xxx
EMAIL_FROM=noreply@houseplanner.ai

# Storage
STORAGE_PROVIDER=local        # local | s3
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_S3_BUCKET=houseplanner-uploads
AWS_S3_REGION=us-east-1

# OAuth
GOOGLE_CLIENT_ID=
GOOGLE_CLIENT_SECRET=

# Currency API
EXCHANGE_RATE_API_KEY=
```

---

## API Documentation

A full API reference is available at [docs/API.md](docs/API.md).

Base URL: `http://localhost:3000/api/v1`

Key endpoint groups:

| Group        | Base Path              |
|--------------|------------------------|
| Auth         | `/api/v1/auth`         |
| Users        | `/api/v1/users`        |
| Projects     | `/api/v1/projects`     |
| AI Generate  | `/api/v1/ai`           |
| Reports      | `/api/v1/reports`      |
| Admin        | `/api/v1/admin`        |

Interactive Swagger docs: `http://localhost:3000/api/docs`

---

## Deployment

For production deployment guides (AWS ECS, DigitalOcean App Platform, bare VPS), SSL setup, and monitoring configuration see [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md).

---

## Screenshots

> Screenshots will be added after the first public release.

| Flutter App (Mobile) | Admin Dashboard |
|---|---|
| _coming soon_ | _coming soon_ |

---

## Project Structure

```
ai-house-planner/
├── backend/                    # Node.js API server
│   ├── src/
│   │   ├── app.js              # Express app entry point
│   │   ├── config/             # Configuration modules
│   │   ├── controllers/        # Route handlers
│   │   ├── middleware/         # Auth, validation, rate-limit
│   │   ├── models/             # Database models
│   │   ├── routes/             # Route definitions
│   │   ├── services/           # Business logic (AI, PDF, etc.)
│   │   └── utils/              # Helpers
│   ├── Dockerfile
│   └── .env.example
│
├── admin_dashboard/            # React admin panel
│   ├── src/
│   │   ├── components/
│   │   ├── pages/
│   │   ├── hooks/
│   │   └── utils/
│   ├── Dockerfile
│   └── nginx.conf
│
├── flutter_app/                # Cross-platform Flutter app
│   ├── lib/
│   ├── android/
│   ├── ios/
│   └── web/
│
├── database/
│   ├── schema.sql              # PostgreSQL schema
│   └── seed.sql                # Sample / seed data
│
├── docs/
│   ├── API.md                  # Complete API reference
│   ├── DEPLOYMENT.md           # Production deployment guide
│   └── FLUTTER_SETUP.md        # Flutter dev setup guide
│
├── docker-compose.yml
├── .gitignore
└── README.md
```

---

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Make your changes and add tests
4. Ensure all checks pass: `npm test && npm run lint`
5. Commit with a conventional commit message: `git commit -m "feat: add room resizing"`
6. Push and open a pull request against `main`

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines on code style, commit conventions, and the review process.

---

## License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

---

## Support

- Documentation: [docs/](docs/)
- Issues: [GitHub Issues](https://github.com/your-org/ai-house-planner/issues)
- Email: support@houseplanner.ai

# AI House Planner — API Reference

**Version:** 1.0.0  
**Base URL:** `https://api.houseplanner.ai/api/v1`  
**Local:** `http://localhost:3000/api/v1`  

All requests and responses use `application/json` unless noted otherwise.

---

## Table of Contents

1. [Authentication](#authentication)
2. [Users](#users)
3. [Projects](#projects)
4. [AI Generation](#ai-generation)
5. [Reports](#reports)
6. [Admin](#admin)
7. [Currency](#currency)
8. [Pagination](#pagination)
9. [Error Codes](#error-codes)
10. [Rate Limiting](#rate-limiting)

---

## Authentication

All protected endpoints require a Bearer token in the `Authorization` header:

```
Authorization: Bearer <access_token>
```

### POST /auth/register

Register a new user with email and password.

**Request:**
```json
{
  "name": "Alice Johnson",
  "email": "alice@example.com",
  "password": "SecurePass@123",
  "language": "en",
  "currency": "USD"
}
```

**Response `201`:**
```json
{
  "success": true,
  "message": "Registration successful. Please verify your email.",
  "data": {
    "user": {
      "id": "a1b2c3d4-...",
      "name": "Alice Johnson",
      "email": "alice@example.com",
      "role": "user",
      "is_verified": false,
      "created_at": "2025-06-09T10:30:00.000Z"
    }
  }
}
```

---

### POST /auth/login

Authenticate with email and password.

**Request:**
```json
{
  "email": "alice@example.com",
  "password": "SecurePass@123"
}
```

**Response `200`:**
```json
{
  "success": true,
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "expires_in": 604800,
    "token_type": "Bearer",
    "user": {
      "id": "a1b2c3d4-...",
      "name": "Alice Johnson",
      "email": "alice@example.com",
      "role": "user",
      "avatar_url": null,
      "language": "en",
      "currency": "USD",
      "theme": "light"
    }
  }
}
```

---

### POST /auth/refresh

Exchange a refresh token for a new access token.

**Request:**
```json
{
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Response `200`:**
```json
{
  "success": true,
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "expires_in": 604800
  }
}
```

---

### POST /auth/logout

Invalidate the current session.

**Headers:** `Authorization: Bearer <token>`

**Response `200`:**
```json
{
  "success": true,
  "message": "Logged out successfully."
}
```

---

### POST /auth/forgot-password

Send a password reset email.

**Request:**
```json
{
  "email": "alice@example.com"
}
```

**Response `200`:**
```json
{
  "success": true,
  "message": "If this email exists, a reset link has been sent."
}
```

---

### POST /auth/reset-password

Reset password using a token received by email.

**Request:**
```json
{
  "token": "abc123resettoken",
  "password": "NewSecurePass@456"
}
```

**Response `200`:**
```json
{
  "success": true,
  "message": "Password reset successfully."
}
```

---

### GET /auth/verify-email/:token

Verify a user's email address.

**Response `200`:**
```json
{
  "success": true,
  "message": "Email verified successfully."
}
```

---

### POST /auth/google

Authenticate with a Google ID token (from Firebase / Google Sign-In SDK).

**Request:**
```json
{
  "id_token": "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Response `200`:** Same as `/auth/login` response.

---

## Users

### GET /users/me

Get the authenticated user's profile.

**Headers:** `Authorization: Bearer <token>`

**Response `200`:**
```json
{
  "success": true,
  "data": {
    "id": "a1b2c3d4-...",
    "name": "Alice Johnson",
    "email": "alice@example.com",
    "avatar_url": "https://cdn.houseplanner.ai/avatars/a1b2.jpg",
    "role": "premium",
    "language": "en",
    "currency": "USD",
    "theme": "light",
    "is_verified": true,
    "last_login": "2025-06-09T08:00:00.000Z",
    "created_at": "2025-01-15T12:00:00.000Z",
    "stats": {
      "total_projects": 5,
      "completed_projects": 3,
      "total_reports": 8
    }
  }
}
```

---

### PATCH /users/me

Update the authenticated user's profile.

**Request:**
```json
{
  "name": "Alice M. Johnson",
  "language": "en",
  "currency": "GBP",
  "theme": "dark"
}
```

**Response `200`:**
```json
{
  "success": true,
  "data": {
    "id": "a1b2c3d4-...",
    "name": "Alice M. Johnson",
    "language": "en",
    "currency": "GBP",
    "theme": "dark",
    "updated_at": "2025-06-09T10:45:00.000Z"
  }
}
```

---

### POST /users/me/avatar

Upload a profile avatar. `Content-Type: multipart/form-data`

**Form fields:**
- `avatar` (file) — JPEG, PNG, or WebP, max 5 MB

**Response `200`:**
```json
{
  "success": true,
  "data": {
    "avatar_url": "https://cdn.houseplanner.ai/avatars/a1b2.jpg"
  }
}
```

---

### PATCH /users/me/password

Change password for email-authenticated users.

**Request:**
```json
{
  "current_password": "OldPass@123",
  "new_password": "NewSecurePass@456"
}
```

**Response `200`:**
```json
{
  "success": true,
  "message": "Password updated successfully."
}
```

---

### DELETE /users/me

Permanently delete the authenticated user's account and all associated data.

**Request:**
```json
{
  "password": "CurrentPass@123",
  "confirm": "DELETE"
}
```

**Response `200`:**
```json
{
  "success": true,
  "message": "Account deleted. We're sorry to see you go."
}
```

---

## Projects

### GET /projects

List all projects for the authenticated user.

**Query Parameters:**

| Param     | Type    | Default | Description                          |
|-----------|---------|---------|--------------------------------------|
| `page`    | integer | 1       | Page number                          |
| `limit`   | integer | 10      | Items per page (max 50)              |
| `status`  | string  | —       | Filter: `draft`, `completed`, `shared`|
| `sort`    | string  | `created_at` | Sort field                    |
| `order`   | string  | `desc`  | `asc` or `desc`                      |
| `search`  | string  | —       | Search by project name               |

**Response `200`:**
```json
{
  "success": true,
  "data": [
    {
      "id": "b1c2d3e4-...",
      "name": "Sunset Villa - Austin",
      "status": "completed",
      "country": "United States",
      "city": "Austin, TX",
      "plot_length": 60,
      "plot_width": 80,
      "unit": "feet",
      "floors": 1,
      "bedrooms": 3,
      "bathrooms": 2,
      "house_style": "modern",
      "total_area": 4800,
      "thumbnail_url": "https://cdn.houseplanner.ai/thumbnails/b1c2.jpg",
      "is_public": true,
      "estimated_cost": 385000,
      "currency": "USD",
      "report_count": 4,
      "created_at": "2025-01-20T09:00:00.000Z",
      "updated_at": "2025-01-22T14:30:00.000Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 10,
    "total": 5,
    "pages": 1
  }
}
```

---

### POST /projects

Create a new project.

**Request:**
```json
{
  "name": "My Dream Home",
  "description": "A modern 3-bedroom house in the suburbs",
  "country": "United States",
  "city": "Austin, TX",
  "plot_length": 60,
  "plot_width": 80,
  "unit": "feet",
  "floors": 1,
  "bedrooms": 3,
  "bathrooms": 2,
  "has_kitchen": true,
  "has_living_room": true,
  "has_dining_room": true,
  "has_garage": true,
  "has_garden": false,
  "has_balcony": false,
  "house_style": "modern",
  "construction_quality": "standard",
  "currency": "USD"
}
```

**Response `201`:**
```json
{
  "success": true,
  "data": {
    "id": "b1c2d3e4-...",
    "name": "My Dream Home",
    "status": "draft",
    "created_at": "2025-06-09T10:00:00.000Z"
  }
}
```

---

### GET /projects/:id

Get full details of a single project.

**Response `200`:**
```json
{
  "success": true,
  "data": {
    "id": "b1c2d3e4-...",
    "name": "Sunset Villa - Austin",
    "description": "Modern single-story villa...",
    "status": "completed",
    "country": "United States",
    "city": "Austin, TX",
    "plot_length": 60,
    "plot_width": 80,
    "unit": "feet",
    "floors": 1,
    "bedrooms": 3,
    "bathrooms": 2,
    "has_kitchen": true,
    "has_living_room": true,
    "has_dining_room": true,
    "has_garage": true,
    "has_garden": true,
    "has_balcony": false,
    "house_style": "modern",
    "construction_quality": "premium",
    "currency": "USD",
    "total_area": 4800,
    "covered_area": 2800,
    "floor_plan_svg": "<svg ...>...</svg>",
    "floor_plan_data": { "rooms": [...] },
    "cost_estimate": {
      "total": 385000,
      "breakdown": { "foundation": 32000, "framing": 58000, "..." : 0 }
    },
    "material_report": { "materials": [...] },
    "optimization_suggestions": { "suggestions": [...], "efficiency_score": 87 },
    "is_public": true,
    "share_token": "share-austin-villa-2024",
    "thumbnail_url": "https://cdn.houseplanner.ai/thumbnails/b1c2.jpg",
    "pdf_url": "https://cdn.houseplanner.ai/reports/b1c2.pdf",
    "created_at": "2025-01-20T09:00:00.000Z",
    "updated_at": "2025-01-22T14:30:00.000Z"
  }
}
```

---

### PATCH /projects/:id

Update project details (metadata only; does not re-generate AI content).

**Request:** Any subset of project fields.

**Response `200`:** Updated project object.

---

### DELETE /projects/:id

Delete a project and all associated reports.

**Response `200`:**
```json
{
  "success": true,
  "message": "Project deleted successfully."
}
```

---

### POST /projects/:id/share

Generate a public share link for a project.

**Response `200`:**
```json
{
  "success": true,
  "data": {
    "share_url": "https://houseplanner.ai/shared/share-austin-villa-2024",
    "share_token": "share-austin-villa-2024",
    "is_public": true
  }
}
```

---

### DELETE /projects/:id/share

Revoke the public share link.

**Response `200`:**
```json
{
  "success": true,
  "message": "Share link revoked."
}
```

---

### GET /projects/shared/:token

View a publicly shared project (no authentication required).

**Response `200`:** Public project object (no user-sensitive fields).

---

## AI Generation

### POST /ai/generate

Generate a complete floor plan with cost estimate and material report for a project.

> This is the core AI endpoint. Depending on plot size and complexity it may take 8–15 seconds.

**Headers:** `Authorization: Bearer <token>`

**Request:**
```json
{
  "project_id": "b1c2d3e4-..."
}
```

**Response `200`:**
```json
{
  "success": true,
  "data": {
    "project_id": "b1c2d3e4-...",
    "floor_plan_svg": "<svg xmlns='http://www.w3.org/2000/svg' ...>...</svg>",
    "floor_plan_data": {
      "rooms": [
        {
          "name": "Master Bedroom",
          "x": 20, "y": 20,
          "width": 14, "height": 16,
          "area": 224,
          "type": "bedroom"
        }
      ],
      "walls": [...],
      "doors": [...],
      "windows": [...]
    },
    "cost_estimate": {
      "currency": "USD",
      "total": 285000,
      "breakdown": {
        "foundation": 24000,
        "framing": 45000,
        "exterior": 32000,
        "roofing": 22000,
        "plumbing": 18000,
        "electrical": 14000,
        "hvac": 19000,
        "insulation": 9000,
        "drywall": 12000,
        "flooring": 25000,
        "interior_finishes": 38000,
        "kitchen_bath": 42000,
        "landscaping": 14000
      }
    },
    "material_report": {
      "materials": [
        {
          "name": "Concrete (Foundation)",
          "quantity": "185 cubic yards",
          "unit": "cubic yard",
          "unit_cost": 125,
          "total": 23125,
          "currency": "USD"
        }
      ]
    },
    "optimization_suggestions": {
      "efficiency_score": 84,
      "suggestions": [
        "Rotate the living room 90° to capture south-facing light",
        "Combine master bath and en suite to save 40 sq ft",
        "Open kitchen-dining wall to improve traffic flow"
      ]
    },
    "ai_analysis": {
      "model": "gpt-4o",
      "tokens_used": 5200,
      "generation_time_ms": 9340
    }
  }
}
```

---

### POST /ai/regenerate

Re-generate AI content for an existing project (overwrites previous results).

**Request:**
```json
{
  "project_id": "b1c2d3e4-...",
  "components": ["floor_plan", "cost_estimate", "material_report"]
}
```

**Response `200`:** Same as `/ai/generate`.

---

### POST /ai/optimize

Request additional optimization suggestions for an existing project without regenerating the floor plan.

**Request:**
```json
{
  "project_id": "b1c2d3e4-...",
  "focus": "cost"
}
```

`focus` options: `cost`, `space`, `natural_light`, `privacy`, `energy`

**Response `200`:**
```json
{
  "success": true,
  "data": {
    "suggestions": [
      "Use engineered lumber for floor joists — saves $3,200 vs solid lumber",
      "Combine pantry and utility room — frees 12 sq ft for larger kitchen",
      "Install tankless water heater to reduce utility bills by ~$380/year"
    ],
    "estimated_savings": 8500,
    "efficiency_score": 91
  }
}
```

---

## Reports

### GET /reports

List all reports for the authenticated user.

**Query Parameters:** `page`, `limit`, `project_id`, `type`

**Response `200`:**
```json
{
  "success": true,
  "data": [
    {
      "id": "c1d2e3f4-...",
      "project_id": "b1c2d3e4-...",
      "project_name": "Sunset Villa - Austin",
      "type": "full",
      "file_name": "sunset-villa-full-report.pdf",
      "file_size": 2457600,
      "format": "pdf",
      "pages": 12,
      "file_url": "https://cdn.houseplanner.ai/reports/c1d2.pdf",
      "created_at": "2025-01-22T14:30:00.000Z"
    }
  ],
  "pagination": { "page": 1, "limit": 10, "total": 4, "pages": 1 }
}
```

---

### POST /reports/generate

Generate and save a new report PDF or SVG for a project.

**Request:**
```json
{
  "project_id": "b1c2d3e4-...",
  "type": "full",
  "format": "pdf",
  "options": {
    "include_cover": true,
    "include_floor_plan": true,
    "include_cost_estimate": true,
    "include_material_list": true,
    "include_suggestions": true,
    "watermark": false
  }
}
```

`type` options: `floor_plan`, `cost`, `material`, `full`  
`format` options: `pdf`, `svg`, `json`

**Response `201`:**
```json
{
  "success": true,
  "data": {
    "id": "c1d2e3f4-...",
    "file_url": "https://cdn.houseplanner.ai/reports/c1d2.pdf",
    "file_name": "sunset-villa-full-report.pdf",
    "file_size": 2457600,
    "pages": 12,
    "format": "pdf",
    "created_at": "2025-06-09T11:00:00.000Z"
  }
}
```

---

### GET /reports/:id/download

Get a pre-signed download URL for a report file.

**Response `200`:**
```json
{
  "success": true,
  "data": {
    "download_url": "https://cdn.houseplanner.ai/reports/c1d2.pdf?token=...",
    "expires_at": "2025-06-09T12:00:00.000Z"
  }
}
```

---

### DELETE /reports/:id

Delete a report.

**Response `200`:**
```json
{
  "success": true,
  "message": "Report deleted."
}
```

---

## Admin

> All admin endpoints require `role: admin`.

### GET /admin/stats

Get platform-wide analytics.

**Response `200`:**
```json
{
  "success": true,
  "data": {
    "users": {
      "total": 1247,
      "active": 1180,
      "new_this_month": 86,
      "by_role": { "user": 1100, "premium": 140, "admin": 7 }
    },
    "projects": {
      "total": 3840,
      "by_status": { "draft": 1200, "completed": 2400, "shared": 240 },
      "by_country": [
        { "country": "United States", "count": 980 },
        { "country": "India", "count": 620 }
      ]
    },
    "ai_usage": {
      "requests_today": 340,
      "requests_this_month": 8200,
      "cost_this_month_usd": 492.80
    },
    "reports_generated": 12640
  }
}
```

---

### GET /admin/users

List all users with pagination and filtering.

**Query Parameters:** `page`, `limit`, `role`, `is_active`, `search`, `sort`, `order`

---

### PATCH /admin/users/:id

Update a user's role or status.

**Request:**
```json
{
  "role": "premium",
  "is_active": true
}
```

---

### DELETE /admin/users/:id

Hard-delete a user account and all data.

---

### GET /admin/projects

List all projects across all users.

**Query Parameters:** `page`, `limit`, `user_id`, `status`, `country`

---

### GET /admin/settings

Get all system settings.

---

### PATCH /admin/settings

Update system settings.

**Request:**
```json
{
  "maintenance_mode": "false",
  "max_projects_free": "5",
  "ai_model": "gpt-4o"
}
```

---

## Currency

### GET /currency/rates

Get current exchange rates (cached, refreshed every 24 hours).

**Query Parameters:** `base` (default: `USD`)

**Response `200`:**
```json
{
  "success": true,
  "data": {
    "base": "USD",
    "rates": {
      "EUR": 0.921,
      "GBP": 0.789,
      "INR": 83.45,
      "AED": 3.673
    },
    "cached_at": "2025-06-09T00:00:00.000Z",
    "expires_at": "2025-06-10T00:00:00.000Z"
  }
}
```

---

## Pagination

All list endpoints return consistent pagination metadata:

```json
{
  "pagination": {
    "page": 2,
    "limit": 10,
    "total": 47,
    "pages": 5
  }
}
```

Use `?page=2&limit=20` query parameters to paginate.

---

## Error Codes

All errors follow this structure:

```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "plot_length must be a positive number",
    "field": "plot_length",
    "status": 400
  }
}
```

| HTTP Status | Code                      | Description                               |
|-------------|---------------------------|-------------------------------------------|
| 400         | `VALIDATION_ERROR`        | Request body failed validation            |
| 401         | `UNAUTHORIZED`            | Missing or invalid access token           |
| 401         | `TOKEN_EXPIRED`           | Access token has expired                  |
| 403         | `FORBIDDEN`               | Insufficient permissions                  |
| 404         | `NOT_FOUND`               | Resource does not exist                   |
| 409         | `CONFLICT`                | Resource already exists (e.g. email)      |
| 422         | `UNPROCESSABLE_ENTITY`    | Semantically invalid request              |
| 429         | `RATE_LIMIT_EXCEEDED`     | Too many requests                         |
| 500         | `INTERNAL_ERROR`          | Unexpected server error                   |
| 503         | `AI_UNAVAILABLE`          | AI provider is temporarily unavailable    |

---

## Rate Limiting

Rate limits are applied per authenticated user (or IP for unauthenticated routes).

| Tier         | General Endpoints | AI Generation Endpoints |
|--------------|-------------------|-------------------------|
| Free         | 100 req/min       | 10 req/day              |
| Pro          | 500 req/min       | 200 req/day             |
| Enterprise   | Unlimited         | Unlimited               |
| Unauthenticated | 20 req/min     | N/A                     |

Rate limit headers are included on every response:

```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 94
X-RateLimit-Reset: 1717929600
Retry-After: 60          (only on 429 responses)
```

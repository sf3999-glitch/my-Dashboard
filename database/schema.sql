-- =============================================================================
-- AI House Planner - PostgreSQL Database Schema
-- Version: 1.0.0
-- =============================================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =============================================================================
-- USERS TABLE
-- =============================================================================
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255),
    name VARCHAR(255) NOT NULL,
    avatar_url TEXT,
    provider VARCHAR(50) DEFAULT 'email',        -- email, google, apple
    provider_id VARCHAR(255),
    role VARCHAR(50) DEFAULT 'user',              -- user, admin, premium
    language VARCHAR(10) DEFAULT 'en',
    currency VARCHAR(10) DEFAULT 'USD',
    theme VARCHAR(20) DEFAULT 'light',            -- light, dark, system
    is_verified BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    verification_token VARCHAR(255),
    reset_password_token VARCHAR(255),
    reset_password_expires TIMESTAMP,
    last_login TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =============================================================================
-- PROJECTS TABLE
-- =============================================================================
CREATE TABLE projects (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    status VARCHAR(50) DEFAULT 'draft',           -- draft, completed, shared, archived

    -- Location
    country VARCHAR(100) NOT NULL,
    city VARCHAR(100),
    region VARCHAR(100),

    -- Plot dimensions
    plot_length DECIMAL(10,2) NOT NULL,
    plot_width DECIMAL(10,2) NOT NULL,
    unit VARCHAR(10) DEFAULT 'feet',              -- feet, meter
    total_area DECIMAL(10,2),
    covered_area DECIMAL(10,2),

    -- House configuration
    floors INTEGER DEFAULT 1,
    bedrooms INTEGER DEFAULT 2,
    bathrooms INTEGER DEFAULT 1,
    has_kitchen BOOLEAN DEFAULT TRUE,
    has_living_room BOOLEAN DEFAULT TRUE,
    has_dining_room BOOLEAN DEFAULT FALSE,
    has_garage BOOLEAN DEFAULT FALSE,
    has_garden BOOLEAN DEFAULT FALSE,
    has_balcony BOOLEAN DEFAULT FALSE,
    has_basement BOOLEAN DEFAULT FALSE,
    has_attic BOOLEAN DEFAULT FALSE,
    has_study_room BOOLEAN DEFAULT FALSE,
    has_laundry_room BOOLEAN DEFAULT FALSE,
    has_storage_room BOOLEAN DEFAULT FALSE,
    has_servant_quarter BOOLEAN DEFAULT FALSE,
    has_prayer_room BOOLEAN DEFAULT FALSE,

    -- House characteristics
    house_style VARCHAR(100),                     -- modern, contemporary, traditional, colonial, mediterranean, minimalist
    construction_quality VARCHAR(50) DEFAULT 'standard', -- basic, standard, premium, luxury

    -- Financial
    currency VARCHAR(10) DEFAULT 'USD',
    budget_min DECIMAL(15,2),
    budget_max DECIMAL(15,2),

    -- Generated data (stored as JSONB for flexibility)
    floor_plan_svg TEXT,
    floor_plan_data JSONB,
    cost_estimate JSONB,
    material_report JSONB,
    optimization_suggestions JSONB,
    ai_analysis JSONB,
    room_dimensions JSONB,
    structural_data JSONB,

    -- Sharing
    share_token VARCHAR(255) UNIQUE,
    is_public BOOLEAN DEFAULT FALSE,

    -- Assets
    thumbnail_url TEXT,
    pdf_url TEXT,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =============================================================================
-- REPORTS TABLE
-- =============================================================================
CREATE TABLE reports (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID REFERENCES projects(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL,                    -- floor_plan, cost, material, full, structural
    file_url TEXT,
    file_name VARCHAR(255),
    file_size INTEGER,                            -- bytes
    format VARCHAR(20) DEFAULT 'pdf',             -- pdf, svg, json, xlsx
    pages INTEGER DEFAULT 1,
    metadata JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =============================================================================
-- ACTIVITY LOGS TABLE
-- =============================================================================
CREATE TABLE activity_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    action VARCHAR(100) NOT NULL,                 -- login, logout, create_project, generate_plan, download_report, etc.
    resource_type VARCHAR(50),                    -- user, project, report
    resource_id UUID,
    details JSONB,
    ip_address INET,
    user_agent TEXT,
    status VARCHAR(20) DEFAULT 'success',         -- success, failure, error
    duration_ms INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =============================================================================
-- CURRENCY CACHE TABLE
-- =============================================================================
CREATE TABLE currency_cache (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    base_currency VARCHAR(10) NOT NULL,
    rates JSONB NOT NULL,
    source VARCHAR(50) DEFAULT 'exchangerate-api',
    cached_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP,
    UNIQUE(base_currency)
);

-- =============================================================================
-- SYSTEM SETTINGS TABLE
-- =============================================================================
CREATE TABLE system_settings (
    key VARCHAR(100) PRIMARY KEY,
    value TEXT,
    type VARCHAR(20) DEFAULT 'string',            -- string, number, boolean, json
    category VARCHAR(50),                         -- general, ai, email, storage, limits
    description TEXT,
    is_public BOOLEAN DEFAULT FALSE,
    updated_by UUID REFERENCES users(id) ON DELETE SET NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =============================================================================
-- SUBSCRIPTION PLANS TABLE
-- =============================================================================
CREATE TABLE subscription_plans (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,                   -- free, basic, pro, enterprise
    display_name VARCHAR(100) NOT NULL,
    description TEXT,
    price_monthly DECIMAL(10,2) DEFAULT 0,
    price_yearly DECIMAL(10,2) DEFAULT 0,
    currency VARCHAR(10) DEFAULT 'USD',
    features JSONB,
    limits JSONB,                                 -- { projects: 3, reports: 10, ai_requests: 50 }
    is_active BOOLEAN DEFAULT TRUE,
    stripe_price_id_monthly VARCHAR(255),
    stripe_price_id_yearly VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =============================================================================
-- USER SUBSCRIPTIONS TABLE
-- =============================================================================
CREATE TABLE user_subscriptions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    plan_id UUID REFERENCES subscription_plans(id),
    status VARCHAR(50) DEFAULT 'active',          -- active, cancelled, expired, trialing, past_due
    billing_cycle VARCHAR(20) DEFAULT 'monthly',  -- monthly, yearly
    stripe_subscription_id VARCHAR(255),
    stripe_customer_id VARCHAR(255),
    current_period_start TIMESTAMP,
    current_period_end TIMESTAMP,
    cancelled_at TIMESTAMP,
    trial_ends_at TIMESTAMP,
    metadata JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =============================================================================
-- AI REQUESTS TABLE (for tracking AI usage and costs)
-- =============================================================================
CREATE TABLE ai_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    project_id UUID REFERENCES projects(id) ON DELETE SET NULL,
    model VARCHAR(100),                           -- gpt-4, claude-3, gemini-pro, etc.
    request_type VARCHAR(50),                     -- floor_plan, cost_estimate, material_list, optimization
    input_tokens INTEGER DEFAULT 0,
    output_tokens INTEGER DEFAULT 0,
    cost_usd DECIMAL(10,6) DEFAULT 0,
    duration_ms INTEGER,
    status VARCHAR(20) DEFAULT 'success',         -- success, failure, timeout
    error_message TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =============================================================================
-- FEEDBACK TABLE
-- =============================================================================
CREATE TABLE feedback (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    project_id UUID REFERENCES projects(id) ON DELETE SET NULL,
    type VARCHAR(50) NOT NULL,                    -- bug, feature_request, general, rating
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    subject VARCHAR(255),
    message TEXT NOT NULL,
    attachments JSONB,
    status VARCHAR(50) DEFAULT 'open',            -- open, in_progress, resolved, closed
    admin_response TEXT,
    responded_at TIMESTAMP,
    responded_by UUID REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =============================================================================
-- INDEXES
-- =============================================================================

-- Users
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_provider ON users(provider);
CREATE INDEX idx_users_is_active ON users(is_active);
CREATE INDEX idx_users_created_at ON users(created_at DESC);

-- Projects
CREATE INDEX idx_projects_user_id ON projects(user_id);
CREATE INDEX idx_projects_status ON projects(status);
CREATE INDEX idx_projects_country ON projects(country);
CREATE INDEX idx_projects_created_at ON projects(created_at DESC);
CREATE INDEX idx_projects_share_token ON projects(share_token) WHERE share_token IS NOT NULL;
CREATE INDEX idx_projects_is_public ON projects(is_public) WHERE is_public = TRUE;
CREATE INDEX idx_projects_house_style ON projects(house_style);

-- Reports
CREATE INDEX idx_reports_project_id ON reports(project_id);
CREATE INDEX idx_reports_user_id ON reports(user_id);
CREATE INDEX idx_reports_type ON reports(type);
CREATE INDEX idx_reports_created_at ON reports(created_at DESC);

-- Activity logs
CREATE INDEX idx_activity_logs_user_id ON activity_logs(user_id);
CREATE INDEX idx_activity_logs_action ON activity_logs(action);
CREATE INDEX idx_activity_logs_resource ON activity_logs(resource_type, resource_id);
CREATE INDEX idx_activity_logs_created_at ON activity_logs(created_at DESC);

-- AI requests
CREATE INDEX idx_ai_requests_user_id ON ai_requests(user_id);
CREATE INDEX idx_ai_requests_project_id ON ai_requests(project_id);
CREATE INDEX idx_ai_requests_created_at ON ai_requests(created_at DESC);

-- Subscriptions
CREATE INDEX idx_user_subscriptions_user_id ON user_subscriptions(user_id);
CREATE INDEX idx_user_subscriptions_status ON user_subscriptions(status);
CREATE INDEX idx_user_subscriptions_stripe_id ON user_subscriptions(stripe_subscription_id);

-- Feedback
CREATE INDEX idx_feedback_user_id ON feedback(user_id);
CREATE INDEX idx_feedback_status ON feedback(status);
CREATE INDEX idx_feedback_type ON feedback(type);

-- =============================================================================
-- UPDATED_AT TRIGGER FUNCTION
-- =============================================================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

-- Apply trigger to all tables with updated_at
CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_projects_updated_at
    BEFORE UPDATE ON projects
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_subscription_plans_updated_at
    BEFORE UPDATE ON subscription_plans
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_subscriptions_updated_at
    BEFORE UPDATE ON user_subscriptions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_feedback_updated_at
    BEFORE UPDATE ON feedback
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_system_settings_updated_at
    BEFORE UPDATE ON system_settings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =============================================================================
-- VIEWS
-- =============================================================================

-- Project summary view (joins key data)
CREATE OR REPLACE VIEW project_summary AS
SELECT
    p.id,
    p.user_id,
    u.name AS user_name,
    u.email AS user_email,
    p.name,
    p.status,
    p.country,
    p.city,
    p.plot_length,
    p.plot_width,
    p.unit,
    p.total_area,
    p.floors,
    p.bedrooms,
    p.bathrooms,
    p.house_style,
    p.construction_quality,
    p.currency,
    p.is_public,
    p.thumbnail_url,
    p.created_at,
    p.updated_at,
    (SELECT COUNT(*) FROM reports r WHERE r.project_id = p.id) AS report_count,
    CASE
        WHEN p.cost_estimate IS NOT NULL THEN (p.cost_estimate->>'total')::DECIMAL
        ELSE NULL
    END AS estimated_cost
FROM projects p
JOIN users u ON u.id = p.user_id;

-- User stats view
CREATE OR REPLACE VIEW user_stats AS
SELECT
    u.id,
    u.name,
    u.email,
    u.role,
    u.is_active,
    u.created_at,
    u.last_login,
    COUNT(DISTINCT p.id) AS total_projects,
    COUNT(DISTINCT p.id) FILTER (WHERE p.status = 'completed') AS completed_projects,
    COUNT(DISTINCT r.id) AS total_reports,
    COUNT(DISTINCT ar.id) AS total_ai_requests,
    COALESCE(SUM(ar.cost_usd), 0) AS total_ai_cost
FROM users u
LEFT JOIN projects p ON p.user_id = u.id
LEFT JOIN reports r ON r.user_id = u.id
LEFT JOIN ai_requests ar ON ar.user_id = u.id
GROUP BY u.id, u.name, u.email, u.role, u.is_active, u.created_at, u.last_login;

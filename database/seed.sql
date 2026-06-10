-- =============================================================================
-- AI House Planner - Seed Data
-- Version: 1.0.0
-- Description: Initial seed data for development and testing
-- =============================================================================

-- =============================================================================
-- SYSTEM SETTINGS
-- =============================================================================
INSERT INTO system_settings (key, value, type, category, description, is_public) VALUES
('app_name',              'AI House Planner',               'string',  'general', 'Application display name',                     TRUE),
('app_version',           '1.0.0',                          'string',  'general', 'Current application version',                  TRUE),
('app_url',               'https://houseplanner.ai',        'string',  'general', 'Frontend application URL',                     TRUE),
('support_email',         'support@houseplanner.ai',        'string',  'general', 'Support contact email',                        TRUE),
('maintenance_mode',      'false',                          'boolean', 'general', 'Enable maintenance mode',                      TRUE),
('max_projects_free',     '3',                              'number',  'limits',  'Max projects for free tier users',             FALSE),
('max_projects_premium',  '50',                             'number',  'limits',  'Max projects for premium users',               FALSE),
('max_file_size_mb',      '10',                             'number',  'limits',  'Max upload file size in MB',                   FALSE),
('ai_provider',           'openai',                         'string',  'ai',      'Primary AI provider (openai/anthropic/gemini)', FALSE),
('ai_model',              'gpt-4o',                         'string',  'ai',      'AI model to use for floor plan generation',    FALSE),
('ai_temperature',        '0.7',                            'number',  'ai',      'AI model temperature (0.0 - 1.0)',             FALSE),
('ai_max_tokens',         '4096',                           'number',  'ai',      'Maximum tokens per AI request',               FALSE),
('email_provider',        'sendgrid',                       'string',  'email',   'Email service provider',                      FALSE),
('email_from_name',       'AI House Planner',               'string',  'email',   'From name for outgoing emails',               FALSE),
('email_from_address',    'noreply@houseplanner.ai',        'string',  'email',   'From address for outgoing emails',            FALSE),
('storage_provider',      'local',                          'string',  'storage', 'File storage provider (local/s3/gcs)',         FALSE),
('s3_bucket',             'houseplanner-uploads',           'string',  'storage', 'AWS S3 bucket name',                          FALSE),
('currency_api_provider', 'exchangerate-api',               'string',  'general', 'Currency conversion API provider',            FALSE),
('currency_cache_hours',  '24',                             'number',  'general', 'Hours to cache currency rates',               FALSE),
('registration_enabled',  'true',                           'boolean', 'general', 'Allow new user registrations',                TRUE),
('google_auth_enabled',   'true',                           'boolean', 'general', 'Enable Google OAuth login',                   TRUE),
('apple_auth_enabled',    'false',                          'boolean', 'general', 'Enable Apple OAuth login',                    TRUE);

-- =============================================================================
-- SUBSCRIPTION PLANS
-- =============================================================================
INSERT INTO subscription_plans (id, name, display_name, description, price_monthly, price_yearly, currency, features, limits, is_active) VALUES
(
    uuid_generate_v4(),
    'free',
    'Free',
    'Perfect for trying out AI House Planner',
    0.00,
    0.00,
    'USD',
    '{"floor_plan_generation": true, "cost_estimate": true, "pdf_export": false, "svg_export": false, "share_project": false, "advanced_ai": false, "priority_support": false}',
    '{"projects": 3, "reports": 5, "ai_requests": 10, "storage_mb": 50}',
    TRUE
),
(
    uuid_generate_v4(),
    'pro',
    'Pro',
    'For homeowners and real estate professionals',
    9.99,
    99.00,
    'USD',
    '{"floor_plan_generation": true, "cost_estimate": true, "pdf_export": true, "svg_export": true, "share_project": true, "advanced_ai": true, "priority_support": false}',
    '{"projects": 25, "reports": 100, "ai_requests": 200, "storage_mb": 2048}',
    TRUE
),
(
    uuid_generate_v4(),
    'enterprise',
    'Enterprise',
    'For architectural firms and large teams',
    49.99,
    499.00,
    'USD',
    '{"floor_plan_generation": true, "cost_estimate": true, "pdf_export": true, "svg_export": true, "share_project": true, "advanced_ai": true, "priority_support": true, "team_collaboration": true, "api_access": true, "white_label": true}',
    '{"projects": -1, "reports": -1, "ai_requests": -1, "storage_mb": -1}',
    TRUE
);

-- =============================================================================
-- USERS
-- =============================================================================

-- Admin user (password: Admin@12345)
INSERT INTO users (id, email, password_hash, name, role, is_verified, is_active, language, currency, theme) VALUES
(
    'a0000000-0000-0000-0000-000000000001',
    'admin@houseplanner.ai',
    '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj4J.9RKxXGu',  -- Admin@12345
    'System Administrator',
    'admin',
    TRUE,
    TRUE,
    'en',
    'USD',
    'dark'
);

-- Sample regular users (password: Password@123 for all)
INSERT INTO users (id, email, password_hash, name, role, is_verified, is_active, language, currency, theme, last_login) VALUES
(
    'a0000000-0000-0000-0000-000000000002',
    'alice.johnson@example.com',
    '$2b$12$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LkDYJo5LB2i',  -- Password@123
    'Alice Johnson',
    'premium',
    TRUE,
    TRUE,
    'en',
    'USD',
    'light',
    NOW() - INTERVAL '2 hours'
),
(
    'a0000000-0000-0000-0000-000000000003',
    'carlos.mendez@example.com',
    '$2b$12$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LkDYJo5LB2i',
    'Carlos Mendez',
    'user',
    TRUE,
    TRUE,
    'es',
    'EUR',
    'light',
    NOW() - INTERVAL '1 day'
),
(
    'a0000000-0000-0000-0000-000000000004',
    'priya.sharma@example.com',
    '$2b$12$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LkDYJo5LB2i',
    'Priya Sharma',
    'premium',
    TRUE,
    TRUE,
    'en',
    'INR',
    'light',
    NOW() - INTERVAL '3 hours'
),
(
    'a0000000-0000-0000-0000-000000000005',
    'john.smith@example.com',
    '$2b$12$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LkDYJo5LB2i',
    'John Smith',
    'user',
    FALSE,
    TRUE,
    'en',
    'GBP',
    'dark',
    NOW() - INTERVAL '5 days'
),
(
    'a0000000-0000-0000-0000-000000000006',
    'fatima.al-rashid@example.com',
    '$2b$12$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LkDYJo5LB2i',
    'Fatima Al-Rashid',
    'user',
    TRUE,
    TRUE,
    'ar',
    'AED',
    'light',
    NOW() - INTERVAL '12 hours'
);

-- =============================================================================
-- PROJECTS
-- =============================================================================

-- Project 1: Modern Villa - USA
INSERT INTO projects (
    id, user_id, name, description, status, country, city,
    plot_length, plot_width, unit, floors, bedrooms, bathrooms,
    has_kitchen, has_living_room, has_dining_room, has_garage, has_garden, has_balcony,
    house_style, construction_quality, currency, total_area, covered_area,
    floor_plan_data, cost_estimate, material_report, ai_analysis,
    share_token, is_public
) VALUES (
    'b0000000-0000-0000-0000-000000000001',
    'a0000000-0000-0000-0000-000000000002',
    'Sunset Villa - Austin',
    'Modern single-story villa with open floor plan and large garden for family living.',
    'completed',
    'United States', 'Austin, TX',
    60.00, 80.00, 'feet',
    1, 3, 2,
    TRUE, TRUE, TRUE, TRUE, TRUE, FALSE,
    'modern', 'premium', 'USD',
    4800.00, 2800.00,
    '{"rooms": [{"name": "Master Bedroom", "width": 14, "length": 16, "area": 224}, {"name": "Bedroom 2", "width": 12, "length": 14, "area": 168}, {"name": "Bedroom 3", "width": 11, "length": 12, "area": 132}, {"name": "Living Room", "width": 20, "length": 22, "area": 440}, {"name": "Kitchen", "width": 14, "length": 16, "area": 224}, {"name": "Dining Room", "width": 12, "length": 14, "area": 168}, {"name": "Master Bath", "width": 10, "length": 12, "area": 120}, {"name": "Bath 2", "width": 8, "length": 10, "area": 80}, {"name": "Garage", "width": 22, "length": 24, "area": 528}]}',
    '{"total": 385000, "breakdown": {"foundation": 32000, "framing": 58000, "exterior": 45000, "roofing": 28000, "plumbing": 22000, "electrical": 18000, "hvac": 25000, "insulation": 12000, "drywall": 15000, "flooring": 32000, "interior_finishes": 48000, "kitchen_bath": 52000, "landscaping": 18000}}',
    '{"materials": [{"name": "Concrete (Foundation)", "quantity": "250 cubic yards", "unit_cost": 125, "total": 31250}, {"name": "Lumber (Framing)", "quantity": "18000 board feet", "unit_cost": 3.20, "total": 57600}, {"name": "Brick Veneer", "quantity": "4500 sq ft", "unit_cost": 9.50, "total": 42750}, {"name": "Asphalt Shingles", "quantity": "2950 sq ft", "unit_cost": 4.80, "total": 14160}]}',
    '{"style_notes": "Open-concept layout maximizes natural light. Kitchen island connects to dining area.", "efficiency_score": 87, "suggestions": ["Add skylights to increase natural lighting", "Consider radiant floor heating in master bath", "Solar panels would offset 60% of energy costs"]}',
    'share-austin-villa-2024',
    TRUE
);

-- Project 2: Apartment, Spain
INSERT INTO projects (
    id, user_id, name, description, status, country, city,
    plot_length, plot_width, unit, floors, bedrooms, bathrooms,
    has_kitchen, has_living_room, has_balcony,
    house_style, construction_quality, currency, total_area, covered_area,
    floor_plan_data, cost_estimate,
    is_public
) VALUES (
    'b0000000-0000-0000-0000-000000000002',
    'a0000000-0000-0000-0000-000000000003',
    'Barcelona Apartment',
    'Compact 2-bedroom apartment with Mediterranean style in Barcelona city center.',
    'completed',
    'Spain', 'Barcelona',
    12.00, 9.00, 'meter',
    1, 2, 1,
    TRUE, TRUE, TRUE,
    'mediterranean', 'standard', 'EUR',
    108.00, 96.00,
    '{"rooms": [{"name": "Master Bedroom", "width": 4.0, "length": 4.5, "area": 18}, {"name": "Bedroom 2", "width": 3.5, "length": 4.0, "area": 14}, {"name": "Living Room", "width": 5.5, "length": 6.0, "area": 33}, {"name": "Kitchen", "width": 3.0, "length": 4.0, "area": 12}, {"name": "Bathroom", "width": 2.0, "length": 2.5, "area": 5}, {"name": "Balcony", "width": 2.0, "length": 5.0, "area": 10}]}',
    '{"total": 142000, "currency": "EUR", "breakdown": {"structure": 28000, "exterior": 18000, "interior": 45000, "plumbing": 12000, "electrical": 10000, "finishes": 22000, "furniture": 7000}}',
    FALSE
);

-- Project 3: Indian Bungalow
INSERT INTO projects (
    id, user_id, name, description, status, country, city,
    plot_length, plot_width, unit, floors, bedrooms, bathrooms,
    has_kitchen, has_living_room, has_dining_room, has_garden, has_balcony, has_prayer_room, has_servant_quarter,
    house_style, construction_quality, currency, total_area, covered_area,
    floor_plan_data, cost_estimate,
    is_public
) VALUES (
    'b0000000-0000-0000-0000-000000000003',
    'a0000000-0000-0000-0000-000000000004',
    'Sharma Family Bungalow',
    'Traditional Indian bungalow with prayer room, servant quarter, and open terrace in Pune.',
    'completed',
    'India', 'Pune',
    40.00, 50.00, 'feet',
    2, 4, 3,
    TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE,
    'traditional', 'premium', 'INR',
    3000.00, 2400.00,
    '{"floors": [{"level": 0, "rooms": [{"name": "Living Room", "width": 18, "length": 22, "area": 396}, {"name": "Dining", "width": 14, "length": 16, "area": 224}, {"name": "Kitchen", "width": 12, "length": 14, "area": 168}, {"name": "Prayer Room", "width": 8, "length": 10, "area": 80}, {"name": "Servant Quarter", "width": 10, "length": 12, "area": 120}]}, {"level": 1, "rooms": [{"name": "Master Bedroom", "width": 16, "length": 18, "area": 288}, {"name": "Bedroom 2", "width": 14, "length": 16, "area": 224}, {"name": "Bedroom 3", "width": 12, "length": 14, "area": 168}, {"name": "Bedroom 4", "width": 12, "length": 12, "area": 144}]}]}',
    '{"total": 4800000, "currency": "INR", "breakdown": {"civil_work": 2200000, "finishing": 1100000, "electrical": 320000, "plumbing": 280000, "woodwork": 450000, "tiles": 250000, "paint": 200000}}',
    FALSE
);

-- Project 4: UK Townhouse
INSERT INTO projects (
    id, user_id, name, description, status, country, city,
    plot_length, plot_width, unit, floors, bedrooms, bathrooms,
    has_kitchen, has_living_room, has_dining_room, has_garden, has_basement,
    house_style, construction_quality, currency, total_area, covered_area,
    is_public
) VALUES (
    'b0000000-0000-0000-0000-000000000004',
    'a0000000-0000-0000-0000-000000000005',
    'London Townhouse Renovation',
    'Victorian-era townhouse renovation with modern interior while preserving heritage facade.',
    'draft',
    'United Kingdom', 'London',
    18.00, 45.00, 'feet',
    3, 4, 2,
    TRUE, TRUE, TRUE, TRUE, TRUE,
    'contemporary', 'luxury', 'GBP',
    2430.00, 2000.00,
    FALSE
);

-- Project 5: Dubai Villa
INSERT INTO projects (
    id, user_id, name, description, status, country, city,
    plot_length, plot_width, unit, floors, bedrooms, bathrooms,
    has_kitchen, has_living_room, has_dining_room, has_garage, has_garden, has_balcony, has_study_room,
    house_style, construction_quality, currency, total_area, covered_area,
    floor_plan_data, cost_estimate,
    share_token, is_public
) VALUES (
    'b0000000-0000-0000-0000-000000000005',
    'a0000000-0000-0000-0000-000000000006',
    'Palm Jumeirah Villa',
    'Luxury contemporary villa with smart home technology and rooftop pool in Dubai.',
    'completed',
    'United Arab Emirates', 'Dubai',
    25.00, 30.00, 'meter',
    3, 5, 5,
    TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE,
    'contemporary', 'luxury', 'AED',
    750.00, 620.00,
    '{"floors": [{"level": 0, "rooms": [{"name": "Reception", "area": 80}, {"name": "Majlis", "area": 60}, {"name": "Dining", "area": 45}, {"name": "Kitchen", "area": 35}, {"name": "Maid Room", "area": 20}, {"name": "Garage", "area": 60}]}, {"level": 1, "rooms": [{"name": "Master Suite", "area": 70}, {"name": "Bedroom 2", "area": 35}, {"name": "Bedroom 3", "area": 30}, {"name": "Family Room", "area": 55}]}, {"level": 2, "rooms": [{"name": "Bedroom 4", "area": 35}, {"name": "Bedroom 5", "area": 30}, {"name": "Study", "area": 25}, {"name": "Rooftop Pool Area", "area": 90}]}]}',
    '{"total": 3850000, "currency": "AED", "breakdown": {"structure": 850000, "exterior": 480000, "smart_home": 220000, "interior_design": 950000, "kitchen_baths": 680000, "pool": 180000, "landscaping": 290000, "other": 200000}}',
    'share-palm-villa-luxury',
    TRUE
);

-- Projects 6-10: Additional projects spread across users
INSERT INTO projects (
    id, user_id, name, status, country, city,
    plot_length, plot_width, unit, floors, bedrooms, bathrooms,
    has_kitchen, has_living_room,
    house_style, construction_quality, currency,
    is_public
) VALUES
(
    'b0000000-0000-0000-0000-000000000006',
    'a0000000-0000-0000-0000-000000000002',
    'Lake House - Vermont',
    'draft', 'United States', 'Burlington, VT',
    55.00, 70.00, 'feet', 2, 4, 3,
    TRUE, TRUE,
    'contemporary', 'premium', 'USD',
    FALSE
),
(
    'b0000000-0000-0000-0000-000000000007',
    'a0000000-0000-0000-0000-000000000003',
    'Summer Cottage - Mallorca',
    'completed', 'Spain', 'Mallorca',
    15.00, 20.00, 'meter', 1, 2, 2,
    TRUE, TRUE,
    'mediterranean', 'standard', 'EUR',
    TRUE
),
(
    'b0000000-0000-0000-0000-000000000008',
    'a0000000-0000-0000-0000-000000000004',
    'Mumbai Studio Apartment',
    'completed', 'India', 'Mumbai',
    25.00, 30.00, 'feet', 1, 1, 1,
    TRUE, TRUE,
    'minimalist', 'standard', 'INR',
    FALSE
),
(
    'b0000000-0000-0000-0000-000000000009',
    'a0000000-0000-0000-0000-000000000006',
    'Abu Dhabi Family Home',
    'draft', 'United Arab Emirates', 'Abu Dhabi',
    20.00, 25.00, 'meter', 2, 4, 3,
    TRUE, TRUE,
    'traditional', 'premium', 'AED',
    FALSE
),
(
    'b0000000-0000-0000-0000-000000000010',
    'a0000000-0000-0000-0000-000000000002',
    'Beach House - Miami',
    'completed', 'United States', 'Miami, FL',
    50.00, 60.00, 'feet', 2, 3, 3,
    TRUE, TRUE,
    'modern', 'luxury', 'USD',
    TRUE
);

-- =============================================================================
-- REPORTS (sample generated reports)
-- =============================================================================
INSERT INTO reports (project_id, user_id, type, file_name, file_size, format, pages) VALUES
('b0000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000002', 'full',       'sunset-villa-full-report.pdf',     2457600, 'pdf',  12),
('b0000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000002', 'floor_plan', 'sunset-villa-floor-plan.pdf',      1024000, 'pdf',   4),
('b0000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000002', 'cost',       'sunset-villa-cost-estimate.pdf',    512000, 'pdf',   3),
('b0000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000002', 'floor_plan', 'sunset-villa-floor-plan.svg',       204800, 'svg',   1),
('b0000000-0000-0000-0000-000000000003', 'a0000000-0000-0000-0000-000000000004', 'full',       'sharma-bungalow-report.pdf',       1843200, 'pdf',  10),
('b0000000-0000-0000-0000-000000000003', 'a0000000-0000-0000-0000-000000000004', 'cost',       'sharma-bungalow-cost.pdf',          409600, 'pdf',   2),
('b0000000-0000-0000-0000-000000000005', 'a0000000-0000-0000-0000-000000000006', 'full',       'palm-villa-full-report.pdf',       3145728, 'pdf',  15),
('b0000000-0000-0000-0000-000000000005', 'a0000000-0000-0000-0000-000000000006', 'material',   'palm-villa-materials.pdf',          614400, 'pdf',   5),
('b0000000-0000-0000-0000-000000000007', 'a0000000-0000-0000-0000-000000000003', 'floor_plan', 'mallorca-cottage-plan.pdf',         307200, 'pdf',   2),
('b0000000-0000-0000-0000-000000000010', 'a0000000-0000-0000-0000-000000000002', 'full',       'miami-beach-house-report.pdf',     2097152, 'pdf',  11);

-- =============================================================================
-- ACTIVITY LOGS (sample activity)
-- =============================================================================
INSERT INTO activity_logs (user_id, action, resource_type, resource_id, details, status, created_at) VALUES
('a0000000-0000-0000-0000-000000000002', 'login',          'user',    'a0000000-0000-0000-0000-000000000002', '{"provider": "email"}',                          'success', NOW() - INTERVAL '2 hours'),
('a0000000-0000-0000-0000-000000000002', 'create_project', 'project', 'b0000000-0000-0000-0000-000000000001', '{"name": "Sunset Villa - Austin"}',              'success', NOW() - INTERVAL '25 days'),
('a0000000-0000-0000-0000-000000000002', 'generate_plan',  'project', 'b0000000-0000-0000-0000-000000000001', '{"model": "gpt-4o", "duration_ms": 8432}',       'success', NOW() - INTERVAL '24 days'),
('a0000000-0000-0000-0000-000000000002', 'download_report','report',  'b0000000-0000-0000-0000-000000000001', '{"type": "full", "format": "pdf"}',              'success', NOW() - INTERVAL '20 days'),
('a0000000-0000-0000-0000-000000000003', 'login',          'user',    'a0000000-0000-0000-0000-000000000003', '{"provider": "google"}',                         'success', NOW() - INTERVAL '1 day'),
('a0000000-0000-0000-0000-000000000003', 'create_project', 'project', 'b0000000-0000-0000-0000-000000000002', '{"name": "Barcelona Apartment"}',                'success', NOW() - INTERVAL '15 days'),
('a0000000-0000-0000-0000-000000000004', 'login',          'user',    'a0000000-0000-0000-0000-000000000004', '{"provider": "email"}',                          'success', NOW() - INTERVAL '3 hours'),
('a0000000-0000-0000-0000-000000000004', 'generate_plan',  'project', 'b0000000-0000-0000-0000-000000000003', '{"model": "gpt-4o", "duration_ms": 9120}',       'success', NOW() - INTERVAL '10 days'),
('a0000000-0000-0000-0000-000000000005', 'login',          'user',    'a0000000-0000-0000-0000-000000000005', '{"provider": "email"}',                          'success', NOW() - INTERVAL '5 days'),
('a0000000-0000-0000-0000-000000000006', 'create_project', 'project', 'b0000000-0000-0000-0000-000000000005', '{"name": "Palm Jumeirah Villa"}',                'success', NOW() - INTERVAL '8 days'),
('a0000000-0000-0000-0000-000000000006', 'generate_plan',  'project', 'b0000000-0000-0000-0000-000000000005', '{"model": "gpt-4o", "duration_ms": 11240}',      'success', NOW() - INTERVAL '7 days'),
('a0000000-0000-0000-0000-000000000001', 'admin_login',    'user',    'a0000000-0000-0000-0000-000000000001', '{"provider": "email", "admin_panel": true}',     'success', NOW() - INTERVAL '6 hours');

-- =============================================================================
-- CURRENCY CACHE (initial rates based on USD)
-- =============================================================================
INSERT INTO currency_cache (base_currency, rates, source, cached_at, expires_at) VALUES
(
    'USD',
    '{
        "USD": 1.000000,
        "EUR": 0.921000,
        "GBP": 0.789000,
        "INR": 83.450000,
        "AED": 3.673000,
        "SAR": 3.750000,
        "PKR": 278.500000,
        "BDT": 109.750000,
        "MYR": 4.720000,
        "SGD": 1.348000,
        "AUD": 1.530000,
        "CAD": 1.363000,
        "JPY": 149.800000,
        "CNY": 7.240000,
        "KWD": 0.307000,
        "QAR": 3.640000,
        "OMR": 0.385000,
        "BHD": 0.377000,
        "EGP": 48.500000,
        "NGN": 1540.000000,
        "ZAR": 18.650000,
        "BRL": 4.970000,
        "MXN": 17.150000,
        "CHF": 0.896000,
        "SEK": 10.480000,
        "NOK": 10.550000,
        "DKK": 6.870000,
        "PLN": 3.950000,
        "CZK": 22.750000,
        "HUF": 356.000000,
        "RON": 4.580000,
        "TRY": 32.150000,
        "RUB": 89.500000,
        "UAH": 38.200000,
        "KRW": 1326.000000,
        "THB": 35.250000,
        "IDR": 15680.000000,
        "PHP": 55.900000,
        "VND": 24400.000000,
        "NZD": 1.638000,
        "HKD": 7.826000,
        "TWD": 31.850000,
        "ILS": 3.728000,
        "CLP": 940.000000,
        "COP": 3920.000000,
        "PEN": 3.730000,
        "ARS": 895.000000
    }',
    'exchangerate-api',
    NOW(),
    NOW() + INTERVAL '24 hours'
);

-- =============================================================================
-- AI REQUESTS (sample usage data)
-- =============================================================================
INSERT INTO ai_requests (user_id, project_id, model, request_type, input_tokens, output_tokens, cost_usd, duration_ms, status) VALUES
('a0000000-0000-0000-0000-000000000002', 'b0000000-0000-0000-0000-000000000001', 'gpt-4o', 'floor_plan',    1250, 3800, 0.076000, 8432,  'success'),
('a0000000-0000-0000-0000-000000000002', 'b0000000-0000-0000-0000-000000000001', 'gpt-4o', 'cost_estimate',  980, 2400, 0.049000, 5210,  'success'),
('a0000000-0000-0000-0000-000000000002', 'b0000000-0000-0000-0000-000000000001', 'gpt-4o', 'optimization',   720, 1850, 0.037000, 3980,  'success'),
('a0000000-0000-0000-0000-000000000003', 'b0000000-0000-0000-0000-000000000002', 'gpt-4o', 'floor_plan',    1100, 3200, 0.064000, 7120,  'success'),
('a0000000-0000-0000-0000-000000000004', 'b0000000-0000-0000-0000-000000000003', 'gpt-4o', 'floor_plan',    1400, 4200, 0.084000, 9120,  'success'),
('a0000000-0000-0000-0000-000000000004', 'b0000000-0000-0000-0000-000000000003', 'gpt-4o', 'material_list',  850, 2900, 0.058000, 6340,  'success'),
('a0000000-0000-0000-0000-000000000006', 'b0000000-0000-0000-0000-000000000005', 'gpt-4o', 'floor_plan',    1600, 4800, 0.096000, 11240, 'success'),
('a0000000-0000-0000-0000-000000000006', 'b0000000-0000-0000-0000-000000000005', 'gpt-4o', 'cost_estimate', 1200, 3600, 0.072000, 7850,  'success'),
('a0000000-0000-0000-0000-000000000006', 'b0000000-0000-0000-0000-000000000005', 'gpt-4o', 'material_list',  950, 3100, 0.062000, 6820,  'success');

-- =============================================================================
-- Verification
-- =============================================================================
DO $$
BEGIN
    RAISE NOTICE 'Seed data inserted successfully:';
    RAISE NOTICE '  - % system settings', (SELECT COUNT(*) FROM system_settings);
    RAISE NOTICE '  - % subscription plans', (SELECT COUNT(*) FROM subscription_plans);
    RAISE NOTICE '  - % users', (SELECT COUNT(*) FROM users);
    RAISE NOTICE '  - % projects', (SELECT COUNT(*) FROM projects);
    RAISE NOTICE '  - % reports', (SELECT COUNT(*) FROM reports);
    RAISE NOTICE '  - % activity log entries', (SELECT COUNT(*) FROM activity_logs);
    RAISE NOTICE '  - % AI request records', (SELECT COUNT(*) FROM ai_requests);
END $$;

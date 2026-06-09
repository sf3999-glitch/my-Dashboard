// ─── Auth ─────────────────────────────────────────────────
export interface AdminUser {
  id: string;
  email: string;
  name: string;
  role: 'super_admin' | 'admin' | 'viewer';
  avatar?: string;
}

export interface LoginCredentials {
  email: string;
  password: string;
}

export interface AuthState {
  user: AdminUser | null;
  token: string | null;
  isAuthenticated: boolean;
  isLoading: boolean;
}

// ─── App Users ────────────────────────────────────────────
export type UserStatus = 'active' | 'suspended' | 'pending' | 'inactive';

export interface AppUser {
  id: string;
  name: string;
  email: string;
  country: string;
  country_code: string;
  projects_count: number;
  status: UserStatus;
  plan: 'free' | 'pro' | 'enterprise';
  joined_at: string;
  last_active_at: string;
  avatar?: string;
  total_spent: number;
}

// ─── Projects ─────────────────────────────────────────────
export type ProjectStatus = 'draft' | 'active' | 'completed' | 'archived';

export interface Project {
  id: string;
  name: string;
  user_id: string;
  user_name: string;
  user_email: string;
  country: string;
  country_code: string;
  floors: number;
  house_style: string;
  total_area: number;
  status: ProjectStatus;
  construction_quality: 'economy' | 'standard' | 'premium' | 'luxury';
  estimated_cost: number;
  currency: string;
  created_at: string;
  updated_at: string;
  ai_interactions: number;
}

// ─── Stats ────────────────────────────────────────────────
export interface DashboardStats {
  total_users: number;
  active_users: number;
  total_projects: number;
  active_projects: number;
  reports_generated: number;
  total_revenue: number;
  monthly_revenue: number;
  avg_projects_per_user: number;
  user_growth_pct: number;
  project_growth_pct: number;
  revenue_growth_pct: number;
  reports_growth_pct: number;
}

export interface TimeSeriesPoint {
  date: string;
  value: number;
  label?: string;
}

export interface CountryData {
  country: string;
  country_code: string;
  users: number;
  projects: number;
  revenue: number;
}

export interface StyleData {
  style: string;
  count: number;
  percentage: number;
}

export interface QualityData {
  quality: string;
  count: number;
  percentage: number;
  color: string;
}

export interface ActivityItem {
  id: string;
  type: 'user_signup' | 'project_created' | 'report_generated' | 'payment' | 'user_suspended';
  title: string;
  description: string;
  timestamp: string;
  user_name?: string;
  user_avatar?: string;
  meta?: Record<string, string | number>;
}

// ─── Analytics ────────────────────────────────────────────
export interface AnalyticsData {
  user_growth: TimeSeriesPoint[];
  project_growth: TimeSeriesPoint[];
  revenue_trend: TimeSeriesPoint[];
  ai_usage: TimeSeriesPoint[];
  countries: CountryData[];
  house_styles: StyleData[];
  construction_quality: QualityData[];
  avg_cost_by_region: { region: string; avg_cost: number; currency: string }[];
  peak_usage_hours: { hour: number; requests: number }[];
}

// ─── Settings ─────────────────────────────────────────────
export interface SystemSettings {
  anthropic_api_key: string;
  openai_api_key: string;
  currency_api_key: string;
  smtp_host: string;
  smtp_port: number;
  smtp_user: string;
  smtp_password: string;
  smtp_from: string;
  rate_limit_per_minute: number;
  rate_limit_per_day: number;
  max_projects_free: number;
  max_projects_pro: number;
  maintenance_mode: boolean;
  allow_signups: boolean;
  require_email_verification: boolean;
  default_currency: string;
  supported_countries: string[];
}

// ─── API Responses ────────────────────────────────────────
export interface PaginatedResponse<T> {
  data: T[];
  total: number;
  page: number;
  per_page: number;
  total_pages: number;
}

export interface ApiResponse<T> {
  success: boolean;
  data: T;
  message?: string;
}

// ─── Table / UI ───────────────────────────────────────────
export interface SortConfig {
  key: string;
  direction: 'asc' | 'desc';
}

export interface FilterConfig {
  status?: string;
  country?: string;
  plan?: string;
  dateFrom?: string;
  dateTo?: string;
}

export interface TableColumn<T> {
  key: keyof T | string;
  label: string;
  sortable?: boolean;
  render?: (value: unknown, row: T) => React.ReactNode;
  className?: string;
}

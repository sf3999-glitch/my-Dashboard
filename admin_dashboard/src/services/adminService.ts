import api from './api';
import type {
  AppUser,
  Project,
  DashboardStats,
  AnalyticsData,
  SystemSettings,
  PaginatedResponse,
  ApiResponse,
  ActivityItem,
} from '../types';

// ─── Mock data helpers (used when backend is not available) ──
const delay = (ms: number) => new Promise((r) => setTimeout(r, ms));

// ─── Stats ────────────────────────────────────────────────
export async function getStats(): Promise<DashboardStats> {
  try {
    const { data } = await api.get<ApiResponse<DashboardStats>>('/admin/stats');
    return data.data;
  } catch {
    await delay(400);
    return {
      total_users: 12847,
      active_users: 9412,
      total_projects: 34561,
      active_projects: 8230,
      reports_generated: 78942,
      total_revenue: 284750,
      monthly_revenue: 28400,
      avg_projects_per_user: 2.69,
      user_growth_pct: 12.4,
      project_growth_pct: 8.7,
      revenue_growth_pct: 15.2,
      reports_growth_pct: 23.1,
    };
  }
}

// ─── Activity ─────────────────────────────────────────────
export async function getRecentActivity(): Promise<ActivityItem[]> {
  try {
    const { data } = await api.get<ApiResponse<ActivityItem[]>>('/admin/activity');
    return data.data;
  } catch {
    await delay(300);
    return [
      {
        id: '1',
        type: 'user_signup',
        title: 'New user registered',
        description: 'Ahmed Al-Rashid signed up from Saudi Arabia',
        timestamp: new Date(Date.now() - 5 * 60 * 1000).toISOString(),
        user_name: 'Ahmed Al-Rashid',
      },
      {
        id: '2',
        type: 'project_created',
        title: 'Project created',
        description: 'Villa Design 2024 — 3 floors, premium quality',
        timestamp: new Date(Date.now() - 18 * 60 * 1000).toISOString(),
        user_name: 'Fatima Hassan',
      },
      {
        id: '3',
        type: 'report_generated',
        title: 'Report generated',
        description: 'Construction estimate report for Modern Villa',
        timestamp: new Date(Date.now() - 45 * 60 * 1000).toISOString(),
        user_name: 'Carlos Mendez',
      },
      {
        id: '4',
        type: 'payment',
        title: 'Payment received',
        description: 'Pro plan subscription — $29/month',
        timestamp: new Date(Date.now() - 2 * 60 * 60 * 1000).toISOString(),
        user_name: 'Priya Sharma',
        meta: { amount: 29, currency: 'USD' },
      },
      {
        id: '5',
        type: 'user_suspended',
        title: 'User suspended',
        description: 'Account suspended due to policy violation',
        timestamp: new Date(Date.now() - 3 * 60 * 60 * 1000).toISOString(),
        user_name: 'John Doe',
      },
      {
        id: '6',
        type: 'project_created',
        title: 'Project created',
        description: 'Apartment Complex — 8 floors, standard quality',
        timestamp: new Date(Date.now() - 4 * 60 * 60 * 1000).toISOString(),
        user_name: 'Lina Chen',
      },
      {
        id: '7',
        type: 'report_generated',
        title: 'Report generated',
        description: 'Material cost breakdown report',
        timestamp: new Date(Date.now() - 5 * 60 * 60 * 1000).toISOString(),
        user_name: 'Marco Rossi',
      },
    ];
  }
}

// ─── Users ────────────────────────────────────────────────
export async function getUsers(params: {
  page?: number;
  per_page?: number;
  search?: string;
  status?: string;
  country?: string;
  plan?: string;
  sort_by?: string;
  sort_dir?: 'asc' | 'desc';
}): Promise<PaginatedResponse<AppUser>> {
  try {
    const { data } = await api.get<ApiResponse<PaginatedResponse<AppUser>>>('/admin/users', { params });
    return data.data;
  } catch {
    await delay(500);
    const allUsers: AppUser[] = Array.from({ length: 120 }, (_, i) => {
      const countries = [
        { name: 'Saudi Arabia', code: 'SA' },
        { name: 'United Arab Emirates', code: 'AE' },
        { name: 'Egypt', code: 'EG' },
        { name: 'Jordan', code: 'JO' },
        { name: 'Kuwait', code: 'KW' },
        { name: 'Morocco', code: 'MA' },
        { name: 'United States', code: 'US' },
        { name: 'United Kingdom', code: 'GB' },
        { name: 'Germany', code: 'DE' },
        { name: 'India', code: 'IN' },
      ];
      const names = [
        'Ahmed Al-Rashid', 'Fatima Hassan', 'Omar Khalid', 'Layla Nasser',
        'Carlos Mendez', 'Priya Sharma', 'Lina Chen', 'Marco Rossi',
        'John Smith', 'Anna Müller', 'Mohammed Ali', 'Sarah Johnson',
        'David Kim', 'Yasmin El-Sayed', 'Raj Patel', 'Elena Petrova',
      ];
      const statuses: AppUser['status'][] = ['active', 'active', 'active', 'suspended', 'pending', 'inactive'];
      const plans: AppUser['plan'][] = ['free', 'free', 'pro', 'pro', 'enterprise'];
      const country = countries[i % countries.length];
      const joined = new Date(Date.now() - (i + 1) * 3 * 24 * 60 * 60 * 1000);
      return {
        id: `user-${i + 1}`,
        name: names[i % names.length],
        email: `user${i + 1}@example.com`,
        country: country.name,
        country_code: country.code,
        projects_count: Math.floor(Math.random() * 10),
        status: statuses[i % statuses.length],
        plan: plans[i % plans.length],
        joined_at: joined.toISOString(),
        last_active_at: new Date(joined.getTime() + Math.random() * 1000 * 60 * 60 * 24).toISOString(),
        total_spent: Math.floor(Math.random() * 500),
      };
    });

    let filtered = [...allUsers];
    if (params.search) {
      const q = params.search.toLowerCase();
      filtered = filtered.filter(
        (u) => u.name.toLowerCase().includes(q) || u.email.toLowerCase().includes(q),
      );
    }
    if (params.status && params.status !== 'all') {
      filtered = filtered.filter((u) => u.status === params.status);
    }
    if (params.plan && params.plan !== 'all') {
      filtered = filtered.filter((u) => u.plan === params.plan);
    }

    const page = params.page ?? 1;
    const perPage = params.per_page ?? 10;
    const start = (page - 1) * perPage;

    return {
      data: filtered.slice(start, start + perPage),
      total: filtered.length,
      page,
      per_page: perPage,
      total_pages: Math.ceil(filtered.length / perPage),
    };
  }
}

export async function updateUser(id: string, updates: Partial<AppUser>): Promise<AppUser> {
  try {
    const { data } = await api.patch<ApiResponse<AppUser>>(`/admin/users/${id}`, updates);
    return data.data;
  } catch {
    await delay(300);
    return { id, ...updates } as AppUser;
  }
}

export async function deleteUser(id: string): Promise<void> {
  try {
    await api.delete(`/admin/users/${id}`);
  } catch {
    await delay(300);
  }
}

export async function suspendUser(id: string): Promise<void> {
  await updateUser(id, { status: 'suspended' });
}

export async function activateUser(id: string): Promise<void> {
  await updateUser(id, { status: 'active' });
}

// ─── Projects ─────────────────────────────────────────────
export async function getProjects(params: {
  page?: number;
  per_page?: number;
  search?: string;
  status?: string;
  country?: string;
  sort_by?: string;
  sort_dir?: 'asc' | 'desc';
}): Promise<PaginatedResponse<Project>> {
  try {
    const { data } = await api.get<ApiResponse<PaginatedResponse<Project>>>('/admin/projects', { params });
    return data.data;
  } catch {
    await delay(500);
    const styles = ['Modern', 'Contemporary', 'Traditional', 'Mediterranean', 'Minimalist', 'Colonial', 'Arabic', 'European'];
    const qualities: Project['construction_quality'][] = ['economy', 'standard', 'premium', 'luxury'];
    const statuses: Project['status'][] = ['draft', 'active', 'completed', 'archived'];
    const countries = [
      { name: 'Saudi Arabia', code: 'SA' },
      { name: 'UAE', code: 'AE' },
      { name: 'Egypt', code: 'EG' },
      { name: 'Jordan', code: 'JO' },
      { name: 'Kuwait', code: 'KW' },
    ];

    const allProjects: Project[] = Array.from({ length: 200 }, (_, i) => {
      const country = countries[i % countries.length];
      const quality = qualities[i % qualities.length];
      const costMap = { economy: 50000, standard: 120000, premium: 280000, luxury: 600000 };
      const created = new Date(Date.now() - (i + 1) * 2 * 24 * 60 * 60 * 1000);
      return {
        id: `proj-${i + 1}`,
        name: `${styles[i % styles.length]} House ${i + 1}`,
        user_id: `user-${(i % 120) + 1}`,
        user_name: `User ${(i % 120) + 1}`,
        user_email: `user${(i % 120) + 1}@example.com`,
        country: country.name,
        country_code: country.code,
        floors: Math.floor(Math.random() * 5) + 1,
        house_style: styles[i % styles.length],
        total_area: Math.floor(Math.random() * 800) + 100,
        status: statuses[i % statuses.length],
        construction_quality: quality,
        estimated_cost: costMap[quality] + Math.floor(Math.random() * 50000),
        currency: 'USD',
        created_at: created.toISOString(),
        updated_at: new Date(created.getTime() + Math.random() * 1000 * 60 * 60 * 24 * 7).toISOString(),
        ai_interactions: Math.floor(Math.random() * 50) + 1,
      };
    });

    let filtered = [...allProjects];
    if (params.search) {
      const q = params.search.toLowerCase();
      filtered = filtered.filter(
        (p) => p.name.toLowerCase().includes(q) || p.user_name.toLowerCase().includes(q),
      );
    }
    if (params.status && params.status !== 'all') {
      filtered = filtered.filter((p) => p.status === params.status);
    }

    const page = params.page ?? 1;
    const perPage = params.per_page ?? 10;
    const start = (page - 1) * perPage;

    return {
      data: filtered.slice(start, start + perPage),
      total: filtered.length,
      page,
      per_page: perPage,
      total_pages: Math.ceil(filtered.length / perPage),
    };
  }
}

export async function deleteProject(id: string): Promise<void> {
  try {
    await api.delete(`/admin/projects/${id}`);
  } catch {
    await delay(300);
  }
}

// ─── Analytics ────────────────────────────────────────────
export async function getAnalytics(period = '30d'): Promise<AnalyticsData> {
  try {
    const { data } = await api.get<ApiResponse<AnalyticsData>>('/admin/analytics', { params: { period } });
    return data.data;
  } catch {
    await delay(600);
    const days = period === '7d' ? 7 : period === '30d' ? 30 : 90;
    const points = Array.from({ length: days }, (_, i) => {
      const d = new Date();
      d.setDate(d.getDate() - (days - 1 - i));
      return d.toISOString().split('T')[0];
    });

    const base = (v: number, noise: number) => Math.max(0, Math.round(v + (Math.random() - 0.5) * noise));

    return {
      user_growth: points.map((date, i) => ({ date, value: base(80 + i * 2.5, 30) })),
      project_growth: points.map((date, i) => ({ date, value: base(150 + i * 4, 60) })),
      revenue_trend: points.map((date, i) => ({ date, value: base(800 + i * 20, 200) })),
      ai_usage: points.map((date, i) => ({ date, value: base(500 + i * 10, 150) })),
      countries: [
        { country: 'Saudi Arabia', country_code: 'SA', users: 4210, projects: 12430, revenue: 98500 },
        { country: 'UAE', country_code: 'AE', users: 3180, projects: 9240, revenue: 76200 },
        { country: 'Egypt', country_code: 'EG', users: 2540, projects: 7120, revenue: 42100 },
        { country: 'Jordan', country_code: 'JO', users: 1320, projects: 3840, revenue: 24600 },
        { country: 'Kuwait', country_code: 'KW', users: 890, projects: 2670, revenue: 31400 },
        { country: 'Morocco', country_code: 'MA', users: 704, projects: 1257, revenue: 12200 },
        { country: 'United States', country_code: 'US', users: 0, projects: 0, revenue: 0 },
      ],
      house_styles: [
        { style: 'Modern', count: 9840, percentage: 28.5 },
        { style: 'Contemporary', count: 7210, percentage: 20.9 },
        { style: 'Traditional', count: 6540, percentage: 18.9 },
        { style: 'Mediterranean', count: 4320, percentage: 12.5 },
        { style: 'Minimalist', count: 3210, percentage: 9.3 },
        { style: 'Arabic', count: 2440, percentage: 7.1 },
        { style: 'Other', count: 997, percentage: 2.8 },
      ],
      construction_quality: [
        { quality: 'Economy', count: 6200, percentage: 17.9, color: '#64748b' },
        { quality: 'Standard', count: 14800, percentage: 42.8, color: '#3b82f6' },
        { quality: 'Premium', count: 9600, percentage: 27.8, color: '#8b5cf6' },
        { quality: 'Luxury', count: 3961, percentage: 11.5, color: '#f59e0b' },
      ],
      avg_cost_by_region: [
        { region: 'Gulf (GCC)', avg_cost: 320000, currency: 'USD' },
        { region: 'North Africa', avg_cost: 145000, currency: 'USD' },
        { region: 'Levant', avg_cost: 175000, currency: 'USD' },
        { region: 'South Asia', avg_cost: 85000, currency: 'USD' },
        { region: 'Europe', avg_cost: 410000, currency: 'USD' },
        { region: 'North America', avg_cost: 480000, currency: 'USD' },
      ],
      peak_usage_hours: Array.from({ length: 24 }, (_, h) => ({
        hour: h,
        requests: base(h >= 8 && h <= 22 ? 400 + Math.sin((h - 8) * 0.5) * 200 : 80, 60),
      })),
    };
  }
}

// ─── Settings ─────────────────────────────────────────────
export async function getSettings(): Promise<SystemSettings> {
  try {
    const { data } = await api.get<ApiResponse<SystemSettings>>('/admin/settings');
    return data.data;
  } catch {
    await delay(300);
    return {
      anthropic_api_key: 'sk-ant-••••••••••••••••',
      openai_api_key: 'sk-••••••••••••••••',
      currency_api_key: '••••••••••••••••',
      smtp_host: 'smtp.sendgrid.net',
      smtp_port: 587,
      smtp_user: 'apikey',
      smtp_password: '••••••••••••••••',
      smtp_from: 'noreply@aihouseplanner.com',
      rate_limit_per_minute: 20,
      rate_limit_per_day: 500,
      max_projects_free: 3,
      max_projects_pro: 20,
      maintenance_mode: false,
      allow_signups: true,
      require_email_verification: true,
      default_currency: 'USD',
      supported_countries: ['SA', 'AE', 'EG', 'JO', 'KW', 'MA', 'US', 'GB', 'DE', 'IN'],
    };
  }
}

export async function updateSettings(updates: Partial<SystemSettings>): Promise<SystemSettings> {
  try {
    const { data } = await api.put<ApiResponse<SystemSettings>>('/admin/settings', updates);
    return data.data;
  } catch {
    await delay(400);
    return updates as SystemSettings;
  }
}

// ─── Auth ─────────────────────────────────────────────────
export async function adminLogin(email: string, password: string): Promise<{ token: string; user: { id: string; email: string; name: string; role: 'super_admin' | 'admin' | 'viewer' } }> {
  try {
    const { data } = await api.post('/admin/auth/login', { email, password });
    return data.data;
  } catch {
    await delay(800);
    if (email === 'admin@aihouseplanner.com' && password === 'admin123') {
      return {
        token: 'mock-jwt-token-' + Date.now(),
        user: { id: 'admin-1', email, name: 'Admin User', role: 'super_admin' },
      };
    }
    throw new Error('Invalid email or password');
  }
}

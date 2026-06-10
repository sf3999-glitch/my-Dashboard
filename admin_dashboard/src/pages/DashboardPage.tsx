import { useQuery } from '@tanstack/react-query';
import {
  UsersIcon,
  FolderIcon,
  DocumentTextIcon,
  CurrencyDollarIcon,
  UserPlusIcon,
  FolderPlusIcon,
  ArrowPathIcon,
  ShieldExclamationIcon,
} from '@heroicons/react/24/outline';
import { StatCard } from '../components/ui/StatCard';
import { LineChart } from '../components/charts/LineChart';
import { BarChart } from '../components/charts/BarChart';
import { PieChart } from '../components/charts/PieChart';
import { Badge, statusBadgeVariant } from '../components/ui/Badge';
import { getStats, getRecentActivity, getAnalytics } from '../services/adminService';
import { formatCompact, formatCurrency, formatRelativeTime, formatDate } from '../utils/helpers';

const ACTIVITY_ICONS: Record<string, React.ReactNode> = {
  user_signup:       <UserPlusIcon className="w-4 h-4" />,
  project_created:   <FolderPlusIcon className="w-4 h-4" />,
  report_generated:  <DocumentTextIcon className="w-4 h-4" />,
  payment:           <CurrencyDollarIcon className="w-4 h-4" />,
  user_suspended:    <ShieldExclamationIcon className="w-4 h-4" />,
};

const ACTIVITY_COLORS: Record<string, string> = {
  user_signup:       'bg-success-100 text-success-600 dark:bg-success-900/30 dark:text-success-400',
  project_created:   'bg-primary-100 text-primary-600 dark:bg-primary-900/30 dark:text-primary-400',
  report_generated:  'bg-accent-100 text-accent-600 dark:bg-accent-900/30 dark:text-accent-400',
  payment:           'bg-warning-100 text-warning-600 dark:bg-warning-900/30 dark:text-warning-400',
  user_suspended:    'bg-danger-100 text-danger-600 dark:bg-danger-900/30 dark:text-danger-400',
};

export default function DashboardPage() {
  const { data: stats, isLoading: statsLoading } = useQuery({
    queryKey: ['stats'],
    queryFn: getStats,
    refetchInterval: 30_000,
  });

  const { data: activity, isLoading: activityLoading } = useQuery({
    queryKey: ['activity'],
    queryFn: getRecentActivity,
    refetchInterval: 60_000,
  });

  const { data: analytics, isLoading: analyticsLoading } = useQuery({
    queryKey: ['analytics', '30d'],
    queryFn: () => getAnalytics('30d'),
  });

  const quickActions = [
    { label: 'Add User', icon: UserPlusIcon, href: '/users', color: 'btn-primary' },
    { label: 'View Reports', icon: DocumentTextIcon, href: '/analytics', color: 'btn-secondary' },
    { label: 'Refresh Data', icon: ArrowPathIcon, action: () => window.location.reload(), color: 'btn-secondary' },
  ];

  return (
    <div className="space-y-6 animate-fade-in">
      {/* Page header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="page-title">Dashboard</h1>
          <p className="text-sm text-secondary-500 dark:text-secondary-400 mt-0.5">
            Welcome back! Here's what's happening today.
          </p>
        </div>
        <div className="flex items-center gap-2">
          <span className="text-xs text-secondary-400">{formatDate(new Date().toISOString(), 'EEEE, MMM d yyyy')}</span>
        </div>
      </div>

      {/* Stats grid */}
      <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-4">
        <StatCard
          title="Total Users"
          value={stats ? formatCompact(stats.total_users) : '—'}
          trend={stats?.user_growth_pct}
          icon={<UsersIcon className="w-5 h-5" />}
          iconBg="bg-primary-100 dark:bg-primary-900/30 text-primary-600 dark:text-primary-400"
          loading={statsLoading}
        />
        <StatCard
          title="Active Projects"
          value={stats ? formatCompact(stats.active_projects) : '—'}
          trend={stats?.project_growth_pct}
          icon={<FolderIcon className="w-5 h-5" />}
          iconBg="bg-accent-100 dark:bg-accent-900/30 text-accent-600 dark:text-accent-400"
          loading={statsLoading}
        />
        <StatCard
          title="Reports Generated"
          value={stats ? formatCompact(stats.reports_generated) : '—'}
          trend={stats?.reports_growth_pct}
          icon={<DocumentTextIcon className="w-5 h-5" />}
          iconBg="bg-warning-100 dark:bg-warning-900/30 text-warning-600 dark:text-warning-400"
          loading={statsLoading}
        />
        <StatCard
          title="Monthly Revenue"
          value={stats ? formatCurrency(stats.monthly_revenue, 'USD', true) : '—'}
          trend={stats?.revenue_growth_pct}
          icon={<CurrencyDollarIcon className="w-5 h-5" />}
          iconBg="bg-success-100 dark:bg-success-900/30 text-success-600 dark:text-success-400"
          loading={statsLoading}
        />
      </div>

      {/* Charts row 1 */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-4">
        {/* Line chart – new users over time */}
        <div className="card p-5 lg:col-span-2">
          <div className="flex items-center justify-between mb-4">
            <div>
              <h2 className="section-title">User Growth</h2>
              <p className="text-xs text-secondary-400 mt-0.5">New users over the last 30 days</p>
            </div>
          </div>
          <LineChart
            data={analytics?.user_growth ?? []}
            lines={[{ key: 'value', label: 'New Users', color: '#3b82f6' }]}
            height={220}
            loading={analyticsLoading}
            formatTooltip={(v) => `${v} users`}
          />
        </div>

        {/* Pie chart – construction quality */}
        <div className="card p-5">
          <h2 className="section-title mb-1">Construction Quality</h2>
          <p className="text-xs text-secondary-400 mb-3">Distribution across all projects</p>
          <PieChart
            data={analytics?.construction_quality?.map((q) => ({
              name: q.quality,
              value: q.count,
              color: q.color,
            })) ?? []}
            height={180}
            loading={analyticsLoading}
            innerRadius={50}
            outerRadius={80}
          />
        </div>
      </div>

      {/* Charts row 2 */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
        {/* Bar chart – projects by country */}
        <div className="card p-5">
          <h2 className="section-title mb-1">Projects by Country</h2>
          <p className="text-xs text-secondary-400 mb-4">Top countries by project count</p>
          <BarChart
            data={analytics?.countries?.slice(0, 6).map((c) => ({ name: c.country, value: c.projects })) ?? []}
            bars={[{ key: 'value', label: 'Projects', color: '#8b5cf6' }]}
            height={220}
            loading={analyticsLoading}
            multiColor
            formatTooltip={(v) => `${v} projects`}
          />
        </div>

        {/* Bar chart – house styles */}
        <div className="card p-5">
          <h2 className="section-title mb-1">Popular House Styles</h2>
          <p className="text-xs text-secondary-400 mb-4">Most requested architectural styles</p>
          <BarChart
            data={analytics?.house_styles?.slice(0, 6).map((s) => ({ name: s.style, value: s.count })) ?? []}
            bars={[{ key: 'value', label: 'Count', color: '#06b6d4' }]}
            height={220}
            loading={analyticsLoading}
            multiColor
            formatTooltip={(v) => `${v} projects`}
          />
        </div>
      </div>

      {/* Bottom row */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-4">
        {/* Recent activity */}
        <div className="card p-5 lg:col-span-2">
          <h2 className="section-title mb-4">Recent Activity</h2>
          {activityLoading ? (
            <div className="space-y-3">
              {Array.from({ length: 5 }).map((_, i) => (
                <div key={i} className="flex items-center gap-3">
                  <div className="skeleton w-9 h-9 rounded-xl" />
                  <div className="flex-1 space-y-1.5">
                    <div className="skeleton h-3 w-3/4 rounded" />
                    <div className="skeleton h-3 w-1/2 rounded" />
                  </div>
                </div>
              ))}
            </div>
          ) : (
            <ul className="space-y-3">
              {activity?.map((item) => (
                <li key={item.id} className="flex items-start gap-3">
                  <div className={`w-9 h-9 rounded-xl flex items-center justify-center flex-shrink-0 ${ACTIVITY_COLORS[item.type] ?? 'bg-secondary-100 text-secondary-500'}`}>
                    {ACTIVITY_ICONS[item.type] ?? <DocumentTextIcon className="w-4 h-4" />}
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className="text-sm font-medium text-secondary-800 dark:text-secondary-200 truncate">{item.title}</p>
                    <p className="text-xs text-secondary-500 dark:text-secondary-400 truncate">{item.description}</p>
                  </div>
                  <span className="text-xs text-secondary-400 flex-shrink-0">{formatRelativeTime(item.timestamp)}</span>
                </li>
              ))}
            </ul>
          )}
        </div>

        {/* Quick actions + mini stats */}
        <div className="space-y-4">
          {/* Quick actions */}
          <div className="card p-5">
            <h2 className="section-title mb-3">Quick Actions</h2>
            <div className="flex flex-col gap-2">
              {quickActions.map((a) => (
                a.href ? (
                  <a key={a.label} href={a.href} className={`${a.color} w-full justify-center`}>
                    <a.icon className="w-4 h-4" />
                    {a.label}
                  </a>
                ) : (
                  <button key={a.label} onClick={a.action} className={`${a.color} w-full justify-center`}>
                    <a.icon className="w-4 h-4" />
                    {a.label}
                  </button>
                )
              ))}
            </div>
          </div>

          {/* Mini stats */}
          <div className="card p-5 space-y-3">
            <h2 className="section-title">Platform Overview</h2>
            {[
              { label: 'Free users',       value: `${stats ? Math.round(stats.total_users * 0.62).toLocaleString() : '—'}`, color: 'bg-secondary-400' },
              { label: 'Pro users',        value: `${stats ? Math.round(stats.total_users * 0.31).toLocaleString() : '—'}`, color: 'bg-primary-500' },
              { label: 'Enterprise users', value: `${stats ? Math.round(stats.total_users * 0.07).toLocaleString() : '—'}`, color: 'bg-accent-500' },
              { label: 'Avg projects/user',value: stats?.avg_projects_per_user.toFixed(2) ?? '—', color: 'bg-warning-500' },
            ].map((row) => (
              <div key={row.label} className="flex items-center justify-between text-sm">
                <div className="flex items-center gap-2">
                  <span className={`w-2 h-2 rounded-full ${row.color}`} />
                  <span className="text-secondary-600 dark:text-secondary-400">{row.label}</span>
                </div>
                <span className="font-semibold text-secondary-900 dark:text-secondary-100 tabular-nums">{row.value}</span>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}

import { useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { getAnalytics } from '../services/adminService';
import { LineChart } from '../components/charts/LineChart';
import { BarChart } from '../components/charts/BarChart';
import { PieChart } from '../components/charts/PieChart';
import { formatCurrency, countryFlag, formatCompact } from '../utils/helpers';

const PERIODS = [
  { label: '7 days',  value: '7d' },
  { label: '30 days', value: '30d' },
  { label: '90 days', value: '90d' },
];

export default function AnalyticsPage() {
  const [period, setPeriod] = useState('30d');

  const { data, isLoading } = useQuery({
    queryKey: ['analytics', period],
    queryFn: () => getAnalytics(period),
  });

  return (
    <div className="space-y-6 animate-fade-in">
      {/* Header */}
      <div className="flex items-center justify-between flex-wrap gap-3">
        <div>
          <h1 className="page-title">Analytics</h1>
          <p className="text-sm text-secondary-500 dark:text-secondary-400 mt-0.5">
            Platform insights and usage statistics
          </p>
        </div>
        <div className="flex items-center bg-secondary-100 dark:bg-secondary-800 rounded-xl p-1 gap-1">
          {PERIODS.map((p) => (
            <button
              key={p.value}
              onClick={() => setPeriod(p.value)}
              className={`px-3 py-1.5 rounded-lg text-sm font-medium transition-all ${
                period === p.value
                  ? 'bg-white dark:bg-secondary-700 text-secondary-900 dark:text-secondary-100 shadow-sm'
                  : 'text-secondary-500 dark:text-secondary-400 hover:text-secondary-700 dark:hover:text-secondary-300'
              }`}
            >
              {p.label}
            </button>
          ))}
        </div>
      </div>

      {/* Row 1 — Usage trends */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
        <div className="card p-5">
          <h2 className="section-title mb-1">User Growth</h2>
          <p className="text-xs text-secondary-400 mb-4">New registrations over time</p>
          <LineChart
            data={data?.user_growth ?? []}
            lines={[{ key: 'value', label: 'New Users', color: '#3b82f6' }]}
            height={220}
            loading={isLoading}
            formatTooltip={(v) => `${v} users`}
          />
        </div>
        <div className="card p-5">
          <h2 className="section-title mb-1">Revenue Trend</h2>
          <p className="text-xs text-secondary-400 mb-4">Daily revenue in USD</p>
          <LineChart
            data={data?.revenue_trend ?? []}
            lines={[{ key: 'value', label: 'Revenue', color: '#22c55e' }]}
            height={220}
            loading={isLoading}
            formatTooltip={(v) => formatCurrency(v)}
          />
        </div>
      </div>

      {/* Row 2 — Project and AI usage */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
        <div className="card p-5">
          <h2 className="section-title mb-1">Project Creation</h2>
          <p className="text-xs text-secondary-400 mb-4">New projects created per day</p>
          <LineChart
            data={data?.project_growth ?? []}
            lines={[{ key: 'value', label: 'Projects', color: '#8b5cf6' }]}
            height={220}
            loading={isLoading}
            formatTooltip={(v) => `${v} projects`}
          />
        </div>
        <div className="card p-5">
          <h2 className="section-title mb-1">AI Usage</h2>
          <p className="text-xs text-secondary-400 mb-4">AI interactions per day</p>
          <LineChart
            data={data?.ai_usage ?? []}
            lines={[{ key: 'value', label: 'AI Requests', color: '#f59e0b' }]}
            height={220}
            loading={isLoading}
            formatTooltip={(v) => `${v} requests`}
          />
        </div>
      </div>

      {/* Row 3 — Country breakdown */}
      <div className="card p-5">
        <h2 className="section-title mb-1">Users by Country</h2>
        <p className="text-xs text-secondary-400 mb-4">Top countries by registered users</p>
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr>
                {['Country', 'Users', 'Projects', 'Revenue', 'Share'].map((h) => (
                  <th key={h} className="table-head">{h}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {isLoading
                ? Array.from({ length: 5 }).map((_, i) => (
                    <tr key={i}>
                      {[...Array(5)].map((_, j) => (
                        <td key={j} className="px-4 py-3"><div className="skeleton h-4 w-3/4 rounded" /></td>
                      ))}
                    </tr>
                  ))
                : data?.countries.map((c) => {
                    const totalUsers = data.countries.reduce((s, x) => s + x.users, 0);
                    const share = totalUsers ? ((c.users / totalUsers) * 100).toFixed(1) : '0';
                    return (
                      <tr key={c.country_code} className="hover:bg-secondary-50 dark:hover:bg-secondary-700/30 transition-colors">
                        <td className="table-cell">
                          <span className="flex items-center gap-2">
                            <span>{countryFlag(c.country_code)}</span>
                            <span className="font-medium text-secondary-800 dark:text-secondary-200">{c.country}</span>
                          </span>
                        </td>
                        <td className="table-cell tabular-nums">{c.users.toLocaleString()}</td>
                        <td className="table-cell tabular-nums">{c.projects.toLocaleString()}</td>
                        <td className="table-cell tabular-nums font-medium">{formatCurrency(c.revenue, 'USD', true)}</td>
                        <td className="table-cell">
                          <div className="flex items-center gap-2">
                            <div className="flex-1 bg-secondary-200 dark:bg-secondary-700 rounded-full h-1.5">
                              <div
                                className="bg-primary-500 h-1.5 rounded-full"
                                style={{ width: `${share}%` }}
                              />
                            </div>
                            <span className="text-xs text-secondary-500 w-10 text-right">{share}%</span>
                          </div>
                        </td>
                      </tr>
                    );
                  })}
            </tbody>
          </table>
        </div>
      </div>

      {/* Row 4 — Styles, Quality, Avg Cost, Peak Hours */}
      <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-4 gap-4">
        {/* House styles */}
        <div className="card p-5">
          <h2 className="section-title mb-1">House Styles</h2>
          <p className="text-xs text-secondary-400 mb-3">Most popular architectural styles</p>
          <BarChart
            data={data?.house_styles?.map((s) => ({ name: s.style, value: s.count })) ?? []}
            bars={[{ key: 'value', label: 'Projects', color: '#3b82f6' }]}
            height={200}
            loading={isLoading}
            multiColor
            horizontal
          />
        </div>

        {/* Construction quality */}
        <div className="card p-5">
          <h2 className="section-title mb-1">Construction Quality</h2>
          <p className="text-xs text-secondary-400 mb-3">Quality distribution</p>
          <PieChart
            data={data?.construction_quality?.map((q) => ({
              name: q.quality,
              value: q.count,
              color: q.color,
            })) ?? []}
            height={160}
            loading={isLoading}
            innerRadius={45}
            outerRadius={70}
          />
        </div>

        {/* Average cost by region */}
        <div className="card p-5">
          <h2 className="section-title mb-1">Avg. Cost by Region</h2>
          <p className="text-xs text-secondary-400 mb-3">Average estimated construction cost</p>
          <BarChart
            data={data?.avg_cost_by_region?.map((r) => ({ name: r.region, value: r.avg_cost })) ?? []}
            bars={[{ key: 'value', label: 'Avg Cost', color: '#10b981' }]}
            height={200}
            loading={isLoading}
            horizontal
            formatTooltip={(v) => formatCurrency(v, 'USD', true)}
            formatY={(v) => `$${formatCompact(v)}`}
          />
        </div>

        {/* Peak usage hours */}
        <div className="card p-5">
          <h2 className="section-title mb-1">Peak Usage Hours</h2>
          <p className="text-xs text-secondary-400 mb-3">Requests by hour of day (UTC)</p>
          <BarChart
            data={data?.peak_usage_hours?.map((h) => ({ name: `${h.hour}:00`, value: h.requests })) ?? []}
            bars={[{ key: 'value', label: 'Requests', color: '#f59e0b' }]}
            height={200}
            loading={isLoading}
            formatX={(v) => v.replace(':00', 'h')}
            formatTooltip={(v) => `${v} reqs`}
          />
        </div>
      </div>
    </div>
  );
}

import { format, formatDistanceToNow, parseISO } from 'date-fns';
import { type ClassValue, clsx } from 'clsx';
import { twMerge } from 'tailwind-merge';

// ─── Tailwind class merging ───────────────────────────────
export function cn(...inputs: ClassValue[]): string {
  return twMerge(clsx(inputs));
}

// ─── Date helpers ─────────────────────────────────────────
export function formatDate(dateStr: string, fmt = 'MMM d, yyyy'): string {
  try {
    return format(parseISO(dateStr), fmt);
  } catch {
    return dateStr;
  }
}

export function formatDateTime(dateStr: string): string {
  try {
    return format(parseISO(dateStr), 'MMM d, yyyy HH:mm');
  } catch {
    return dateStr;
  }
}

export function formatRelativeTime(dateStr: string): string {
  try {
    return formatDistanceToNow(parseISO(dateStr), { addSuffix: true });
  } catch {
    return dateStr;
  }
}

// ─── Number / Currency helpers ────────────────────────────
export function formatNumber(
  value: number,
  opts: Intl.NumberFormatOptions = {},
): string {
  return new Intl.NumberFormat('en-US', opts).format(value);
}

export function formatCurrency(
  amount: number,
  currency = 'USD',
  compact = false,
): string {
  if (compact && Math.abs(amount) >= 1_000) {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency,
      notation: 'compact',
      maximumFractionDigits: 1,
    }).format(amount);
  }
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency,
    maximumFractionDigits: 0,
  }).format(amount);
}

export function formatCompact(value: number): string {
  if (value >= 1_000_000) return `${(value / 1_000_000).toFixed(1)}M`;
  if (value >= 1_000) return `${(value / 1_000).toFixed(1)}K`;
  return String(value);
}

export function formatPercent(value: number, decimals = 1): string {
  return `${value >= 0 ? '+' : ''}${value.toFixed(decimals)}%`;
}

// ─── String helpers ───────────────────────────────────────
export function truncate(str: string, length = 40): string {
  if (str.length <= length) return str;
  return `${str.slice(0, length)}…`;
}

export function capitalize(str: string): string {
  return str.charAt(0).toUpperCase() + str.slice(1).toLowerCase();
}

export function slugify(str: string): string {
  return str.toLowerCase().replace(/\s+/g, '-').replace(/[^a-z0-9-]/g, '');
}

export function initials(name: string): string {
  return name
    .split(' ')
    .slice(0, 2)
    .map((w) => w[0]?.toUpperCase() ?? '')
    .join('');
}

// ─── CSV Export ───────────────────────────────────────────
export function exportCSV<T extends Record<string, unknown>>(
  data: T[],
  filename = 'export',
  columns?: { key: keyof T; label: string }[],
): void {
  if (!data.length) return;

  const keys = columns ? columns.map((c) => c.key) : (Object.keys(data[0]) as (keyof T)[]);
  const headers = columns ? columns.map((c) => c.label) : keys.map(String);

  const rows = data.map((row) =>
    keys
      .map((key) => {
        const val = row[key];
        const str = val == null ? '' : String(val);
        return str.includes(',') || str.includes('"') || str.includes('\n')
          ? `"${str.replace(/"/g, '""')}"`
          : str;
      })
      .join(','),
  );

  const csv = [headers.join(','), ...rows].join('\n');
  const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = `${filename}_${format(new Date(), 'yyyy-MM-dd')}.csv`;
  a.click();
  URL.revokeObjectURL(url);
}

// ─── Color helpers ────────────────────────────────────────
export const STATUS_COLORS: Record<string, string> = {
  active:    'success',
  suspended: 'danger',
  pending:   'warning',
  inactive:  'secondary',
  draft:     'secondary',
  completed: 'success',
  archived:  'secondary',
};

export const QUALITY_COLORS: Record<string, string> = {
  economy:  '#64748b',
  standard: '#3b82f6',
  premium:  '#8b5cf6',
  luxury:   '#f59e0b',
};

export const CHART_COLORS = [
  '#3b82f6',
  '#8b5cf6',
  '#06b6d4',
  '#10b981',
  '#f59e0b',
  '#ef4444',
  '#ec4899',
  '#14b8a6',
];

// ─── Misc ─────────────────────────────────────────────────
export function debounce<T extends (...args: unknown[]) => unknown>(
  fn: T,
  delay: number,
): (...args: Parameters<T>) => void {
  let timer: ReturnType<typeof setTimeout>;
  return (...args: Parameters<T>) => {
    clearTimeout(timer);
    timer = setTimeout(() => fn(...args), delay);
  };
}

export function sleep(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

export function countryFlag(code: string): string {
  // Convert ISO 3166-1 alpha-2 to flag emoji
  return code
    .toUpperCase()
    .split('')
    .map((c) => String.fromCodePoint(0x1f1e0 - 65 + c.charCodeAt(0)))
    .join('');
}

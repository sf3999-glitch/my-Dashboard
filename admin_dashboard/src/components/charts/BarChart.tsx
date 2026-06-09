import {
  ResponsiveContainer,
  BarChart as ReBarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  Cell,
  type TooltipProps,
} from 'recharts';
import { cn } from '../../utils/helpers';

interface BarConfig {
  key: string;
  label: string;
  color: string;
}

interface BarChartProps {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  data: any[];
  bars: BarConfig[];
  xKey?: string;
  height?: number;
  loading?: boolean;
  className?: string;
  formatX?: (val: string) => string;
  formatY?: (val: number) => string;
  formatTooltip?: (val: number) => string;
  horizontal?: boolean;
  multiColor?: boolean;
}

function CustomTooltip({ active, payload, label, formatTooltip }: TooltipProps<number, string> & { formatTooltip?: (v: number) => string }) {
  if (!active || !payload?.length) return null;
  return (
    <div className="bg-white dark:bg-secondary-800 border border-secondary-200 dark:border-secondary-700 rounded-xl shadow-dropdown p-3 text-sm">
      <p className="font-medium text-secondary-700 dark:text-secondary-300 mb-2">{label}</p>
      {payload.map((entry) => (
        <div key={entry.dataKey} className="flex items-center gap-2">
          <span className="w-2 h-2 rounded-sm flex-shrink-0" style={{ background: entry.color }} />
          <span className="text-secondary-600 dark:text-secondary-400">{entry.name}:</span>
          <span className="font-semibold text-secondary-900 dark:text-secondary-100">
            {formatTooltip ? formatTooltip(entry.value as number) : (entry.value as number).toLocaleString()}
          </span>
        </div>
      ))}
    </div>
  );
}

const COLORS = ['#3b82f6', '#8b5cf6', '#06b6d4', '#10b981', '#f59e0b', '#ef4444', '#ec4899', '#14b8a6'];

export function BarChart({
  data,
  bars,
  xKey = 'name',
  height = 260,
  loading,
  className,
  formatX,
  formatY,
  formatTooltip,
  horizontal,
  multiColor,
}: BarChartProps) {
  if (loading) {
    return (
      <div className={cn('animate-pulse flex gap-2 items-end', className)} style={{ height }}>
        {Array.from({ length: 8 }).map((_, i) => (
          <div key={i} className="flex-1 bg-secondary-200 dark:bg-secondary-700 rounded-t" style={{ height: `${25 + Math.random() * 65}%` }} />
        ))}
      </div>
    );
  }

  const Chart = (
    <ReBarChart
      data={data}
      layout={horizontal ? 'vertical' : 'horizontal'}
      margin={{ top: 4, right: 4, bottom: 0, left: horizontal ? 80 : -10 }}
    >
      <CartesianGrid strokeDasharray="3 3" className="stroke-secondary-200 dark:stroke-secondary-700" />
      {horizontal ? (
        <>
          <XAxis
            type="number"
            tickFormatter={formatY ?? ((v: number) => v.toLocaleString())}
            tick={{ fontSize: 11, fill: 'var(--color-text-muted)' }}
            axisLine={false}
            tickLine={false}
          />
          <YAxis
            type="category"
            dataKey={xKey}
            tickFormatter={formatX}
            tick={{ fontSize: 11, fill: 'var(--color-text-muted)' }}
            axisLine={false}
            tickLine={false}
            width={75}
          />
        </>
      ) : (
        <>
          <XAxis
            dataKey={xKey}
            tickFormatter={formatX}
            tick={{ fontSize: 11, fill: 'var(--color-text-muted)' }}
            axisLine={false}
            tickLine={false}
          />
          <YAxis
            tickFormatter={formatY ?? ((v: number) => v.toLocaleString())}
            tick={{ fontSize: 11, fill: 'var(--color-text-muted)' }}
            axisLine={false}
            tickLine={false}
          />
        </>
      )}
      <Tooltip content={<CustomTooltip formatTooltip={formatTooltip} />} />
      {bars.length > 1 && <Legend wrapperStyle={{ fontSize: 12 }} />}
      {bars.map((b) => (
        <Bar key={b.key} dataKey={b.key} name={b.label} fill={b.color} radius={[4, 4, 0, 0]}>
          {multiColor && data.map((_entry, idx) => (
            <Cell key={`cell-${idx}`} fill={COLORS[idx % COLORS.length]} />
          ))}
        </Bar>
      ))}
    </ReBarChart>
  );

  return (
    <div className={cn('w-full', className)} style={{ height }}>
      <ResponsiveContainer width="100%" height="100%">
        {Chart}
      </ResponsiveContainer>
    </div>
  );
}

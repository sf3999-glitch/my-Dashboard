import {
  ResponsiveContainer,
  PieChart as RePieChart,
  Pie,
  Cell,
  Tooltip,
  Legend,
  type TooltipProps,
} from 'recharts';
import { cn } from '../../utils/helpers';

interface PieChartProps {
  data: { name: string; value: number; color?: string }[];
  height?: number;
  loading?: boolean;
  className?: string;
  innerRadius?: number;
  outerRadius?: number;
  showLegend?: boolean;
  formatTooltip?: (val: number) => string;
}

const DEFAULT_COLORS = ['#3b82f6', '#8b5cf6', '#06b6d4', '#10b981', '#f59e0b', '#ef4444', '#ec4899'];

function CustomTooltip({ active, payload, formatTooltip }: TooltipProps<number, string> & { formatTooltip?: (v: number) => string }) {
  if (!active || !payload?.length) return null;
  const entry = payload[0];
  const total = payload[0]?.payload?.total;
  const pct = total ? ((entry.value as number) / total * 100).toFixed(1) : null;
  return (
    <div className="bg-white dark:bg-secondary-800 border border-secondary-200 dark:border-secondary-700 rounded-xl shadow-dropdown p-3 text-sm">
      <div className="flex items-center gap-2 mb-1">
        <span className="w-2.5 h-2.5 rounded-full" style={{ background: entry.payload.fill }} />
        <span className="font-medium text-secondary-800 dark:text-secondary-200">{entry.name}</span>
      </div>
      <p className="text-secondary-900 dark:text-secondary-100 font-semibold">
        {formatTooltip ? formatTooltip(entry.value as number) : (entry.value as number).toLocaleString()}
        {pct && <span className="text-secondary-400 font-normal ml-1">({pct}%)</span>}
      </p>
    </div>
  );
}

function CustomLegend({ payload }: { payload?: Array<{ value: string; color: string; payload: { value: number } }> }) {
  if (!payload) return null;
  const total = payload.reduce((s, e) => s + e.payload.value, 0);
  return (
    <ul className="flex flex-col gap-1.5 mt-3">
      {payload.map((entry) => {
        const pct = total ? (entry.payload.value / total * 100).toFixed(1) : '0';
        return (
          <li key={entry.value} className="flex items-center justify-between gap-3 text-xs">
            <span className="flex items-center gap-1.5 text-secondary-700 dark:text-secondary-300">
              <span className="w-2 h-2 rounded-full flex-shrink-0" style={{ background: entry.color }} />
              {entry.value}
            </span>
            <span className="font-medium text-secondary-500 dark:text-secondary-400">{pct}%</span>
          </li>
        );
      })}
    </ul>
  );
}

export function PieChart({
  data,
  height = 260,
  loading,
  className,
  innerRadius = 60,
  outerRadius = 90,
  showLegend = true,
  formatTooltip,
}: PieChartProps) {
  if (loading) {
    return (
      <div className={cn('flex items-center justify-center', className)} style={{ height }}>
        <div className="w-32 h-32 rounded-full border-8 border-secondary-200 dark:border-secondary-700 border-t-primary-500 animate-spin" />
      </div>
    );
  }

  const total = data.reduce((s, d) => s + d.value, 0);
  const enriched = data.map((d) => ({ ...d, total }));

  return (
    <div className={cn('w-full', className)} style={{ height: showLegend ? 'auto' : height }}>
      <ResponsiveContainer width="100%" height={height}>
        <RePieChart>
          <Pie
            data={enriched}
            cx="50%"
            cy="50%"
            innerRadius={innerRadius}
            outerRadius={outerRadius}
            paddingAngle={2}
            dataKey="value"
          >
            {enriched.map((entry, index) => (
              <Cell
                key={`cell-${index}`}
                fill={entry.color ?? DEFAULT_COLORS[index % DEFAULT_COLORS.length]}
              />
            ))}
          </Pie>
          <Tooltip content={<CustomTooltip formatTooltip={formatTooltip} />} />
        </RePieChart>
      </ResponsiveContainer>
      {showLegend && (
        <CustomLegend
          payload={data.map((d, i) => ({
            value: d.name,
            color: d.color ?? DEFAULT_COLORS[i % DEFAULT_COLORS.length],
            payload: { value: d.value },
          }))}
        />
      )}
    </div>
  );
}

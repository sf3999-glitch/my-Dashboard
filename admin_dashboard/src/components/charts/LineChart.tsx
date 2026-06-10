import {
  ResponsiveContainer,
  LineChart as ReLineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  type TooltipProps,
} from 'recharts';
import { format, parseISO } from 'date-fns';
import { cn } from '../../utils/helpers';

interface LineConfig {
  key: string;
  label: string;
  color: string;
  dashed?: boolean;
}

interface LineChartProps {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  data: any[];
  lines: LineConfig[];
  xKey?: string;
  height?: number;
  loading?: boolean;
  className?: string;
  formatX?: (val: string) => string;
  formatY?: (val: number) => string;
  formatTooltip?: (val: number) => string;
}

function CustomTooltip({ active, payload, label, formatTooltip }: TooltipProps<number, string> & { formatTooltip?: (v: number) => string }) {
  if (!active || !payload?.length) return null;
  return (
    <div className="bg-white dark:bg-secondary-800 border border-secondary-200 dark:border-secondary-700 rounded-xl shadow-dropdown p-3 text-sm">
      <p className="font-medium text-secondary-700 dark:text-secondary-300 mb-2">
        {label}
      </p>
      {payload.map((entry) => (
        <div key={entry.dataKey} className="flex items-center gap-2">
          <span className="w-2 h-2 rounded-full flex-shrink-0" style={{ background: entry.color }} />
          <span className="text-secondary-600 dark:text-secondary-400">{entry.name}:</span>
          <span className="font-semibold text-secondary-900 dark:text-secondary-100">
            {formatTooltip ? formatTooltip(entry.value as number) : (entry.value as number).toLocaleString()}
          </span>
        </div>
      ))}
    </div>
  );
}

function ChartSkeleton({ height }: { height: number }) {
  return (
    <div className="animate-pulse flex flex-col gap-2" style={{ height }}>
      <div className="flex-1 flex items-end gap-1 pb-6">
        {Array.from({ length: 20 }).map((_, i) => (
          <div
            key={i}
            className="flex-1 bg-secondary-200 dark:bg-secondary-700 rounded-t"
            style={{ height: `${30 + Math.random() * 70}%` }}
          />
        ))}
      </div>
    </div>
  );
}

export function LineChart({
  data,
  lines,
  xKey = 'date',
  height = 260,
  loading,
  className,
  formatX,
  formatY,
  formatTooltip,
}: LineChartProps) {
  if (loading) return <ChartSkeleton height={height} />;

  const defaultFormatX = (val: string) => {
    try { return format(parseISO(val), 'MMM d'); } catch { return val; }
  };

  return (
    <div className={cn('w-full', className)} style={{ height }}>
      <ResponsiveContainer width="100%" height="100%">
        <ReLineChart data={data} margin={{ top: 4, right: 4, bottom: 0, left: -10 }}>
          <CartesianGrid strokeDasharray="3 3" className="stroke-secondary-200 dark:stroke-secondary-700" />
          <XAxis
            dataKey={xKey}
            tickFormatter={formatX ?? defaultFormatX}
            tick={{ fontSize: 11, fill: 'var(--color-text-muted)' }}
            axisLine={false}
            tickLine={false}
            interval="preserveStartEnd"
          />
          <YAxis
            tickFormatter={formatY ?? ((v: number) => v.toLocaleString())}
            tick={{ fontSize: 11, fill: 'var(--color-text-muted)' }}
            axisLine={false}
            tickLine={false}
          />
          <Tooltip content={<CustomTooltip formatTooltip={formatTooltip} />} />
          {lines.length > 1 && <Legend wrapperStyle={{ fontSize: 12 }} />}
          {lines.map((l) => (
            <Line
              key={l.key}
              type="monotone"
              dataKey={l.key}
              name={l.label}
              stroke={l.color}
              strokeWidth={2}
              strokeDasharray={l.dashed ? '5 5' : undefined}
              dot={false}
              activeDot={{ r: 4, strokeWidth: 0 }}
            />
          ))}
        </ReLineChart>
      </ResponsiveContainer>
    </div>
  );
}

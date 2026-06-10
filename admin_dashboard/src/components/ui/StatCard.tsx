import { cn } from '../../utils/helpers';

interface StatCardProps {
  title: string;
  value: string | number;
  trend?: number;
  trendLabel?: string;
  icon: React.ReactNode;
  iconBg?: string;
  loading?: boolean;
  className?: string;
}

function Skeleton({ className }: { className?: string }) {
  return <div className={cn('skeleton rounded', className)} />;
}

export function StatCard({
  title,
  value,
  trend,
  trendLabel = 'vs last month',
  icon,
  iconBg = 'bg-primary-100 dark:bg-primary-900/30 text-primary-600 dark:text-primary-400',
  loading,
  className,
}: StatCardProps) {
  const isPositive = trend !== undefined && trend >= 0;

  return (
    <div className={cn('card p-5 flex flex-col gap-4', className)}>
      <div className="flex items-start justify-between">
        <div>
          <p className="text-xs font-medium text-secondary-500 dark:text-secondary-400 uppercase tracking-wide">
            {title}
          </p>
          {loading ? (
            <Skeleton className="mt-2 h-7 w-24" />
          ) : (
            <p className="mt-1 text-2xl font-bold text-secondary-900 dark:text-secondary-50 tabular-nums">
              {value}
            </p>
          )}
        </div>
        <div className={cn('p-2.5 rounded-xl flex-shrink-0', iconBg)}>
          <div className="w-5 h-5">{icon}</div>
        </div>
      </div>

      {trend !== undefined && (
        <div className="flex items-center gap-1.5">
          {loading ? (
            <Skeleton className="h-4 w-32" />
          ) : (
            <>
              <span
                className={cn(
                  'inline-flex items-center text-xs font-semibold',
                  isPositive ? 'text-success-600 dark:text-success-400' : 'text-danger-600 dark:text-danger-400',
                )}
              >
                {isPositive ? '↑' : '↓'} {Math.abs(trend).toFixed(1)}%
              </span>
              <span className="text-xs text-secondary-400 dark:text-secondary-500">{trendLabel}</span>
            </>
          )}
        </div>
      )}
    </div>
  );
}

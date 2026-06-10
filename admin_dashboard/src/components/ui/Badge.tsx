import { cn } from '../../utils/helpers';

type BadgeVariant = 'success' | 'warning' | 'danger' | 'info' | 'secondary' | 'primary';

interface BadgeProps {
  variant?: BadgeVariant;
  children: React.ReactNode;
  className?: string;
  dot?: boolean;
}

const variantClasses: Record<BadgeVariant, string> = {
  success:   'bg-success-100 text-success-700 dark:bg-success-700/20 dark:text-success-400',
  warning:   'bg-warning-100 text-warning-700 dark:bg-warning-700/20 dark:text-warning-400',
  danger:    'bg-danger-100 text-danger-700 dark:bg-danger-700/20 dark:text-danger-400',
  info:      'bg-primary-100 text-primary-700 dark:bg-primary-700/20 dark:text-primary-400',
  primary:   'bg-primary-100 text-primary-700 dark:bg-primary-700/20 dark:text-primary-400',
  secondary: 'bg-secondary-100 text-secondary-600 dark:bg-secondary-700/40 dark:text-secondary-400',
};

const dotColors: Record<BadgeVariant, string> = {
  success:   'bg-success-500',
  warning:   'bg-warning-500',
  danger:    'bg-danger-500',
  info:      'bg-primary-500',
  primary:   'bg-primary-500',
  secondary: 'bg-secondary-400',
};

export function Badge({ variant = 'secondary', children, className, dot }: BadgeProps) {
  return (
    <span
      className={cn(
        'inline-flex items-center gap-1.5 px-2 py-0.5 rounded-full text-xs font-medium',
        variantClasses[variant],
        className,
      )}
    >
      {dot && (
        <span className={cn('w-1.5 h-1.5 rounded-full flex-shrink-0', dotColors[variant])} />
      )}
      {children}
    </span>
  );
}

export function statusBadgeVariant(status: string): BadgeVariant {
  const map: Record<string, BadgeVariant> = {
    active:    'success',
    completed: 'success',
    suspended: 'danger',
    pending:   'warning',
    inactive:  'secondary',
    draft:     'secondary',
    archived:  'secondary',
    free:      'secondary',
    pro:       'info',
    enterprise:'primary',
    economy:   'secondary',
    standard:  'info',
    premium:   'primary',
    luxury:    'warning',
  };
  return map[status.toLowerCase()] ?? 'secondary';
}

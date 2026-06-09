import { useState, useEffect } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { useForm } from 'react-hook-form';
import {
  KeyIcon,
  EnvelopeIcon,
  ShieldCheckIcon,
  BoltIcon,
  ExclamationTriangleIcon,
  EyeIcon,
  EyeSlashIcon,
  CheckCircleIcon,
} from '@heroicons/react/24/outline';
import toast from 'react-hot-toast';
import { getSettings, updateSettings } from '../services/adminService';
import type { SystemSettings } from '../types';
import { cn } from '../utils/helpers';

interface SectionProps {
  icon: React.ComponentType<{ className?: string }>;
  title: string;
  description: string;
  children: React.ReactNode;
  iconColor?: string;
}

function Section({ icon: Icon, title, description, children, iconColor = 'text-primary-600' }: SectionProps) {
  return (
    <div className="card overflow-hidden">
      <div className="flex items-start gap-4 px-6 py-5 border-b border-secondary-200 dark:border-secondary-700 bg-secondary-50/50 dark:bg-secondary-900/30">
        <div className={cn('p-2 rounded-xl bg-white dark:bg-secondary-800 shadow-sm', iconColor)}>
          <Icon className="w-5 h-5" />
        </div>
        <div>
          <h2 className="text-sm font-semibold text-secondary-900 dark:text-secondary-100">{title}</h2>
          <p className="text-xs text-secondary-500 dark:text-secondary-400 mt-0.5">{description}</p>
        </div>
      </div>
      <div className="px-6 py-5 space-y-4">{children}</div>
    </div>
  );
}

function Toggle({ checked, onChange, label, description }: { checked: boolean; onChange: (v: boolean) => void; label: string; description?: string }) {
  return (
    <label className="flex items-center justify-between gap-4 cursor-pointer group">
      <div>
        <p className="text-sm font-medium text-secondary-800 dark:text-secondary-200">{label}</p>
        {description && <p className="text-xs text-secondary-500 dark:text-secondary-400 mt-0.5">{description}</p>}
      </div>
      <button
        type="button"
        role="switch"
        aria-checked={checked}
        onClick={() => onChange(!checked)}
        className={cn(
          'relative inline-flex h-6 w-11 flex-shrink-0 rounded-full border-2 border-transparent transition-colors duration-200 focus:outline-none focus:ring-2 focus:ring-primary-500 focus:ring-offset-2 dark:focus:ring-offset-secondary-900',
          checked ? 'bg-primary-600' : 'bg-secondary-300 dark:bg-secondary-600',
        )}
      >
        <span
          className={cn(
            'pointer-events-none inline-block h-5 w-5 transform rounded-full bg-white shadow transition duration-200',
            checked ? 'translate-x-5' : 'translate-x-0',
          )}
        />
      </button>
    </label>
  );
}

function SecretInput({ value, onChange, placeholder, id }: { value: string; onChange: (v: string) => void; placeholder?: string; id: string }) {
  const [show, setShow] = useState(false);
  return (
    <div className="relative">
      <input
        id={id}
        type={show ? 'text' : 'password'}
        value={value}
        onChange={(e) => onChange(e.target.value)}
        placeholder={placeholder}
        className="input pr-10 font-mono text-sm"
      />
      <button
        type="button"
        onClick={() => setShow((s) => !s)}
        className="absolute right-3 top-1/2 -translate-y-1/2 text-secondary-400 hover:text-secondary-600"
      >
        {show ? <EyeSlashIcon className="w-4 h-4" /> : <EyeIcon className="w-4 h-4" />}
      </button>
    </div>
  );
}

export default function SettingsPage() {
  const qc = useQueryClient();
  const [dirtyFields, setDirtyFields] = useState<Set<string>>(new Set());
  const [localSettings, setLocalSettings] = useState<SystemSettings | null>(null);

  const { data: settings, isLoading } = useQuery({
    queryKey: ['settings'],
    queryFn: getSettings,
  });

  useEffect(() => {
    if (settings && !localSettings) {
      setLocalSettings(settings);
    }
  }, [settings, localSettings]);

  const mutation = useMutation({
    mutationFn: updateSettings,
    onSuccess: (data) => {
      toast.success('Settings saved successfully');
      setDirtyFields(new Set());
      qc.setQueryData(['settings'], data);
    },
    onError: () => toast.error('Failed to save settings'),
  });

  const update = <K extends keyof SystemSettings>(key: K, value: SystemSettings[K]) => {
    setLocalSettings((s) => s ? { ...s, [key]: value } : s);
    setDirtyFields((d) => new Set([...d, key]));
  };

  const handleSave = () => {
    if (!localSettings) return;
    mutation.mutate(localSettings);
  };

  const s = localSettings ?? settings;

  if (isLoading || !s) {
    return (
      <div className="space-y-5 animate-pulse">
        {Array.from({ length: 4 }).map((_, i) => (
          <div key={i} className="card h-40" />
        ))}
      </div>
    );
  }

  return (
    <div className="space-y-6 animate-fade-in">
      {/* Header */}
      <div className="flex items-center justify-between flex-wrap gap-3">
        <div>
          <h1 className="page-title">Settings</h1>
          <p className="text-sm text-secondary-500 dark:text-secondary-400 mt-0.5">
            Configure system settings and integrations
          </p>
        </div>
        <div className="flex items-center gap-3">
          {dirtyFields.size > 0 && (
            <p className="text-xs text-warning-600 dark:text-warning-400 flex items-center gap-1">
              <ExclamationTriangleIcon className="w-3.5 h-3.5" />
              {dirtyFields.size} unsaved change{dirtyFields.size > 1 ? 's' : ''}
            </p>
          )}
          <button
            onClick={handleSave}
            disabled={mutation.isPending || dirtyFields.size === 0}
            className="btn-primary"
          >
            {mutation.isPending ? (
              <span className="flex items-center gap-2">
                <span className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin" />
                Saving…
              </span>
            ) : (
              <>
                <CheckCircleIcon className="w-4 h-4" />
                Save Changes
              </>
            )}
          </button>
        </div>
      </div>

      {/* API Keys */}
      <Section
        icon={KeyIcon}
        title="API Keys"
        description="Configure third-party AI and service API keys"
        iconColor="text-primary-600 dark:text-primary-400"
      >
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <label className="label" htmlFor="anthropic_key">Anthropic API Key</label>
            <SecretInput
              id="anthropic_key"
              value={s.anthropic_api_key}
              onChange={(v) => update('anthropic_api_key', v)}
              placeholder="sk-ant-…"
            />
            <p className="text-xs text-secondary-400 mt-1">Used for Claude AI house planning features</p>
          </div>
          <div>
            <label className="label" htmlFor="openai_key">OpenAI API Key</label>
            <SecretInput
              id="openai_key"
              value={s.openai_api_key}
              onChange={(v) => update('openai_api_key', v)}
              placeholder="sk-…"
            />
            <p className="text-xs text-secondary-400 mt-1">Used for image generation features</p>
          </div>
          <div>
            <label className="label" htmlFor="currency_key">Currency API Key</label>
            <SecretInput
              id="currency_key"
              value={s.currency_api_key}
              onChange={(v) => update('currency_api_key', v)}
              placeholder="Your currency API key"
            />
            <p className="text-xs text-secondary-400 mt-1">Used for real-time currency conversion</p>
          </div>
          <div>
            <label className="label" htmlFor="default_currency">Default Currency</label>
            <select
              id="default_currency"
              value={s.default_currency}
              onChange={(e) => update('default_currency', e.target.value)}
              className="input"
            >
              {['USD', 'EUR', 'GBP', 'SAR', 'AED', 'EGP', 'KWD', 'JOD'].map((c) => (
                <option key={c} value={c}>{c}</option>
              ))}
            </select>
          </div>
        </div>
      </Section>

      {/* Email config */}
      <Section
        icon={EnvelopeIcon}
        title="Email Configuration"
        description="SMTP settings for transactional emails"
        iconColor="text-accent-600 dark:text-accent-400"
      >
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <label className="label" htmlFor="smtp_host">SMTP Host</label>
            <input
              id="smtp_host"
              type="text"
              value={s.smtp_host}
              onChange={(e) => update('smtp_host', e.target.value)}
              className="input"
              placeholder="smtp.sendgrid.net"
            />
          </div>
          <div>
            <label className="label" htmlFor="smtp_port">SMTP Port</label>
            <input
              id="smtp_port"
              type="number"
              value={s.smtp_port}
              onChange={(e) => update('smtp_port', Number(e.target.value))}
              className="input"
              placeholder="587"
            />
          </div>
          <div>
            <label className="label" htmlFor="smtp_user">SMTP Username</label>
            <input
              id="smtp_user"
              type="text"
              value={s.smtp_user}
              onChange={(e) => update('smtp_user', e.target.value)}
              className="input"
            />
          </div>
          <div>
            <label className="label" htmlFor="smtp_pass">SMTP Password</label>
            <SecretInput
              id="smtp_pass"
              value={s.smtp_password}
              onChange={(v) => update('smtp_password', v)}
              placeholder="SMTP password or API key"
            />
          </div>
          <div className="md:col-span-2">
            <label className="label" htmlFor="smtp_from">From Address</label>
            <input
              id="smtp_from"
              type="email"
              value={s.smtp_from}
              onChange={(e) => update('smtp_from', e.target.value)}
              className="input"
              placeholder="noreply@aihouseplanner.com"
            />
          </div>
        </div>
      </Section>

      {/* Rate limiting */}
      <Section
        icon={BoltIcon}
        title="Rate Limiting & Quotas"
        description="Control API usage limits per user"
        iconColor="text-warning-600 dark:text-warning-400"
      >
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <label className="label" htmlFor="rate_minute">Requests per minute (per user)</label>
            <input
              id="rate_minute"
              type="number"
              value={s.rate_limit_per_minute}
              onChange={(e) => update('rate_limit_per_minute', Number(e.target.value))}
              className="input"
              min={1}
            />
          </div>
          <div>
            <label className="label" htmlFor="rate_day">Requests per day (per user)</label>
            <input
              id="rate_day"
              type="number"
              value={s.rate_limit_per_day}
              onChange={(e) => update('rate_limit_per_day', Number(e.target.value))}
              className="input"
              min={1}
            />
          </div>
          <div>
            <label className="label" htmlFor="max_free">Max projects (Free plan)</label>
            <input
              id="max_free"
              type="number"
              value={s.max_projects_free}
              onChange={(e) => update('max_projects_free', Number(e.target.value))}
              className="input"
              min={1}
            />
          </div>
          <div>
            <label className="label" htmlFor="max_pro">Max projects (Pro plan)</label>
            <input
              id="max_pro"
              type="number"
              value={s.max_projects_pro}
              onChange={(e) => update('max_projects_pro', Number(e.target.value))}
              className="input"
              min={1}
            />
          </div>
        </div>
      </Section>

      {/* Platform controls */}
      <Section
        icon={ShieldCheckIcon}
        title="Platform Controls"
        description="Manage platform availability and security settings"
        iconColor="text-success-600 dark:text-success-400"
      >
        <div className="space-y-5 divide-y divide-secondary-100 dark:divide-secondary-700">
          <Toggle
            checked={s.maintenance_mode}
            onChange={(v) => update('maintenance_mode', v)}
            label="Maintenance Mode"
            description="Show a maintenance page to all non-admin users"
          />
          <div className="pt-4">
            <Toggle
              checked={s.allow_signups}
              onChange={(v) => update('allow_signups', v)}
              label="Allow New Signups"
              description="Enable or disable new user registrations"
            />
          </div>
          <div className="pt-4">
            <Toggle
              checked={s.require_email_verification}
              onChange={(v) => update('require_email_verification', v)}
              label="Require Email Verification"
              description="Users must verify their email before accessing the platform"
            />
          </div>
        </div>

        {s.maintenance_mode && (
          <div className="mt-4 flex items-start gap-3 p-4 bg-warning-50 dark:bg-warning-900/20 rounded-xl border border-warning-200 dark:border-warning-800">
            <ExclamationTriangleIcon className="w-5 h-5 text-warning-600 flex-shrink-0 mt-0.5" />
            <div>
              <p className="text-sm font-medium text-warning-800 dark:text-warning-300">Maintenance mode is active</p>
              <p className="text-xs text-warning-600 dark:text-warning-400 mt-0.5">
                All regular users are currently seeing a maintenance page. Only admins can access the platform.
              </p>
            </div>
          </div>
        )}
      </Section>
    </div>
  );
}

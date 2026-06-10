import { useState } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { EyeIcon, EyeSlashIcon, BuildingOffice2Icon } from '@heroicons/react/24/outline';
import toast from 'react-hot-toast';
import { useAuth } from '../hooks/useAuth';
import { ThemeToggle } from '../components/ui/ThemeToggle';

const schema = z.object({
  email: z.string().email('Please enter a valid email'),
  password: z.string().min(6, 'Password must be at least 6 characters'),
});

type FormValues = z.infer<typeof schema>;

export default function LoginPage() {
  const { login } = useAuth();
  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading] = useState(false);

  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<FormValues>({ resolver: zodResolver(schema) });

  const onSubmit = async (values: FormValues) => {
    setLoading(true);
    try {
      await login(values.email, values.password);
      toast.success('Welcome back!');
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Login failed');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-secondary-950 via-secondary-900 to-primary-950 flex flex-col">
      {/* Top bar */}
      <div className="flex justify-end p-4">
        <ThemeToggle />
      </div>

      {/* Center content */}
      <div className="flex-1 flex items-center justify-center px-4">
        <div className="w-full max-w-md">
          {/* Logo */}
          <div className="text-center mb-8">
            <div className="inline-flex items-center justify-center w-16 h-16 bg-primary-600 rounded-2xl shadow-lg mb-4">
              <BuildingOffice2Icon className="w-8 h-8 text-white" />
            </div>
            <h1 className="text-2xl font-bold text-white">AI House Planner</h1>
            <p className="text-secondary-400 text-sm mt-1">Admin Console</p>
          </div>

          {/* Card */}
          <div className="bg-white dark:bg-secondary-800 rounded-2xl shadow-2xl border border-secondary-200 dark:border-secondary-700 p-8">
            <h2 className="text-xl font-semibold text-secondary-900 dark:text-secondary-100 mb-1">
              Sign in to your account
            </h2>
            <p className="text-sm text-secondary-500 dark:text-secondary-400 mb-6">
              Enter your admin credentials to continue
            </p>

            <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
              <div>
                <label className="label" htmlFor="email">Email address</label>
                <input
                  id="email"
                  type="email"
                  autoComplete="email"
                  placeholder="admin@aihouseplanner.com"
                  {...register('email')}
                  className="input"
                />
                {errors.email && (
                  <p className="mt-1 text-xs text-danger-600 dark:text-danger-400">{errors.email.message}</p>
                )}
              </div>

              <div>
                <label className="label" htmlFor="password">Password</label>
                <div className="relative">
                  <input
                    id="password"
                    type={showPassword ? 'text' : 'password'}
                    autoComplete="current-password"
                    placeholder="••••••••"
                    {...register('password')}
                    className="input pr-10"
                  />
                  <button
                    type="button"
                    onClick={() => setShowPassword((s) => !s)}
                    className="absolute right-3 top-1/2 -translate-y-1/2 text-secondary-400 hover:text-secondary-600"
                  >
                    {showPassword ? <EyeSlashIcon className="w-4 h-4" /> : <EyeIcon className="w-4 h-4" />}
                  </button>
                </div>
                {errors.password && (
                  <p className="mt-1 text-xs text-danger-600 dark:text-danger-400">{errors.password.message}</p>
                )}
              </div>

              <button
                type="submit"
                disabled={loading}
                className="btn-primary w-full justify-center py-2.5 text-sm mt-2"
              >
                {loading ? (
                  <span className="flex items-center gap-2">
                    <span className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin" />
                    Signing in…
                  </span>
                ) : (
                  'Sign in'
                )}
              </button>
            </form>

            {/* Demo hint */}
            <div className="mt-5 pt-5 border-t border-secondary-200 dark:border-secondary-700">
              <p className="text-xs text-secondary-400 text-center">
                Demo credentials: <span className="font-mono text-primary-600 dark:text-primary-400">admin@aihouseplanner.com</span> / <span className="font-mono text-primary-600 dark:text-primary-400">admin123</span>
              </p>
            </div>
          </div>

          <p className="text-center text-xs text-secondary-600 mt-6">
            © {new Date().getFullYear()} AI House Planner. All rights reserved.
          </p>
        </div>
      </div>
    </div>
  );
}

import { Fragment, useState } from 'react';
import { Link, useLocation } from 'react-router-dom';
import {
  BellIcon,
  ChevronRightIcon,
  HomeIcon,
  UserIcon,
  ArrowRightOnRectangleIcon,
} from '@heroicons/react/24/outline';
import { cn, initials, formatRelativeTime } from '../../utils/helpers';
import { ThemeToggle } from '../ui/ThemeToggle';
import { useAuth } from '../../hooks/useAuth';

const BREADCRUMB_MAP: Record<string, string> = {
  dashboard: 'Dashboard',
  users: 'Users',
  projects: 'Projects',
  analytics: 'Analytics',
  settings: 'Settings',
};

const MOCK_NOTIFICATIONS = [
  { id: '1', title: 'New user registered', time: new Date(Date.now() - 5 * 60 * 1000).toISOString(), read: false },
  { id: '2', title: 'Server CPU usage high', time: new Date(Date.now() - 30 * 60 * 1000).toISOString(), read: false },
  { id: '3', title: 'Monthly report ready', time: new Date(Date.now() - 2 * 60 * 60 * 1000).toISOString(), read: true },
  { id: '4', title: 'Payment received: $29', time: new Date(Date.now() - 4 * 60 * 60 * 1000).toISOString(), read: true },
];

export function Header() {
  const location = useLocation();
  const { user, logout } = useAuth();
  const [showNotifications, setShowNotifications] = useState(false);
  const [showProfile, setShowProfile] = useState(false);
  const [notifications, setNotifications] = useState(MOCK_NOTIFICATIONS);

  const unread = notifications.filter((n) => !n.read).length;
  const segments = location.pathname.split('/').filter(Boolean);

  const markAllRead = () => setNotifications((ns) => ns.map((n) => ({ ...n, read: true })));

  return (
    <header className="fixed top-0 right-0 left-0 z-20 h-16 bg-white dark:bg-secondary-900 border-b border-secondary-200 dark:border-secondary-700 flex items-center px-4 gap-4">
      {/* Breadcrumb */}
      <nav className="flex items-center gap-1 text-sm flex-1 min-w-0 ml-[var(--sidebar-offset,0px)]">
        <Link to="/dashboard" className="text-secondary-400 hover:text-secondary-600 flex-shrink-0">
          <HomeIcon className="w-4 h-4" />
        </Link>
        {segments.map((seg, i) => {
          const path = '/' + segments.slice(0, i + 1).join('/');
          const label = BREADCRUMB_MAP[seg] ?? seg;
          const isLast = i === segments.length - 1;
          return (
            <Fragment key={path}>
              <ChevronRightIcon className="w-3 h-3 text-secondary-300 flex-shrink-0" />
              {isLast ? (
                <span className="font-semibold text-secondary-900 dark:text-secondary-100 truncate">{label}</span>
              ) : (
                <Link to={path} className="text-secondary-500 hover:text-secondary-700 dark:text-secondary-400 truncate">
                  {label}
                </Link>
              )}
            </Fragment>
          );
        })}
      </nav>

      {/* Right side */}
      <div className="flex items-center gap-1 flex-shrink-0">
        <ThemeToggle />

        {/* Notifications */}
        <div className="relative">
          <button
            onClick={() => { setShowNotifications((s) => !s); setShowProfile(false); }}
            className="relative w-10 h-10 flex items-center justify-center rounded-xl text-secondary-500 dark:text-secondary-400 hover:bg-secondary-100 dark:hover:bg-secondary-700 transition-colors"
          >
            <BellIcon className="w-5 h-5" />
            {unread > 0 && (
              <span className="absolute top-1.5 right-1.5 w-4 h-4 bg-danger-500 text-white text-[10px] font-bold rounded-full flex items-center justify-center">
                {unread}
              </span>
            )}
          </button>

          {showNotifications && (
            <div className="absolute right-0 top-12 w-80 bg-white dark:bg-secondary-800 border border-secondary-200 dark:border-secondary-700 rounded-xl shadow-dropdown animate-fade-in z-50">
              <div className="flex items-center justify-between px-4 py-3 border-b border-secondary-100 dark:border-secondary-700">
                <h3 className="text-sm font-semibold text-secondary-900 dark:text-secondary-100">Notifications</h3>
                {unread > 0 && (
                  <button onClick={markAllRead} className="text-xs text-primary-600 dark:text-primary-400 hover:underline">
                    Mark all read
                  </button>
                )}
              </div>
              <ul className="divide-y divide-secondary-100 dark:divide-secondary-700 max-h-72 overflow-y-auto">
                {notifications.map((n) => (
                  <li
                    key={n.id}
                    className={cn(
                      'px-4 py-3 hover:bg-secondary-50 dark:hover:bg-secondary-700/50 transition-colors cursor-pointer',
                      !n.read && 'bg-primary-50/50 dark:bg-primary-900/10',
                    )}
                    onClick={() => setNotifications((ns) => ns.map((x) => x.id === n.id ? { ...x, read: true } : x))}
                  >
                    <div className="flex items-start gap-3">
                      {!n.read && <span className="mt-1.5 w-1.5 h-1.5 bg-primary-500 rounded-full flex-shrink-0" />}
                      <div className={cn('flex-1', n.read && 'pl-4')}>
                        <p className="text-sm text-secondary-800 dark:text-secondary-200">{n.title}</p>
                        <p className="text-xs text-secondary-400 mt-0.5">{formatRelativeTime(n.time)}</p>
                      </div>
                    </div>
                  </li>
                ))}
              </ul>
            </div>
          )}
        </div>

        {/* Profile menu */}
        <div className="relative">
          <button
            onClick={() => { setShowProfile((s) => !s); setShowNotifications(false); }}
            className="flex items-center gap-2 pl-1 pr-3 py-1.5 rounded-xl hover:bg-secondary-100 dark:hover:bg-secondary-700 transition-colors"
          >
            <div className="w-7 h-7 rounded-full bg-primary-600 flex items-center justify-center text-white text-xs font-bold">
              {user ? initials(user.name) : 'A'}
            </div>
            <span className="text-sm font-medium text-secondary-700 dark:text-secondary-300 hidden sm:block">
              {user?.name?.split(' ')[0] ?? 'Admin'}
            </span>
          </button>

          {showProfile && (
            <div className="absolute right-0 top-12 w-52 bg-white dark:bg-secondary-800 border border-secondary-200 dark:border-secondary-700 rounded-xl shadow-dropdown animate-fade-in z-50">
              <div className="px-4 py-3 border-b border-secondary-100 dark:border-secondary-700">
                <p className="text-sm font-medium text-secondary-900 dark:text-secondary-100">{user?.name}</p>
                <p className="text-xs text-secondary-400 mt-0.5">{user?.email}</p>
              </div>
              <ul className="p-1">
                <li>
                  <button className="w-full flex items-center gap-3 px-3 py-2 text-sm text-secondary-600 dark:text-secondary-400 hover:bg-secondary-100 dark:hover:bg-secondary-700 rounded-lg transition-colors">
                    <UserIcon className="w-4 h-4" />
                    Profile
                  </button>
                </li>
                <li>
                  <button
                    onClick={logout}
                    className="w-full flex items-center gap-3 px-3 py-2 text-sm text-danger-600 dark:text-danger-400 hover:bg-danger-50 dark:hover:bg-danger-900/20 rounded-lg transition-colors"
                  >
                    <ArrowRightOnRectangleIcon className="w-4 h-4" />
                    Logout
                  </button>
                </li>
              </ul>
            </div>
          )}
        </div>
      </div>

      {/* Close dropdowns on outside click */}
      {(showNotifications || showProfile) && (
        <div
          className="fixed inset-0 z-40"
          onClick={() => { setShowNotifications(false); setShowProfile(false); }}
        />
      )}
    </header>
  );
}

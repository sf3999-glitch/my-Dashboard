import { useState } from 'react';
import { NavLink, useLocation } from 'react-router-dom';
import {
  HomeIcon,
  UsersIcon,
  FolderIcon,
  ChartBarIcon,
  Cog6ToothIcon,
  ChevronLeftIcon,
  ChevronRightIcon,
  BuildingOffice2Icon,
  ArrowRightOnRectangleIcon,
} from '@heroicons/react/24/outline';
import { cn, initials } from '../../utils/helpers';
import { useAuth } from '../../hooks/useAuth';

interface NavItem {
  label: string;
  path: string;
  icon: React.ComponentType<{ className?: string }>;
  badge?: number;
}

const navItems: NavItem[] = [
  { label: 'Dashboard',  path: '/dashboard',  icon: HomeIcon },
  { label: 'Users',      path: '/users',       icon: UsersIcon },
  { label: 'Projects',   path: '/projects',    icon: FolderIcon },
  { label: 'Analytics',  path: '/analytics',   icon: ChartBarIcon },
  { label: 'Settings',   path: '/settings',    icon: Cog6ToothIcon },
];

interface SidebarProps {
  collapsed: boolean;
  onToggle: () => void;
}

export function Sidebar({ collapsed, onToggle }: SidebarProps) {
  const location = useLocation();
  const { user, logout } = useAuth();

  return (
    <aside
      className={cn(
        'fixed top-0 left-0 z-30 h-full flex flex-col',
        'bg-white dark:bg-secondary-900 border-r border-secondary-200 dark:border-secondary-700',
        'transition-all duration-300 ease-in-out',
        collapsed ? 'w-[72px]' : 'w-64',
      )}
    >
      {/* Logo */}
      <div className={cn(
        'flex items-center gap-3 px-4 border-b border-secondary-200 dark:border-secondary-700',
        'h-16 flex-shrink-0',
      )}>
        <div className="w-9 h-9 bg-primary-600 rounded-xl flex items-center justify-center flex-shrink-0">
          <BuildingOffice2Icon className="w-5 h-5 text-white" />
        </div>
        {!collapsed && (
          <div className="overflow-hidden">
            <p className="font-bold text-secondary-900 dark:text-secondary-50 text-sm leading-tight whitespace-nowrap">
              AI House Planner
            </p>
            <p className="text-xs text-secondary-400 dark:text-secondary-500 whitespace-nowrap">Admin Console</p>
          </div>
        )}
      </div>

      {/* Nav */}
      <nav className="flex-1 overflow-y-auto py-4 px-3 flex flex-col gap-1">
        {!collapsed && (
          <p className="text-[10px] font-semibold text-secondary-400 dark:text-secondary-600 uppercase tracking-widest px-3 mb-2">
            Navigation
          </p>
        )}
        {navItems.map((item) => {
          const isActive = location.pathname.startsWith(item.path);
          return (
            <NavLink
              key={item.path}
              to={item.path}
              title={collapsed ? item.label : undefined}
              className={cn(
                'nav-item group relative',
                isActive ? 'nav-item-active' : 'nav-item-inactive',
                collapsed && 'justify-center',
              )}
            >
              <item.icon className={cn('w-5 h-5 flex-shrink-0', isActive ? 'text-primary-600 dark:text-primary-400' : '')} />
              {!collapsed && <span className="text-sm">{item.label}</span>}
              {!collapsed && item.badge && (
                <span className="ml-auto bg-primary-600 text-white text-xs font-bold w-5 h-5 rounded-full flex items-center justify-center">
                  {item.badge}
                </span>
              )}
              {/* Active indicator bar */}
              {isActive && (
                <span className="absolute left-0 top-1/2 -translate-y-1/2 w-0.5 h-5 bg-primary-600 rounded-r-full" />
              )}
              {/* Tooltip when collapsed */}
              {collapsed && (
                <div className="absolute left-full ml-3 px-2 py-1 bg-secondary-900 dark:bg-secondary-700 text-white text-xs rounded-lg whitespace-nowrap opacity-0 group-hover:opacity-100 pointer-events-none transition-opacity z-50">
                  {item.label}
                </div>
              )}
            </NavLink>
          );
        })}
      </nav>

      {/* User profile */}
      <div className="border-t border-secondary-200 dark:border-secondary-700 p-3">
        <div className={cn('flex items-center gap-3', collapsed && 'justify-center')}>
          <div className="w-8 h-8 rounded-full bg-primary-600 flex items-center justify-center text-white text-xs font-bold flex-shrink-0">
            {user ? initials(user.name) : 'A'}
          </div>
          {!collapsed && (
            <div className="flex-1 min-w-0">
              <p className="text-sm font-medium text-secondary-900 dark:text-secondary-100 truncate">
                {user?.name ?? 'Admin'}
              </p>
              <p className="text-xs text-secondary-400 dark:text-secondary-500 truncate">
                {user?.role?.replace('_', ' ') ?? 'admin'}
              </p>
            </div>
          )}
          {!collapsed && (
            <button
              onClick={logout}
              title="Logout"
              className="p-1.5 rounded-lg text-secondary-400 hover:text-danger-500 hover:bg-danger-50 dark:hover:bg-danger-900/20 transition-colors flex-shrink-0"
            >
              <ArrowRightOnRectangleIcon className="w-4 h-4" />
            </button>
          )}
        </div>
      </div>

      {/* Collapse toggle */}
      <button
        onClick={onToggle}
        className={cn(
          'absolute -right-3 top-20 z-40',
          'w-6 h-6 rounded-full border border-secondary-300 dark:border-secondary-600',
          'bg-white dark:bg-secondary-800 shadow-sm',
          'flex items-center justify-center',
          'text-secondary-500 hover:text-secondary-700 dark:text-secondary-400',
          'transition-colors',
        )}
      >
        {collapsed ? <ChevronRightIcon className="w-3 h-3" /> : <ChevronLeftIcon className="w-3 h-3" />}
      </button>
    </aside>
  );
}

import { useState, useEffect } from 'react';
import { Outlet } from 'react-router-dom';
import { Sidebar } from './Sidebar';
import { Header } from './Header';
import { cn } from '../../utils/helpers';

export default function Layout() {
  const [collapsed, setCollapsed] = useState(() => {
    return localStorage.getItem('sidebar_collapsed') === 'true';
  });

  useEffect(() => {
    localStorage.setItem('sidebar_collapsed', String(collapsed));
  }, [collapsed]);

  const sidebarWidth = collapsed ? 72 : 256;

  return (
    <div className="min-h-screen bg-secondary-50 dark:bg-secondary-950">
      <Sidebar collapsed={collapsed} onToggle={() => setCollapsed((c) => !c)} />

      {/* Header offset handled inline */}
      <div
        className="transition-all duration-300 ease-in-out"
        style={{ paddingLeft: sidebarWidth }}
      >
        <Header />

        <main
          className={cn(
            'min-h-screen pt-16',
            'px-4 sm:px-6 lg:px-8 py-6',
          )}
        >
          <div className="max-w-screen-2xl mx-auto">
            <Outlet />
          </div>
        </main>
      </div>
    </div>
  );
}

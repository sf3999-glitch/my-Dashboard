import React, { createContext, useCallback, useEffect, useMemo, useState } from 'react';
import type { AdminUser, AuthState } from '../types';
import { adminLogin } from '../services/adminService';

interface AuthContextValue extends AuthState {
  login: (email: string, password: string) => Promise<void>;
  logout: () => void;
}

export const AuthContext = createContext<AuthContextValue | null>(null);

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [state, setState] = useState<AuthState>({
    user: null,
    token: null,
    isAuthenticated: false,
    isLoading: true,
  });

  // Restore session from localStorage on mount
  useEffect(() => {
    const token = localStorage.getItem('admin_token');
    const userStr = localStorage.getItem('admin_user');
    if (token && userStr) {
      try {
        const user: AdminUser = JSON.parse(userStr);
        setState({ user, token, isAuthenticated: true, isLoading: false });
      } catch {
        localStorage.removeItem('admin_token');
        localStorage.removeItem('admin_user');
        setState((s) => ({ ...s, isLoading: false }));
      }
    } else {
      setState((s) => ({ ...s, isLoading: false }));
    }
  }, []);

  const login = useCallback(async (email: string, password: string) => {
    const result = await adminLogin(email, password);
    const user: AdminUser = result.user;
    localStorage.setItem('admin_token', result.token);
    localStorage.setItem('admin_user', JSON.stringify(user));
    setState({ user, token: result.token, isAuthenticated: true, isLoading: false });
  }, []);

  const logout = useCallback(() => {
    localStorage.removeItem('admin_token');
    localStorage.removeItem('admin_user');
    setState({ user: null, token: null, isAuthenticated: false, isLoading: false });
  }, []);

  const value = useMemo<AuthContextValue>(
    () => ({ ...state, login, logout }),
    [state, login, logout],
  );

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

import { useState } from 'react';
import {
  ChevronUpIcon,
  ChevronDownIcon,
  ChevronLeftIcon,
  ChevronRightIcon,
  MagnifyingGlassIcon,
} from '@heroicons/react/24/outline';
import { cn } from '../../utils/helpers';
import type { SortConfig, TableColumn } from '../../types';

interface DataTableProps<T extends { id: string }> {
  columns: TableColumn<T>[];
  data: T[];
  total: number;
  page: number;
  perPage: number;
  onPageChange: (page: number) => void;
  onSort?: (key: string, dir: 'asc' | 'desc') => void;
  sortConfig?: SortConfig;
  searchValue?: string;
  onSearch?: (value: string) => void;
  searchPlaceholder?: string;
  loading?: boolean;
  selectedIds?: Set<string>;
  onSelectAll?: (checked: boolean) => void;
  onSelectRow?: (id: string, checked: boolean) => void;
  emptyMessage?: string;
  actions?: React.ReactNode;
}

function SkeletonRow({ cols }: { cols: number }) {
  return (
    <tr>
      {Array.from({ length: cols }).map((_, i) => (
        <td key={i} className="px-4 py-3">
          <div className="skeleton h-4 rounded w-3/4" />
        </td>
      ))}
    </tr>
  );
}

export function DataTable<T extends { id: string }>({
  columns,
  data,
  total,
  page,
  perPage,
  onPageChange,
  onSort,
  sortConfig,
  searchValue,
  onSearch,
  searchPlaceholder = 'Search…',
  loading,
  selectedIds,
  onSelectAll,
  onSelectRow,
  emptyMessage = 'No data found',
  actions,
}: DataTableProps<T>) {
  const totalPages = Math.max(1, Math.ceil(total / perPage));
  const showSelection = Boolean(onSelectAll && onSelectRow);

  const handleSort = (col: TableColumn<T>) => {
    if (!col.sortable || !onSort) return;
    const key = String(col.key);
    const current = sortConfig?.key === key ? sortConfig.direction : 'asc';
    onSort(key, current === 'asc' ? 'desc' : 'asc');
  };

  const allChecked = showSelection && data.length > 0 && data.every((r) => selectedIds?.has(r.id));
  const someChecked = showSelection && !allChecked && data.some((r) => selectedIds?.has(r.id));

  const start = (page - 1) * perPage + 1;
  const end = Math.min(page * perPage, total);

  return (
    <div className="card overflow-hidden">
      {/* Toolbar */}
      {(onSearch || actions) && (
        <div className="flex flex-col sm:flex-row items-start sm:items-center gap-3 px-4 py-3 border-b border-secondary-200 dark:border-secondary-700">
          {onSearch && (
            <div className="relative flex-1 min-w-0 max-w-xs">
              <MagnifyingGlassIcon className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-secondary-400" />
              <input
                type="text"
                value={searchValue}
                onChange={(e) => onSearch(e.target.value)}
                placeholder={searchPlaceholder}
                className="input pl-9 py-1.5 text-sm"
              />
            </div>
          )}
          {actions && <div className="flex items-center gap-2 ml-auto">{actions}</div>}
        </div>
      )}

      {/* Table */}
      <div className="overflow-x-auto">
        <table className="w-full">
          <thead>
            <tr>
              {showSelection && (
                <th className="table-head w-10">
                  <input
                    type="checkbox"
                    checked={allChecked}
                    ref={(el) => { if (el) el.indeterminate = someChecked; }}
                    onChange={(e) => onSelectAll?.(e.target.checked)}
                    className="rounded border-secondary-300 text-primary-600 focus:ring-primary-500 cursor-pointer"
                  />
                </th>
              )}
              {columns.map((col) => (
                <th
                  key={String(col.key)}
                  className={cn('table-head', col.sortable && 'cursor-pointer select-none', col.className)}
                  onClick={() => handleSort(col)}
                >
                  <div className="flex items-center gap-1">
                    {col.label}
                    {col.sortable && sortConfig?.key === String(col.key) ? (
                      sortConfig.direction === 'asc' ? (
                        <ChevronUpIcon className="w-3 h-3 text-primary-500" />
                      ) : (
                        <ChevronDownIcon className="w-3 h-3 text-primary-500" />
                      )
                    ) : col.sortable ? (
                      <span className="opacity-0 group-hover:opacity-100">
                        <ChevronUpIcon className="w-3 h-3 text-secondary-300" />
                      </span>
                    ) : null}
                  </div>
                </th>
              ))}
            </tr>
          </thead>
          <tbody>
            {loading ? (
              Array.from({ length: 6 }).map((_, i) => (
                <SkeletonRow key={i} cols={columns.length + (showSelection ? 1 : 0)} />
              ))
            ) : data.length === 0 ? (
              <tr>
                <td
                  colSpan={columns.length + (showSelection ? 1 : 0)}
                  className="text-center py-16 text-secondary-400 dark:text-secondary-500 text-sm"
                >
                  {emptyMessage}
                </td>
              </tr>
            ) : (
              data.map((row) => (
                <tr
                  key={row.id}
                  className="hover:bg-secondary-50 dark:hover:bg-secondary-700/30 transition-colors"
                >
                  {showSelection && (
                    <td className="table-cell w-10">
                      <input
                        type="checkbox"
                        checked={selectedIds?.has(row.id) ?? false}
                        onChange={(e) => onSelectRow?.(row.id, e.target.checked)}
                        className="rounded border-secondary-300 text-primary-600 focus:ring-primary-500 cursor-pointer"
                      />
                    </td>
                  )}
                  {columns.map((col) => (
                    <td key={String(col.key)} className={cn('table-cell', col.className)}>
                      {col.render
                        ? col.render(row[col.key as keyof T] as unknown, row)
                        : String(row[col.key as keyof T] ?? '—')}
                    </td>
                  ))}
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>

      {/* Pagination */}
      <div className="flex flex-col sm:flex-row items-center justify-between gap-3 px-4 py-3 border-t border-secondary-200 dark:border-secondary-700">
        <p className="text-xs text-secondary-500 dark:text-secondary-400">
          {total > 0 ? `Showing ${start}–${end} of ${total.toLocaleString()} results` : 'No results'}
        </p>
        <div className="flex items-center gap-1">
          <button
            onClick={() => onPageChange(1)}
            disabled={page === 1}
            className="btn-ghost px-2 py-1 text-xs disabled:opacity-40"
          >
            «
          </button>
          <button
            onClick={() => onPageChange(page - 1)}
            disabled={page === 1}
            className="btn-ghost px-2 py-1 disabled:opacity-40"
          >
            <ChevronLeftIcon className="w-4 h-4" />
          </button>

          {Array.from({ length: Math.min(5, totalPages) }, (_, i) => {
            let p: number;
            if (totalPages <= 5) {
              p = i + 1;
            } else if (page <= 3) {
              p = i + 1;
            } else if (page >= totalPages - 2) {
              p = totalPages - 4 + i;
            } else {
              p = page - 2 + i;
            }
            return (
              <button
                key={p}
                onClick={() => onPageChange(p)}
                className={cn(
                  'w-8 h-8 text-xs font-medium rounded-lg transition-colors',
                  p === page
                    ? 'bg-primary-600 text-white'
                    : 'text-secondary-600 dark:text-secondary-400 hover:bg-secondary-100 dark:hover:bg-secondary-700',
                )}
              >
                {p}
              </button>
            );
          })}

          <button
            onClick={() => onPageChange(page + 1)}
            disabled={page === totalPages}
            className="btn-ghost px-2 py-1 disabled:opacity-40"
          >
            <ChevronRightIcon className="w-4 h-4" />
          </button>
          <button
            onClick={() => onPageChange(totalPages)}
            disabled={page === totalPages}
            className="btn-ghost px-2 py-1 text-xs disabled:opacity-40"
          >
            »
          </button>
        </div>
      </div>
    </div>
  );
}

import { useState, useCallback } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import {
  ArrowDownTrayIcon,
  TrashIcon,
  EyeIcon,
  FunnelIcon,
} from '@heroicons/react/24/outline';
import toast from 'react-hot-toast';
import { DataTable } from '../components/ui/DataTable';
import { Badge, statusBadgeVariant } from '../components/ui/Badge';
import { Modal, ConfirmModal } from '../components/ui/Modal';
import { getProjects, deleteProject } from '../services/adminService';
import {
  formatDate,
  formatCurrency,
  exportCSV,
  countryFlag,
  capitalize,
  cn,
} from '../utils/helpers';
import type { Project, SortConfig } from '../types';

export default function ProjectsPage() {
  const qc = useQueryClient();
  const [page, setPage] = useState(1);
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState('all');
  const [sortConfig, setSortConfig] = useState<SortConfig>({ key: 'created_at', direction: 'desc' });
  const [showFilters, setShowFilters] = useState(false);

  const [viewProject, setViewProject] = useState<Project | null>(null);
  const [deleteTarget, setDeleteTarget] = useState<Project | null>(null);

  const { data, isLoading } = useQuery({
    queryKey: ['projects', page, search, statusFilter, sortConfig],
    queryFn: () =>
      getProjects({
        page,
        per_page: 10,
        search,
        status: statusFilter,
        sort_by: sortConfig.key,
        sort_dir: sortConfig.direction,
      }),
    placeholderData: (prev) => prev,
  });

  const deleteMutation = useMutation({
    mutationFn: deleteProject,
    onSuccess: () => {
      toast.success('Project deleted');
      qc.invalidateQueries({ queryKey: ['projects'] });
      setDeleteTarget(null);
    },
    onError: () => toast.error('Failed to delete project'),
  });

  const handleSearch = useCallback((v: string) => { setSearch(v); setPage(1); }, []);

  const handleExport = () => {
    const rows = data?.data ?? [];
    exportCSV(rows as unknown as Record<string, unknown>[], 'projects', [
      { key: 'name' as keyof Project, label: 'Name' },
      { key: 'user_name' as keyof Project, label: 'User' },
      { key: 'country' as keyof Project, label: 'Country' },
      { key: 'floors' as keyof Project, label: 'Floors' },
      { key: 'house_style' as keyof Project, label: 'Style' },
      { key: 'construction_quality' as keyof Project, label: 'Quality' },
      { key: 'estimated_cost' as keyof Project, label: 'Est. Cost' },
      { key: 'status' as keyof Project, label: 'Status' },
      { key: 'created_at' as keyof Project, label: 'Created' },
    ]);
    toast.success('CSV exported');
  };

  const columns = [
    {
      key: 'name' as keyof Project,
      label: 'Project',
      sortable: true,
      render: (_: unknown, row: Project) => (
        <div className="min-w-0">
          <p className="font-medium text-secondary-900 dark:text-secondary-100 truncate max-w-[160px]">{row.name}</p>
          <p className="text-xs text-secondary-400 truncate">{row.house_style} · {row.total_area} m²</p>
        </div>
      ),
    },
    {
      key: 'user_name' as keyof Project,
      label: 'Owner',
      render: (_: unknown, row: Project) => (
        <div className="min-w-0">
          <p className="text-sm text-secondary-800 dark:text-secondary-200 truncate max-w-[140px]">{row.user_name}</p>
          <p className="text-xs text-secondary-400 truncate">{row.user_email}</p>
        </div>
      ),
    },
    {
      key: 'country' as keyof Project,
      label: 'Country',
      render: (_: unknown, row: Project) => (
        <span className="flex items-center gap-1.5 text-sm">
          {countryFlag(row.country_code)} {row.country}
        </span>
      ),
    },
    {
      key: 'floors' as keyof Project,
      label: 'Floors',
      sortable: true,
      render: (v: unknown) => <span className="tabular-nums font-medium">{String(v)}</span>,
    },
    {
      key: 'construction_quality' as keyof Project,
      label: 'Quality',
      render: (v: unknown) => (
        <Badge variant={statusBadgeVariant(String(v))}>{capitalize(String(v))}</Badge>
      ),
    },
    {
      key: 'estimated_cost' as keyof Project,
      label: 'Est. Cost',
      sortable: true,
      render: (v: unknown) => (
        <span className="font-medium tabular-nums">{formatCurrency(Number(v), 'USD', true)}</span>
      ),
    },
    {
      key: 'status' as keyof Project,
      label: 'Status',
      sortable: true,
      render: (v: unknown) => (
        <Badge variant={statusBadgeVariant(String(v))} dot>{capitalize(String(v))}</Badge>
      ),
    },
    {
      key: 'created_at' as keyof Project,
      label: 'Created',
      sortable: true,
      render: (v: unknown) => (
        <span className="text-xs text-secondary-400">{formatDate(String(v))}</span>
      ),
    },
    {
      key: 'id' as keyof Project,
      label: 'Actions',
      render: (_: unknown, row: Project) => (
        <div className="flex items-center gap-1">
          <button onClick={() => setViewProject(row)} className="btn-ghost p-1.5" title="View">
            <EyeIcon className="w-4 h-4" />
          </button>
          <button onClick={() => setDeleteTarget(row)} className="btn-ghost p-1.5 text-danger-500" title="Delete">
            <TrashIcon className="w-4 h-4" />
          </button>
        </div>
      ),
    },
  ];

  return (
    <div className="space-y-5 animate-fade-in">
      <div className="flex items-center justify-between flex-wrap gap-3">
        <div>
          <h1 className="page-title">Projects</h1>
          <p className="text-sm text-secondary-500 dark:text-secondary-400 mt-0.5">
            {data ? `${data.total.toLocaleString()} total projects` : 'Manage house planning projects'}
          </p>
        </div>
        <div className="flex items-center gap-2">
          <button onClick={() => setShowFilters((s) => !s)} className={cn('btn-secondary', showFilters && 'ring-2 ring-primary-500')}>
            <FunnelIcon className="w-4 h-4" />
            Filters
          </button>
          <button onClick={handleExport} className="btn-secondary">
            <ArrowDownTrayIcon className="w-4 h-4" />
            Export CSV
          </button>
        </div>
      </div>

      {showFilters && (
        <div className="card p-4 flex flex-wrap gap-3 animate-slide-in">
          <div className="flex flex-col gap-1">
            <label className="label">Status</label>
            <select
              value={statusFilter}
              onChange={(e) => { setStatusFilter(e.target.value); setPage(1); }}
              className="input text-sm py-1.5 w-36"
            >
              <option value="all">All statuses</option>
              <option value="draft">Draft</option>
              <option value="active">Active</option>
              <option value="completed">Completed</option>
              <option value="archived">Archived</option>
            </select>
          </div>
          <div className="flex items-end">
            <button
              onClick={() => { setStatusFilter('all'); setSearch(''); setPage(1); }}
              className="btn-ghost text-sm"
            >
              Clear filters
            </button>
          </div>
        </div>
      )}

      <DataTable
        columns={columns}
        data={data?.data ?? []}
        total={data?.total ?? 0}
        page={page}
        perPage={10}
        onPageChange={setPage}
        onSort={(key, dir) => setSortConfig({ key, direction: dir })}
        sortConfig={sortConfig}
        searchValue={search}
        onSearch={handleSearch}
        searchPlaceholder="Search by project or owner…"
        loading={isLoading}
        emptyMessage="No projects found"
      />

      {/* View modal */}
      <Modal
        isOpen={!!viewProject}
        onClose={() => setViewProject(null)}
        title="Project Details"
        size="xl"
        footer={<button onClick={() => setViewProject(null)} className="btn-secondary">Close</button>}
      >
        {viewProject && (
          <div className="space-y-4">
            <div className="flex items-start justify-between gap-4">
              <div>
                <h3 className="text-lg font-bold text-secondary-900 dark:text-secondary-100">{viewProject.name}</h3>
                <p className="text-sm text-secondary-500 mt-0.5">{viewProject.house_style} · {viewProject.total_area} m²</p>
              </div>
              <div className="flex gap-2">
                <Badge variant={statusBadgeVariant(viewProject.status)} dot>{capitalize(viewProject.status)}</Badge>
                <Badge variant={statusBadgeVariant(viewProject.construction_quality)}>{capitalize(viewProject.construction_quality)}</Badge>
              </div>
            </div>

            <div className="grid grid-cols-2 md:grid-cols-3 gap-3">
              {[
                ['Owner', viewProject.user_name],
                ['Email', viewProject.user_email],
                ['Country', `${countryFlag(viewProject.country_code)} ${viewProject.country}`],
                ['Floors', viewProject.floors],
                ['Total Area', `${viewProject.total_area} m²`],
                ['Estimated Cost', formatCurrency(viewProject.estimated_cost)],
                ['AI Interactions', viewProject.ai_interactions],
                ['Created', formatDate(viewProject.created_at)],
                ['Last Updated', formatDate(viewProject.updated_at)],
              ].map(([label, value]) => (
                <div key={String(label)} className="bg-secondary-50 dark:bg-secondary-900/50 rounded-lg p-3">
                  <p className="text-xs text-secondary-400 mb-0.5">{label}</p>
                  <p className="font-medium text-secondary-800 dark:text-secondary-200 text-sm">{String(value)}</p>
                </div>
              ))}
            </div>
          </div>
        )}
      </Modal>

      {/* Delete confirm */}
      <ConfirmModal
        isOpen={!!deleteTarget}
        onClose={() => setDeleteTarget(null)}
        onConfirm={() => deleteTarget && deleteMutation.mutate(deleteTarget.id)}
        title="Delete Project"
        message={`Are you sure you want to delete "${deleteTarget?.name}"? This cannot be undone.`}
        confirmLabel="Delete Project"
        loading={deleteMutation.isPending}
      />
    </div>
  );
}

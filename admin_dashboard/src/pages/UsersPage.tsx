import { useState, useCallback } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import {
  ArrowDownTrayIcon,
  FunnelIcon,
  TrashIcon,
  PencilSquareIcon,
  NoSymbolIcon,
  CheckCircleIcon,
  EyeIcon,
} from '@heroicons/react/24/outline';
import toast from 'react-hot-toast';
import { DataTable } from '../components/ui/DataTable';
import { Badge, statusBadgeVariant } from '../components/ui/Badge';
import { Modal, ConfirmModal } from '../components/ui/Modal';
import {
  getUsers,
  deleteUser,
  suspendUser,
  activateUser,
  updateUser,
} from '../services/adminService';
import {
  formatDate,
  formatCurrency,
  formatRelativeTime,
  exportCSV,
  countryFlag,
  initials,
  cn,
} from '../utils/helpers';
import type { AppUser, SortConfig } from '../types';

type ActionType = 'view' | 'edit' | 'delete' | 'suspend' | 'activate';

const PLAN_LABELS: Record<string, string> = { free: 'Free', pro: 'Pro', enterprise: 'Enterprise' };

export default function UsersPage() {
  const qc = useQueryClient();
  const [page, setPage] = useState(1);
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState('all');
  const [planFilter, setPlanFilter] = useState('all');
  const [sortConfig, setSortConfig] = useState<SortConfig>({ key: 'joined_at', direction: 'desc' });
  const [selectedIds, setSelectedIds] = useState<Set<string>>(new Set());
  const [showFilters, setShowFilters] = useState(false);

  const [activeUser, setActiveUser] = useState<AppUser | null>(null);
  const [actionType, setActionType] = useState<ActionType | null>(null);

  const { data, isLoading } = useQuery({
    queryKey: ['users', page, search, statusFilter, planFilter, sortConfig],
    queryFn: () =>
      getUsers({
        page,
        per_page: 10,
        search,
        status: statusFilter,
        plan: planFilter,
        sort_by: sortConfig.key,
        sort_dir: sortConfig.direction,
      }),
    placeholderData: (prev) => prev,
  });

  const deleteMutation = useMutation({
    mutationFn: deleteUser,
    onSuccess: () => {
      toast.success('User deleted');
      qc.invalidateQueries({ queryKey: ['users'] });
      closeModal();
    },
    onError: () => toast.error('Failed to delete user'),
  });

  const suspendMutation = useMutation({
    mutationFn: suspendUser,
    onSuccess: () => {
      toast.success('User suspended');
      qc.invalidateQueries({ queryKey: ['users'] });
      closeModal();
    },
  });

  const activateMutation = useMutation({
    mutationFn: activateUser,
    onSuccess: () => {
      toast.success('User activated');
      qc.invalidateQueries({ queryKey: ['users'] });
      closeModal();
    },
  });

  const closeModal = () => { setActiveUser(null); setActionType(null); };

  const openAction = (user: AppUser, type: ActionType) => {
    setActiveUser(user);
    setActionType(type);
  };

  const handleSearch = useCallback((v: string) => {
    setSearch(v);
    setPage(1);
  }, []);

  const handleExport = () => {
    const rows = data?.data ?? [];
    exportCSV(rows as unknown as Record<string, unknown>[], 'users', [
      { key: 'name' as keyof AppUser, label: 'Name' },
      { key: 'email' as keyof AppUser, label: 'Email' },
      { key: 'country' as keyof AppUser, label: 'Country' },
      { key: 'status' as keyof AppUser, label: 'Status' },
      { key: 'plan' as keyof AppUser, label: 'Plan' },
      { key: 'projects_count' as keyof AppUser, label: 'Projects' },
      { key: 'joined_at' as keyof AppUser, label: 'Joined' },
    ]);
    toast.success('CSV exported');
  };

  const handleBulkDelete = async () => {
    for (const id of selectedIds) {
      await deleteUser(id);
    }
    toast.success(`${selectedIds.size} users deleted`);
    setSelectedIds(new Set());
    qc.invalidateQueries({ queryKey: ['users'] });
  };

  const columns = [
    {
      key: 'name' as keyof AppUser,
      label: 'User',
      sortable: true,
      render: (_: unknown, row: AppUser) => (
        <div className="flex items-center gap-3">
          <div className="w-8 h-8 rounded-full bg-primary-100 dark:bg-primary-900/40 flex items-center justify-center text-primary-700 dark:text-primary-300 text-xs font-bold flex-shrink-0">
            {initials(row.name)}
          </div>
          <div className="min-w-0">
            <p className="font-medium text-secondary-900 dark:text-secondary-100 truncate">{row.name}</p>
            <p className="text-xs text-secondary-400 truncate">{row.email}</p>
          </div>
        </div>
      ),
    },
    {
      key: 'country' as keyof AppUser,
      label: 'Country',
      sortable: true,
      render: (_: unknown, row: AppUser) => (
        <span className="flex items-center gap-1.5 text-sm">
          <span>{countryFlag(row.country_code)}</span>
          <span>{row.country}</span>
        </span>
      ),
    },
    {
      key: 'projects_count' as keyof AppUser,
      label: 'Projects',
      sortable: true,
      render: (v: unknown) => (
        <span className="font-medium tabular-nums">{String(v)}</span>
      ),
    },
    {
      key: 'plan' as keyof AppUser,
      label: 'Plan',
      render: (v: unknown) => (
        <Badge variant={statusBadgeVariant(String(v))}>{PLAN_LABELS[String(v)] ?? String(v)}</Badge>
      ),
    },
    {
      key: 'status' as keyof AppUser,
      label: 'Status',
      sortable: true,
      render: (v: unknown) => (
        <Badge variant={statusBadgeVariant(String(v))} dot>
          {String(v).charAt(0).toUpperCase() + String(v).slice(1)}
        </Badge>
      ),
    },
    {
      key: 'joined_at' as keyof AppUser,
      label: 'Joined',
      sortable: true,
      render: (v: unknown) => (
        <span className="text-secondary-500 dark:text-secondary-400 text-xs">{formatDate(String(v))}</span>
      ),
    },
    {
      key: 'id' as keyof AppUser,
      label: 'Actions',
      render: (_: unknown, row: AppUser) => (
        <div className="flex items-center gap-1">
          <button onClick={() => openAction(row, 'view')} title="View" className="btn-ghost p-1.5">
            <EyeIcon className="w-4 h-4" />
          </button>
          <button onClick={() => openAction(row, 'edit')} title="Edit" className="btn-ghost p-1.5">
            <PencilSquareIcon className="w-4 h-4" />
          </button>
          {row.status === 'suspended' ? (
            <button onClick={() => openAction(row, 'activate')} title="Activate" className="btn-ghost p-1.5 text-success-600">
              <CheckCircleIcon className="w-4 h-4" />
            </button>
          ) : (
            <button onClick={() => openAction(row, 'suspend')} title="Suspend" className="btn-ghost p-1.5 text-warning-600">
              <NoSymbolIcon className="w-4 h-4" />
            </button>
          )}
          <button onClick={() => openAction(row, 'delete')} title="Delete" className="btn-ghost p-1.5 text-danger-500">
            <TrashIcon className="w-4 h-4" />
          </button>
        </div>
      ),
    },
  ];

  return (
    <div className="space-y-5 animate-fade-in">
      {/* Header */}
      <div className="flex items-center justify-between flex-wrap gap-3">
        <div>
          <h1 className="page-title">Users</h1>
          <p className="text-sm text-secondary-500 dark:text-secondary-400 mt-0.5">
            {data ? `${data.total.toLocaleString()} total users` : 'Manage user accounts'}
          </p>
        </div>
        <div className="flex items-center gap-2">
          {selectedIds.size > 0 && (
            <button onClick={handleBulkDelete} className="btn-danger">
              <TrashIcon className="w-4 h-4" />
              Delete {selectedIds.size}
            </button>
          )}
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

      {/* Filters */}
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
              <option value="active">Active</option>
              <option value="suspended">Suspended</option>
              <option value="pending">Pending</option>
              <option value="inactive">Inactive</option>
            </select>
          </div>
          <div className="flex flex-col gap-1">
            <label className="label">Plan</label>
            <select
              value={planFilter}
              onChange={(e) => { setPlanFilter(e.target.value); setPage(1); }}
              className="input text-sm py-1.5 w-36"
            >
              <option value="all">All plans</option>
              <option value="free">Free</option>
              <option value="pro">Pro</option>
              <option value="enterprise">Enterprise</option>
            </select>
          </div>
          <div className="flex items-end">
            <button
              onClick={() => { setStatusFilter('all'); setPlanFilter('all'); setSearch(''); setPage(1); }}
              className="btn-ghost text-sm"
            >
              Clear filters
            </button>
          </div>
        </div>
      )}

      {/* Table */}
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
        searchPlaceholder="Search by name or email…"
        loading={isLoading}
        selectedIds={selectedIds}
        onSelectAll={(checked) => {
          if (checked) setSelectedIds(new Set(data?.data.map((u) => u.id) ?? []));
          else setSelectedIds(new Set());
        }}
        onSelectRow={(id, checked) => {
          setSelectedIds((prev) => {
            const next = new Set(prev);
            if (checked) next.add(id);
            else next.delete(id);
            return next;
          });
        }}
        emptyMessage="No users found matching your filters"
      />

      {/* View modal */}
      <Modal
        isOpen={actionType === 'view' && !!activeUser}
        onClose={closeModal}
        title="User Details"
        size="lg"
        footer={<button onClick={closeModal} className="btn-secondary">Close</button>}
      >
        {activeUser && (
          <div className="space-y-4">
            <div className="flex items-center gap-4">
              <div className="w-14 h-14 rounded-full bg-primary-100 dark:bg-primary-900/40 flex items-center justify-center text-primary-700 dark:text-primary-300 text-lg font-bold">
                {initials(activeUser.name)}
              </div>
              <div>
                <p className="text-lg font-semibold text-secondary-900 dark:text-secondary-100">{activeUser.name}</p>
                <p className="text-sm text-secondary-500">{activeUser.email}</p>
                <div className="flex items-center gap-2 mt-1">
                  <Badge variant={statusBadgeVariant(activeUser.status)} dot>{activeUser.status}</Badge>
                  <Badge variant={statusBadgeVariant(activeUser.plan)}>{activeUser.plan}</Badge>
                </div>
              </div>
            </div>
            <div className="grid grid-cols-2 gap-3 text-sm">
              {[
                ['Country', `${countryFlag(activeUser.country_code)} ${activeUser.country}`],
                ['Projects', activeUser.projects_count],
                ['Total Spent', formatCurrency(activeUser.total_spent)],
                ['Joined', formatDate(activeUser.joined_at)],
                ['Last Active', formatRelativeTime(activeUser.last_active_at)],
                ['User ID', activeUser.id],
              ].map(([label, value]) => (
                <div key={String(label)} className="bg-secondary-50 dark:bg-secondary-900/50 rounded-lg p-3">
                  <p className="text-xs text-secondary-400 mb-0.5">{label}</p>
                  <p className="font-medium text-secondary-800 dark:text-secondary-200">{String(value)}</p>
                </div>
              ))}
            </div>
          </div>
        )}
      </Modal>

      {/* Edit modal */}
      <Modal
        isOpen={actionType === 'edit' && !!activeUser}
        onClose={closeModal}
        title="Edit User"
        size="md"
        footer={
          <>
            <button onClick={closeModal} className="btn-secondary">Cancel</button>
            <button
              onClick={async () => {
                if (!activeUser) return;
                await updateUser(activeUser.id, { status: activeUser.status });
                toast.success('User updated');
                qc.invalidateQueries({ queryKey: ['users'] });
                closeModal();
              }}
              className="btn-primary"
            >
              Save changes
            </button>
          </>
        }
      >
        {activeUser && (
          <div className="space-y-3">
            <div>
              <label className="label">Name</label>
              <input
                defaultValue={activeUser.name}
                className="input"
                onChange={(e) => setActiveUser((u) => u ? { ...u, name: e.target.value } : u)}
              />
            </div>
            <div>
              <label className="label">Status</label>
              <select
                value={activeUser.status}
                onChange={(e) => setActiveUser((u) => u ? { ...u, status: e.target.value as AppUser['status'] } : u)}
                className="input"
              >
                <option value="active">Active</option>
                <option value="suspended">Suspended</option>
                <option value="inactive">Inactive</option>
                <option value="pending">Pending</option>
              </select>
            </div>
            <div>
              <label className="label">Plan</label>
              <select
                value={activeUser.plan}
                onChange={(e) => setActiveUser((u) => u ? { ...u, plan: e.target.value as AppUser['plan'] } : u)}
                className="input"
              >
                <option value="free">Free</option>
                <option value="pro">Pro</option>
                <option value="enterprise">Enterprise</option>
              </select>
            </div>
          </div>
        )}
      </Modal>

      {/* Delete confirm */}
      <ConfirmModal
        isOpen={actionType === 'delete' && !!activeUser}
        onClose={closeModal}
        onConfirm={() => activeUser && deleteMutation.mutate(activeUser.id)}
        title="Delete User"
        message={`Are you sure you want to permanently delete ${activeUser?.name}? This action cannot be undone.`}
        confirmLabel="Delete User"
        loading={deleteMutation.isPending}
      />

      {/* Suspend confirm */}
      <ConfirmModal
        isOpen={actionType === 'suspend' && !!activeUser}
        onClose={closeModal}
        onConfirm={() => activeUser && suspendMutation.mutate(activeUser.id)}
        title="Suspend User"
        message={`Suspend ${activeUser?.name}? They will lose access to the platform.`}
        confirmLabel="Suspend"
        variant="danger"
        loading={suspendMutation.isPending}
      />

      {/* Activate confirm */}
      <ConfirmModal
        isOpen={actionType === 'activate' && !!activeUser}
        onClose={closeModal}
        onConfirm={() => activeUser && activateMutation.mutate(activeUser.id)}
        title="Activate User"
        message={`Restore access for ${activeUser?.name}?`}
        confirmLabel="Activate"
        variant="primary"
        loading={activateMutation.isPending}
      />
    </div>
  );
}

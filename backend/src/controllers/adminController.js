'use strict';

const { Op, fn, col, literal } = require('sequelize');
const { sequelize } = require('../config/database');
const { User, Project, Report } = require('../models');
const logger = require('../config/logger');

// ─────────────────────────────────────────────
// GET /api/admin/users
// ─────────────────────────────────────────────
const getAllUsers = async (req, res) => {
  const { page = 1, limit = 20, search, role, is_active, sort = 'created_at', order = 'DESC' } = req.query;
  const offset = (parseInt(page) - 1) * parseInt(limit);

  const where = {};
  if (search) {
    where[Op.or] = [
      { name: { [Op.iLike]: `%${search}%` } },
      { email: { [Op.iLike]: `%${search}%` } }
    ];
  }
  if (role) where.role = role;
  if (is_active !== undefined) where.is_active = is_active === 'true';

  const allowedSorts = ['name', 'email', 'created_at', 'last_login', 'login_count', 'role'];
  const sortField = allowedSorts.includes(sort) ? sort : 'created_at';
  const sortOrder = order.toUpperCase() === 'ASC' ? 'ASC' : 'DESC';

  const { count, rows } = await User.findAndCountAll({
    where,
    limit: Math.min(parseInt(limit), 100),
    offset,
    order: [[sortField, sortOrder]],
    attributes: {
      exclude: ['password_hash', 'email_verify_token', 'password_reset_token', 'refresh_token']
    }
  });

  return res.json({
    success: true,
    data: {
      users: rows,
      pagination: {
        total: count,
        page: parseInt(page),
        limit: parseInt(limit),
        pages: Math.ceil(count / parseInt(limit))
      }
    }
  });
};

// ─────────────────────────────────────────────
// GET /api/admin/users/:id
// ─────────────────────────────────────────────
const getUserById = async (req, res) => {
  const user = await User.findByPk(req.params.id, {
    attributes: { exclude: ['password_hash', 'email_verify_token', 'password_reset_token', 'refresh_token'] },
    include: [
      {
        model: Project,
        as: 'projects',
        attributes: ['id', 'name', 'status', 'country', 'estimated_total_cost', 'created_at'],
        limit: 10,
        order: [['created_at', 'DESC']]
      }
    ]
  });

  if (!user) {
    return res.status(404).json({ success: false, message: 'User not found' });
  }

  const projectCount = await Project.count({ where: { user_id: user.id } });
  const reportCount = await Report.count({ where: { user_id: user.id } });

  return res.json({
    success: true,
    data: { user, stats: { project_count: projectCount, report_count: reportCount } }
  });
};

// ─────────────────────────────────────────────
// GET /api/admin/users/stats
// ─────────────────────────────────────────────
const getUserStats = async (req, res) => {
  const [totalUsers, activeUsers, verifiedUsers, adminUsers] = await Promise.all([
    User.count(),
    User.count({ where: { is_active: true } }),
    User.count({ where: { is_verified: true } }),
    User.count({ where: { role: 'admin' } })
  ]);

  // Registration trend - last 30 days
  const thirtyDaysAgo = new Date();
  thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

  const newUsersLast30 = await User.count({
    where: { created_at: { [Op.gte]: thirtyDaysAgo } }
  });

  const byProvider = await User.findAll({
    attributes: ['provider', [fn('COUNT', col('id')), 'count']],
    group: ['provider'],
    raw: true
  });

  return res.json({
    success: true,
    data: {
      total_users: totalUsers,
      active_users: activeUsers,
      verified_users: verifiedUsers,
      admin_users: adminUsers,
      new_users_last_30_days: newUsersLast30,
      by_provider: byProvider
    }
  });
};

// ─────────────────────────────────────────────
// PATCH /api/admin/users/:id/status
// ─────────────────────────────────────────────
const updateUserStatus = async (req, res) => {
  const { is_active, role } = req.body;

  const user = await User.findByPk(req.params.id);
  if (!user) {
    return res.status(404).json({ success: false, message: 'User not found' });
  }

  // Prevent admin from disabling themselves
  if (req.userId === user.id && is_active === false) {
    return res.status(400).json({ success: false, message: 'Cannot disable your own account' });
  }

  const updates = {};
  if (is_active !== undefined) updates.is_active = is_active;
  if (role !== undefined && ['user', 'admin'].includes(role)) updates.role = role;

  await user.update(updates);
  logger.info(`Admin ${req.userId} updated user ${user.id}: ${JSON.stringify(updates)}`);

  return res.json({ success: true, data: { user }, message: 'User status updated' });
};

// ─────────────────────────────────────────────
// GET /api/admin/projects
// ─────────────────────────────────────────────
const getAllProjects = async (req, res) => {
  const { page = 1, limit = 20, status, country, search } = req.query;
  const offset = (parseInt(page) - 1) * parseInt(limit);

  const where = {};
  if (status) where.status = status;
  if (country) where.country = { [Op.iLike]: `%${country}%` };
  if (search) {
    where[Op.or] = [
      { name: { [Op.iLike]: `%${search}%` } },
      { city: { [Op.iLike]: `%${search}%` } }
    ];
  }

  const { count, rows } = await Project.findAndCountAll({
    where,
    limit: Math.min(parseInt(limit), 100),
    offset,
    order: [['created_at', 'DESC']],
    attributes: { exclude: ['ai_floor_plan', 'cost_estimate', 'material_report', 'optimization_suggestions'] },
    include: [
      { model: User, as: 'user', attributes: ['id', 'name', 'email'] }
    ]
  });

  return res.json({
    success: true,
    data: {
      projects: rows,
      pagination: { total: count, page: parseInt(page), limit: parseInt(limit), pages: Math.ceil(count / parseInt(limit)) }
    }
  });
};

// ─────────────────────────────────────────────
// GET /api/admin/system-stats
// ─────────────────────────────────────────────
const getSystemStats = async (req, res) => {
  const [
    totalUsers,
    activeUsers,
    totalProjects,
    projectsByStatus,
    totalReports,
    recentProjects
  ] = await Promise.all([
    User.count(),
    User.count({ where: { is_active: true } }),
    Project.count(),
    Project.findAll({
      attributes: ['status', [fn('COUNT', col('id')), 'count']],
      group: ['status'],
      raw: true
    }),
    Report.count(),
    Project.findAll({
      limit: 5,
      order: [['created_at', 'DESC']],
      attributes: ['id', 'name', 'status', 'country', 'created_at'],
      include: [{ model: User, as: 'user', attributes: ['name', 'email'] }]
    })
  ]);

  // Monthly project creation trend (last 6 months)
  const sixMonthsAgo = new Date();
  sixMonthsAgo.setMonth(sixMonthsAgo.getMonth() - 6);

  const monthlyTrend = await Project.findAll({
    where: { created_at: { [Op.gte]: sixMonthsAgo } },
    attributes: [
      [fn('DATE_TRUNC', 'month', col('created_at')), 'month'],
      [fn('COUNT', col('id')), 'count']
    ],
    group: [literal("DATE_TRUNC('month', created_at)")],
    order: [[literal("DATE_TRUNC('month', created_at)"), 'ASC']],
    raw: true
  });

  // Top countries
  const topCountries = await Project.findAll({
    where: { country: { [Op.ne]: null } },
    attributes: ['country', [fn('COUNT', col('id')), 'count']],
    group: ['country'],
    order: [[literal('count'), 'DESC']],
    limit: 10,
    raw: true
  });

  return res.json({
    success: true,
    data: {
      users: { total: totalUsers, active: activeUsers },
      projects: {
        total: totalProjects,
        by_status: projectsByStatus,
        recent: recentProjects
      },
      reports: { total: totalReports },
      monthly_trend: monthlyTrend,
      top_countries: topCountries
    }
  });
};

// ─────────────────────────────────────────────
// GET /api/admin/activity-logs
// ─────────────────────────────────────────────
const getActivityLogs = async (req, res) => {
  const { page = 1, limit = 50 } = req.query;
  const offset = (parseInt(page) - 1) * parseInt(limit);

  // Return recent users and projects as activity log
  const recentUsers = await User.findAll({
    limit: 20,
    order: [['created_at', 'DESC']],
    attributes: ['id', 'name', 'email', 'provider', 'created_at'],
    raw: true
  });

  const recentProjects = await Project.findAll({
    limit: 30,
    order: [['updated_at', 'DESC']],
    attributes: ['id', 'name', 'status', 'user_id', 'updated_at'],
    include: [{ model: User, as: 'user', attributes: ['name', 'email'] }]
  });

  const activities = [
    ...recentUsers.map((u) => ({
      type: 'user_registered',
      timestamp: u.created_at,
      description: `New user registered: ${u.email}`,
      user_id: u.id
    })),
    ...recentProjects.map((p) => ({
      type: 'project_updated',
      timestamp: p.updated_at,
      description: `Project "${p.name}" updated to ${p.status}`,
      user_id: p.user_id,
      user_name: p.user ? p.user.name : 'Unknown'
    }))
  ].sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp))
    .slice(offset, offset + parseInt(limit));

  return res.json({
    success: true,
    data: {
      activities,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit)
      }
    }
  });
};

// ─────────────────────────────────────────────
// DELETE /api/admin/users/:id
// ─────────────────────────────────────────────
const deleteUser = async (req, res) => {
  if (req.params.id === req.userId) {
    return res.status(400).json({ success: false, message: 'Cannot delete your own account' });
  }

  const user = await User.findByPk(req.params.id);
  if (!user) {
    return res.status(404).json({ success: false, message: 'User not found' });
  }

  await user.destroy();
  logger.warn(`Admin ${req.userId} deleted user ${req.params.id}`);
  return res.json({ success: true, message: 'User deleted successfully' });
};

module.exports = {
  getAllUsers,
  getUserById,
  getUserStats,
  updateUserStatus,
  getAllProjects,
  getSystemStats,
  getActivityLogs,
  deleteUser
};

'use strict';

const { Op } = require('sequelize');
const { v4: uuidv4 } = require('uuid');
const { Project, User, Report } = require('../models');
const logger = require('../config/logger');

// ─────────────────────────────────────────────
// GET /api/projects
// ─────────────────────────────────────────────
const getAllProjects = async (req, res) => {
  const {
    page = 1,
    limit = 10,
    status,
    search,
    sort = 'created_at',
    order = 'DESC'
  } = req.query;

  const offset = (parseInt(page) - 1) * parseInt(limit);
  const where = { user_id: req.userId };

  if (status) where.status = status;
  if (search) {
    where[Op.or] = [
      { name: { [Op.iLike]: `%${search}%` } },
      { description: { [Op.iLike]: `%${search}%` } },
      { country: { [Op.iLike]: `%${search}%` } },
      { city: { [Op.iLike]: `%${search}%` } }
    ];
  }

  const allowedSorts = ['name', 'status', 'created_at', 'updated_at', 'estimated_total_cost'];
  const sortField = allowedSorts.includes(sort) ? sort : 'created_at';
  const sortOrder = order.toUpperCase() === 'ASC' ? 'ASC' : 'DESC';

  const { count, rows } = await Project.findAndCountAll({
    where,
    limit: Math.min(parseInt(limit), 100),
    offset,
    order: [[sortField, sortOrder]],
    attributes: {
      exclude: ['ai_floor_plan', 'cost_estimate', 'material_report', 'optimization_suggestions']
    }
  });

  return res.json({
    success: true,
    data: {
      projects: rows,
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
// POST /api/projects
// ─────────────────────────────────────────────
const createProject = async (req, res) => {
  const {
    name, description, country, city,
    plot_length, plot_width, unit, floors,
    bedrooms, bathrooms, kitchen, living_room,
    garage, garden, balcony, house_style,
    construction_quality, currency, tags
  } = req.body;

  const project = await Project.create({
    user_id: req.userId,
    name,
    description,
    country,
    city,
    plot_length: plot_length ? parseFloat(plot_length) : null,
    plot_width: plot_width ? parseFloat(plot_width) : null,
    unit: unit || 'feet',
    floors: floors || 1,
    bedrooms: bedrooms !== undefined ? parseInt(bedrooms) : 3,
    bathrooms: bathrooms !== undefined ? parseInt(bathrooms) : 2,
    kitchen: kitchen !== false,
    living_room: living_room !== false,
    garage: garage || false,
    garden: garden || false,
    balcony: balcony || false,
    house_style,
    construction_quality: construction_quality || 'standard',
    currency: currency || 'USD',
    status: 'draft',
    tags: tags || []
  });

  logger.info(`Project created: ${project.id} by user ${req.userId}`);
  return res.status(201).json({
    success: true,
    data: { project },
    message: 'Project created successfully'
  });
};

// ─────────────────────────────────────────────
// GET /api/projects/:id
// ─────────────────────────────────────────────
const getProject = async (req, res) => {
  const project = await Project.findOne({
    where: { id: req.params.id, user_id: req.userId },
    include: [
      {
        model: Report,
        as: 'reports',
        attributes: ['id', 'type', 'format', 'file_url', 'file_size', 'created_at', 'download_count'],
        order: [['created_at', 'DESC']],
        limit: 10
      }
    ]
  });

  if (!project) {
    return res.status(404).json({ success: false, message: 'Project not found' });
  }

  return res.json({ success: true, data: { project } });
};

// ─────────────────────────────────────────────
// GET /api/projects/shared/:token (public)
// ─────────────────────────────────────────────
const getSharedProject = async (req, res) => {
  const project = await Project.findOne({
    where: { share_token: req.params.token, is_public: true },
    attributes: {
      exclude: ['user_id', 'metadata', 'share_token']
    }
  });

  if (!project) {
    return res.status(404).json({ success: false, message: 'Project not found or sharing is disabled' });
  }

  return res.json({ success: true, data: { project } });
};

// ─────────────────────────────────────────────
// PUT /api/projects/:id
// ─────────────────────────────────────────────
const updateProject = async (req, res) => {
  const project = await Project.findOne({
    where: { id: req.params.id, user_id: req.userId }
  });

  if (!project) {
    return res.status(404).json({ success: false, message: 'Project not found' });
  }

  const allowedFields = [
    'name', 'description', 'status', 'country', 'city',
    'plot_length', 'plot_width', 'unit', 'floors',
    'bedrooms', 'bathrooms', 'kitchen', 'living_room',
    'garage', 'garden', 'balcony', 'house_style',
    'construction_quality', 'currency', 'tags', 'thumbnail_url'
  ];

  const updates = {};
  allowedFields.forEach((field) => {
    if (req.body[field] !== undefined) {
      updates[field] = req.body[field];
    }
  });

  await project.update(updates);
  logger.info(`Project updated: ${project.id} by user ${req.userId}`);

  return res.json({
    success: true,
    data: { project },
    message: 'Project updated successfully'
  });
};

// ─────────────────────────────────────────────
// DELETE /api/projects/:id
// ─────────────────────────────────────────────
const deleteProject = async (req, res) => {
  const project = await Project.findOne({
    where: { id: req.params.id, user_id: req.userId }
  });

  if (!project) {
    return res.status(404).json({ success: false, message: 'Project not found' });
  }

  await project.destroy();
  logger.info(`Project deleted: ${req.params.id} by user ${req.userId}`);

  return res.json({ success: true, message: 'Project deleted successfully' });
};

// ─────────────────────────────────────────────
// POST /api/projects/:id/duplicate
// ─────────────────────────────────────────────
const duplicateProject = async (req, res) => {
  const original = await Project.findOne({
    where: { id: req.params.id, user_id: req.userId }
  });

  if (!original) {
    return res.status(404).json({ success: false, message: 'Project not found' });
  }

  const data = original.toJSON();
  delete data.id;
  delete data.created_at;
  delete data.updated_at;
  delete data.share_token;

  const copy = await Project.create({
    ...data,
    name: `${data.name} (Copy)`,
    status: 'draft',
    is_public: false,
    user_id: req.userId
  });

  logger.info(`Project duplicated: ${original.id} -> ${copy.id} by user ${req.userId}`);
  return res.status(201).json({
    success: true,
    data: { project: copy },
    message: 'Project duplicated successfully'
  });
};

// ─────────────────────────────────────────────
// POST /api/projects/:id/share
// ─────────────────────────────────────────────
const shareProject = async (req, res) => {
  const { is_public } = req.body;

  const project = await Project.findOne({
    where: { id: req.params.id, user_id: req.userId }
  });

  if (!project) {
    return res.status(404).json({ success: false, message: 'Project not found' });
  }

  if (is_public) {
    const token = require('crypto').randomBytes(24).toString('hex');
    await project.update({ is_public: true, share_token: token });
    const shareUrl = `${process.env.FRONTEND_URL}/shared/${token}`;
    return res.json({
      success: true,
      data: { share_url: shareUrl, share_token: token },
      message: 'Project sharing enabled'
    });
  } else {
    await project.update({ is_public: false, share_token: null });
    return res.json({ success: true, message: 'Project sharing disabled' });
  }
};

module.exports = {
  getAllProjects,
  createProject,
  getProject,
  getSharedProject,
  updateProject,
  deleteProject,
  duplicateProject,
  shareProject
};

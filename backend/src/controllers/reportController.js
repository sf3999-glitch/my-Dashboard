'use strict';

const path = require('path');
const fs = require('fs');
const crypto = require('crypto');
const { Project, Report } = require('../models');
const pdfService = require('../services/pdfService');
const floorPlanService = require('../services/floorPlanService');
const logger = require('../config/logger');

const UPLOAD_DIR = process.env.UPLOAD_DIR || 'uploads';
const REPORTS_DIR = path.join(process.cwd(), UPLOAD_DIR, 'reports');

// ─────────────────────────────────────────────
// POST /api/reports/generate
// ─────────────────────────────────────────────
const generateReport = async (req, res) => {
  const { project_id, type = 'full', format = 'pdf' } = req.body;

  const project = await Project.findOne({ where: { id: project_id, user_id: req.userId } });
  if (!project) {
    return res.status(404).json({ success: false, message: 'Project not found' });
  }

  if (!fs.existsSync(REPORTS_DIR)) {
    fs.mkdirSync(REPORTS_DIR, { recursive: true });
  }

  const filename = `${type}-${project.id}-${Date.now()}.${format}`;
  const filepath = path.join(REPORTS_DIR, filename);

  let fileBuffer;
  try {
    if (format === 'pdf') {
      switch (type) {
        case 'floor_plan':
          fileBuffer = await pdfService.generateFloorPlanPDF(project);
          break;
        case 'cost':
          fileBuffer = await pdfService.generateCostReportPDF(project);
          break;
        case 'material':
          fileBuffer = await pdfService.generateMaterialReportPDF(project);
          break;
        case 'optimization':
          fileBuffer = await pdfService.generateOptimizationPDF(project);
          break;
        case 'full':
        default:
          fileBuffer = await pdfService.generateProjectPDF(project);
          break;
      }
      fs.writeFileSync(filepath, fileBuffer);
    } else if (format === 'svg') {
      if (!project.ai_floor_plan || !project.ai_floor_plan.svg) {
        return res.status(400).json({
          success: false,
          message: 'Floor plan must be generated before exporting as SVG'
        });
      }
      fs.writeFileSync(filepath, project.ai_floor_plan.svg, 'utf8');
    } else if (format === 'json') {
      const jsonData = {
        project: {
          id: project.id,
          name: project.name,
          description: project.description,
          country: project.country,
          city: project.city,
          plot_length: project.plot_length,
          plot_width: project.plot_width,
          unit: project.unit,
          floors: project.floors,
          bedrooms: project.bedrooms,
          bathrooms: project.bathrooms,
          construction_quality: project.construction_quality,
          house_style: project.house_style,
          currency: project.currency
        },
        floor_plan: project.ai_floor_plan,
        cost_estimate: project.cost_estimate,
        material_report: project.material_report,
        optimization_suggestions: project.optimization_suggestions,
        exported_at: new Date().toISOString()
      };
      fs.writeFileSync(filepath, JSON.stringify(jsonData, null, 2), 'utf8');
    }

    const stats = fs.statSync(filepath);
    const fileUrl = `/uploads/reports/${filename}`;

    const report = await Report.create({
      project_id: project.id,
      user_id: req.userId,
      type,
      format,
      file_url: fileUrl,
      file_size: stats.size,
      title: `${project.name} - ${type.replace('_', ' ')} report`
    });

    logger.info(`Report generated: ${report.id} for project ${project.id}`);

    return res.json({
      success: true,
      data: { report },
      message: 'Report generated successfully'
    });
  } catch (error) {
    // Clean up file on error
    if (fs.existsSync(filepath)) fs.unlinkSync(filepath);
    throw error;
  }
};

// ─────────────────────────────────────────────
// GET /api/reports/project/:projectId
// ─────────────────────────────────────────────
const getProjectReports = async (req, res) => {
  const project = await Project.findOne({
    where: { id: req.params.projectId, user_id: req.userId }
  });
  if (!project) {
    return res.status(404).json({ success: false, message: 'Project not found' });
  }

  const reports = await Report.findAll({
    where: { project_id: project.id },
    order: [['created_at', 'DESC']]
  });

  return res.json({ success: true, data: { reports } });
};

// ─────────────────────────────────────────────
// GET /api/reports/:id/download
// ─────────────────────────────────────────────
const downloadReport = async (req, res) => {
  const report = await Report.findOne({
    where: { id: req.params.id, user_id: req.userId }
  });

  if (!report) {
    return res.status(404).json({ success: false, message: 'Report not found' });
  }

  const filepath = path.join(process.cwd(), report.file_url);
  if (!fs.existsSync(filepath)) {
    return res.status(404).json({ success: false, message: 'Report file not found. Please regenerate.' });
  }

  await report.increment('download_count');

  const mimeTypes = { pdf: 'application/pdf', svg: 'image/svg+xml', json: 'application/json' };
  const contentType = mimeTypes[report.format] || 'application/octet-stream';
  const filename = `${report.title || 'report'}.${report.format}`;

  res.setHeader('Content-Type', contentType);
  res.setHeader('Content-Disposition', `attachment; filename="${filename.replace(/[^a-z0-9.-]/gi, '_')}"`);
  res.setHeader('Content-Length', report.file_size);

  const fileStream = fs.createReadStream(filepath);
  fileStream.pipe(res);
};

// ─────────────────────────────────────────────
// POST /api/reports/:id/share
// ─────────────────────────────────────────────
const shareReport = async (req, res) => {
  const { expires_hours = 72 } = req.body;

  const report = await Report.findOne({
    where: { id: req.params.id, user_id: req.userId }
  });

  if (!report) {
    return res.status(404).json({ success: false, message: 'Report not found' });
  }

  const shareToken = crypto.randomBytes(24).toString('hex');
  const expiresAt = new Date(Date.now() + parseInt(expires_hours) * 60 * 60 * 1000);

  await report.update({ share_token: shareToken, expires_at: expiresAt });

  const shareUrl = `${process.env.FRONTEND_URL || 'http://localhost:3001'}/reports/shared/${shareToken}`;

  return res.json({
    success: true,
    data: { share_url: shareUrl, share_token: shareToken, expires_at: expiresAt },
    message: 'Report sharing link created'
  });
};

// ─────────────────────────────────────────────
// GET /api/reports/shared/:token (public)
// ─────────────────────────────────────────────
const getSharedReport = async (req, res) => {
  const report = await Report.findOne({
    where: {
      share_token: req.params.token,
      expires_at: { [require('sequelize').Op.gt]: new Date() }
    }
  });

  if (!report) {
    return res.status(404).json({ success: false, message: 'Shared report not found or expired' });
  }

  const filepath = path.join(process.cwd(), report.file_url);
  if (!fs.existsSync(filepath)) {
    return res.status(404).json({ success: false, message: 'Report file not available' });
  }

  await report.increment('download_count');

  const mimeTypes = { pdf: 'application/pdf', svg: 'image/svg+xml', json: 'application/json' };
  const contentType = mimeTypes[report.format] || 'application/octet-stream';

  res.setHeader('Content-Type', contentType);
  res.setHeader('Content-Disposition', `inline; filename="report.${report.format}"`);

  const fileStream = fs.createReadStream(filepath);
  fileStream.pipe(res);
};

// ─────────────────────────────────────────────
// DELETE /api/reports/:id
// ─────────────────────────────────────────────
const deleteReport = async (req, res) => {
  const report = await Report.findOne({
    where: { id: req.params.id, user_id: req.userId }
  });

  if (!report) {
    return res.status(404).json({ success: false, message: 'Report not found' });
  }

  // Delete physical file
  if (report.file_url) {
    const filepath = path.join(process.cwd(), report.file_url);
    if (fs.existsSync(filepath)) {
      fs.unlinkSync(filepath);
    }
  }

  await report.destroy();
  return res.json({ success: true, message: 'Report deleted successfully' });
};

module.exports = {
  generateReport,
  getProjectReports,
  downloadReport,
  shareReport,
  getSharedReport,
  deleteReport
};

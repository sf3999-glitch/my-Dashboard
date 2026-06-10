'use strict';

const PDFDocument = require('pdfkit');
const logger = require('../config/logger');

// ─────────────────────────────────────────────
// Color palette
// ─────────────────────────────────────────────
const COLORS = {
  primary: '#1A237E',
  secondary: '#283593',
  accent: '#1976D2',
  success: '#2E7D32',
  warning: '#F57F17',
  light_bg: '#F5F5F5',
  border: '#E0E0E0',
  text_dark: '#212121',
  text_medium: '#616161',
  text_light: '#9E9E9E',
  white: '#FFFFFF'
};

// ─────────────────────────────────────────────
// Helper: create a new PDF document
// ─────────────────────────────────────────────
const createDoc = () => {
  return new PDFDocument({
    margins: { top: 50, bottom: 50, left: 50, right: 50 },
    size: 'A4',
    bufferPages: true,
    info: {
      Title: 'AI House Planner Report',
      Author: 'AI House Planner',
      Creator: 'AI House Planner & Construction Cost Estimator'
    }
  });
};

// ─────────────────────────────────────────────
// Helper: collect PDF buffer
// ─────────────────────────────────────────────
const collectBuffer = (doc) => {
  return new Promise((resolve, reject) => {
    const chunks = [];
    doc.on('data', (chunk) => chunks.push(chunk));
    doc.on('end', () => resolve(Buffer.concat(chunks)));
    doc.on('error', reject);
  });
};

// ─────────────────────────────────────────────
// Page header
// ─────────────────────────────────────────────
const addPageHeader = (doc, title, subtitle = '') => {
  doc.rect(0, 0, doc.page.width, 80).fill(COLORS.primary);
  doc.fill(COLORS.white).fontSize(22).font('Helvetica-Bold')
    .text(title, 50, 20, { width: doc.page.width - 100, align: 'center' });
  if (subtitle) {
    doc.fontSize(12).font('Helvetica')
      .text(subtitle, 50, 48, { width: doc.page.width - 100, align: 'center' });
  }
  doc.moveDown(3);
};

// ─────────────────────────────────────────────
// Page footer
// ─────────────────────────────────────────────
const addPageFooter = (doc, pageNum, totalPages, projectName) => {
  const footerY = doc.page.height - 40;
  doc.rect(0, footerY - 5, doc.page.width, 45).fill(COLORS.light_bg);
  doc.fill(COLORS.text_medium).fontSize(9).font('Helvetica')
    .text(`AI House Planner | ${projectName}`, 50, footerY, { width: 300 })
    .text(`Page ${pageNum} of ${totalPages}`, 50, footerY, {
      width: doc.page.width - 100,
      align: 'right'
    });
};

// ─────────────────────────────────────────────
// Section heading
// ─────────────────────────────────────────────
const addSection = (doc, title, y) => {
  if (y !== undefined) doc.y = y;
  const boxY = doc.y;
  doc.rect(50, boxY, doc.page.width - 100, 26).fill(COLORS.secondary);
  doc.fill(COLORS.white).fontSize(13).font('Helvetica-Bold')
    .text(title, 58, boxY + 6);
  doc.moveDown(0.8);
  doc.fill(COLORS.text_dark);
};

// ─────────────────────────────────────────────
// Key-value row
// ─────────────────────────────────────────────
const addKVRow = (doc, key, value, bg = false) => {
  const rowH = 22;
  const y = doc.y;
  if (bg) {
    doc.rect(50, y, doc.page.width - 100, rowH).fill('#F9F9F9');
  }
  doc.fill(COLORS.text_medium).fontSize(10).font('Helvetica')
    .text(key + ':', 58, y + 5, { width: 180 });
  doc.fill(COLORS.text_dark).font('Helvetica-Bold')
    .text(String(value), 245, y + 5, { width: doc.page.width - 300 });
  doc.rect(50, y, doc.page.width - 100, rowH).stroke(COLORS.border);
  doc.y = y + rowH;
};

// ─────────────────────────────────────────────
// Cost row with bar chart visualization
// ─────────────────────────────────────────────
const addCostRow = (doc, label, amount, pct, currency, maxBarWidth = 200) => {
  const y = doc.y;
  const barWidth = (parseFloat(pct) / 100) * maxBarWidth;

  doc.fill(COLORS.text_dark).fontSize(10).font('Helvetica')
    .text(label, 58, y + 4, { width: 180 });

  // Bar
  doc.rect(240, y + 6, maxBarWidth, 12).fill(COLORS.border);
  doc.rect(240, y + 6, barWidth, 12).fill(COLORS.accent);

  // Amount
  doc.fill(COLORS.text_dark).font('Helvetica-Bold')
    .text(`${currency} ${amount.toLocaleString()}`, 450, y + 4, { width: 100, align: 'right' });
  doc.fill(COLORS.text_medium).font('Helvetica').fontSize(9)
    .text(`${pct}%`, 560, y + 6);

  doc.y = y + 24;
};

// ─────────────────────────────────────────────
// Project overview section
// ─────────────────────────────────────────────
const addProjectOverview = (doc, project) => {
  addSection(doc, 'Project Overview');

  const details = [
    ['Project Name', project.name || 'N/A'],
    ['Location', [project.city, project.country].filter(Boolean).join(', ') || 'N/A'],
    ['Plot Size', project.plot_length && project.plot_width
      ? `${project.plot_length} x ${project.plot_width} ${project.unit || 'feet'}`
      : 'N/A'],
    ['Floors', project.floors || 1],
    ['Bedrooms', project.bedrooms || 0],
    ['Bathrooms', project.bathrooms || 0],
    ['House Style', project.house_style || 'Not specified'],
    ['Construction Quality', (project.construction_quality || 'standard').toUpperCase()],
    ['Status', (project.status || 'draft').replace('_', ' ').toUpperCase()],
    ['Currency', project.currency || 'USD'],
    ['Features', [
      project.kitchen && 'Kitchen',
      project.living_room && 'Living Room',
      project.garage && 'Garage',
      project.garden && 'Garden',
      project.balcony && 'Balcony'
    ].filter(Boolean).join(', ') || 'None'],
    ['Created', project.created_at ? new Date(project.created_at).toLocaleDateString() : 'N/A']
  ];

  details.forEach(([k, v], i) => addKVRow(doc, k, v, i % 2 === 0));
  doc.moveDown(1);
};

// ─────────────────────────────────────────────
// Cost estimate section
// ─────────────────────────────────────────────
const addCostEstimate = (doc, project) => {
  if (!project.cost_estimate) return;
  const cost = project.cost_estimate;
  const currency = cost.currency || project.currency || 'USD';
  const summary = cost.summary || {};

  addSection(doc, 'Construction Cost Estimate');

  // Summary box
  const totalCost = summary.total_cost || cost.total_cost || 0;
  doc.rect(50, doc.y, doc.page.width - 100, 60).fill('#E3F2FD');
  doc.fill(COLORS.primary).fontSize(14).font('Helvetica-Bold')
    .text('Total Estimated Cost', 60, doc.y + 8);
  doc.fill(COLORS.accent).fontSize(22).font('Helvetica-Bold')
    .text(`${currency} ${totalCost.toLocaleString()}`, 60, doc.y + 26);
  doc.y = doc.y + 70;
  doc.fill(COLORS.text_dark);

  // Low / High range
  if (cost.cost_summary) {
    const cs = cost.cost_summary;
    doc.fontSize(10).font('Helvetica')
      .text(`Range: ${cs.formatted?.low || ''} – ${cs.formatted?.high || ''}`, 58);
    doc.moveDown(0.5);
  }

  // Category breakdown
  if (cost.breakdown || cost.category_breakdown) {
    addSection(doc, 'Cost Breakdown by Category');
    const bd = cost.breakdown || cost.category_breakdown || {};

    Object.entries(bd).forEach(([key, item]) => {
      if (doc.y > doc.page.height - 100) doc.addPage();
      const amount = item.amount || item.cost || 0;
      const pct = item.percentage || '0';
      addCostRow(doc, item.label || item.name || key, amount, pct, currency);
    });
    doc.moveDown(1);
  }

  // AI Analysis
  if (cost.ai_analysis) {
    if (doc.y > doc.page.height - 150) doc.addPage();
    addSection(doc, 'AI Cost Analysis');
    const ai = cost.ai_analysis;
    if (ai.analysis_summary) {
      doc.fontSize(10).font('Helvetica').fill(COLORS.text_dark)
        .text(ai.analysis_summary, 58, doc.y, { width: doc.page.width - 116 });
      doc.moveDown(0.8);
    }
    if (ai.risk_factors && ai.risk_factors.length) {
      doc.fontSize(11).font('Helvetica-Bold').text('Risk Factors:', 58);
      doc.moveDown(0.3);
      ai.risk_factors.forEach((r) => {
        doc.fontSize(10).font('Helvetica')
          .text(`• [${(r.impact || '').toUpperCase()}] ${r.factor}`, 65, doc.y, { width: doc.page.width - 130 });
        if (r.mitigation) {
          doc.fillColor(COLORS.text_medium)
            .text(`  Mitigation: ${r.mitigation}`, 75, doc.y, { width: doc.page.width - 140 });
        }
        doc.fillColor(COLORS.text_dark);
        doc.moveDown(0.3);
      });
    }
  }
};

// ─────────────────────────────────────────────
// Floor plan section
// ─────────────────────────────────────────────
const addFloorPlanSection = (doc, project) => {
  if (!project.ai_floor_plan) return;
  const fp = project.ai_floor_plan;

  if (doc.y > doc.page.height - 200) doc.addPage();
  addSection(doc, 'Floor Plan Summary');

  if (fp.design_notes) {
    doc.fontSize(10).font('Helvetica').fill(COLORS.text_dark)
      .text(fp.design_notes, 58, doc.y, { width: doc.page.width - 116 });
    doc.moveDown(0.5);
  }

  addKVRow(doc, 'Total Floors', fp.total_floors || project.floors || 1, false);
  addKVRow(doc, 'Total Area', `${fp.total_area_sqft ? Math.round(fp.total_area_sqft) : 'N/A'} sq ft`, true);
  addKVRow(doc, 'House Area', `${fp.house_area_sqft ? Math.round(fp.house_area_sqft) : 'N/A'} sq ft`, false);
  addKVRow(doc, 'Layout Style', fp.layout_style || 'N/A', true);

  if (fp.rooms && fp.rooms.length) {
    doc.moveDown(0.8);
    addSection(doc, 'Room Breakdown');
    doc.fontSize(10).font('Helvetica-Bold').fill(COLORS.text_dark);

    // Table header
    const tableY = doc.y;
    doc.rect(50, tableY, doc.page.width - 100, 22).fill(COLORS.accent);
    doc.fill(COLORS.white)
      .text('Room', 58, tableY + 5, { width: 160 })
      .text('Floor', 220, tableY + 5, { width: 60 })
      .text('Dimensions (ft)', 285, tableY + 5, { width: 130 })
      .text('Area', 420, tableY + 5, { width: 80, align: 'right' });
    doc.y = tableY + 24;

    fp.rooms.forEach((room, i) => {
      if (doc.y > doc.page.height - 80) doc.addPage();
      const rowY = doc.y;
      if (i % 2 === 0) {
        doc.rect(50, rowY, doc.page.width - 100, 20).fill('#F5F5F5');
      }
      doc.fill(COLORS.text_dark).font('Helvetica').fontSize(10)
        .text(room.name || room.type, 58, rowY + 4, { width: 160 })
        .text(String(room.floor || 1), 220, rowY + 4, { width: 60 })
        .text(room.width_ft && room.length_ft ? `${room.width_ft.toFixed(0)}' x ${room.length_ft.toFixed(0)}'` : 'N/A', 285, rowY + 4, { width: 130 })
        .text(room.area_sqft ? `${Math.round(room.area_sqft)} sf` : 'N/A', 420, rowY + 4, { width: 80, align: 'right' });
      doc.rect(50, rowY, doc.page.width - 100, 20).stroke(COLORS.border);
      doc.y = rowY + 20;
    });
    doc.moveDown(1);
  }
};

// ─────────────────────────────────────────────
// Materials section
// ─────────────────────────────────────────────
const addMaterialsSection = (doc, project) => {
  if (!project.material_report) return;
  const mr = project.material_report;

  if (doc.y > doc.page.height - 200) doc.addPage();
  addSection(doc, 'Materials Report');

  if (mr.summary) {
    addKVRow(doc, 'Total Materials Cost', `${mr.summary.currency || project.currency || 'USD'} ${(mr.summary.total_estimated_cost || 0).toLocaleString()}`, false);
    addKVRow(doc, 'Quality Tier', mr.summary.quality_tier || 'standard', true);
    if (mr.summary.notes) {
      doc.fontSize(10).font('Helvetica').fill(COLORS.text_medium)
        .text(mr.summary.notes, 58, doc.y + 5, { width: doc.page.width - 116 });
      doc.moveDown(0.5);
    }
  }

  if (mr.categories && mr.categories.length) {
    doc.moveDown(0.5);
    mr.categories.forEach((cat) => {
      if (doc.y > doc.page.height - 150) doc.addPage();
      doc.fontSize(11).font('Helvetica-Bold').fill(COLORS.secondary)
        .text(cat.category, 58, doc.y);
      doc.moveDown(0.2);

      if (cat.subcategory_items) {
        cat.subcategory_items.forEach((item) => {
          doc.fontSize(9).font('Helvetica').fill(COLORS.text_dark)
            .text(`  ${item.name}`, 65, doc.y, { width: 200, continued: true })
            .text(`${item.quantity} ${item.unit}`, { width: 120, continued: true })
            .text(`${item.unit_cost ? item.unit_cost.toLocaleString() : 'N/A'}/unit`, { width: 100, continued: true })
            .text(`${(item.total_cost || 0).toLocaleString()}`, { width: 80, align: 'right' });
          doc.moveDown(0.2);
        });
      }
      doc.fill(COLORS.text_medium).fontSize(10).font('Helvetica-Bold')
        .text(`Category Total: ${(cat.category_total || 0).toLocaleString()}`, 58, doc.y, { align: 'right', width: doc.page.width - 116 });
      doc.moveDown(0.5);
      doc.fill(COLORS.text_dark);
    });
  }
};

// ─────────────────────────────────────────────
// Optimization suggestions section
// ─────────────────────────────────────────────
const addOptimizationsSection = (doc, project) => {
  if (!project.optimization_suggestions) return;
  const opt = project.optimization_suggestions;

  if (doc.y > doc.page.height - 200) doc.addPage();
  addSection(doc, 'AI Optimization Suggestions');

  if (opt.overall_score !== undefined) {
    doc.fontSize(14).font('Helvetica-Bold').fill(COLORS.primary)
      .text(`Overall Score: ${opt.overall_score}/100 (${opt.overall_score_label || ''})`, 58, doc.y);
    doc.moveDown(0.5);
  }

  if (opt.summary) {
    doc.fontSize(10).font('Helvetica').fill(COLORS.text_dark)
      .text(opt.summary, 58, doc.y, { width: doc.page.width - 116 });
    doc.moveDown(0.8);
  }

  if (opt.quick_wins && opt.quick_wins.length) {
    doc.fontSize(11).font('Helvetica-Bold').fill(COLORS.success)
      .text('Quick Wins', 58);
    doc.moveDown(0.3);
    opt.quick_wins.forEach((qw) => {
      if (doc.y > doc.page.height - 80) doc.addPage();
      doc.fontSize(10).font('Helvetica-Bold').fill(COLORS.text_dark)
        .text(`• ${qw.title}`, 65, doc.y);
      doc.font('Helvetica').fill(COLORS.text_medium)
        .text(qw.description, 75, doc.y, { width: doc.page.width - 140 });
      if (qw.estimated_savings) {
        doc.fill(COLORS.success)
          .text(`Savings: ${qw.estimated_savings.toLocaleString()}`, 75, doc.y);
      }
      doc.fill(COLORS.text_dark);
      doc.moveDown(0.4);
    });
  }

  if (opt.energy_features && opt.energy_features.length) {
    if (doc.y > doc.page.height - 150) doc.addPage();
    doc.fontSize(11).font('Helvetica-Bold').fill(COLORS.accent)
      .text('Energy Features', 58);
    doc.moveDown(0.3);
    opt.energy_features.forEach((ef) => {
      doc.fontSize(10).font('Helvetica-Bold').fill(COLORS.text_dark)
        .text(`• ${ef.feature}`, 65, doc.y);
      doc.font('Helvetica').fill(COLORS.text_medium)
        .text(`Cost: ${(ef.estimated_cost || 0).toLocaleString()} | Payback: ${ef.payback_years || 'N/A'} years | Feasibility: ${ef.feasibility || 'N/A'}`, 75, doc.y);
      doc.fill(COLORS.text_dark);
      doc.moveDown(0.4);
    });
  }
};

// ─────────────────────────────────────────────
// Public: generate full project PDF
// ─────────────────────────────────────────────
const generateProjectPDF = async (project) => {
  const doc = createDoc();
  const bufferPromise = collectBuffer(doc);

  // Cover page header
  addPageHeader(doc, 'AI House Planner', 'Complete Project Report');

  // Project overview
  addProjectOverview(doc, project);

  // Cost estimate
  if (project.cost_estimate) {
    if (doc.y > doc.page.height - 200) doc.addPage();
    addCostEstimate(doc, project);
  }

  // Floor plan
  if (project.ai_floor_plan) {
    if (doc.y > doc.page.height - 200) doc.addPage();
    addFloorPlanSection(doc, project);
  }

  // Materials
  if (project.material_report) {
    if (doc.y > doc.page.height - 200) doc.addPage();
    addMaterialsSection(doc, project);
  }

  // Optimizations
  if (project.optimization_suggestions) {
    if (doc.y > doc.page.height - 200) doc.addPage();
    addOptimizationsSection(doc, project);
  }

  // Finalize and add footers
  const range = doc.bufferedPageRange();
  for (let i = 0; i < range.count; i++) {
    doc.switchToPage(i);
    addPageFooter(doc, i + 1, range.count, project.name || 'House Project');
  }

  doc.end();
  return bufferPromise;
};

// ─────────────────────────────────────────────
// Public: floor plan only PDF
// ─────────────────────────────────────────────
const generateFloorPlanPDF = async (project) => {
  const doc = createDoc();
  const bufferPromise = collectBuffer(doc);

  addPageHeader(doc, project.name || 'Floor Plan', 'Architectural Floor Plan');
  addProjectOverview(doc, project);

  if (project.ai_floor_plan) {
    addFloorPlanSection(doc, project);
  } else {
    doc.fontSize(14).fill(COLORS.text_medium)
      .text('Floor plan not yet generated. Please generate the floor plan first.', {
        align: 'center'
      });
  }

  const range = doc.bufferedPageRange();
  for (let i = 0; i < range.count; i++) {
    doc.switchToPage(i);
    addPageFooter(doc, i + 1, range.count, project.name || 'Floor Plan');
  }
  doc.end();
  return bufferPromise;
};

// ─────────────────────────────────────────────
// Public: cost report only PDF
// ─────────────────────────────────────────────
const generateCostReportPDF = async (project) => {
  const doc = createDoc();
  const bufferPromise = collectBuffer(doc);

  addPageHeader(doc, project.name || 'Cost Report', 'Construction Cost Estimate Report');
  addProjectOverview(doc, project);

  if (project.cost_estimate) {
    addCostEstimate(doc, project);
  } else {
    doc.fontSize(14).fill(COLORS.text_medium)
      .text('Cost estimate not yet generated.', { align: 'center' });
  }

  const range = doc.bufferedPageRange();
  for (let i = 0; i < range.count; i++) {
    doc.switchToPage(i);
    addPageFooter(doc, i + 1, range.count, project.name || 'Cost Report');
  }
  doc.end();
  return bufferPromise;
};

// ─────────────────────────────────────────────
// Public: materials only PDF
// ─────────────────────────────────────────────
const generateMaterialReportPDF = async (project) => {
  const doc = createDoc();
  const bufferPromise = collectBuffer(doc);

  addPageHeader(doc, project.name || 'Materials', 'Construction Materials Report');
  addProjectOverview(doc, project);

  if (project.material_report) {
    addMaterialsSection(doc, project);
  } else {
    doc.fontSize(14).fill(COLORS.text_medium)
      .text('Material report not yet generated.', { align: 'center' });
  }

  const range = doc.bufferedPageRange();
  for (let i = 0; i < range.count; i++) {
    doc.switchToPage(i);
    addPageFooter(doc, i + 1, range.count, project.name || 'Materials');
  }
  doc.end();
  return bufferPromise;
};

// ─────────────────────────────────────────────
// Public: optimization PDF
// ─────────────────────────────────────────────
const generateOptimizationPDF = async (project) => {
  const doc = createDoc();
  const bufferPromise = collectBuffer(doc);

  addPageHeader(doc, project.name || 'Optimization', 'AI Optimization Suggestions Report');
  addProjectOverview(doc, project);

  if (project.optimization_suggestions) {
    addOptimizationsSection(doc, project);
  } else {
    doc.fontSize(14).fill(COLORS.text_medium)
      .text('Optimization suggestions not yet generated.', { align: 'center' });
  }

  const range = doc.bufferedPageRange();
  for (let i = 0; i < range.count; i++) {
    doc.switchToPage(i);
    addPageFooter(doc, i + 1, range.count, project.name || 'Optimization');
  }
  doc.end();
  return bufferPromise;
};

module.exports = {
  generateProjectPDF,
  generateFloorPlanPDF,
  generateCostReportPDF,
  generateMaterialReportPDF,
  generateOptimizationPDF
};

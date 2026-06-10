'use strict';

const { Project } = require('../models');
const aiService = require('../services/aiService');
const costCalculatorService = require('../services/costCalculatorService');
const floorPlanService = require('../services/floorPlanService');
const logger = require('../config/logger');

// Helper: fetch project and verify ownership
const getOwnedProject = async (projectId, userId) => {
  const project = await Project.findOne({ where: { id: projectId, user_id: userId } });
  return project;
};

// ─────────────────────────────────────────────
// POST /api/ai/generate-floor-plan
// ─────────────────────────────────────────────
const generateFloorPlan = async (req, res) => {
  const { project_id } = req.body;

  const project = await getOwnedProject(project_id, req.userId);
  if (!project) {
    return res.status(404).json({ success: false, message: 'Project not found' });
  }

  if (!project.plot_length || !project.plot_width) {
    return res.status(400).json({
      success: false,
      message: 'Plot dimensions (length and width) are required to generate a floor plan'
    });
  }

  logger.info(`Generating floor plan for project ${project_id}`);

  // Generate AI floor plan layout data
  const aiLayoutData = await aiService.generateFloorPlan(project);

  // Convert AI layout to SVG
  const svgFloorPlan = floorPlanService.generateSVGFloorPlan(
    aiLayoutData.rooms,
    {
      length: parseFloat(project.plot_length),
      width: parseFloat(project.plot_width),
      unit: project.unit
    },
    project.floors
  );

  const floorPlanData = {
    ...aiLayoutData,
    svg: svgFloorPlan,
    generated_at: new Date().toISOString()
  };

  // Compute total area
  const totalAreaSqft = aiLayoutData.rooms
    ? aiLayoutData.rooms.reduce((sum, r) => sum + (r.area_sqft || 0), 0)
    : null;

  await project.update({
    ai_floor_plan: floorPlanData,
    status: project.status === 'draft' ? 'planning' : project.status,
    total_area_sqft: totalAreaSqft || project.total_area_sqft
  });

  return res.json({
    success: true,
    data: { floor_plan: floorPlanData },
    message: 'Floor plan generated successfully'
  });
};

// ─────────────────────────────────────────────
// POST /api/ai/generate-cost-estimate
// ─────────────────────────────────────────────
const generateCostEstimate = async (req, res) => {
  const { project_id } = req.body;

  const project = await getOwnedProject(project_id, req.userId);
  if (!project) {
    return res.status(404).json({ success: false, message: 'Project not found' });
  }

  logger.info(`Generating cost estimate for project ${project_id}`);

  // Use local calculator for base estimate
  const localEstimate = costCalculatorService.calculateConstructionCost(
    project,
    project.currency || 'USD',
    1 // exchange rate; currencyService can provide real rates if configured
  );

  // Enhance with AI commentary and refinements
  const aiEnhancement = await aiService.generateCostEstimate(project, localEstimate);

  const costEstimate = {
    ...localEstimate,
    ai_analysis: aiEnhancement,
    generated_at: new Date().toISOString()
  };

  await project.update({
    cost_estimate: costEstimate,
    estimated_total_cost: costEstimate.total_cost || null
  });

  return res.json({
    success: true,
    data: { cost_estimate: costEstimate },
    message: 'Cost estimate generated successfully'
  });
};

// ─────────────────────────────────────────────
// POST /api/ai/generate-materials
// ─────────────────────────────────────────────
const generateMaterials = async (req, res) => {
  const { project_id } = req.body;

  const project = await getOwnedProject(project_id, req.userId);
  if (!project) {
    return res.status(404).json({ success: false, message: 'Project not found' });
  }

  logger.info(`Generating material report for project ${project_id}`);

  const materialReport = await aiService.generateMaterialReport(project);

  await project.update({ material_report: { ...materialReport, generated_at: new Date().toISOString() } });

  return res.json({
    success: true,
    data: { material_report: materialReport },
    message: 'Material report generated successfully'
  });
};

// ─────────────────────────────────────────────
// POST /api/ai/generate-suggestions
// ─────────────────────────────────────────────
const generateSuggestions = async (req, res) => {
  const { project_id } = req.body;

  const project = await getOwnedProject(project_id, req.userId);
  if (!project) {
    return res.status(404).json({ success: false, message: 'Project not found' });
  }

  logger.info(`Generating optimization suggestions for project ${project_id}`);

  const suggestions = await aiService.generateOptimizationSuggestions(project);

  await project.update({
    optimization_suggestions: { ...suggestions, generated_at: new Date().toISOString() }
  });

  return res.json({
    success: true,
    data: { suggestions },
    message: 'Optimization suggestions generated successfully'
  });
};

// ─────────────────────────────────────────────
// POST /api/ai/generate-full-report
// ─────────────────────────────────────────────
const generateFullReport = async (req, res) => {
  const { project_id } = req.body;

  const project = await getOwnedProject(project_id, req.userId);
  if (!project) {
    return res.status(404).json({ success: false, message: 'Project not found' });
  }

  if (!project.plot_length || !project.plot_width) {
    return res.status(400).json({
      success: false,
      message: 'Plot dimensions are required to generate a full report'
    });
  }

  logger.info(`Generating full report for project ${project_id}`);

  // Run all generations in parallel where possible
  const localEstimate = costCalculatorService.calculateConstructionCost(
    project, project.currency || 'USD', 1
  );

  const [aiLayoutData, aiEnhancement, materialReport, suggestions] = await Promise.all([
    aiService.generateFloorPlan(project),
    aiService.generateCostEstimate(project, localEstimate),
    aiService.generateMaterialReport(project),
    aiService.generateOptimizationSuggestions(project)
  ]);

  // Build floor plan SVG
  const svgFloorPlan = floorPlanService.generateSVGFloorPlan(
    aiLayoutData.rooms,
    {
      length: parseFloat(project.plot_length),
      width: parseFloat(project.plot_width),
      unit: project.unit
    },
    project.floors
  );

  const now = new Date().toISOString();
  const updates = {
    ai_floor_plan: { ...aiLayoutData, svg: svgFloorPlan, generated_at: now },
    cost_estimate: { ...localEstimate, ai_analysis: aiEnhancement, generated_at: now },
    material_report: { ...materialReport, generated_at: now },
    optimization_suggestions: { ...suggestions, generated_at: now },
    status: 'planning',
    total_area_sqft: aiLayoutData.rooms
      ? aiLayoutData.rooms.reduce((s, r) => s + (r.area_sqft || 0), 0)
      : project.total_area_sqft,
    estimated_total_cost: localEstimate.total_cost || project.estimated_total_cost
  };

  await project.update(updates);
  const updatedProject = await project.reload();

  return res.json({
    success: true,
    data: {
      project: updatedProject,
      floor_plan: updates.ai_floor_plan,
      cost_estimate: updates.cost_estimate,
      material_report: updates.material_report,
      suggestions: updates.optimization_suggestions
    },
    message: 'Full report generated successfully'
  });
};

module.exports = {
  generateFloorPlan,
  generateCostEstimate,
  generateMaterials,
  generateSuggestions,
  generateFullReport
};

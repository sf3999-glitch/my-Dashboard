'use strict';

const express = require('express');
const router = express.Router();

const aiController = require('../controllers/aiController');
const { authenticate } = require('../middleware/auth');
const {
  validateGenerateFloorPlan,
  validateGenerateCostEstimate,
  validateGenerateMaterials,
  validateGenerateSuggestions,
  validateGenerateFullReport
} = require('../middleware/validation');

router.use(authenticate);

router.post('/generate-floor-plan', validateGenerateFloorPlan, aiController.generateFloorPlan);
router.post('/generate-cost-estimate', validateGenerateCostEstimate, aiController.generateCostEstimate);
router.post('/generate-materials', validateGenerateMaterials, aiController.generateMaterials);
router.post('/generate-suggestions', validateGenerateSuggestions, aiController.generateSuggestions);
router.post('/generate-full-report', validateGenerateFullReport, aiController.generateFullReport);

module.exports = router;

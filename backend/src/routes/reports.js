'use strict';

const express = require('express');
const router = express.Router();

const reportController = require('../controllers/reportController');
const { authenticate } = require('../middleware/auth');
const { validateGenerateReport, validateReportId } = require('../middleware/validation');

// Public - shared report download
router.get('/shared/:token', reportController.getSharedReport);

// Protected routes
router.use(authenticate);

router.post('/generate', validateGenerateReport, reportController.generateReport);
router.get('/project/:projectId', reportController.getProjectReports);
router.get('/:id/download', validateReportId, reportController.downloadReport);
router.post('/:id/share', validateReportId, reportController.shareReport);
router.delete('/:id', validateReportId, reportController.deleteReport);

module.exports = router;

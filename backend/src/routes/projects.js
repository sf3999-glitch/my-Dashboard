'use strict';

const express = require('express');
const router = express.Router();

const projectController = require('../controllers/projectController');
const { authenticate, optionalAuth } = require('../middleware/auth');
const {
  validateCreateProject,
  validateUpdateProject,
  validateProjectId
} = require('../middleware/validation');

// Public route - shared project
router.get('/shared/:token', projectController.getSharedProject);

// All routes below require authentication
router.use(authenticate);

router.get('/', projectController.getAllProjects);
router.post('/', validateCreateProject, projectController.createProject);
router.get('/:id', validateProjectId, projectController.getProject);
router.put('/:id', validateUpdateProject, projectController.updateProject);
router.delete('/:id', validateProjectId, projectController.deleteProject);
router.post('/:id/duplicate', validateProjectId, projectController.duplicateProject);
router.post('/:id/share', validateProjectId, projectController.shareProject);

module.exports = router;

'use strict';

const express = require('express');
const router = express.Router();

const adminController = require('../controllers/adminController');
const { authenticate, requireAdmin } = require('../middleware/auth');
const { validateUserId, validatePagination } = require('../middleware/validation');

// All admin routes require authentication + admin role
router.use(authenticate, requireAdmin);

// User management
router.get('/users', validatePagination, adminController.getAllUsers);
router.get('/users/stats', adminController.getUserStats);
router.get('/users/:id', validateUserId, adminController.getUserById);
router.patch('/users/:id/status', validateUserId, adminController.updateUserStatus);
router.delete('/users/:id', validateUserId, adminController.deleteUser);

// Project management
router.get('/projects', validatePagination, adminController.getAllProjects);

// System
router.get('/system-stats', adminController.getSystemStats);
router.get('/activity-logs', validatePagination, adminController.getActivityLogs);

module.exports = router;

'use strict';

const { body, param, query, validationResult } = require('express-validator');

/**
 * Middleware to check validation results and return errors
 */
const handleValidationErrors = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({
      success: false,
      message: 'Validation failed',
      errors: errors.array().map((e) => ({
        field: e.path,
        message: e.msg,
        value: e.value
      }))
    });
  }
  next();
};

// ─────────────────────────────────────────────
// Auth validators
// ─────────────────────────────────────────────
const validateRegister = [
  body('name')
    .trim()
    .notEmpty().withMessage('Name is required')
    .isLength({ min: 2, max: 100 }).withMessage('Name must be 2–100 characters'),
  body('email')
    .trim()
    .notEmpty().withMessage('Email is required')
    .isEmail().withMessage('Invalid email address')
    .normalizeEmail(),
  body('password')
    .notEmpty().withMessage('Password is required')
    .isLength({ min: 8 }).withMessage('Password must be at least 8 characters')
    .matches(/[A-Z]/).withMessage('Password must contain at least one uppercase letter')
    .matches(/[0-9]/).withMessage('Password must contain at least one number'),
  handleValidationErrors
];

const validateLogin = [
  body('email')
    .trim()
    .notEmpty().withMessage('Email is required')
    .isEmail().withMessage('Invalid email address')
    .normalizeEmail(),
  body('password')
    .notEmpty().withMessage('Password is required'),
  handleValidationErrors
];

const validateForgotPassword = [
  body('email')
    .trim()
    .notEmpty().withMessage('Email is required')
    .isEmail().withMessage('Invalid email address')
    .normalizeEmail(),
  handleValidationErrors
];

const validateResetPassword = [
  body('token')
    .notEmpty().withMessage('Reset token is required'),
  body('password')
    .notEmpty().withMessage('Password is required')
    .isLength({ min: 8 }).withMessage('Password must be at least 8 characters')
    .matches(/[A-Z]/).withMessage('Password must contain at least one uppercase letter')
    .matches(/[0-9]/).withMessage('Password must contain at least one number'),
  handleValidationErrors
];

const validateUpdateProfile = [
  body('name')
    .optional()
    .trim()
    .isLength({ min: 2, max: 100 }).withMessage('Name must be 2–100 characters'),
  body('language')
    .optional()
    .isLength({ min: 2, max: 10 }).withMessage('Invalid language code'),
  body('currency')
    .optional()
    .isLength({ min: 3, max: 5 }).withMessage('Invalid currency code'),
  body('theme')
    .optional()
    .isIn(['light', 'dark', 'system']).withMessage('Theme must be light, dark, or system'),
  handleValidationErrors
];

// ─────────────────────────────────────────────
// Project validators
// ─────────────────────────────────────────────
const validateCreateProject = [
  body('name')
    .trim()
    .notEmpty().withMessage('Project name is required')
    .isLength({ min: 1, max: 255 }).withMessage('Name must be 1–255 characters'),
  body('description')
    .optional()
    .isLength({ max: 2000 }).withMessage('Description too long'),
  body('country')
    .optional()
    .isLength({ min: 2, max: 100 }).withMessage('Invalid country'),
  body('city')
    .optional()
    .isLength({ max: 100 }).withMessage('City name too long'),
  body('plot_length')
    .optional()
    .isFloat({ min: 1, max: 10000 }).withMessage('Plot length must be 1–10,000'),
  body('plot_width')
    .optional()
    .isFloat({ min: 1, max: 10000 }).withMessage('Plot width must be 1–10,000'),
  body('unit')
    .optional()
    .isIn(['feet', 'meters']).withMessage('Unit must be feet or meters'),
  body('floors')
    .optional()
    .isInt({ min: 1, max: 10 }).withMessage('Floors must be 1–10'),
  body('bedrooms')
    .optional()
    .isInt({ min: 0, max: 20 }).withMessage('Bedrooms must be 0–20'),
  body('bathrooms')
    .optional()
    .isInt({ min: 0, max: 20 }).withMessage('Bathrooms must be 0–20'),
  body('construction_quality')
    .optional()
    .isIn(['basic', 'standard', 'premium', 'luxury']).withMessage('Invalid construction quality'),
  body('house_style')
    .optional()
    .isLength({ max: 100 }).withMessage('House style name too long'),
  body('currency')
    .optional()
    .isLength({ min: 3, max: 5 }).withMessage('Invalid currency code'),
  handleValidationErrors
];

const validateUpdateProject = [
  param('id').isUUID().withMessage('Invalid project ID'),
  body('name')
    .optional()
    .trim()
    .isLength({ min: 1, max: 255 }).withMessage('Name must be 1–255 characters'),
  body('status')
    .optional()
    .isIn(['draft', 'planning', 'in_progress', 'completed', 'archived']).withMessage('Invalid status'),
  body('floors')
    .optional()
    .isInt({ min: 1, max: 10 }).withMessage('Floors must be 1–10'),
  body('bedrooms')
    .optional()
    .isInt({ min: 0, max: 20 }).withMessage('Bedrooms must be 0–20'),
  body('bathrooms')
    .optional()
    .isInt({ min: 0, max: 20 }).withMessage('Bathrooms must be 0–20'),
  body('construction_quality')
    .optional()
    .isIn(['basic', 'standard', 'premium', 'luxury']).withMessage('Invalid construction quality'),
  handleValidationErrors
];

const validateProjectId = [
  param('id').isUUID().withMessage('Invalid project ID'),
  handleValidationErrors
];

// ─────────────────────────────────────────────
// AI validators
// ─────────────────────────────────────────────
const validateGenerateFloorPlan = [
  body('project_id').isUUID().withMessage('Valid project ID required'),
  handleValidationErrors
];

const validateGenerateCostEstimate = [
  body('project_id').isUUID().withMessage('Valid project ID required'),
  handleValidationErrors
];

const validateGenerateMaterials = [
  body('project_id').isUUID().withMessage('Valid project ID required'),
  handleValidationErrors
];

const validateGenerateSuggestions = [
  body('project_id').isUUID().withMessage('Valid project ID required'),
  handleValidationErrors
];

const validateGenerateFullReport = [
  body('project_id').isUUID().withMessage('Valid project ID required'),
  handleValidationErrors
];

// ─────────────────────────────────────────────
// Report validators
// ─────────────────────────────────────────────
const validateGenerateReport = [
  body('project_id').isUUID().withMessage('Valid project ID required'),
  body('type')
    .isIn(['floor_plan', 'cost', 'material', 'full', 'optimization'])
    .withMessage('Invalid report type'),
  body('format')
    .optional()
    .isIn(['pdf', 'svg', 'json']).withMessage('Format must be pdf, svg, or json'),
  handleValidationErrors
];

const validateReportId = [
  param('id').isUUID().withMessage('Invalid report ID'),
  handleValidationErrors
];

// ─────────────────────────────────────────────
// Admin validators
// ─────────────────────────────────────────────
const validateUserId = [
  param('id').isUUID().withMessage('Invalid user ID'),
  handleValidationErrors
];

const validatePagination = [
  query('page').optional().isInt({ min: 1 }).withMessage('Page must be a positive integer'),
  query('limit').optional().isInt({ min: 1, max: 100 }).withMessage('Limit must be 1–100'),
  handleValidationErrors
];

module.exports = {
  handleValidationErrors,
  // Auth
  validateRegister,
  validateLogin,
  validateForgotPassword,
  validateResetPassword,
  validateUpdateProfile,
  // Projects
  validateCreateProject,
  validateUpdateProject,
  validateProjectId,
  // AI
  validateGenerateFloorPlan,
  validateGenerateCostEstimate,
  validateGenerateMaterials,
  validateGenerateSuggestions,
  validateGenerateFullReport,
  // Reports
  validateGenerateReport,
  validateReportId,
  // Admin
  validateUserId,
  validatePagination
};

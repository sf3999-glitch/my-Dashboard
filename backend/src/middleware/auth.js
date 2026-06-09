'use strict';

const jwt = require('jsonwebtoken');
const { User } = require('../models');
const logger = require('../config/logger');

/**
 * Authenticate JWT token from Authorization header or cookie
 */
const authenticate = async (req, res, next) => {
  try {
    let token = null;

    // Check Authorization header
    const authHeader = req.headers.authorization;
    if (authHeader && authHeader.startsWith('Bearer ')) {
      token = authHeader.substring(7);
    }

    // Fallback to cookie
    if (!token && req.cookies && req.cookies.access_token) {
      token = req.cookies.access_token;
    }

    if (!token) {
      return res.status(401).json({
        success: false,
        message: 'Access token required'
      });
    }

    // Verify token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    // Fetch user from database
    const user = await User.findOne({
      where: {
        id: decoded.userId,
        is_active: true
      }
    });

    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'User not found or account disabled'
      });
    }

    // Attach user to request
    req.user = user;
    req.userId = user.id;
    next();
  } catch (error) {
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({
        success: false,
        message: 'Access token expired',
        code: 'TOKEN_EXPIRED'
      });
    }
    if (error.name === 'JsonWebTokenError') {
      return res.status(401).json({
        success: false,
        message: 'Invalid access token',
        code: 'TOKEN_INVALID'
      });
    }
    logger.error('Authentication middleware error:', error);
    return res.status(500).json({
      success: false,
      message: 'Authentication failed'
    });
  }
};

/**
 * Require admin role
 */
const requireAdmin = (req, res, next) => {
  if (!req.user) {
    return res.status(401).json({
      success: false,
      message: 'Authentication required'
    });
  }

  if (req.user.role !== 'admin') {
    logger.warn(`Unauthorized admin access attempt by user ${req.user.id} (${req.user.email})`);
    return res.status(403).json({
      success: false,
      message: 'Admin access required'
    });
  }

  next();
};

/**
 * Optional authentication - attaches user if token present but doesn't fail
 */
const optionalAuth = async (req, res, next) => {
  try {
    let token = null;

    const authHeader = req.headers.authorization;
    if (authHeader && authHeader.startsWith('Bearer ')) {
      token = authHeader.substring(7);
    }

    if (!token && req.cookies && req.cookies.access_token) {
      token = req.cookies.access_token;
    }

    if (!token) {
      return next();
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    const user = await User.findOne({
      where: { id: decoded.userId, is_active: true }
    });

    if (user) {
      req.user = user;
      req.userId = user.id;
    }
  } catch (err) {
    // Silently ignore auth errors for optional auth
  }

  next();
};

/**
 * Generate JWT access token
 */
const generateAccessToken = (userId, role = 'user') => {
  return jwt.sign(
    { userId, role },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
  );
};

/**
 * Generate JWT refresh token
 */
const generateRefreshToken = (userId) => {
  return jwt.sign(
    { userId, type: 'refresh' },
    process.env.JWT_REFRESH_SECRET || process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '30d' }
  );
};

/**
 * Verify refresh token
 */
const verifyRefreshToken = (token) => {
  return jwt.verify(
    token,
    process.env.JWT_REFRESH_SECRET || process.env.JWT_SECRET
  );
};

module.exports = {
  authenticate,
  requireAdmin,
  optionalAuth,
  generateAccessToken,
  generateRefreshToken,
  verifyRefreshToken
};

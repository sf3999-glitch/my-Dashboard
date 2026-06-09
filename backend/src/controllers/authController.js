'use strict';

const crypto = require('crypto');
const bcrypt = require('bcryptjs');
const { Op } = require('sequelize');
const { User } = require('../models');
const {
  generateAccessToken,
  generateRefreshToken,
  verifyRefreshToken
} = require('../middleware/auth');
const logger = require('../config/logger');
const emailService = require('../services/emailService');

// ─────────────────────────────────────────────
// Helper: build token response
// ─────────────────────────────────────────────
const sendTokenResponse = (user, res, statusCode = 200) => {
  const accessToken = generateAccessToken(user.id, user.role);
  const refreshToken = generateRefreshToken(user.id);

  const userObj = user.toJSON ? user.toJSON() : { ...user.dataValues };
  delete userObj.password_hash;
  delete userObj.email_verify_token;
  delete userObj.password_reset_token;
  delete userObj.refresh_token;

  return res.status(statusCode).json({
    success: true,
    data: {
      user: userObj,
      access_token: accessToken,
      refresh_token: refreshToken,
      token_type: 'Bearer',
      expires_in: process.env.JWT_EXPIRES_IN || '7d'
    }
  });
};

// ─────────────────────────────────────────────
// POST /api/auth/register
// ─────────────────────────────────────────────
const register = async (req, res) => {
  const { name, email, password, language, currency } = req.body;

  const existing = await User.findOne({ where: { email } });
  if (existing) {
    return res.status(409).json({ success: false, message: 'Email already registered' });
  }

  const verifyToken = crypto.randomBytes(32).toString('hex');
  const verifyExpires = new Date(Date.now() + 24 * 60 * 60 * 1000); // 24h

  const user = await User.create({
    name,
    email,
    password_hash: password, // hashed by model hook
    provider: 'email',
    language: language || 'en',
    currency: currency || 'USD',
    email_verify_token: crypto.createHash('sha256').update(verifyToken).digest('hex'),
    email_verify_expires: verifyExpires,
    is_verified: false
  });

  // Send verification email (non-blocking)
  emailService.sendVerificationEmail(user.email, user.name, verifyToken).catch((err) => {
    logger.error('Failed to send verification email:', err);
  });

  logger.info(`New user registered: ${user.email}`);
  return sendTokenResponse(user, res, 201);
};

// ─────────────────────────────────────────────
// POST /api/auth/login
// ─────────────────────────────────────────────
const login = async (req, res) => {
  const { email, password } = req.body;

  const user = await User.findOne({ where: { email } });
  if (!user) {
    return res.status(401).json({ success: false, message: 'Invalid email or password' });
  }

  if (!user.is_active) {
    return res.status(403).json({ success: false, message: 'Account is disabled' });
  }

  if (user.provider !== 'email') {
    return res.status(400).json({
      success: false,
      message: `This account uses ${user.provider} login. Please sign in with ${user.provider}.`
    });
  }

  const valid = await user.validatePassword(password);
  if (!valid) {
    return res.status(401).json({ success: false, message: 'Invalid email or password' });
  }

  // Update last login
  await user.update({
    last_login: new Date(),
    login_count: (user.login_count || 0) + 1
  });

  logger.info(`User logged in: ${user.email}`);
  return sendTokenResponse(user, res);
};

// ─────────────────────────────────────────────
// POST /api/auth/logout
// ─────────────────────────────────────────────
const logout = async (req, res) => {
  // Clear refresh token from DB if stored
  if (req.user) {
    await req.user.update({ refresh_token: null }).catch(() => {});
  }
  return res.json({ success: true, message: 'Logged out successfully' });
};

// ─────────────────────────────────────────────
// POST /api/auth/refresh
// ─────────────────────────────────────────────
const refreshToken = async (req, res) => {
  const { refresh_token } = req.body;
  if (!refresh_token) {
    return res.status(400).json({ success: false, message: 'Refresh token required' });
  }

  let decoded;
  try {
    decoded = verifyRefreshToken(refresh_token);
  } catch (err) {
    return res.status(401).json({ success: false, message: 'Invalid or expired refresh token' });
  }

  const user = await User.findOne({ where: { id: decoded.userId, is_active: true } });
  if (!user) {
    return res.status(401).json({ success: false, message: 'User not found' });
  }

  return sendTokenResponse(user, res);
};

// ─────────────────────────────────────────────
// GET /api/auth/google/callback (handled by passport)
// ─────────────────────────────────────────────
const googleCallback = (req, res) => {
  if (!req.user) {
    return res.redirect(`${process.env.FRONTEND_URL}/auth/error?message=Google+auth+failed`);
  }
  const accessToken = generateAccessToken(req.user.id, req.user.role);
  const refreshToken2 = generateRefreshToken(req.user.id);
  const frontendUrl = process.env.FRONTEND_URL || 'http://localhost:3001';
  return res.redirect(
    `${frontendUrl}/auth/callback?token=${accessToken}&refresh=${refreshToken2}`
  );
};

// ─────────────────────────────────────────────
// POST /api/auth/forgot-password
// ─────────────────────────────────────────────
const forgotPassword = async (req, res) => {
  const { email } = req.body;

  const user = await User.findOne({ where: { email } });
  // Always respond success to prevent email enumeration
  const successMsg = 'If that email is registered, a password reset link has been sent.';
  if (!user || user.provider !== 'email') {
    return res.json({ success: true, message: successMsg });
  }

  const resetToken = crypto.randomBytes(32).toString('hex');
  const resetExpires = new Date(Date.now() + 60 * 60 * 1000); // 1 hour

  await user.update({
    password_reset_token: crypto.createHash('sha256').update(resetToken).digest('hex'),
    password_reset_expires: resetExpires
  });

  emailService.sendPasswordResetEmail(user.email, user.name, resetToken).catch((err) => {
    logger.error('Failed to send password reset email:', err);
  });

  return res.json({ success: true, message: successMsg });
};

// ─────────────────────────────────────────────
// POST /api/auth/reset-password
// ─────────────────────────────────────────────
const resetPassword = async (req, res) => {
  const { token, password } = req.body;

  const hashedToken = crypto.createHash('sha256').update(token).digest('hex');
  const user = await User.findOne({
    where: {
      password_reset_token: hashedToken,
      password_reset_expires: { [Op.gt]: new Date() }
    }
  });

  if (!user) {
    return res.status(400).json({ success: false, message: 'Invalid or expired reset token' });
  }

  await user.update({
    password_hash: password, // hashed by model hook
    password_reset_token: null,
    password_reset_expires: null
  });

  logger.info(`Password reset for user: ${user.email}`);
  return res.json({ success: true, message: 'Password reset successfully. You can now log in.' });
};

// ─────────────────────────────────────────────
// GET /api/auth/verify-email?token=xxx
// ─────────────────────────────────────────────
const verifyEmail = async (req, res) => {
  const { token } = req.query;
  if (!token) {
    return res.status(400).json({ success: false, message: 'Verification token required' });
  }

  const hashedToken = crypto.createHash('sha256').update(token).digest('hex');
  const user = await User.findOne({
    where: {
      email_verify_token: hashedToken,
      email_verify_expires: { [Op.gt]: new Date() }
    }
  });

  if (!user) {
    return res.status(400).json({ success: false, message: 'Invalid or expired verification token' });
  }

  await user.update({
    is_verified: true,
    email_verify_token: null,
    email_verify_expires: null
  });

  logger.info(`Email verified for user: ${user.email}`);
  return res.json({ success: true, message: 'Email verified successfully' });
};

// ─────────────────────────────────────────────
// GET /api/auth/profile
// ─────────────────────────────────────────────
const getProfile = async (req, res) => {
  const user = await User.findByPk(req.userId);
  if (!user) {
    return res.status(404).json({ success: false, message: 'User not found' });
  }
  return res.json({ success: true, data: { user } });
};

// ─────────────────────────────────────────────
// PUT /api/auth/profile
// ─────────────────────────────────────────────
const updateProfile = async (req, res) => {
  const { name, avatar_url, language, currency, theme } = req.body;

  const user = await User.findByPk(req.userId);
  if (!user) {
    return res.status(404).json({ success: false, message: 'User not found' });
  }

  const updates = {};
  if (name !== undefined) updates.name = name;
  if (avatar_url !== undefined) updates.avatar_url = avatar_url;
  if (language !== undefined) updates.language = language;
  if (currency !== undefined) updates.currency = currency;
  if (theme !== undefined) updates.theme = theme;

  await user.update(updates);
  return res.json({ success: true, data: { user }, message: 'Profile updated successfully' });
};

// ─────────────────────────────────────────────
// POST /api/auth/change-password
// ─────────────────────────────────────────────
const changePassword = async (req, res) => {
  const { current_password, new_password } = req.body;
  if (!current_password || !new_password) {
    return res.status(400).json({ success: false, message: 'Current and new password required' });
  }
  if (new_password.length < 8) {
    return res.status(400).json({ success: false, message: 'New password must be at least 8 characters' });
  }

  const user = await User.findByPk(req.userId);
  if (!user || user.provider !== 'email') {
    return res.status(400).json({ success: false, message: 'Password change not available for OAuth accounts' });
  }

  const valid = await user.validatePassword(current_password);
  if (!valid) {
    return res.status(401).json({ success: false, message: 'Current password is incorrect' });
  }

  await user.update({ password_hash: new_password });
  return res.json({ success: true, message: 'Password changed successfully' });
};

// ─────────────────────────────────────────────
// Handle Google OAuth user creation/login
// ─────────────────────────────────────────────
const handleGoogleUser = async (profile) => {
  const email = profile.emails[0].value;
  let user = await User.findOne({ where: { email } });

  if (!user) {
    user = await User.create({
      name: profile.displayName || email.split('@')[0],
      email,
      provider: 'google',
      provider_id: profile.id,
      avatar_url: profile.photos?.[0]?.value || null,
      is_verified: true
    });
  } else if (user.provider === 'email') {
    // Merge Google into existing email account
    await user.update({
      provider_id: profile.id,
      avatar_url: user.avatar_url || profile.photos?.[0]?.value || null,
      is_verified: true
    });
  }

  await user.update({
    last_login: new Date(),
    login_count: (user.login_count || 0) + 1
  });

  return user;
};

module.exports = {
  register,
  login,
  logout,
  refreshToken,
  googleCallback,
  forgotPassword,
  resetPassword,
  verifyEmail,
  getProfile,
  updateProfile,
  changePassword,
  handleGoogleUser
};

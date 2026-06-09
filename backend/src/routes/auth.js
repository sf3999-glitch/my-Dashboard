'use strict';

const express = require('express');
const passport = require('passport');
const { Strategy: GoogleStrategy } = require('passport-google-oauth20');

const router = express.Router();
const authController = require('../controllers/authController');
const { authenticate } = require('../middleware/auth');
const {
  validateRegister,
  validateLogin,
  validateForgotPassword,
  validateResetPassword,
  validateUpdateProfile
} = require('../middleware/validation');

// ─────────────────────────────────────────────
// Configure Google OAuth passport strategy
// ─────────────────────────────────────────────
if (process.env.GOOGLE_CLIENT_ID && process.env.GOOGLE_CLIENT_SECRET) {
  passport.use(
    new GoogleStrategy(
      {
        clientID: process.env.GOOGLE_CLIENT_ID,
        clientSecret: process.env.GOOGLE_CLIENT_SECRET,
        callbackURL: process.env.GOOGLE_CALLBACK_URL || '/api/auth/google/callback'
      },
      async (accessToken, refreshToken, profile, done) => {
        try {
          const user = await authController.handleGoogleUser(profile);
          done(null, user);
        } catch (err) {
          done(err, null);
        }
      }
    )
  );
}

passport.serializeUser((user, done) => done(null, user.id));
passport.deserializeUser(async (id, done) => {
  const { User } = require('../models');
  const user = await User.findByPk(id).catch((err) => done(err, null));
  done(null, user);
});

// ─────────────────────────────────────────────
// Routes
// ─────────────────────────────────────────────

// Public routes
router.post('/register', validateRegister, authController.register);
router.post('/login', validateLogin, authController.login);
router.post('/refresh', authController.refreshToken);
router.post('/forgot-password', validateForgotPassword, authController.forgotPassword);
router.post('/reset-password', validateResetPassword, authController.resetPassword);
router.get('/verify-email', authController.verifyEmail);

// Google OAuth
router.get(
  '/google',
  passport.authenticate('google', { scope: ['profile', 'email'], session: false })
);
router.get(
  '/google/callback',
  passport.authenticate('google', { session: false, failureRedirect: '/api/auth/google/failure' }),
  authController.googleCallback
);
router.get('/google/failure', (_req, res) => {
  res.status(401).json({ success: false, message: 'Google authentication failed' });
});

// Protected routes
router.post('/logout', authenticate, authController.logout);
router.get('/profile', authenticate, authController.getProfile);
router.put('/profile', authenticate, validateUpdateProfile, authController.updateProfile);
router.post('/change-password', authenticate, authController.changePassword);

module.exports = router;

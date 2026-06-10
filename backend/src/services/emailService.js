'use strict';

const nodemailer = require('nodemailer');
const logger = require('../config/logger');

let transporter = null;

const getTransporter = () => {
  if (transporter) return transporter;

  if (!process.env.SMTP_HOST || !process.env.SMTP_USER) {
    logger.warn('Email not configured — emails will be logged to console only');
    return null;
  }

  transporter = nodemailer.createTransport({
    host: process.env.SMTP_HOST,
    port: parseInt(process.env.SMTP_PORT || '587'),
    secure: process.env.SMTP_PORT === '465',
    auth: {
      user: process.env.SMTP_USER,
      pass: process.env.SMTP_PASS
    },
    tls: { rejectUnauthorized: false }
  });

  return transporter;
};

const sendEmail = async ({ to, subject, html, text }) => {
  const transport = getTransporter();
  if (!transport) {
    logger.info(`[Email Preview] To: ${to} | Subject: ${subject}`);
    return;
  }

  await transport.sendMail({
    from: `"AI House Planner" <${process.env.EMAIL_FROM || process.env.SMTP_USER}>`,
    to,
    subject,
    text: text || subject,
    html
  });

  logger.info(`Email sent to ${to}: ${subject}`);
};

// ─────────────────────────────────────────────
// Email templates
// ─────────────────────────────────────────────
const baseTemplate = (content) => `
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <style>
    body { font-family: Arial, sans-serif; background: #f5f5f5; margin: 0; padding: 20px; }
    .container { max-width: 600px; margin: 0 auto; background: white; border-radius: 8px; overflow: hidden; }
    .header { background: #1A237E; padding: 30px; text-align: center; }
    .header h1 { color: white; margin: 0; font-size: 24px; }
    .header p { color: #90CAF9; margin: 8px 0 0; }
    .body { padding: 30px; }
    .btn { display: inline-block; background: #1976D2; color: white; padding: 14px 30px; border-radius: 6px; text-decoration: none; font-weight: bold; margin: 20px 0; }
    .footer { background: #ECEFF1; padding: 20px; text-align: center; color: #9E9E9E; font-size: 12px; }
    .info-box { background: #E3F2FD; border-left: 4px solid #1976D2; padding: 15px; border-radius: 4px; margin: 20px 0; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>AI House Planner</h1>
      <p>Design your dream home with AI</p>
    </div>
    <div class="body">${content}</div>
    <div class="footer">
      <p>AI House Planner &amp; Construction Cost Estimator</p>
      <p>If you didn't request this email, please ignore it.</p>
    </div>
  </div>
</body>
</html>`;

const sendVerificationEmail = async (email, name, token) => {
  const frontendUrl = process.env.FRONTEND_URL || 'http://localhost:3001';
  const verifyUrl = `${frontendUrl}/auth/verify-email?token=${token}`;

  await sendEmail({
    to: email,
    subject: 'Verify your AI House Planner account',
    html: baseTemplate(`
      <h2>Hello, ${name}! 👋</h2>
      <p>Thank you for registering with AI House Planner. Please verify your email address to get started.</p>
      <div class="info-box">
        <strong>This verification link expires in 24 hours.</strong>
      </div>
      <a href="${verifyUrl}" class="btn">Verify Email Address</a>
      <p>Or copy this link: <br><a href="${verifyUrl}">${verifyUrl}</a></p>
    `)
  });
};

const sendPasswordResetEmail = async (email, name, token) => {
  const frontendUrl = process.env.FRONTEND_URL || 'http://localhost:3001';
  const resetUrl = `${frontendUrl}/auth/reset-password?token=${token}`;

  await sendEmail({
    to: email,
    subject: 'Reset your AI House Planner password',
    html: baseTemplate(`
      <h2>Password Reset Request</h2>
      <p>Hello, ${name}. We received a request to reset your password.</p>
      <div class="info-box">
        <strong>This link expires in 1 hour.</strong> If you didn't request this, you can safely ignore this email.
      </div>
      <a href="${resetUrl}" class="btn">Reset Password</a>
      <p>Or copy this link: <br><a href="${resetUrl}">${resetUrl}</a></p>
    `)
  });
};

const sendWelcomeEmail = async (email, name) => {
  await sendEmail({
    to: email,
    subject: 'Welcome to AI House Planner!',
    html: baseTemplate(`
      <h2>Welcome, ${name}! 🏠</h2>
      <p>Your account is ready. Here's what you can do:</p>
      <ul>
        <li><strong>Create a project</strong> — Enter your plot dimensions and requirements</li>
        <li><strong>Generate floor plans</strong> — AI creates optimized layouts for you</li>
        <li><strong>Get cost estimates</strong> — Detailed breakdowns for any country</li>
        <li><strong>Download reports</strong> — Professional PDF, SVG, or JSON exports</li>
      </ul>
      <a href="${process.env.FRONTEND_URL || 'http://localhost:3001'}/dashboard" class="btn">Start Planning</a>
    `)
  });
};

module.exports = {
  sendVerificationEmail,
  sendPasswordResetEmail,
  sendWelcomeEmail,
  sendEmail
};

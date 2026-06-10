'use strict';

require('dotenv').config();
const bcrypt = require('bcryptjs');
const { sequelize } = require('../config/database');
const { User, Project } = require('../models');
const logger = require('../config/logger');

const seed = async () => {
  try {
    logger.info('Starting database seed...');
    await sequelize.authenticate();

    // ─── Admin user ───────────────────────────────────────────────
    const adminEmail = process.env.ADMIN_EMAIL || 'admin@houseplanner.ai';
    const [admin] = await User.findOrCreate({
      where: { email: adminEmail },
      defaults: {
        name: 'Admin User',
        email: adminEmail,
        password_hash: process.env.ADMIN_PASSWORD || 'Admin@123456',
        role: 'admin',
        is_verified: true,
        is_active: true,
        provider: 'email',
        currency: 'USD',
        language: 'en'
      }
    });
    logger.info(`Admin user: ${admin.email} (${admin.id})`);

    // ─── Demo user ────────────────────────────────────────────────
    const [demoUser] = await User.findOrCreate({
      where: { email: 'demo@houseplanner.ai' },
      defaults: {
        name: 'Demo User',
        email: 'demo@houseplanner.ai',
        password_hash: 'Demo@123456',
        role: 'user',
        is_verified: true,
        is_active: true,
        provider: 'email',
        currency: 'USD',
        language: 'en'
      }
    });
    logger.info(`Demo user: ${demoUser.email} (${demoUser.id})`);

    // ─── Demo projects ────────────────────────────────────────────
    const demoProjects = [
      {
        user_id: demoUser.id,
        name: 'Modern Family Home - California',
        description: 'A contemporary 3-bedroom home with open floor plan and sustainable features',
        country: 'US',
        city: 'Los Angeles',
        plot_length: 60,
        plot_width: 40,
        unit: 'feet',
        floors: 2,
        bedrooms: 3,
        bathrooms: 2,
        kitchen: true,
        living_room: true,
        garage: true,
        garden: true,
        balcony: false,
        house_style: 'modern',
        construction_quality: 'premium',
        currency: 'USD',
        status: 'planning'
      },
      {
        user_id: demoUser.id,
        name: 'Compact Urban Flat - London',
        description: 'Efficient 2-bedroom apartment optimized for urban living',
        country: 'GB',
        city: 'London',
        plot_length: 30,
        plot_width: 25,
        unit: 'feet',
        floors: 1,
        bedrooms: 2,
        bathrooms: 1,
        kitchen: true,
        living_room: true,
        garage: false,
        garden: false,
        balcony: true,
        house_style: 'contemporary',
        construction_quality: 'standard',
        currency: 'GBP',
        status: 'draft'
      },
      {
        user_id: demoUser.id,
        name: 'Traditional Villa - Dubai',
        description: 'Luxurious 5-bedroom villa with Arabic architectural elements',
        country: 'AE',
        city: 'Dubai',
        plot_length: 100,
        plot_width: 80,
        unit: 'feet',
        floors: 2,
        bedrooms: 5,
        bathrooms: 4,
        kitchen: true,
        living_room: true,
        garage: true,
        garden: true,
        balcony: true,
        house_style: 'arabic',
        construction_quality: 'luxury',
        currency: 'AED',
        status: 'draft'
      },
      {
        user_id: demoUser.id,
        name: 'Eco House - Mumbai',
        description: 'Sustainable 4-bedroom home with solar panels and rainwater harvesting',
        country: 'IN',
        city: 'Mumbai',
        plot_length: 40,
        plot_width: 30,
        unit: 'meters',
        floors: 3,
        bedrooms: 4,
        bathrooms: 3,
        kitchen: true,
        living_room: true,
        garage: false,
        garden: true,
        balcony: true,
        house_style: 'modern',
        construction_quality: 'standard',
        currency: 'INR',
        status: 'draft'
      }
    ];

    for (const proj of demoProjects) {
      const [project, created] = await Project.findOrCreate({
        where: { name: proj.name, user_id: proj.user_id },
        defaults: proj
      });
      logger.info(`${created ? 'Created' : 'Found'} project: ${project.name}`);
    }

    logger.info('\nSeed completed successfully!');
    logger.info('─────────────────────────────────────────');
    logger.info(`Admin: ${adminEmail} / ${process.env.ADMIN_PASSWORD || 'Admin@123456'}`);
    logger.info('Demo:  demo@houseplanner.ai / Demo@123456');
    logger.info('─────────────────────────────────────────');
    process.exit(0);
  } catch (error) {
    logger.error('Seed failed:', error);
    process.exit(1);
  }
};

seed();

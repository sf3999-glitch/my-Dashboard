'use strict';

require('dotenv').config();
const { sequelize } = require('../config/database');
const logger = require('../config/logger');

// Import models to register them with Sequelize
require('../models');

const migrate = async () => {
  try {
    logger.info('Starting database migration...');
    await sequelize.authenticate();
    logger.info('Database connection established');

    // Sync all models - alter: true updates existing tables safely
    await sequelize.sync({ alter: process.env.NODE_ENV !== 'production' });

    logger.info('Database migration completed successfully');
    logger.info('Tables created/updated:');
    logger.info('  - users');
    logger.info('  - projects');
    logger.info('  - reports');

    process.exit(0);
  } catch (error) {
    logger.error('Migration failed:', error);
    process.exit(1);
  }
};

migrate();

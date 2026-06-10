'use strict';

const { Sequelize } = require('sequelize');
const logger = require('./logger');

const {
  DB_HOST = 'localhost',
  DB_PORT = 5432,
  DB_NAME = 'house_planner_db',
  DB_USER = 'postgres',
  DB_PASSWORD = '',
  NODE_ENV = 'development',
  DATABASE_URL
} = process.env;

let sequelize;

if (DATABASE_URL) {
  // Use connection URL if provided (e.g., Heroku, Railway)
  sequelize = new Sequelize(DATABASE_URL, {
    dialect: 'postgres',
    protocol: 'postgres',
    logging: NODE_ENV === 'development' ? (msg) => logger.debug(msg) : false,
    dialectOptions: {
      ssl: NODE_ENV === 'production'
        ? { require: true, rejectUnauthorized: false }
        : false
    },
    pool: {
      max: 10,
      min: 0,
      acquire: 30000,
      idle: 10000
    }
  });
} else {
  sequelize = new Sequelize(DB_NAME, DB_USER, DB_PASSWORD, {
    host: DB_HOST,
    port: parseInt(DB_PORT, 10),
    dialect: 'postgres',
    logging: NODE_ENV === 'development' ? (msg) => logger.debug(msg) : false,
    dialectOptions: {
      ssl: NODE_ENV === 'production'
        ? { require: true, rejectUnauthorized: false }
        : false
    },
    pool: {
      max: 10,
      min: 0,
      acquire: 30000,
      idle: 10000
    },
    define: {
      timestamps: true,
      underscored: true,
      createdAt: 'created_at',
      updatedAt: 'updated_at'
    }
  });
}

// Test database connection
const connectDatabase = async () => {
  try {
    await sequelize.authenticate();
    logger.info('Database connection established successfully.');
  } catch (error) {
    logger.error('Unable to connect to the database:', error);
    throw error;
  }
};

module.exports = { sequelize, connectDatabase };

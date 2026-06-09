'use strict';

const { DataTypes, Model } = require('sequelize');
const { sequelize } = require('../config/database');

class Project extends Model {}

Project.init(
  {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true,
      allowNull: false
    },
    user_id: {
      type: DataTypes.UUID,
      allowNull: false,
      references: {
        model: 'users',
        key: 'id'
      },
      onDelete: 'CASCADE',
      onUpdate: 'CASCADE'
    },
    name: {
      type: DataTypes.STRING(255),
      allowNull: false,
      validate: {
        notEmpty: true,
        len: [1, 255]
      }
    },
    description: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    status: {
      type: DataTypes.ENUM('draft', 'planning', 'in_progress', 'completed', 'archived'),
      defaultValue: 'draft',
      allowNull: false
    },
    // Location
    country: {
      type: DataTypes.STRING(100),
      allowNull: true
    },
    city: {
      type: DataTypes.STRING(100),
      allowNull: true
    },
    // Plot dimensions
    plot_length: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: true,
      validate: { min: 0 }
    },
    plot_width: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: true,
      validate: { min: 0 }
    },
    unit: {
      type: DataTypes.ENUM('feet', 'meters'),
      defaultValue: 'feet',
      allowNull: false
    },
    // House configuration
    floors: {
      type: DataTypes.INTEGER,
      defaultValue: 1,
      allowNull: false,
      validate: { min: 1, max: 10 }
    },
    bedrooms: {
      type: DataTypes.INTEGER,
      defaultValue: 3,
      allowNull: false,
      validate: { min: 0, max: 20 }
    },
    bathrooms: {
      type: DataTypes.INTEGER,
      defaultValue: 2,
      allowNull: false,
      validate: { min: 0, max: 20 }
    },
    kitchen: {
      type: DataTypes.BOOLEAN,
      defaultValue: true,
      allowNull: false
    },
    living_room: {
      type: DataTypes.BOOLEAN,
      defaultValue: true,
      allowNull: false
    },
    garage: {
      type: DataTypes.BOOLEAN,
      defaultValue: false,
      allowNull: false
    },
    garden: {
      type: DataTypes.BOOLEAN,
      defaultValue: false,
      allowNull: false
    },
    balcony: {
      type: DataTypes.BOOLEAN,
      defaultValue: false,
      allowNull: false
    },
    // Style and quality
    house_style: {
      type: DataTypes.STRING(100),
      allowNull: true
      // e.g.: 'modern', 'traditional', 'colonial', 'craftsman', 'mediterranean', etc.
    },
    construction_quality: {
      type: DataTypes.ENUM('basic', 'standard', 'premium', 'luxury'),
      defaultValue: 'standard',
      allowNull: false
    },
    currency: {
      type: DataTypes.STRING(10),
      defaultValue: 'USD',
      allowNull: false
    },
    // AI-generated data (stored as JSONB for flexibility)
    ai_floor_plan: {
      type: DataTypes.JSONB,
      allowNull: true,
      comment: 'AI-generated floor plan data including SVG and room data'
    },
    cost_estimate: {
      type: DataTypes.JSONB,
      allowNull: true,
      comment: 'Detailed cost breakdown by category'
    },
    material_report: {
      type: DataTypes.JSONB,
      allowNull: true,
      comment: 'Material quantities and costs'
    },
    optimization_suggestions: {
      type: DataTypes.JSONB,
      allowNull: true,
      comment: 'AI-powered optimization suggestions'
    },
    // Computed/cached values
    total_area_sqft: {
      type: DataTypes.DECIMAL(12, 2),
      allowNull: true
    },
    estimated_total_cost: {
      type: DataTypes.DECIMAL(15, 2),
      allowNull: true
    },
    // Sharing
    share_token: {
      type: DataTypes.STRING(64),
      allowNull: true,
      unique: true
    },
    is_public: {
      type: DataTypes.BOOLEAN,
      defaultValue: false,
      allowNull: false
    },
    // Metadata
    thumbnail_url: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    tags: {
      type: DataTypes.ARRAY(DataTypes.STRING),
      defaultValue: [],
      allowNull: true
    },
    metadata: {
      type: DataTypes.JSONB,
      defaultValue: {},
      allowNull: true
    }
  },
  {
    sequelize,
    modelName: 'Project',
    tableName: 'projects',
    timestamps: true,
    underscored: true,
    indexes: [
      { fields: ['user_id'] },
      { fields: ['status'] },
      { fields: ['country'] },
      { fields: ['created_at'] },
      { unique: true, fields: ['share_token'], where: { share_token: { [require('sequelize').Op.ne]: null } } }
    ]
  }
);

module.exports = Project;

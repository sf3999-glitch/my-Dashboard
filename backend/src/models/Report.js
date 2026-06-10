'use strict';

const { DataTypes, Model } = require('sequelize');
const { sequelize } = require('../config/database');

class Report extends Model {}

Report.init(
  {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true,
      allowNull: false
    },
    project_id: {
      type: DataTypes.UUID,
      allowNull: false,
      references: {
        model: 'projects',
        key: 'id'
      },
      onDelete: 'CASCADE',
      onUpdate: 'CASCADE'
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
    type: {
      type: DataTypes.ENUM('floor_plan', 'cost', 'material', 'full', 'optimization'),
      allowNull: false
    },
    file_url: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    file_size: {
      type: DataTypes.INTEGER,
      allowNull: true,
      comment: 'File size in bytes'
    },
    format: {
      type: DataTypes.ENUM('pdf', 'svg', 'json', 'png'),
      allowNull: false,
      defaultValue: 'pdf'
    },
    title: {
      type: DataTypes.STRING(255),
      allowNull: true
    },
    metadata: {
      type: DataTypes.JSONB,
      defaultValue: {},
      allowNull: true
    },
    download_count: {
      type: DataTypes.INTEGER,
      defaultValue: 0,
      allowNull: false
    },
    share_token: {
      type: DataTypes.STRING(64),
      allowNull: true,
      unique: true
    },
    expires_at: {
      type: DataTypes.DATE,
      allowNull: true
    }
  },
  {
    sequelize,
    modelName: 'Report',
    tableName: 'reports',
    timestamps: true,
    underscored: true,
    indexes: [
      { fields: ['project_id'] },
      { fields: ['user_id'] },
      { fields: ['type'] },
      { fields: ['format'] },
      { fields: ['created_at'] },
      { unique: true, fields: ['share_token'], where: { share_token: { [require('sequelize').Op.ne]: null } } }
    ]
  }
);

module.exports = Report;

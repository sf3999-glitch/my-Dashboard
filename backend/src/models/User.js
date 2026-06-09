'use strict';

const { DataTypes, Model } = require('sequelize');
const bcrypt = require('bcryptjs');
const { sequelize } = require('../config/database');

class User extends Model {
  // Instance method to check password
  async validatePassword(password) {
    if (!this.password_hash) return false;
    return bcrypt.compare(password, this.password_hash);
  }

  // Instance method to return safe user object (no password)
  toJSON() {
    const values = { ...this.get() };
    delete values.password_hash;
    return values;
  }
}

User.init(
  {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true,
      allowNull: false
    },
    email: {
      type: DataTypes.STRING(255),
      allowNull: false,
      unique: true,
      validate: {
        isEmail: true,
        notEmpty: true
      }
    },
    password_hash: {
      type: DataTypes.STRING(255),
      allowNull: true // null for OAuth users
    },
    name: {
      type: DataTypes.STRING(255),
      allowNull: false,
      validate: {
        notEmpty: true,
        len: [1, 255]
      }
    },
    avatar_url: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    provider: {
      type: DataTypes.ENUM('email', 'google', 'apple'),
      defaultValue: 'email',
      allowNull: false
    },
    provider_id: {
      type: DataTypes.STRING(255),
      allowNull: true
    },
    role: {
      type: DataTypes.ENUM('user', 'admin'),
      defaultValue: 'user',
      allowNull: false
    },
    language: {
      type: DataTypes.STRING(10),
      defaultValue: 'en',
      allowNull: false
    },
    currency: {
      type: DataTypes.STRING(10),
      defaultValue: 'USD',
      allowNull: false
    },
    theme: {
      type: DataTypes.ENUM('light', 'dark', 'system'),
      defaultValue: 'system',
      allowNull: false
    },
    is_verified: {
      type: DataTypes.BOOLEAN,
      defaultValue: false,
      allowNull: false
    },
    is_active: {
      type: DataTypes.BOOLEAN,
      defaultValue: true,
      allowNull: false
    },
    email_verify_token: {
      type: DataTypes.STRING(255),
      allowNull: true
    },
    email_verify_expires: {
      type: DataTypes.DATE,
      allowNull: true
    },
    password_reset_token: {
      type: DataTypes.STRING(255),
      allowNull: true
    },
    password_reset_expires: {
      type: DataTypes.DATE,
      allowNull: true
    },
    refresh_token: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    last_login: {
      type: DataTypes.DATE,
      allowNull: true
    },
    login_count: {
      type: DataTypes.INTEGER,
      defaultValue: 0,
      allowNull: false
    },
    metadata: {
      type: DataTypes.JSONB,
      defaultValue: {},
      allowNull: true
    }
  },
  {
    sequelize,
    modelName: 'User',
    tableName: 'users',
    timestamps: true,
    underscored: true,
    indexes: [
      { unique: true, fields: ['email'] },
      { fields: ['provider', 'provider_id'] },
      { fields: ['role'] },
      { fields: ['is_active'] },
      { fields: ['created_at'] }
    ],
    hooks: {
      beforeCreate: async (user) => {
        if (user.password_hash && !user.password_hash.startsWith('$2')) {
          user.password_hash = await bcrypt.hash(user.password_hash, 12);
        }
      },
      beforeUpdate: async (user) => {
        if (user.changed('password_hash') && user.password_hash && !user.password_hash.startsWith('$2')) {
          user.password_hash = await bcrypt.hash(user.password_hash, 12);
        }
      }
    }
  }
);

module.exports = User;

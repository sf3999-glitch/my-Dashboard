'use strict';

const User = require('./User');
const Project = require('./Project');
const Report = require('./Report');

// User <-> Project associations
User.hasMany(Project, {
  foreignKey: 'user_id',
  as: 'projects',
  onDelete: 'CASCADE'
});
Project.belongsTo(User, {
  foreignKey: 'user_id',
  as: 'user'
});

// Project <-> Report associations
Project.hasMany(Report, {
  foreignKey: 'project_id',
  as: 'reports',
  onDelete: 'CASCADE'
});
Report.belongsTo(Project, {
  foreignKey: 'project_id',
  as: 'project'
});

// User <-> Report associations
User.hasMany(Report, {
  foreignKey: 'user_id',
  as: 'reports',
  onDelete: 'CASCADE'
});
Report.belongsTo(User, {
  foreignKey: 'user_id',
  as: 'user'
});

module.exports = {
  User,
  Project,
  Report
};

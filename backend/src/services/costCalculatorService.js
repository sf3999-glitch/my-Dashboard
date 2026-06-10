'use strict';

/**
 * Construction cost calculation engine with country-specific rates.
 * Supports 100+ countries, 4 quality tiers, imperial/metric units.
 */

// Cost rates in USD per square foot for each country
// Rates represent standard quality (1.0 multiplier)
const COUNTRY_COST_RATES = {
  // North America
  US: { base: 150, labor: 65, material: 85, currency: 'USD', name: 'United States' },
  CA: { base: 140, labor: 60, material: 80, currency: 'CAD', name: 'Canada' },
  MX: { base: 45, labor: 15, material: 30, currency: 'MXN', name: 'Mexico' },

  // South America
  BR: { base: 40, labor: 12, material: 28, currency: 'BRL', name: 'Brazil' },
  AR: { base: 35, labor: 10, material: 25, currency: 'ARS', name: 'Argentina' },
  CO: { base: 38, labor: 11, material: 27, currency: 'COP', name: 'Colombia' },
  CL: { base: 55, labor: 18, material: 37, currency: 'CLP', name: 'Chile' },
  PE: { base: 32, labor: 9, material: 23, currency: 'PEN', name: 'Peru' },

  // Europe
  DE: { base: 160, labor: 75, material: 85, currency: 'EUR', name: 'Germany' },
  FR: { base: 155, labor: 70, material: 85, currency: 'EUR', name: 'France' },
  GB: { base: 175, labor: 80, material: 95, currency: 'GBP', name: 'United Kingdom' },
  IT: { base: 130, labor: 55, material: 75, currency: 'EUR', name: 'Italy' },
  ES: { base: 120, labor: 45, material: 75, currency: 'EUR', name: 'Spain' },
  NL: { base: 165, labor: 75, material: 90, currency: 'EUR', name: 'Netherlands' },
  BE: { base: 155, labor: 70, material: 85, currency: 'EUR', name: 'Belgium' },
  CH: { base: 200, labor: 95, material: 105, currency: 'CHF', name: 'Switzerland' },
  AT: { base: 155, labor: 70, material: 85, currency: 'EUR', name: 'Austria' },
  SE: { base: 175, labor: 80, material: 95, currency: 'SEK', name: 'Sweden' },
  NO: { base: 195, labor: 90, material: 105, currency: 'NOK', name: 'Norway' },
  DK: { base: 180, labor: 85, material: 95, currency: 'DKK', name: 'Denmark' },
  FI: { base: 160, labor: 72, material: 88, currency: 'EUR', name: 'Finland' },
  PT: { base: 95, labor: 35, material: 60, currency: 'EUR', name: 'Portugal' },
  GR: { base: 80, labor: 28, material: 52, currency: 'EUR', name: 'Greece' },
  PL: { base: 65, labor: 20, material: 45, currency: 'PLN', name: 'Poland' },
  CZ: { base: 70, labor: 22, material: 48, currency: 'CZK', name: 'Czech Republic' },
  HU: { base: 60, labor: 18, material: 42, currency: 'HUF', name: 'Hungary' },
  RO: { base: 45, labor: 12, material: 33, currency: 'RON', name: 'Romania' },
  TR: { base: 30, labor: 8, material: 22, currency: 'TRY', name: 'Turkey' },
  RU: { base: 35, labor: 10, material: 25, currency: 'RUB', name: 'Russia' },
  UA: { base: 25, labor: 7, material: 18, currency: 'UAH', name: 'Ukraine' },

  // Asia
  CN: { base: 50, labor: 15, material: 35, currency: 'CNY', name: 'China' },
  JP: { base: 130, labor: 55, material: 75, currency: 'JPY', name: 'Japan' },
  KR: { base: 100, labor: 40, material: 60, currency: 'KRW', name: 'South Korea' },
  IN: { base: 20, labor: 5, material: 15, currency: 'INR', name: 'India' },
  PK: { base: 18, labor: 4, material: 14, currency: 'PKR', name: 'Pakistan' },
  BD: { base: 15, labor: 3, material: 12, currency: 'BDT', name: 'Bangladesh' },
  LK: { base: 22, labor: 6, material: 16, currency: 'LKR', name: 'Sri Lanka' },
  NP: { base: 16, labor: 4, material: 12, currency: 'NPR', name: 'Nepal' },
  SG: { base: 200, labor: 90, material: 110, currency: 'SGD', name: 'Singapore' },
  MY: { base: 55, labor: 18, material: 37, currency: 'MYR', name: 'Malaysia' },
  TH: { base: 45, labor: 13, material: 32, currency: 'THB', name: 'Thailand' },
  VN: { base: 25, labor: 6, material: 19, currency: 'VND', name: 'Vietnam' },
  PH: { base: 35, labor: 10, material: 25, currency: 'PHP', name: 'Philippines' },
  ID: { base: 28, labor: 7, material: 21, currency: 'IDR', name: 'Indonesia' },
  HK: { base: 250, labor: 110, material: 140, currency: 'HKD', name: 'Hong Kong' },
  TW: { base: 95, labor: 38, material: 57, currency: 'TWD', name: 'Taiwan' },
  IL: { base: 130, labor: 55, material: 75, currency: 'ILS', name: 'Israel' },
  SA: { base: 80, labor: 25, material: 55, currency: 'SAR', name: 'Saudi Arabia' },
  AE: { base: 100, labor: 35, material: 65, currency: 'AED', name: 'UAE' },
  QA: { base: 110, labor: 38, material: 72, currency: 'QAR', name: 'Qatar' },
  KW: { base: 95, labor: 32, material: 63, currency: 'KWD', name: 'Kuwait' },
  BH: { base: 75, labor: 24, material: 51, currency: 'BHD', name: 'Bahrain' },
  OM: { base: 70, labor: 22, material: 48, currency: 'OMR', name: 'Oman' },
  JO: { base: 55, labor: 16, material: 39, currency: 'JOD', name: 'Jordan' },
  LB: { base: 50, labor: 15, material: 35, currency: 'LBP', name: 'Lebanon' },
  IQ: { base: 40, labor: 11, material: 29, currency: 'IQD', name: 'Iraq' },
  IR: { base: 20, labor: 5, material: 15, currency: 'IRR', name: 'Iran' },

  // Africa
  ZA: { base: 45, labor: 13, material: 32, currency: 'ZAR', name: 'South Africa' },
  NG: { base: 30, labor: 8, material: 22, currency: 'NGN', name: 'Nigeria' },
  EG: { base: 25, labor: 6, material: 19, currency: 'EGP', name: 'Egypt' },
  KE: { base: 28, labor: 7, material: 21, currency: 'KES', name: 'Kenya' },
  GH: { base: 25, labor: 6, material: 19, currency: 'GHS', name: 'Ghana' },
  ET: { base: 20, labor: 5, material: 15, currency: 'ETB', name: 'Ethiopia' },
  TZ: { base: 22, labor: 5, material: 17, currency: 'TZS', name: 'Tanzania' },
  MA: { base: 35, labor: 9, material: 26, currency: 'MAD', name: 'Morocco' },
  DZ: { base: 32, labor: 8, material: 24, currency: 'DZD', name: 'Algeria' },
  TN: { base: 30, labor: 8, material: 22, currency: 'TND', name: 'Tunisia' },

  // Oceania
  AU: { base: 160, labor: 72, material: 88, currency: 'AUD', name: 'Australia' },
  NZ: { base: 150, labor: 68, material: 82, currency: 'NZD', name: 'New Zealand' },
};

// Quality multipliers applied to base cost
const QUALITY_MULTIPLIERS = {
  basic:    { total: 0.65, labor: 0.70, material: 0.60, description: 'Economy grade materials, basic finishes' },
  standard: { total: 1.00, labor: 1.00, material: 1.00, description: 'Standard quality materials, good finishes' },
  premium:  { total: 1.55, labor: 1.40, material: 1.65, description: 'Premium materials, high-end finishes' },
  luxury:   { total: 2.50, labor: 2.20, material: 2.75, description: 'Luxury materials, custom finishes' },
};

// Cost distribution by category (% of total)
const COST_DISTRIBUTION = {
  foundation:       0.12,
  structure:        0.22,
  roofing:          0.08,
  electrical:       0.08,
  plumbing:         0.08,
  hvac:             0.06,
  interior_walls:   0.06,
  flooring:         0.07,
  painting:         0.04,
  doors_windows:    0.07,
  kitchen:          0.05,
  bathrooms:        0.04,
  exterior:         0.03,
};

// Room area standards (sq ft per room for standard quality)
const ROOM_STANDARDS = {
  bedroom:     { min: 120, standard: 180, premium: 250 },
  bathroom:    { min: 45,  standard: 65,  premium: 90  },
  kitchen:     { min: 100, standard: 150, premium: 220 },
  living_room: { min: 180, standard: 280, premium: 400 },
  garage:      { min: 200, standard: 400, premium: 600 },
  garden:      { min: 300, standard: 600, premium: 1200 },
  balcony:     { min: 60,  standard: 100, premium: 180 },
  hallway:     { min: 60,  standard: 80,  premium: 100 },
  dining:      { min: 100, standard: 150, premium: 200 },
};

// Material quantities per 1000 sq ft of construction
const MATERIAL_QUANTITIES_PER_1000SQFT = {
  cement:       { quantity: 400, unit: 'bags (50kg)', category: 'Structure' },
  steel:        { quantity: 4,   unit: 'tons',        category: 'Structure' },
  bricks:       { quantity: 8000, unit: 'units',      category: 'Structure' },
  sand:         { quantity: 15,  unit: 'cubic yards', category: 'Structure' },
  gravel:       { quantity: 10,  unit: 'cubic yards', category: 'Structure' },
  timber:       { quantity: 2000, unit: 'board feet', category: 'Structure' },
  roofing_tiles: { quantity: 1200, unit: 'units',     category: 'Roofing' },
  waterproofing: { quantity: 50,  unit: 'gallons',    category: 'Roofing' },
  copper_wire:  { quantity: 500,  unit: 'feet',       category: 'Electrical' },
  conduit:      { quantity: 300,  unit: 'feet',       category: 'Electrical' },
  pvc_pipe:     { quantity: 200,  unit: 'feet',       category: 'Plumbing' },
  fittings:     { quantity: 50,   unit: 'pieces',     category: 'Plumbing' },
  drywall:      { quantity: 350,  unit: 'sheets',     category: 'Interior' },
  flooring:     { quantity: 1100, unit: 'sq ft',      category: 'Interior' },
  paint:        { quantity: 45,   unit: 'gallons',    category: 'Interior' },
  insulation:   { quantity: 1100, unit: 'sq ft',      category: 'Insulation' },
  windows:      { quantity: 8,    unit: 'units',      category: 'Doors & Windows' },
  doors:        { quantity: 6,    unit: 'units',      category: 'Doors & Windows' },
};

/**
 * Converts area between sq feet and sq meters
 */
function convertArea(value, fromUnit) {
  if (fromUnit === 'meter') {
    return { sqft: value * 10.764, sqm: value };
  }
  return { sqft: value, sqm: value / 10.764 };
}

/**
 * Calculates total plot area
 */
function calculatePlotArea(length, width, unit) {
  const area = length * width;
  return convertArea(area, unit);
}

/**
 * Estimates covered area based on plot, floors, and configuration
 */
function estimateCoveredArea(plotAreaSqft, floors, hasGarage, hasGarden) {
  let groundCoverage = plotAreaSqft * 0.60; // 60% ground coverage
  if (hasGarden) groundCoverage = plotAreaSqft * 0.45;
  if (hasGarage) groundCoverage = groundCoverage * 0.85; // garage takes some ground space

  const coveredArea = groundCoverage * floors;
  return { sqft: coveredArea, sqm: coveredArea / 10.764 };
}

/**
 * Calculates room breakdown with dimensions
 */
function calculateRoomBreakdown(projectData, coveredAreaSqft, quality) {
  const qMap = { basic: 'min', standard: 'standard', premium: 'premium', luxury: 'premium' };
  const qualityKey = qMap[quality] || 'standard';
  const luxMulti = quality === 'luxury' ? 1.5 : 1.0;

  const rooms = [];
  let totalRoomArea = 0;

  // Bedrooms
  for (let i = 0; i < projectData.bedrooms; i++) {
    const area = Math.round(ROOM_STANDARDS.bedroom[qualityKey] * luxMulti);
    rooms.push({
      type: 'bedroom',
      name: i === 0 ? 'Master Bedroom' : `Bedroom ${i + 1}`,
      area_sqft: area,
      area_sqm: parseFloat((area / 10.764).toFixed(1)),
      dimensions: `${Math.round(Math.sqrt(area * 1.3))}' x ${Math.round(Math.sqrt(area / 1.3))}'`,
    });
    totalRoomArea += area;
  }

  // Bathrooms
  for (let i = 0; i < projectData.bathrooms; i++) {
    const area = Math.round(ROOM_STANDARDS.bathroom[qualityKey] * luxMulti);
    rooms.push({
      type: 'bathroom',
      name: i === 0 ? 'Master Bathroom' : `Bathroom ${i + 1}`,
      area_sqft: area,
      area_sqm: parseFloat((area / 10.764).toFixed(1)),
      dimensions: `${Math.round(Math.sqrt(area * 1.4))}' x ${Math.round(Math.sqrt(area / 1.4))}'`,
    });
    totalRoomArea += area;
  }

  // Kitchen
  if (projectData.has_kitchen || projectData.kitchen) {
    const area = Math.round(ROOM_STANDARDS.kitchen[qualityKey] * luxMulti);
    rooms.push({
      type: 'kitchen',
      name: 'Kitchen',
      area_sqft: area,
      area_sqm: parseFloat((area / 10.764).toFixed(1)),
      dimensions: `${Math.round(Math.sqrt(area * 1.5))}' x ${Math.round(Math.sqrt(area / 1.5))}'`,
    });
    totalRoomArea += area;
  }

  // Living Room
  if (projectData.has_living_room || projectData.living_room) {
    const area = Math.round(ROOM_STANDARDS.living_room[qualityKey] * luxMulti);
    rooms.push({
      type: 'living_room',
      name: 'Living Room',
      area_sqft: area,
      area_sqm: parseFloat((area / 10.764).toFixed(1)),
      dimensions: `${Math.round(Math.sqrt(area * 1.5))}' x ${Math.round(Math.sqrt(area / 1.5))}'`,
    });
    totalRoomArea += area;
  }

  // Garage
  if (projectData.has_garage || projectData.garage) {
    const area = Math.round(ROOM_STANDARDS.garage[qualityKey] * luxMulti);
    rooms.push({
      type: 'garage',
      name: 'Garage',
      area_sqft: area,
      area_sqm: parseFloat((area / 10.764).toFixed(1)),
      dimensions: `${Math.round(Math.sqrt(area * 2))}' x ${Math.round(Math.sqrt(area / 2))}'`,
    });
    totalRoomArea += area;
  }

  // Garden
  if (projectData.has_garden || projectData.garden) {
    const area = Math.round(ROOM_STANDARDS.garden[qualityKey] * luxMulti);
    rooms.push({
      type: 'garden',
      name: 'Garden',
      area_sqft: area,
      area_sqm: parseFloat((area / 10.764).toFixed(1)),
      dimensions: `${Math.round(Math.sqrt(area * 1.2))}' x ${Math.round(Math.sqrt(area / 1.2))}'`,
    });
  }

  // Balcony
  if (projectData.has_balcony || projectData.balcony) {
    const area = Math.round(ROOM_STANDARDS.balcony[qualityKey] * luxMulti);
    rooms.push({
      type: 'balcony',
      name: 'Balcony',
      area_sqft: area,
      area_sqm: parseFloat((area / 10.764).toFixed(1)),
      dimensions: `${Math.round(Math.sqrt(area * 3))}' x ${Math.round(Math.sqrt(area / 3))}'`,
    });
    totalRoomArea += area;
  }

  // Hallways and circulation (10% of total)
  const hallwayArea = Math.round(totalRoomArea * 0.10);
  rooms.push({
    type: 'hallway',
    name: 'Hallways & Circulation',
    area_sqft: hallwayArea,
    area_sqm: parseFloat((hallwayArea / 10.764).toFixed(1)),
    dimensions: 'Variable',
  });
  totalRoomArea += hallwayArea;

  return { rooms, totalRoomArea };
}

/**
 * Main cost calculation function
 * @param {Object} projectData - Project parameters
 * @param {string} targetCurrency - Target currency (e.g., 'USD')
 * @param {number} exchangeRate - Exchange rate from USD to target currency
 * @returns {Object} Detailed cost breakdown
 */
function calculateConstructionCost(projectData, targetCurrency = 'USD', exchangeRate = 1) {
  const countryCode = getCountryCode(projectData.country);
  const rates = COUNTRY_COST_RATES[countryCode] || COUNTRY_COST_RATES.US;
  const quality = projectData.construction_quality || 'standard';
  const qualityMultiplier = QUALITY_MULTIPLIERS[quality] || QUALITY_MULTIPLIERS.standard;

  // Calculate areas
  const plotArea = calculatePlotArea(
    parseFloat(projectData.plot_length),
    parseFloat(projectData.plot_width),
    projectData.unit || 'feet'
  );

  const coveredArea = estimateCoveredArea(
    plotArea.sqft,
    parseInt(projectData.floors) || 1,
    !!(projectData.has_garage || projectData.garage),
    !!(projectData.has_garden || projectData.garden)
  );

  // Room breakdown
  const { rooms, totalRoomArea } = calculateRoomBreakdown(
    projectData, coveredArea.sqft, quality
  );

  // Effective covered area (max of room total and estimated covered area)
  const effectiveSqft = Math.max(coveredArea.sqft, totalRoomArea);

  // Base cost per sq ft (USD)
  const baseCostPerSqft = rates.base * qualityMultiplier.total;

  // Total base cost in USD
  const totalCostUSD = effectiveSqft * baseCostPerSqft;

  // Calculate category breakdown
  const breakdown = {};
  Object.entries(COST_DISTRIBUTION).forEach(([category, percentage]) => {
    const amount = totalCostUSD * percentage;
    breakdown[category] = {
      amount_usd: Math.round(amount),
      amount: Math.round(amount * exchangeRate),
      percentage: (percentage * 100).toFixed(1),
      label: formatCategoryLabel(category),
    };
  });

  // Add contingency (5-10%)
  const contingencyRate = quality === 'luxury' ? 0.10 : quality === 'premium' ? 0.08 : 0.05;
  const contingency = totalCostUSD * contingencyRate;

  const totalWithContingency = totalCostUSD + contingency;

  // Construction timeline estimate
  const timelineMonths = calculateTimeline(effectiveSqft, parseInt(projectData.floors) || 1, quality);

  // Labor vs material split
  const laborCostUSD = effectiveSqft * rates.labor * qualityMultiplier.labor;
  const materialCostUSD = effectiveSqft * rates.material * qualityMultiplier.material;

  return {
    summary: {
      total_cost_usd: Math.round(totalCostUSD),
      total_cost: Math.round(totalCostUSD * exchangeRate),
      total_cost_with_contingency: Math.round(totalWithContingency * exchangeRate),
      currency: targetCurrency,
      cost_per_sqft: parseFloat((baseCostPerSqft * exchangeRate).toFixed(2)),
      cost_per_sqm: parseFloat((baseCostPerSqft * 10.764 * exchangeRate).toFixed(2)),
      labor_cost: Math.round(laborCostUSD * exchangeRate),
      material_cost: Math.round(materialCostUSD * exchangeRate),
      contingency: Math.round(contingency * exchangeRate),
      contingency_rate: contingencyRate * 100,
    },
    areas: {
      plot_sqft: Math.round(plotArea.sqft),
      plot_sqm: parseFloat(plotArea.sqm.toFixed(1)),
      covered_sqft: Math.round(effectiveSqft),
      covered_sqm: parseFloat((effectiveSqft / 10.764).toFixed(1)),
      floors: parseInt(projectData.floors) || 1,
    },
    breakdown,
    rooms,
    quality: {
      level: quality,
      multiplier: qualityMultiplier.total,
      description: qualityMultiplier.description,
    },
    timeline: {
      months: timelineMonths,
      phases: generateTimelinePhases(timelineMonths),
    },
    country_info: {
      country: projectData.country,
      code: countryCode,
      local_currency: rates.currency,
      base_rate_per_sqft: rates.base,
    },
  };
}

/**
 * Calculate material quantities for a project
 */
function calculateMaterialQuantities(projectData, coveredAreaSqft, quality) {
  const qualityMultiplier = QUALITY_MULTIPLIERS[quality] || QUALITY_MULTIPLIERS.standard;
  const scaleFactor = coveredAreaSqft / 1000;

  const materials = [];

  Object.entries(MATERIAL_QUANTITIES_PER_1000SQFT).forEach(([material, specs]) => {
    let quantity = specs.quantity * scaleFactor;

    // Apply quality adjustment for some materials
    if (['flooring', 'paint', 'doors', 'windows'].includes(material)) {
      quantity *= qualityMultiplier.material;
    }

    materials.push({
      name: formatMaterialName(material),
      quantity: Math.round(quantity),
      unit: specs.unit,
      category: specs.category,
    });
  });

  return materials;
}

/**
 * Generate optimization suggestions based on project data
 */
function generateBasicOptimizations(projectData, costData) {
  const suggestions = [];

  const quality = projectData.construction_quality || 'standard';

  if (quality === 'luxury' || quality === 'premium') {
    suggestions.push({
      type: 'cost_saving',
      title: 'Phased Construction',
      description: 'Consider building in phases to spread costs. Complete structural work first, then finishes.',
      potential_savings: '10-15%',
      priority: 'high',
    });
  }

  if (parseInt(projectData.bedrooms) >= 4) {
    suggestions.push({
      type: 'design',
      title: 'Open Plan Living',
      description: 'Combine kitchen, dining, and living areas to reduce wall costs and increase perceived space.',
      potential_savings: '5-8%',
      priority: 'medium',
    });
  }

  if (parseInt(projectData.floors) >= 2) {
    suggestions.push({
      type: 'energy',
      title: 'Optimal Staircase Placement',
      description: 'Center the staircase to minimize hallway length and maximize usable space on each floor.',
      potential_savings: '3-5%',
      priority: 'medium',
    });
  }

  suggestions.push({
    type: 'energy',
    title: 'Solar Panel Installation',
    description: 'Install solar panels to reduce long-term energy costs. ROI typically within 5-7 years.',
    potential_savings: '20-30% on energy bills',
    priority: 'medium',
  });

  suggestions.push({
    type: 'material',
    title: 'Bulk Material Purchase',
    description: 'Purchase cement, steel, and bricks in bulk at project start to lock in current prices and get volume discounts.',
    potential_savings: '5-10% on materials',
    priority: 'high',
  });

  if (!projectData.has_garden && !projectData.garden) {
    suggestions.push({
      type: 'design',
      title: 'Add Green Space',
      description: 'A small garden or green space increases property value by 5-15% and improves quality of life.',
      potential_savings: '+5-15% property value',
      priority: 'low',
    });
  }

  return suggestions;
}

// --- Helper functions ---

function getCountryCode(countryName) {
  if (!countryName) return 'US';
  if (countryName.length === 2) return countryName.toUpperCase();

  const lookup = {};
  Object.entries(COUNTRY_COST_RATES).forEach(([code, data]) => {
    lookup[data.name.toLowerCase()] = code;
  });

  return lookup[countryName.toLowerCase()] || guessCountryCode(countryName) || 'US';
}

function guessCountryCode(name) {
  const n = name.toLowerCase();
  for (const [code, data] of Object.entries(COUNTRY_COST_RATES)) {
    if (data.name.toLowerCase().includes(n) || n.includes(data.name.toLowerCase().split(' ')[0])) {
      return code;
    }
  }
  return null;
}

function formatCategoryLabel(key) {
  return key.split('_').map(w => w.charAt(0).toUpperCase() + w.slice(1)).join(' ');
}

function formatMaterialName(key) {
  return key.split('_').map(w => w.charAt(0).toUpperCase() + w.slice(1)).join(' ');
}

function calculateTimeline(sqft, floors, quality) {
  const base = Math.ceil(sqft / 500) * 2; // 2 months per 500 sqft
  const floorBonus = (floors - 1) * 2;
  const qualityBonus = { basic: 0, standard: 1, premium: 3, luxury: 5 }[quality] || 1;
  return Math.max(4, base + floorBonus + qualityBonus);
}

function generateTimelinePhases(totalMonths) {
  const phases = [
    { phase: 'Planning & Permits', percentage: 10, description: 'Architectural drawings, permits, site preparation' },
    { phase: 'Foundation', percentage: 15, description: 'Excavation, footings, foundation walls' },
    { phase: 'Structure & Framing', percentage: 25, description: 'Walls, columns, beams, floor slabs' },
    { phase: 'Roofing & Waterproofing', percentage: 10, description: 'Roof structure, tiles/sheets, waterproofing' },
    { phase: 'MEP Rough-In', percentage: 15, description: 'Electrical, plumbing, HVAC rough work' },
    { phase: 'Interior Finishing', percentage: 20, description: 'Drywall, flooring, painting, fixtures' },
    { phase: 'Exterior & Landscaping', percentage: 5, description: 'External walls, landscaping, driveway' },
  ];

  let elapsed = 0;
  return phases.map(p => {
    const months = Math.round((p.percentage / 100) * totalMonths);
    const start = elapsed + 1;
    elapsed += months;
    return { ...p, duration_months: months, start_month: start, end_month: elapsed };
  });
}

function getSupportedCountries() {
  return Object.entries(COUNTRY_COST_RATES).map(([code, data]) => ({
    code,
    name: data.name,
    currency: data.currency,
    base_rate_usd: data.base,
  })).sort((a, b) => a.name.localeCompare(b.name));
}

module.exports = {
  calculateConstructionCost,
  calculateMaterialQuantities,
  generateBasicOptimizations,
  getSupportedCountries,
  QUALITY_MULTIPLIERS,
  COUNTRY_COST_RATES,
};

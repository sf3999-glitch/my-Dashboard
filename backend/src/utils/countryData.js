'use strict';

/**
 * Comprehensive country data for construction cost estimation.
 * Fields:
 *   name: Country name
 *   code: ISO 3166-1 alpha-2
 *   currency: Default currency code
 *   cost_per_sqft_usd: Base construction cost per sq ft in USD (standard quality)
 *   labor_index: Labor cost multiplier vs US baseline (1.0)
 *   material_index: Material cost multiplier vs US baseline (1.0)
 *   permit_index: Additional % cost for permits & regulatory compliance
 *   popular_styles: Most common house styles in the region
 *   region: Geographic region
 */
const COUNTRY_DATA = {
  // ─── North America ───────────────────────────────────────────
  US: {
    name: 'United States', code: 'US', currency: 'USD',
    cost_per_sqft_usd: 150, labor_index: 1.00, material_index: 1.00, permit_index: 0.03,
    popular_styles: ['craftsman', 'colonial', 'ranch', 'farmhouse', 'modern'],
    region: 'North America'
  },
  CA: {
    name: 'Canada', code: 'CA', currency: 'CAD',
    cost_per_sqft_usd: 140, labor_index: 0.95, material_index: 0.95, permit_index: 0.03,
    popular_styles: ['craftsman', 'colonial', 'contemporary', 'modern'],
    region: 'North America'
  },
  MX: {
    name: 'Mexico', code: 'MX', currency: 'MXN',
    cost_per_sqft_usd: 45, labor_index: 0.20, material_index: 0.55, permit_index: 0.04,
    popular_styles: ['hacienda', 'colonial', 'modern', 'mediterranean'],
    region: 'North America'
  },

  // ─── South America ────────────────────────────────────────────
  BR: {
    name: 'Brazil', code: 'BR', currency: 'BRL',
    cost_per_sqft_usd: 40, labor_index: 0.18, material_index: 0.50, permit_index: 0.05,
    popular_styles: ['modern', 'contemporary', 'tropical'],
    region: 'South America'
  },
  AR: {
    name: 'Argentina', code: 'AR', currency: 'ARS',
    cost_per_sqft_usd: 35, labor_index: 0.15, material_index: 0.45, permit_index: 0.04,
    popular_styles: ['colonial', 'modern', 'traditional'],
    region: 'South America'
  },
  CO: {
    name: 'Colombia', code: 'CO', currency: 'COP',
    cost_per_sqft_usd: 38, labor_index: 0.16, material_index: 0.48, permit_index: 0.04,
    popular_styles: ['colonial', 'modern', 'tropical'],
    region: 'South America'
  },
  CL: {
    name: 'Chile', code: 'CL', currency: 'CLP',
    cost_per_sqft_usd: 55, labor_index: 0.25, material_index: 0.60, permit_index: 0.03,
    popular_styles: ['modern', 'contemporary', 'european'],
    region: 'South America'
  },
  PE: {
    name: 'Peru', code: 'PE', currency: 'PEN',
    cost_per_sqft_usd: 32, labor_index: 0.14, material_index: 0.42, permit_index: 0.04,
    popular_styles: ['colonial', 'modern', 'traditional'],
    region: 'South America'
  },
  VE: {
    name: 'Venezuela', code: 'VE', currency: 'VES',
    cost_per_sqft_usd: 28, labor_index: 0.10, material_index: 0.38, permit_index: 0.05,
    popular_styles: ['colonial', 'modern'],
    region: 'South America'
  },
  EC: {
    name: 'Ecuador', code: 'EC', currency: 'USD',
    cost_per_sqft_usd: 33, labor_index: 0.14, material_index: 0.44, permit_index: 0.04,
    popular_styles: ['colonial', 'modern', 'traditional'],
    region: 'South America'
  },
  UY: {
    name: 'Uruguay', code: 'UY', currency: 'UYU',
    cost_per_sqft_usd: 50, labor_index: 0.22, material_index: 0.58, permit_index: 0.03,
    popular_styles: ['modern', 'european', 'contemporary'],
    region: 'South America'
  },

  // ─── Europe ────────────────────────────────────────────────────
  DE: {
    name: 'Germany', code: 'DE', currency: 'EUR',
    cost_per_sqft_usd: 160, labor_index: 1.10, material_index: 1.05, permit_index: 0.04,
    popular_styles: ['modern', 'bauhaus', 'contemporary', 'traditional'],
    region: 'Europe'
  },
  FR: {
    name: 'France', code: 'FR', currency: 'EUR',
    cost_per_sqft_usd: 155, labor_index: 1.05, material_index: 1.05, permit_index: 0.04,
    popular_styles: ['french_provincial', 'modern', 'contemporary', 'mansard'],
    region: 'Europe'
  },
  GB: {
    name: 'United Kingdom', code: 'GB', currency: 'GBP',
    cost_per_sqft_usd: 175, labor_index: 1.15, material_index: 1.10, permit_index: 0.04,
    popular_styles: ['georgian', 'victorian', 'modern', 'craftsman'],
    region: 'Europe'
  },
  IT: {
    name: 'Italy', code: 'IT', currency: 'EUR',
    cost_per_sqft_usd: 130, labor_index: 0.90, material_index: 0.90, permit_index: 0.05,
    popular_styles: ['mediterranean', 'tuscan', 'modern', 'classical'],
    region: 'Europe'
  },
  ES: {
    name: 'Spain', code: 'ES', currency: 'EUR',
    cost_per_sqft_usd: 120, labor_index: 0.80, material_index: 0.88, permit_index: 0.04,
    popular_styles: ['mediterranean', 'modern', 'contemporary', 'andalusian'],
    region: 'Europe'
  },
  NL: {
    name: 'Netherlands', code: 'NL', currency: 'EUR',
    cost_per_sqft_usd: 165, labor_index: 1.12, material_index: 1.08, permit_index: 0.04,
    popular_styles: ['modern', 'dutch_gable', 'contemporary', 'minimalist'],
    region: 'Europe'
  },
  BE: {
    name: 'Belgium', code: 'BE', currency: 'EUR',
    cost_per_sqft_usd: 155, labor_index: 1.05, material_index: 1.05, permit_index: 0.04,
    popular_styles: ['modern', 'art_nouveau', 'contemporary'],
    region: 'Europe'
  },
  CH: {
    name: 'Switzerland', code: 'CH', currency: 'CHF',
    cost_per_sqft_usd: 200, labor_index: 1.45, material_index: 1.30, permit_index: 0.03,
    popular_styles: ['swiss_chalet', 'modern', 'contemporary', 'alpine'],
    region: 'Europe'
  },
  AT: {
    name: 'Austria', code: 'AT', currency: 'EUR',
    cost_per_sqft_usd: 155, labor_index: 1.05, material_index: 1.05, permit_index: 0.04,
    popular_styles: ['austrian_alpine', 'modern', 'contemporary', 'art_nouveau'],
    region: 'Europe'
  },
  SE: {
    name: 'Sweden', code: 'SE', currency: 'SEK',
    cost_per_sqft_usd: 175, labor_index: 1.18, material_index: 1.12, permit_index: 0.03,
    popular_styles: ['scandinavian', 'modern', 'minimalist'],
    region: 'Europe'
  },
  NO: {
    name: 'Norway', code: 'NO', currency: 'NOK',
    cost_per_sqft_usd: 195, labor_index: 1.40, material_index: 1.25, permit_index: 0.03,
    popular_styles: ['scandinavian', 'modern', 'nordic'],
    region: 'Europe'
  },
  DK: {
    name: 'Denmark', code: 'DK', currency: 'DKK',
    cost_per_sqft_usd: 180, labor_index: 1.25, material_index: 1.18, permit_index: 0.03,
    popular_styles: ['scandinavian', 'modern', 'danish_functional'],
    region: 'Europe'
  },
  FI: {
    name: 'Finland', code: 'FI', currency: 'EUR',
    cost_per_sqft_usd: 160, labor_index: 1.10, material_index: 1.08, permit_index: 0.03,
    popular_styles: ['scandinavian', 'modern', 'nordic', 'log_house'],
    region: 'Europe'
  },
  PT: {
    name: 'Portugal', code: 'PT', currency: 'EUR',
    cost_per_sqft_usd: 95, labor_index: 0.58, material_index: 0.75, permit_index: 0.04,
    popular_styles: ['portuguese', 'modern', 'mediterranean', 'azulejo'],
    region: 'Europe'
  },
  GR: {
    name: 'Greece', code: 'GR', currency: 'EUR',
    cost_per_sqft_usd: 80, labor_index: 0.45, material_index: 0.68, permit_index: 0.05,
    popular_styles: ['mediterranean', 'cycladic', 'modern', 'classical'],
    region: 'Europe'
  },
  PL: {
    name: 'Poland', code: 'PL', currency: 'PLN',
    cost_per_sqft_usd: 65, labor_index: 0.30, material_index: 0.62, permit_index: 0.04,
    popular_styles: ['modern', 'contemporary', 'traditional_polish'],
    region: 'Europe'
  },
  CZ: {
    name: 'Czech Republic', code: 'CZ', currency: 'CZK',
    cost_per_sqft_usd: 70, labor_index: 0.32, material_index: 0.65, permit_index: 0.04,
    popular_styles: ['modern', 'contemporary', 'central_european'],
    region: 'Europe'
  },
  HU: {
    name: 'Hungary', code: 'HU', currency: 'HUF',
    cost_per_sqft_usd: 60, labor_index: 0.28, material_index: 0.58, permit_index: 0.04,
    popular_styles: ['modern', 'contemporary', 'traditional'],
    region: 'Europe'
  },
  RO: {
    name: 'Romania', code: 'RO', currency: 'RON',
    cost_per_sqft_usd: 45, labor_index: 0.20, material_index: 0.50, permit_index: 0.04,
    popular_styles: ['modern', 'traditional_romanian', 'contemporary'],
    region: 'Europe'
  },
  TR: {
    name: 'Turkey', code: 'TR', currency: 'TRY',
    cost_per_sqft_usd: 30, labor_index: 0.13, material_index: 0.40, permit_index: 0.05,
    popular_styles: ['modern', 'ottoman', 'mediterranean', 'contemporary'],
    region: 'Europe/Asia'
  },
  RU: {
    name: 'Russia', code: 'RU', currency: 'RUB',
    cost_per_sqft_usd: 35, labor_index: 0.15, material_index: 0.42, permit_index: 0.05,
    popular_styles: ['modern', 'dacha', 'contemporary', 'traditional'],
    region: 'Europe/Asia'
  },
  UA: {
    name: 'Ukraine', code: 'UA', currency: 'UAH',
    cost_per_sqft_usd: 25, labor_index: 0.10, material_index: 0.35, permit_index: 0.05,
    popular_styles: ['modern', 'traditional', 'contemporary'],
    region: 'Europe'
  },

  // ─── Asia ──────────────────────────────────────────────────────
  CN: {
    name: 'China', code: 'CN', currency: 'CNY',
    cost_per_sqft_usd: 50, labor_index: 0.22, material_index: 0.55, permit_index: 0.05,
    popular_styles: ['modern', 'contemporary', 'chinese_traditional', 'minimalist'],
    region: 'Asia'
  },
  JP: {
    name: 'Japan', code: 'JP', currency: 'JPY',
    cost_per_sqft_usd: 130, labor_index: 0.88, material_index: 0.95, permit_index: 0.04,
    popular_styles: ['japanese_traditional', 'modern', 'contemporary', 'minimalist'],
    region: 'Asia'
  },
  KR: {
    name: 'South Korea', code: 'KR', currency: 'KRW',
    cost_per_sqft_usd: 100, labor_index: 0.65, material_index: 0.82, permit_index: 0.04,
    popular_styles: ['modern', 'contemporary', 'korean_traditional', 'minimalist'],
    region: 'Asia'
  },
  IN: {
    name: 'India', code: 'IN', currency: 'INR',
    cost_per_sqft_usd: 20, labor_index: 0.08, material_index: 0.30, permit_index: 0.04,
    popular_styles: ['modern', 'traditional_indian', 'contemporary', 'colonial'],
    region: 'Asia'
  },
  PK: {
    name: 'Pakistan', code: 'PK', currency: 'PKR',
    cost_per_sqft_usd: 18, labor_index: 0.07, material_index: 0.28, permit_index: 0.05,
    popular_styles: ['modern', 'mughal', 'traditional', 'contemporary'],
    region: 'Asia'
  },
  BD: {
    name: 'Bangladesh', code: 'BD', currency: 'BDT',
    cost_per_sqft_usd: 15, labor_index: 0.06, material_index: 0.24, permit_index: 0.05,
    popular_styles: ['modern', 'traditional', 'contemporary'],
    region: 'Asia'
  },
  LK: {
    name: 'Sri Lanka', code: 'LK', currency: 'LKR',
    cost_per_sqft_usd: 22, labor_index: 0.09, material_index: 0.32, permit_index: 0.04,
    popular_styles: ['modern', 'colonial', 'tropical', 'traditional'],
    region: 'Asia'
  },
  NP: {
    name: 'Nepal', code: 'NP', currency: 'NPR',
    cost_per_sqft_usd: 16, labor_index: 0.06, material_index: 0.25, permit_index: 0.04,
    popular_styles: ['traditional_nepali', 'modern', 'contemporary'],
    region: 'Asia'
  },
  SG: {
    name: 'Singapore', code: 'SG', currency: 'SGD',
    cost_per_sqft_usd: 200, labor_index: 1.30, material_index: 1.35, permit_index: 0.03,
    popular_styles: ['modern', 'contemporary', 'minimalist', 'tropical_modern'],
    region: 'Asia'
  },
  MY: {
    name: 'Malaysia', code: 'MY', currency: 'MYR',
    cost_per_sqft_usd: 55, labor_index: 0.25, material_index: 0.60, permit_index: 0.04,
    popular_styles: ['modern', 'tropical', 'colonial', 'contemporary'],
    region: 'Asia'
  },
  TH: {
    name: 'Thailand', code: 'TH', currency: 'THB',
    cost_per_sqft_usd: 45, labor_index: 0.18, material_index: 0.55, permit_index: 0.04,
    popular_styles: ['thai_traditional', 'modern', 'tropical', 'contemporary'],
    region: 'Asia'
  },
  VN: {
    name: 'Vietnam', code: 'VN', currency: 'VND',
    cost_per_sqft_usd: 25, labor_index: 0.10, material_index: 0.38, permit_index: 0.05,
    popular_styles: ['modern', 'french_colonial', 'contemporary', 'traditional'],
    region: 'Asia'
  },
  PH: {
    name: 'Philippines', code: 'PH', currency: 'PHP',
    cost_per_sqft_usd: 35, labor_index: 0.14, material_index: 0.48, permit_index: 0.04,
    popular_styles: ['modern', 'tropical', 'contemporary', 'colonial'],
    region: 'Asia'
  },
  ID: {
    name: 'Indonesia', code: 'ID', currency: 'IDR',
    cost_per_sqft_usd: 28, labor_index: 0.11, material_index: 0.40, permit_index: 0.04,
    popular_styles: ['tropical', 'modern', 'balinese', 'contemporary'],
    region: 'Asia'
  },
  HK: {
    name: 'Hong Kong', code: 'HK', currency: 'HKD',
    cost_per_sqft_usd: 250, labor_index: 1.60, material_index: 1.60, permit_index: 0.03,
    popular_styles: ['modern', 'contemporary', 'minimalist'],
    region: 'Asia'
  },
  TW: {
    name: 'Taiwan', code: 'TW', currency: 'TWD',
    cost_per_sqft_usd: 95, labor_index: 0.60, material_index: 0.78, permit_index: 0.04,
    popular_styles: ['modern', 'contemporary', 'japanese_influenced'],
    region: 'Asia'
  },
  MM: {
    name: 'Myanmar', code: 'MM', currency: 'MMK',
    cost_per_sqft_usd: 18, labor_index: 0.07, material_index: 0.28, permit_index: 0.05,
    popular_styles: ['modern', 'traditional_burmese', 'contemporary'],
    region: 'Asia'
  },
  KH: {
    name: 'Cambodia', code: 'KH', currency: 'KHR',
    cost_per_sqft_usd: 20, labor_index: 0.08, material_index: 0.30, permit_index: 0.05,
    popular_styles: ['khmer', 'modern', 'tropical'],
    region: 'Asia'
  },

  // ─── Middle East ───────────────────────────────────────────────
  SA: {
    name: 'Saudi Arabia', code: 'SA', currency: 'SAR',
    cost_per_sqft_usd: 80, labor_index: 0.42, material_index: 0.72, permit_index: 0.03,
    popular_styles: ['arabic', 'modern', 'contemporary', 'villa'],
    region: 'Middle East'
  },
  AE: {
    name: 'UAE', code: 'AE', currency: 'AED',
    cost_per_sqft_usd: 100, labor_index: 0.55, material_index: 0.85, permit_index: 0.03,
    popular_styles: ['modern', 'arabic', 'contemporary', 'ultra_modern'],
    region: 'Middle East'
  },
  QA: {
    name: 'Qatar', code: 'QA', currency: 'QAR',
    cost_per_sqft_usd: 110, labor_index: 0.60, material_index: 0.90, permit_index: 0.03,
    popular_styles: ['modern', 'arabic', 'contemporary'],
    region: 'Middle East'
  },
  KW: {
    name: 'Kuwait', code: 'KW', currency: 'KWD',
    cost_per_sqft_usd: 95, labor_index: 0.52, material_index: 0.82, permit_index: 0.03,
    popular_styles: ['modern', 'arabic', 'contemporary'],
    region: 'Middle East'
  },
  BH: {
    name: 'Bahrain', code: 'BH', currency: 'BHD',
    cost_per_sqft_usd: 75, labor_index: 0.40, material_index: 0.70, permit_index: 0.03,
    popular_styles: ['arabic', 'modern', 'contemporary'],
    region: 'Middle East'
  },
  OM: {
    name: 'Oman', code: 'OM', currency: 'OMR',
    cost_per_sqft_usd: 70, labor_index: 0.38, material_index: 0.65, permit_index: 0.04,
    popular_styles: ['omani_traditional', 'arabic', 'modern'],
    region: 'Middle East'
  },
  JO: {
    name: 'Jordan', code: 'JO', currency: 'JOD',
    cost_per_sqft_usd: 55, labor_index: 0.28, material_index: 0.58, permit_index: 0.04,
    popular_styles: ['arabic', 'modern', 'traditional'],
    region: 'Middle East'
  },
  IL: {
    name: 'Israel', code: 'IL', currency: 'ILS',
    cost_per_sqft_usd: 130, labor_index: 0.85, material_index: 0.90, permit_index: 0.04,
    popular_styles: ['modern', 'contemporary', 'mediterranean'],
    region: 'Middle East'
  },
  LB: {
    name: 'Lebanon', code: 'LB', currency: 'LBP',
    cost_per_sqft_usd: 50, labor_index: 0.22, material_index: 0.55, permit_index: 0.05,
    popular_styles: ['lebanese_traditional', 'mediterranean', 'modern'],
    region: 'Middle East'
  },
  IQ: {
    name: 'Iraq', code: 'IQ', currency: 'IQD',
    cost_per_sqft_usd: 40, labor_index: 0.16, material_index: 0.48, permit_index: 0.06,
    popular_styles: ['arabic', 'modern', 'traditional'],
    region: 'Middle East'
  },
  IR: {
    name: 'Iran', code: 'IR', currency: 'IRR',
    cost_per_sqft_usd: 20, labor_index: 0.08, material_index: 0.30, permit_index: 0.05,
    popular_styles: ['persian', 'modern', 'traditional'],
    region: 'Middle East'
  },

  // ─── Africa ────────────────────────────────────────────────────
  ZA: {
    name: 'South Africa', code: 'ZA', currency: 'ZAR',
    cost_per_sqft_usd: 45, labor_index: 0.18, material_index: 0.52, permit_index: 0.04,
    popular_styles: ['cape_dutch', 'modern', 'contemporary', 'ranch'],
    region: 'Africa'
  },
  NG: {
    name: 'Nigeria', code: 'NG', currency: 'NGN',
    cost_per_sqft_usd: 30, labor_index: 0.12, material_index: 0.42, permit_index: 0.05,
    popular_styles: ['modern', 'traditional', 'contemporary'],
    region: 'Africa'
  },
  EG: {
    name: 'Egypt', code: 'EG', currency: 'EGP',
    cost_per_sqft_usd: 25, labor_index: 0.09, material_index: 0.38, permit_index: 0.05,
    popular_styles: ['arabic', 'modern', 'mediterranean', 'traditional'],
    region: 'Africa'
  },
  KE: {
    name: 'Kenya', code: 'KE', currency: 'KES',
    cost_per_sqft_usd: 28, labor_index: 0.11, material_index: 0.40, permit_index: 0.04,
    popular_styles: ['modern', 'swahili', 'contemporary'],
    region: 'Africa'
  },
  GH: {
    name: 'Ghana', code: 'GH', currency: 'GHS',
    cost_per_sqft_usd: 25, labor_index: 0.09, material_index: 0.38, permit_index: 0.05,
    popular_styles: ['modern', 'traditional', 'contemporary'],
    region: 'Africa'
  },
  ET: {
    name: 'Ethiopia', code: 'ET', currency: 'ETB',
    cost_per_sqft_usd: 20, labor_index: 0.07, material_index: 0.30, permit_index: 0.05,
    popular_styles: ['modern', 'traditional_ethiopian', 'contemporary'],
    region: 'Africa'
  },
  TZ: {
    name: 'Tanzania', code: 'TZ', currency: 'TZS',
    cost_per_sqft_usd: 22, labor_index: 0.08, material_index: 0.32, permit_index: 0.05,
    popular_styles: ['swahili', 'modern', 'contemporary'],
    region: 'Africa'
  },
  MA: {
    name: 'Morocco', code: 'MA', currency: 'MAD',
    cost_per_sqft_usd: 35, labor_index: 0.14, material_index: 0.46, permit_index: 0.04,
    popular_styles: ['moroccan', 'riad', 'modern', 'mediterranean'],
    region: 'Africa'
  },
  DZ: {
    name: 'Algeria', code: 'DZ', currency: 'DZD',
    cost_per_sqft_usd: 32, labor_index: 0.12, material_index: 0.44, permit_index: 0.05,
    popular_styles: ['arabic', 'modern', 'traditional'],
    region: 'Africa'
  },
  TN: {
    name: 'Tunisia', code: 'TN', currency: 'TND',
    cost_per_sqft_usd: 30, labor_index: 0.12, material_index: 0.42, permit_index: 0.04,
    popular_styles: ['arabic', 'mediterranean', 'modern'],
    region: 'Africa'
  },
  UG: {
    name: 'Uganda', code: 'UG', currency: 'UGX',
    cost_per_sqft_usd: 18, labor_index: 0.07, material_index: 0.28, permit_index: 0.05,
    popular_styles: ['modern', 'traditional', 'contemporary'],
    region: 'Africa'
  },
  ZW: {
    name: 'Zimbabwe', code: 'ZW', currency: 'ZWL',
    cost_per_sqft_usd: 22, labor_index: 0.08, material_index: 0.32, permit_index: 0.05,
    popular_styles: ['colonial', 'modern', 'contemporary'],
    region: 'Africa'
  },

  // ─── Oceania ───────────────────────────────────────────────────
  AU: {
    name: 'Australia', code: 'AU', currency: 'AUD',
    cost_per_sqft_usd: 160, labor_index: 1.08, material_index: 1.05, permit_index: 0.03,
    popular_styles: ['queenslander', 'contemporary', 'modern', 'federation'],
    region: 'Oceania'
  },
  NZ: {
    name: 'New Zealand', code: 'NZ', currency: 'NZD',
    cost_per_sqft_usd: 150, labor_index: 1.02, material_index: 1.00, permit_index: 0.03,
    popular_styles: ['villa', 'bungalow', 'contemporary', 'modern'],
    region: 'Oceania'
  }
};

// ─────────────────────────────────────────────
// House styles registry with regional variations
// ─────────────────────────────────────────────
const HOUSE_STYLES = {
  modern: { name: 'Modern', description: 'Clean lines, minimal ornamentation, open floor plans', premium: 0.10 },
  contemporary: { name: 'Contemporary', description: 'Current design trends, sustainable features', premium: 0.12 },
  traditional: { name: 'Traditional', description: 'Classic proportions, symmetrical facade', premium: 0.00 },
  colonial: { name: 'Colonial', description: 'Symmetrical, formal design with historical references', premium: 0.05 },
  craftsman: { name: 'Craftsman', description: 'Handcrafted details, natural materials, covered porches', premium: 0.08 },
  mediterranean: { name: 'Mediterranean', description: 'Stucco exterior, terracotta tiles, arched openings', premium: 0.15 },
  ranch: { name: 'Ranch', description: 'Single story, open plan, indoor-outdoor connection', premium: -0.05 },
  farmhouse: { name: 'Farmhouse', description: 'Rustic charm, wraparound porch, practical layout', premium: 0.03 },
  victorian: { name: 'Victorian', description: 'Ornate details, asymmetrical facade, steep roofline', premium: 0.20 },
  minimalist: { name: 'Minimalist', description: 'Maximum simplicity, functional spaces, clean aesthetic', premium: 0.05 },
  industrial: { name: 'Industrial', description: 'Raw materials exposed, large windows, loft-like', premium: 0.08 },
  tudor: { name: 'Tudor', description: 'Steep gabled roofs, half-timbering, ornamental chimneys', premium: 0.15 },
  cape_cod: { name: 'Cape Cod', description: 'Steep pitched roof, wood shingles, symmetrical facade', premium: -0.02 },
  bungalow: { name: 'Bungalow', description: 'Low profile, wide porch, open interior spaces', premium: -0.05 },
  split_level: { name: 'Split Level', description: 'Multiple levels offset by half floor, space efficient', premium: 0.03 },
  arabic: { name: 'Arabic/Islamic', description: 'Geometric patterns, courtyard-centered, ornate arches', premium: 0.15 },
  scandinavian: { name: 'Scandinavian', description: 'Functional simplicity, natural light, energy efficient', premium: 0.10 },
  tropical: { name: 'Tropical', description: 'Elevated structure, large overhangs, natural ventilation', premium: 0.05 },
  japanese_traditional: { name: 'Japanese Traditional', description: 'Harmony with nature, shoji screens, tatami rooms', premium: 0.20 },
  french_provincial: { name: 'French Provincial', description: 'Symmetrical design, high mansard roof, formal gardens', premium: 0.18 },
  tuscan: { name: 'Tuscan', description: 'Stone exterior, terracotta tiles, rustic elegance', premium: 0.12 }
};

// ─────────────────────────────────────────────
// Lookup helpers
// ─────────────────────────────────────────────
const getCountryByCode = (code) => COUNTRY_DATA[code.toUpperCase()] || COUNTRY_DATA['US'];

const getCountryByName = (name) => {
  const lower = name.toLowerCase();
  return Object.values(COUNTRY_DATA).find(
    (c) => c.name.toLowerCase() === lower || c.code.toLowerCase() === lower
  ) || COUNTRY_DATA['US'];
};

const getAllCountries = () => {
  return Object.values(COUNTRY_DATA).sort((a, b) => a.name.localeCompare(b.name));
};

const getCountriesByRegion = () => {
  const regions = {};
  Object.values(COUNTRY_DATA).forEach((c) => {
    if (!regions[c.region]) regions[c.region] = [];
    regions[c.region].push(c);
  });
  return regions;
};

const getHouseStyles = () => {
  return Object.entries(HOUSE_STYLES).map(([id, style]) => ({ id, ...style }));
};

module.exports = {
  COUNTRY_DATA,
  HOUSE_STYLES,
  getCountryByCode,
  getCountryByName,
  getAllCountries,
  getCountriesByRegion,
  getHouseStyles
};

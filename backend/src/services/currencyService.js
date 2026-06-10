'use strict';

const axios = require('axios');
const NodeCache = require('node-cache');
const logger = require('../config/logger');

// Cache rates for 1 hour
const rateCache = new NodeCache({ stdTTL: 3600 });

// ─────────────────────────────────────────────
// Static fallback exchange rates (vs USD)
// Updated periodically — not for financial use
// ─────────────────────────────────────────────
const STATIC_RATES_FROM_USD = {
  USD: 1.00,
  EUR: 0.92,
  GBP: 0.79,
  JPY: 149.50,
  CAD: 1.36,
  AUD: 1.53,
  CHF: 0.88,
  CNY: 7.24,
  HKD: 7.82,
  SGD: 1.34,
  INR: 83.12,
  PKR: 278.5,
  BDT: 110.0,
  LKR: 325.0,
  NPR: 133.0,
  MXN: 17.15,
  BRL: 4.97,
  ARS: 820.0,
  COP: 3950.0,
  CLP: 900.0,
  PEN: 3.72,
  ZAR: 18.7,
  NGN: 1550.0,
  EGP: 30.9,
  KES: 153.0,
  GHS: 12.5,
  MAD: 9.97,
  TZS: 2540.0,
  ETB: 56.5,
  DZD: 134.5,
  TND: 3.10,
  SAR: 3.75,
  AED: 3.67,
  QAR: 3.64,
  KWD: 0.307,
  BHD: 0.376,
  OMR: 0.385,
  JOD: 0.709,
  ILS: 3.70,
  TRY: 30.5,
  RUB: 92.0,
  UAH: 37.0,
  PLN: 4.02,
  CZK: 22.5,
  HUF: 358.0,
  RON: 4.58,
  SEK: 10.45,
  NOK: 10.55,
  DKK: 6.88,
  IDR: 15700.0,
  MYR: 4.68,
  THB: 35.2,
  VND: 24450.0,
  PHP: 56.4,
  KRW: 1325.0,
  TWD: 31.8,
  NZD: 1.63,
  IQD: 1310.0,
  IRR: 42000.0,
  LBP: 89500.0,
  // Additional currencies
  HRK: 7.05,
  BGN: 1.80,
  ISK: 138.0,
  MKD: 56.8,
  RSD: 108.0,
  ALL: 101.0,
  BAM: 1.80,
  GEL: 2.65,
  AMD: 401.0,
  AZN: 1.70,
  BYN: 3.24,
  MDL: 17.7,
  KZT: 456.0,
  UZS: 12250.0,
  TJS: 10.9,
  TMT: 3.51,
  KGS: 89.0,
  MNT: 3450.0,
  MMK: 2100.0,
  KHR: 4085.0,
  LAK: 20500.0,
  BND: 1.34,
  PGK: 3.73,
  FJD: 2.23,
  XAF: 604.0,
  XOF: 604.0,
  GNF: 8600.0,
  MGA: 4500.0,
  MZN: 63.5,
  ZMW: 26.4,
  MWK: 1680.0,
  RWF: 1285.0,
  BIF: 2860.0,
  AOA: 830.0,
  CDF: 2750.0,
  SLL: 22000.0,
  GHS2: 12.5,
  LRD: 188.0,
  SZL: 18.7,
  LSL: 18.7,
  NAD: 18.7
};

// ─────────────────────────────────────────────
// Currency metadata
// ─────────────────────────────────────────────
const CURRENCY_METADATA = {
  USD: { name: 'US Dollar', symbol: '$', country: 'United States' },
  EUR: { name: 'Euro', symbol: '€', country: 'European Union' },
  GBP: { name: 'British Pound', symbol: '£', country: 'United Kingdom' },
  JPY: { name: 'Japanese Yen', symbol: '¥', country: 'Japan' },
  CAD: { name: 'Canadian Dollar', symbol: 'CA$', country: 'Canada' },
  AUD: { name: 'Australian Dollar', symbol: 'A$', country: 'Australia' },
  CHF: { name: 'Swiss Franc', symbol: 'CHF', country: 'Switzerland' },
  CNY: { name: 'Chinese Yuan', symbol: '¥', country: 'China' },
  HKD: { name: 'Hong Kong Dollar', symbol: 'HK$', country: 'Hong Kong' },
  SGD: { name: 'Singapore Dollar', symbol: 'S$', country: 'Singapore' },
  INR: { name: 'Indian Rupee', symbol: '₹', country: 'India' },
  PKR: { name: 'Pakistani Rupee', symbol: '₨', country: 'Pakistan' },
  BDT: { name: 'Bangladeshi Taka', symbol: '৳', country: 'Bangladesh' },
  MXN: { name: 'Mexican Peso', symbol: 'MX$', country: 'Mexico' },
  BRL: { name: 'Brazilian Real', symbol: 'R$', country: 'Brazil' },
  ARS: { name: 'Argentine Peso', symbol: 'AR$', country: 'Argentina' },
  ZAR: { name: 'South African Rand', symbol: 'R', country: 'South Africa' },
  NGN: { name: 'Nigerian Naira', symbol: '₦', country: 'Nigeria' },
  EGP: { name: 'Egyptian Pound', symbol: 'E£', country: 'Egypt' },
  KES: { name: 'Kenyan Shilling', symbol: 'KSh', country: 'Kenya' },
  SAR: { name: 'Saudi Riyal', symbol: 'SR', country: 'Saudi Arabia' },
  AED: { name: 'UAE Dirham', symbol: 'AED', country: 'UAE' },
  QAR: { name: 'Qatari Riyal', symbol: 'QR', country: 'Qatar' },
  KWD: { name: 'Kuwaiti Dinar', symbol: 'KD', country: 'Kuwait' },
  TRY: { name: 'Turkish Lira', symbol: '₺', country: 'Turkey' },
  RUB: { name: 'Russian Ruble', symbol: '₽', country: 'Russia' },
  PLN: { name: 'Polish Zloty', symbol: 'zł', country: 'Poland' },
  SEK: { name: 'Swedish Krona', symbol: 'kr', country: 'Sweden' },
  NOK: { name: 'Norwegian Krone', symbol: 'kr', country: 'Norway' },
  DKK: { name: 'Danish Krone', symbol: 'kr', country: 'Denmark' },
  IDR: { name: 'Indonesian Rupiah', symbol: 'Rp', country: 'Indonesia' },
  MYR: { name: 'Malaysian Ringgit', symbol: 'RM', country: 'Malaysia' },
  THB: { name: 'Thai Baht', symbol: '฿', country: 'Thailand' },
  PHP: { name: 'Philippine Peso', symbol: '₱', country: 'Philippines' },
  KRW: { name: 'South Korean Won', symbol: '₩', country: 'South Korea' },
  NZD: { name: 'New Zealand Dollar', symbol: 'NZ$', country: 'New Zealand' },
  ILS: { name: 'Israeli Shekel', symbol: '₪', country: 'Israel' },
  CZK: { name: 'Czech Koruna', symbol: 'Kč', country: 'Czech Republic' },
  HUF: { name: 'Hungarian Forint', symbol: 'Ft', country: 'Hungary' },
  RON: { name: 'Romanian Leu', symbol: 'lei', country: 'Romania' }
};

// Country → currency mapping
const COUNTRY_CURRENCY_MAP = {
  'United States': 'USD', 'US': 'USD', 'USA': 'USD',
  'Canada': 'CAD', 'CA': 'CAD',
  'Mexico': 'MXN', 'MX': 'MXN',
  'Brazil': 'BRL', 'BR': 'BRL',
  'Argentina': 'ARS', 'AR': 'ARS',
  'Colombia': 'COP', 'CO': 'COP',
  'Chile': 'CLP', 'CL': 'CLP',
  'Peru': 'PEN', 'PE': 'PEN',
  'Germany': 'EUR', 'DE': 'EUR',
  'France': 'EUR', 'FR': 'EUR',
  'Italy': 'EUR', 'IT': 'EUR',
  'Spain': 'EUR', 'ES': 'EUR',
  'Netherlands': 'EUR', 'NL': 'EUR',
  'Belgium': 'EUR', 'BE': 'EUR',
  'Austria': 'EUR', 'AT': 'EUR',
  'Portugal': 'EUR', 'PT': 'EUR',
  'Greece': 'EUR', 'GR': 'EUR',
  'Finland': 'EUR', 'FI': 'EUR',
  'United Kingdom': 'GBP', 'GB': 'GBP', 'UK': 'GBP',
  'Switzerland': 'CHF', 'CH': 'CHF',
  'Sweden': 'SEK', 'SE': 'SEK',
  'Norway': 'NOK', 'NO': 'NOK',
  'Denmark': 'DKK', 'DK': 'DKK',
  'Poland': 'PLN', 'PL': 'PLN',
  'Czech Republic': 'CZK', 'CZ': 'CZK',
  'Hungary': 'HUF', 'HU': 'HUF',
  'Romania': 'RON', 'RO': 'RON',
  'Turkey': 'TRY', 'TR': 'TRY',
  'Russia': 'RUB', 'RU': 'RUB',
  'Ukraine': 'UAH', 'UA': 'UAH',
  'China': 'CNY', 'CN': 'CNY',
  'Japan': 'JPY', 'JP': 'JPY',
  'South Korea': 'KRW', 'KR': 'KRW',
  'India': 'INR', 'IN': 'INR',
  'Pakistan': 'PKR', 'PK': 'PKR',
  'Bangladesh': 'BDT', 'BD': 'BDT',
  'Sri Lanka': 'LKR', 'LK': 'LKR',
  'Nepal': 'NPR', 'NP': 'NPR',
  'Singapore': 'SGD', 'SG': 'SGD',
  'Malaysia': 'MYR', 'MY': 'MYR',
  'Thailand': 'THB', 'TH': 'THB',
  'Vietnam': 'VND', 'VN': 'VND',
  'Philippines': 'PHP', 'PH': 'PHP',
  'Indonesia': 'IDR', 'ID': 'IDR',
  'Hong Kong': 'HKD', 'HK': 'HKD',
  'Taiwan': 'TWD', 'TW': 'TWD',
  'Israel': 'ILS', 'IL': 'ILS',
  'Saudi Arabia': 'SAR', 'SA': 'SAR',
  'UAE': 'AED', 'AE': 'AED',
  'Qatar': 'QAR', 'QA': 'QAR',
  'Kuwait': 'KWD', 'KW': 'KWD',
  'Bahrain': 'BHD', 'BH': 'BHD',
  'Oman': 'OMR', 'OM': 'OMR',
  'Jordan': 'JOD', 'JO': 'JOD',
  'South Africa': 'ZAR', 'ZA': 'ZAR',
  'Nigeria': 'NGN', 'NG': 'NGN',
  'Egypt': 'EGP', 'EG': 'EGP',
  'Kenya': 'KES', 'KE': 'KES',
  'Ghana': 'GHS', 'GH': 'GHS',
  'Morocco': 'MAD', 'MA': 'MAD',
  'Australia': 'AUD', 'AU': 'AUD',
  'New Zealand': 'NZD', 'NZ': 'NZD'
};

// ─────────────────────────────────────────────
// Fetch live rates from external API
// ─────────────────────────────────────────────
const fetchLiveRates = async () => {
  const cached = rateCache.get('live_rates');
  if (cached) return cached;

  try {
    if (!process.env.CURRENCY_API_KEY && !process.env.CURRENCY_API_URL) {
      return STATIC_RATES_FROM_USD;
    }
    const url = `${process.env.CURRENCY_API_URL || 'https://api.exchangerate-api.com/v4/latest/USD'}`;
    const response = await axios.get(url, { timeout: 5000 });
    const rates = response.data.rates;
    if (rates) {
      rateCache.set('live_rates', rates);
      return rates;
    }
  } catch (err) {
    logger.warn('Failed to fetch live exchange rates, using static rates:', err.message);
  }
  return STATIC_RATES_FROM_USD;
};

// ─────────────────────────────────────────────
// Get all exchange rates (USD base)
// ─────────────────────────────────────────────
const getExchangeRates = () => {
  const cached = rateCache.get('live_rates');
  return cached || STATIC_RATES_FROM_USD;
};

// ─────────────────────────────────────────────
// Get list of supported currencies
// ─────────────────────────────────────────────
const getSupportedCurrencies = () => {
  return Object.entries(CURRENCY_METADATA).map(([code, meta]) => ({
    code,
    name: meta.name,
    symbol: meta.symbol,
    country: meta.country,
    rate_vs_usd: STATIC_RATES_FROM_USD[code] || 1
  })).sort((a, b) => a.name.localeCompare(b.name));
};

// ─────────────────────────────────────────────
// Convert amount between currencies
// ─────────────────────────────────────────────
const convertAmount = async (amount, fromCurrency, toCurrency) => {
  if (fromCurrency === toCurrency) return amount;

  const rates = await fetchLiveRates();
  const fromRate = rates[fromCurrency];
  const toRate = rates[toCurrency];

  if (!fromRate || !toRate) {
    logger.warn(`Currency conversion failed: ${fromCurrency} → ${toCurrency}`);
    return amount;
  }

  // Convert: amount → USD → target
  const amountInUSD = amount / fromRate;
  return Math.round(amountInUSD * toRate * 100) / 100;
};

// ─────────────────────────────────────────────
// Get default currency for a country
// ─────────────────────────────────────────────
const getCurrencyForCountry = (country) => {
  if (!country) return 'USD';
  return COUNTRY_CURRENCY_MAP[country] ||
    COUNTRY_CURRENCY_MAP[country.toUpperCase()] ||
    'USD';
};

// ─────────────────────────────────────────────
// Format amount with currency symbol
// ─────────────────────────────────────────────
const formatCurrency = (amount, currencyCode) => {
  const meta = CURRENCY_METADATA[currencyCode];
  const symbol = meta ? meta.symbol : currencyCode;
  const formatted = Math.round(amount).toLocaleString('en-US');
  return `${symbol}${formatted}`;
};

module.exports = {
  getSupportedCurrencies,
  convertAmount,
  getCurrencyForCountry,
  getExchangeRates,
  formatCurrency,
  fetchLiveRates,
  STATIC_RATES_FROM_USD,
  CURRENCY_METADATA
};

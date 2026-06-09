class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'AI House Planner';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  // API
  static const String baseApiUrl = 'https://api.aihouseplanner.com/v1';
  static const String aiApiUrl = 'https://ai.aihouseplanner.com/v1';
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 60000;

  // Storage Keys
  static const String keyAuthToken = 'auth_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserId = 'user_id';
  static const String keyThemeMode = 'theme_mode';
  static const String keyLocale = 'locale';
  static const String keyCurrency = 'currency';
  static const String keyOnboardingDone = 'onboarding_done';
  static const String keyUserData = 'user_data';

  // Hive Boxes
  static const String boxProjects = 'projects';
  static const String boxFloorPlans = 'floor_plans';
  static const String boxCostEstimates = 'cost_estimates';
  static const String boxSettings = 'settings';

  // Supported Languages
  static const List<Map<String, String>> supportedLanguages = [
    {'code': 'en', 'name': 'English', 'nativeName': 'English', 'flag': '🇺🇸'},
    {'code': 'es', 'name': 'Spanish', 'nativeName': 'Español', 'flag': '🇪🇸'},
    {'code': 'fr', 'name': 'French', 'nativeName': 'Français', 'flag': '🇫🇷'},
    {'code': 'ar', 'name': 'Arabic', 'nativeName': 'العربية', 'flag': '🇸🇦'},
    {'code': 'zh', 'name': 'Chinese', 'nativeName': '中文', 'flag': '🇨🇳'},
    {'code': 'hi', 'name': 'Hindi', 'nativeName': 'हिंदी', 'flag': '🇮🇳'},
    {'code': 'ur', 'name': 'Urdu', 'nativeName': 'اردو', 'flag': '🇵🇰'},
  ];

  // Supported Currencies
  static const List<Map<String, dynamic>> supportedCurrencies = [
    {'code': 'USD', 'name': 'US Dollar', 'symbol': '\$', 'rate': 1.0},
    {'code': 'EUR', 'name': 'Euro', 'symbol': '€', 'rate': 0.92},
    {'code': 'GBP', 'name': 'British Pound', 'symbol': '£', 'rate': 0.79},
    {'code': 'SAR', 'name': 'Saudi Riyal', 'symbol': 'ر.س', 'rate': 3.75},
    {'code': 'AED', 'name': 'UAE Dirham', 'symbol': 'د.إ', 'rate': 3.67},
    {'code': 'PKR', 'name': 'Pakistani Rupee', 'symbol': '₨', 'rate': 278.5},
    {'code': 'INR', 'name': 'Indian Rupee', 'symbol': '₹', 'rate': 83.2},
    {'code': 'CNY', 'name': 'Chinese Yuan', 'symbol': '¥', 'rate': 7.24},
    {'code': 'MXN', 'name': 'Mexican Peso', 'symbol': '\$', 'rate': 17.15},
    {'code': 'CAD', 'name': 'Canadian Dollar', 'symbol': 'C\$', 'rate': 1.36},
    {'code': 'AUD', 'name': 'Australian Dollar', 'symbol': 'A\$', 'rate': 1.53},
    {'code': 'BRL', 'name': 'Brazilian Real', 'symbol': 'R\$', 'rate': 4.97},
    {'code': 'NGN', 'name': 'Nigerian Naira', 'symbol': '₦', 'rate': 1550.0},
    {'code': 'EGP', 'name': 'Egyptian Pound', 'symbol': 'E£', 'rate': 30.9},
    {'code': 'TRY', 'name': 'Turkish Lira', 'symbol': '₺', 'rate': 32.1},
  ];

  // House Styles
  static const List<Map<String, String>> houseStyles = [
    {'id': 'modern', 'name': 'Modern', 'description': 'Clean lines, minimalist design'},
    {'id': 'contemporary', 'name': 'Contemporary', 'description': 'Current trends, open spaces'},
    {'id': 'traditional', 'name': 'Traditional', 'description': 'Classic architectural elements'},
    {'id': 'colonial', 'name': 'Colonial', 'description': 'Symmetrical, formal design'},
    {'id': 'mediterranean', 'name': 'Mediterranean', 'description': 'Warm tones, arched windows'},
    {'id': 'craftsman', 'name': 'Craftsman', 'description': 'Natural materials, handcrafted details'},
    {'id': 'ranch', 'name': 'Ranch', 'description': 'Single story, open plan'},
    {'id': 'victorian', 'name': 'Victorian', 'description': 'Ornate details, steep roofs'},
  ];

  // Construction Quality
  static const List<Map<String, dynamic>> constructionQualities = [
    {
      'id': 'basic',
      'name': 'Basic',
      'description': 'Standard materials, functional design',
      'multiplier': 0.7,
    },
    {
      'id': 'standard',
      'name': 'Standard',
      'description': 'Good quality materials, balanced design',
      'multiplier': 1.0,
    },
    {
      'id': 'premium',
      'name': 'Premium',
      'description': 'High-end materials, detailed finishes',
      'multiplier': 1.5,
    },
    {
      'id': 'luxury',
      'name': 'Luxury',
      'description': 'Top-tier materials, custom everything',
      'multiplier': 2.2,
    },
  ];

  // Measurement Units
  static const List<Map<String, String>> measurementUnits = [
    {'id': 'feet', 'name': 'Feet (ft)', 'symbol': 'ft'},
    {'id': 'meter', 'name': 'Meters (m)', 'symbol': 'm'},
  ];

  // Default Values
  static const double defaultPlotLength = 40.0;
  static const double defaultPlotWidth = 30.0;
  static const int defaultFloors = 1;
  static const int defaultBedrooms = 3;
  static const int defaultBathrooms = 2;
  static const String defaultCurrency = 'USD';
  static const String defaultLanguage = 'en';
  static const String defaultUnit = 'feet';

  // Pagination
  static const int defaultPageSize = 20;

  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 350);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // Border Radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;

  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  // Countries list (top 100+)
  static const List<Map<String, String>> countries = [
    {'code': 'US', 'name': 'United States'},
    {'code': 'GB', 'name': 'United Kingdom'},
    {'code': 'CA', 'name': 'Canada'},
    {'code': 'AU', 'name': 'Australia'},
    {'code': 'DE', 'name': 'Germany'},
    {'code': 'FR', 'name': 'France'},
    {'code': 'IN', 'name': 'India'},
    {'code': 'PK', 'name': 'Pakistan'},
    {'code': 'SA', 'name': 'Saudi Arabia'},
    {'code': 'AE', 'name': 'United Arab Emirates'},
    {'code': 'EG', 'name': 'Egypt'},
    {'code': 'NG', 'name': 'Nigeria'},
    {'code': 'BR', 'name': 'Brazil'},
    {'code': 'MX', 'name': 'Mexico'},
    {'code': 'CN', 'name': 'China'},
    {'code': 'JP', 'name': 'Japan'},
    {'code': 'KR', 'name': 'South Korea'},
    {'code': 'TR', 'name': 'Turkey'},
    {'code': 'ZA', 'name': 'South Africa'},
    {'code': 'AR', 'name': 'Argentina'},
    {'code': 'CO', 'name': 'Colombia'},
    {'code': 'CL', 'name': 'Chile'},
    {'code': 'PE', 'name': 'Peru'},
    {'code': 'VE', 'name': 'Venezuela'},
    {'code': 'EC', 'name': 'Ecuador'},
    {'code': 'GT', 'name': 'Guatemala'},
    {'code': 'BO', 'name': 'Bolivia'},
    {'code': 'DO', 'name': 'Dominican Republic'},
    {'code': 'HN', 'name': 'Honduras'},
    {'code': 'PY', 'name': 'Paraguay'},
    {'code': 'SV', 'name': 'El Salvador'},
    {'code': 'NI', 'name': 'Nicaragua'},
    {'code': 'CR', 'name': 'Costa Rica'},
    {'code': 'PA', 'name': 'Panama'},
    {'code': 'CU', 'name': 'Cuba'},
    {'code': 'IT', 'name': 'Italy'},
    {'code': 'ES', 'name': 'Spain'},
    {'code': 'PT', 'name': 'Portugal'},
    {'code': 'NL', 'name': 'Netherlands'},
    {'code': 'BE', 'name': 'Belgium'},
    {'code': 'SE', 'name': 'Sweden'},
    {'code': 'NO', 'name': 'Norway'},
    {'code': 'DK', 'name': 'Denmark'},
    {'code': 'FI', 'name': 'Finland'},
    {'code': 'PL', 'name': 'Poland'},
    {'code': 'RU', 'name': 'Russia'},
    {'code': 'UA', 'name': 'Ukraine'},
    {'code': 'RO', 'name': 'Romania'},
    {'code': 'CZ', 'name': 'Czech Republic'},
    {'code': 'HU', 'name': 'Hungary'},
    {'code': 'GR', 'name': 'Greece'},
    {'code': 'ID', 'name': 'Indonesia'},
    {'code': 'MY', 'name': 'Malaysia'},
    {'code': 'PH', 'name': 'Philippines'},
    {'code': 'TH', 'name': 'Thailand'},
    {'code': 'VN', 'name': 'Vietnam'},
    {'code': 'BD', 'name': 'Bangladesh'},
    {'code': 'LK', 'name': 'Sri Lanka'},
    {'code': 'NP', 'name': 'Nepal'},
    {'code': 'IQ', 'name': 'Iraq'},
    {'code': 'IR', 'name': 'Iran'},
    {'code': 'SY', 'name': 'Syria'},
    {'code': 'JO', 'name': 'Jordan'},
    {'code': 'LB', 'name': 'Lebanon'},
    {'code': 'KW', 'name': 'Kuwait'},
    {'code': 'QA', 'name': 'Qatar'},
    {'code': 'BH', 'name': 'Bahrain'},
    {'code': 'OM', 'name': 'Oman'},
    {'code': 'YE', 'name': 'Yemen'},
    {'code': 'IL', 'name': 'Israel'},
    {'code': 'MA', 'name': 'Morocco'},
    {'code': 'DZ', 'name': 'Algeria'},
    {'code': 'TN', 'name': 'Tunisia'},
    {'code': 'LY', 'name': 'Libya'},
    {'code': 'SD', 'name': 'Sudan'},
    {'code': 'ET', 'name': 'Ethiopia'},
    {'code': 'KE', 'name': 'Kenya'},
    {'code': 'GH', 'name': 'Ghana'},
    {'code': 'TZ', 'name': 'Tanzania'},
    {'code': 'UG', 'name': 'Uganda'},
    {'code': 'CI', 'name': 'Ivory Coast'},
    {'code': 'CM', 'name': 'Cameroon'},
    {'code': 'SN', 'name': 'Senegal'},
    {'code': 'NZ', 'name': 'New Zealand'},
    {'code': 'SG', 'name': 'Singapore'},
    {'code': 'HK', 'name': 'Hong Kong'},
    {'code': 'TW', 'name': 'Taiwan'},
    {'code': 'AF', 'name': 'Afghanistan'},
    {'code': 'MM', 'name': 'Myanmar'},
    {'code': 'KH', 'name': 'Cambodia'},
    {'code': 'LA', 'name': 'Laos'},
    {'code': 'MN', 'name': 'Mongolia'},
    {'code': 'UZ', 'name': 'Uzbekistan'},
    {'code': 'KZ', 'name': 'Kazakhstan'},
    {'code': 'AZ', 'name': 'Azerbaijan'},
    {'code': 'GE', 'name': 'Georgia'},
    {'code': 'AM', 'name': 'Armenia'},
    {'code': 'CH', 'name': 'Switzerland'},
    {'code': 'AT', 'name': 'Austria'},
  ];
}

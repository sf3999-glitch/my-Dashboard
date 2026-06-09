import 'package:flutter/material.dart';

import 'translations/en.dart';
import 'translations/es.dart';
import 'translations/fr.dart';
import 'translations/ar.dart';
import 'translations/zh.dart';
import 'translations/hi.dart';
import 'translations/ur.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('ar'),
    Locale('zh'),
    Locale('hi'),
    Locale('ur'),
  ];

  static final Map<String, Map<String, String>> _translations = {
    'en': enTranslations,
    'es': esTranslations,
    'fr': frTranslations,
    'ar': arTranslations,
    'zh': zhTranslations,
    'hi': hiTranslations,
    'ur': urTranslations,
  };

  String translate(String key) {
    final langCode = locale.languageCode;
    final translations = _translations[langCode] ?? _translations['en']!;
    return translations[key] ?? _translations['en']![key] ?? key;
  }

  // Convenience method
  String t(String key) => translate(key);

  // App General
  String get appName => translate('app_name');
  String get loading => translate('loading');
  String get error => translate('error');
  String get retry => translate('retry');
  String get cancel => translate('cancel');
  String get confirm => translate('confirm');
  String get save => translate('save');
  String get delete => translate('delete');
  String get edit => translate('edit');
  String get share => translate('share');
  String get download => translate('download');
  String get close => translate('close');
  String get next => translate('next');
  String get back => translate('back');
  String get skip => translate('skip');
  String get done => translate('done');
  String get yes => translate('yes');
  String get no => translate('no');
  String get ok => translate('ok');
  String get search => translate('search');
  String get filter => translate('filter');
  String get noResults => translate('no_results');
  String get tryAgain => translate('try_again');

  // Auth
  String get signIn => translate('sign_in');
  String get signUp => translate('sign_up');
  String get signOut => translate('sign_out');
  String get email => translate('email');
  String get password => translate('password');
  String get confirmPassword => translate('confirm_password');
  String get forgotPassword => translate('forgot_password');
  String get resetPassword => translate('reset_password');
  String get fullName => translate('full_name');
  String get welcomeBack => translate('welcome_back');
  String get createAccount => translate('create_account');
  String get alreadyHaveAccount => translate('already_have_account');
  String get dontHaveAccount => translate('dont_have_account');
  String get continueWithGoogle => translate('continue_with_google');
  String get continueWithApple => translate('continue_with_apple');
  String get orContinueWith => translate('or_continue_with');
  String get termsAndConditions => translate('terms_and_conditions');
  String get privacyPolicy => translate('privacy_policy');
  String get agreeToTerms => translate('agree_to_terms');

  // Onboarding
  String get onboarding1Title => translate('onboarding_1_title');
  String get onboarding1Desc => translate('onboarding_1_desc');
  String get onboarding2Title => translate('onboarding_2_title');
  String get onboarding2Desc => translate('onboarding_2_desc');
  String get onboarding3Title => translate('onboarding_3_title');
  String get onboarding3Desc => translate('onboarding_3_desc');
  String get getStarted => translate('get_started');

  // Home / Projects
  String get myProjects => translate('my_projects');
  String get newProject => translate('new_project');
  String get noProjects => translate('no_projects');
  String get noProjectsDesc => translate('no_projects_desc');
  String get createFirstProject => translate('create_first_project');
  String get projectName => translate('project_name');
  String get projectLocation => translate('project_location');
  String get projectCreated => translate('project_created');
  String get projectUpdated => translate('project_updated');
  String get projectDeleted => translate('project_deleted');
  String get deleteProject => translate('delete_project');
  String get deleteProjectConfirm => translate('delete_project_confirm');
  String get duplicateProject => translate('duplicate_project');

  // Project Status
  String get statusDraft => translate('status_draft');
  String get statusGenerating => translate('status_generating');
  String get statusCompleted => translate('status_completed');
  String get statusError => translate('status_error');

  // New Project Steps
  String get createProject => translate('create_project');
  String get step1Location => translate('step_1_location');
  String get step2Plot => translate('step_2_plot');
  String get step3Rooms => translate('step_3_rooms');
  String get step4Style => translate('step_4_style');
  String get country => translate('country');
  String get city => translate('city');
  String get plotLength => translate('plot_length');
  String get plotWidth => translate('plot_width');
  String get numberOfFloors => translate('number_of_floors');
  String get bedrooms => translate('bedrooms');
  String get bathrooms => translate('bathrooms');
  String get kitchen => translate('kitchen');
  String get livingRoom => translate('living_room');
  String get garage => translate('garage');
  String get garden => translate('garden');
  String get balcony => translate('balcony');
  String get houseStyle => translate('house_style');
  String get constructionQuality => translate('construction_quality');
  String get unit => translate('unit');
  String get generatePlan => translate('generate_plan');
  String get generatingPlan => translate('generating_plan');
  String get generatingPlanDesc => translate('generating_plan_desc');

  // Floor Plan
  String get floorPlan => translate('floor_plan');
  String get viewFloorPlan => translate('view_floor_plan');
  String get floor => translate('floor');
  String get totalArea => translate('total_area');
  String get rooms => translate('rooms');
  String get zoomIn => translate('zoom_in');
  String get zoomOut => translate('zoom_out');
  String get resetView => translate('reset_view');

  // Cost Estimate
  String get costEstimate => translate('cost_estimate');
  String get totalCost => translate('total_cost');
  String get costBreakdown => translate('cost_breakdown');
  String get foundation => translate('foundation');
  String get structure => translate('structure');
  String get roofing => translate('roofing');
  String get electrical => translate('electrical');
  String get plumbing => translate('plumbing');
  String get hvac => translate('hvac');
  String get interior => translate('interior');
  String get exterior => translate('exterior');
  String get landscaping => translate('landscaping');
  String get laborCost => translate('labor_cost');
  String get materialCost => translate('material_cost');
  String get contingency => translate('contingency');
  String get timeline => translate('timeline');
  String get perSqft => translate('per_sqft');
  String get perSqm => translate('per_sqm');
  String get changeCurrency => translate('change_currency');

  // Materials
  String get materials => translate('materials');
  String get materialName => translate('material_name');
  String get quantity => translate('quantity');
  String get unitPrice => translate('unit_price');
  String get totalPrice => translate('total_price');
  String get category => translate('category');

  // Report
  String get report => translate('report');
  String get downloadReport => translate('download_report');
  String get shareReport => translate('share_report');
  String get emailReport => translate('email_report');
  String get copyLink => translate('copy_link');
  String get linkCopied => translate('link_copied');
  String get pdfReport => translate('pdf_report');
  String get generatingReport => translate('generating_report');

  // Settings
  String get settings => translate('settings');
  String get appearance => translate('appearance');
  String get darkMode => translate('dark_mode');
  String get lightMode => translate('light_mode');
  String get systemTheme => translate('system_theme');
  String get language => translate('language');
  String get currency => translate('currency');
  String get notifications => translate('notifications');
  String get about => translate('about');
  String get appVersion => translate('app_version');
  String get termsOfService => translate('terms_of_service');
  String get rateApp => translate('rate_app');
  String get contactSupport => translate('contact_support');
  String get profile => translate('profile');
  String get account => translate('account');

  // Errors
  String get errorGeneral => translate('error_general');
  String get errorNetwork => translate('error_network');
  String get errorAuth => translate('error_auth');
  String get errorInvalidEmail => translate('error_invalid_email');
  String get errorWeakPassword => translate('error_weak_password');
  String get errorPasswordMismatch => translate('error_password_mismatch');
  String get errorFieldRequired => translate('error_field_required');
  String get errorAiGeneration => translate('error_ai_generation');

  // Validation
  String get validationRequired => translate('validation_required');
  String get validationEmail => translate('validation_email');
  String get validationMinLength => translate('validation_min_length');
  String get validationPasswordStrength => translate('validation_password_strength');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'es', 'fr', 'ar', 'zh', 'hi', 'ur']
        .contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

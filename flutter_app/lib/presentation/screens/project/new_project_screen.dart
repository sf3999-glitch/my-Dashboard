import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../data/models/project_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/project_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

class NewProjectScreen extends ConsumerStatefulWidget {
  const NewProjectScreen({super.key});

  @override
  ConsumerState<NewProjectScreen> createState() => _NewProjectScreenState();
}

class _NewProjectScreenState extends ConsumerState<NewProjectScreen>
    with TickerProviderStateMixin {
  int _currentStep = 0;
  final _totalSteps = 4;

  late AnimationController _stepAnimController;
  late Animation<Offset> _slideAnim;

  // Step 1: Location
  String? _selectedCountry;
  final _cityController = TextEditingController();

  // Step 2: Plot Details
  final _lengthController = TextEditingController(text: '40');
  final _widthController = TextEditingController(text: '30');
  String _selectedUnit = 'feet';
  int _floors = 1;

  // Step 3: Rooms
  int _bedrooms = 3;
  int _bathrooms = 2;
  bool _hasKitchen = true;
  bool _hasLivingRoom = true;
  bool _hasGarage = false;
  bool _hasGarden = false;
  bool _hasBalcony = false;

  // Step 4: Style
  String _selectedStyle = 'modern';
  String _selectedQuality = 'standard';

  // Form keys
  final _step1Key = GlobalKey<FormState>();
  final _step2Key = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _stepAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _stepAnimController, curve: Curves.easeOutCubic));
    _stepAnimController.forward();
  }

  @override
  void dispose() {
    _cityController.dispose();
    _lengthController.dispose();
    _widthController.dispose();
    _stepAnimController.dispose();
    super.dispose();
  }

  void _goToStep(int step) {
    _stepAnimController.reset();
    setState(() => _currentStep = step);
    _stepAnimController.forward();
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        if (_selectedCountry == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a country')),
          );
          return false;
        }
        if (_cityController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter a city')),
          );
          return false;
        }
        return true;
      case 1:
        return _step2Key.currentState?.validate() ?? false;
      case 2:
        return true;
      case 3:
        return true;
      default:
        return true;
    }
  }

  Future<void> _createProject() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final project = ProjectModel(
      id: const Uuid().v4(),
      userId: user.id,
      name: '${_selectedStyle.capitalize()} Home in ${_cityController.text.trim()}',
      country: _selectedCountry ?? '',
      city: _cityController.text.trim(),
      plotLength: double.tryParse(_lengthController.text) ?? 40,
      plotWidth: double.tryParse(_widthController.text) ?? 30,
      unit: _selectedUnit,
      floors: _floors,
      bedrooms: _bedrooms,
      bathrooms: _bathrooms,
      hasKitchen: _hasKitchen,
      hasLivingRoom: _hasLivingRoom,
      hasGarage: _hasGarage,
      hasGarden: _hasGarden,
      hasBalcony: _hasBalcony,
      houseStyle: _selectedStyle,
      constructionQuality: _selectedQuality,
      status: ProjectStatus.generating,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final newProject = await ref.read(projectsProvider.notifier).createProject(project);
    if (newProject != null && mounted) {
      // Navigate to project detail where generation will happen
      context.pushReplacement('/project/${newProject.id}', extra: newProject);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(l10n.createProject),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_currentStep + 1) / _totalSteps,
            backgroundColor: colorScheme.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            minHeight: 4,
          ),
        ),
      ),
      body: Column(
        children: [
          // Step indicators
          _buildStepIndicators(context, l10n, colorScheme),

          // Step content
          Expanded(
            child: SlideTransition(
              position: _slideAnim,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: _buildCurrentStep(context, l10n, colorScheme),
              ),
            ),
          ),

          // Navigation buttons
          _buildNavigation(context, l10n, colorScheme),
        ],
      ),
    );
  }

  Widget _buildStepIndicators(
    BuildContext context,
    AppLocalizations l10n,
    ColorScheme colorScheme,
  ) {
    final steps = [l10n.step1Location, l10n.step2Plot, l10n.step3Rooms, l10n.step4Style];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(bottom: BorderSide(color: colorScheme.outline, width: 0.5)),
      ),
      child: Row(
        children: List.generate(steps.length, (i) {
          final isActive = i == _currentStep;
          final isDone = i < _currentStep;

          return Expanded(
            child: GestureDetector(
              onTap: i < _currentStep ? () => _goToStep(i) : null,
              child: Column(
                children: [
                  Row(
                    children: [
                      if (i > 0) Expanded(child: Divider(
                        color: isDone ? colorScheme.primary : colorScheme.outline,
                        thickness: 2,
                      )),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: isActive || isDone
                              ? colorScheme.primary
                              : colorScheme.surfaceVariant,
                          shape: BoxShape.circle,
                          boxShadow: isActive
                              ? [BoxShadow(color: colorScheme.primary.withOpacity(0.3), blurRadius: 8, spreadRadius: 2)]
                              : null,
                        ),
                        child: Center(
                          child: isDone
                              ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                              : Text(
                                  '${i + 1}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: isActive ? Colors.white : colorScheme.onSurfaceVariant,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                        ),
                      ),
                      if (i < steps.length - 1) Expanded(child: Divider(
                        color: isDone ? colorScheme.primary : colorScheme.outline,
                        thickness: 2,
                      )),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    steps[i],
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                      color: isActive ? colorScheme.primary : colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCurrentStep(
    BuildContext context,
    AppLocalizations l10n,
    ColorScheme colorScheme,
  ) {
    switch (_currentStep) {
      case 0:
        return _buildStep1(context, l10n, colorScheme);
      case 1:
        return _buildStep2(context, l10n, colorScheme);
      case 2:
        return _buildStep3(context, l10n, colorScheme);
      case 3:
        return _buildStep4(context, l10n, colorScheme);
      default:
        return const SizedBox();
    }
  }

  Widget _buildStep1(BuildContext context, AppLocalizations l10n, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepHeader(context, Icons.location_on_rounded, l10n.step1Location, 'Where will your house be built?', colorScheme),
        const SizedBox(height: 28),
        // Country dropdown
        DropdownButtonFormField<String>(
          value: _selectedCountry,
          decoration: InputDecoration(
            labelText: l10n.country,
            prefixIcon: const Icon(Icons.flag_rounded),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          hint: const Text('Select Country'),
          isExpanded: true,
          items: AppConstants.countries.map((country) {
            return DropdownMenuItem<String>(
              value: country['code'],
              child: Text(country['name']!),
            );
          }).toList(),
          onChanged: (value) => setState(() => _selectedCountry = value),
        ),
        const SizedBox(height: 16),
        // City input
        CustomTextField(
          controller: _cityController,
          label: l10n.city,
          hint: 'Enter city name',
          prefixIcon: Icons.location_city_rounded,
          validator: (value) {
            if (value == null || value.isEmpty) return l10n.validationRequired;
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildStep2(BuildContext context, AppLocalizations l10n, ColorScheme colorScheme) {
    return Form(
      key: _step2Key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepHeader(context, Icons.square_foot_rounded, l10n.step2Plot, 'Enter your plot dimensions', colorScheme),
          const SizedBox(height: 28),

          // Unit selector
          Row(
            children: AppConstants.measurementUnits.map((unit) {
              final isSelected = _selectedUnit == unit['id'];
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: unit['id'] == 'feet' ? 8 : 0),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedUnit = unit['id']!),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? colorScheme.primary : colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? colorScheme.primary : colorScheme.outline,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            unit['symbol']!,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: isSelected ? Colors.white : colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            unit['name']!,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              color: isSelected ? Colors.white.withOpacity(0.8) : colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // Plot dimensions
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _lengthController,
                  decoration: InputDecoration(
                    labelText: l10n.plotLength,
                    suffixText: _selectedUnit == 'feet' ? 'ft' : 'm',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Required';
                    final d = double.tryParse(value);
                    if (d == null || d <= 0) return 'Invalid';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close_rounded, size: 16, color: colorScheme.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _widthController,
                  decoration: InputDecoration(
                    labelText: l10n.plotWidth,
                    suffixText: _selectedUnit == 'feet' ? 'ft' : 'm',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Required';
                    final d = double.tryParse(value);
                    if (d == null || d <= 0) return 'Invalid';
                    return null;
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Area preview
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline, color: colorScheme.primary, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Plot Area: ${((double.tryParse(_lengthController.text) ?? 0) * (double.tryParse(_widthController.text) ?? 0)).toStringAsFixed(0)} ${_selectedUnit == 'feet' ? 'sq ft' : 'sq m'}',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Number of floors
          _buildCounterCard(
            context,
            icon: Icons.layers_rounded,
            title: l10n.numberOfFloors,
            value: _floors,
            min: 1,
            max: 5,
            colorScheme: colorScheme,
            onChanged: (v) => setState(() => _floors = v),
          ),
        ],
      ),
    );
  }

  Widget _buildStep3(BuildContext context, AppLocalizations l10n, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepHeader(context, Icons.bedroom_parent_rounded, l10n.step3Rooms, 'Configure your room layout', colorScheme),
        const SizedBox(height: 28),

        // Bedrooms slider
        _buildSliderCard(
          context,
          icon: Icons.bed_rounded,
          title: l10n.bedrooms,
          value: _bedrooms,
          min: 1,
          max: 8,
          colorScheme: colorScheme,
          color: const Color(0xFF5CA85C),
          onChanged: (v) => setState(() => _bedrooms = v),
        ),
        const SizedBox(height: 16),

        // Bathrooms counter
        _buildCounterCard(
          context,
          icon: Icons.bathtub_rounded,
          title: l10n.bathrooms,
          value: _bathrooms,
          min: 1,
          max: 6,
          colorScheme: colorScheme,
          onChanged: (v) => setState(() => _bathrooms = v),
        ),
        const SizedBox(height: 20),

        Text(
          'Additional Rooms',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),

        // Room toggles grid
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.5,
          children: [
            _roomToggle(context, Icons.kitchen_rounded, l10n.kitchen, _hasKitchen, (v) => setState(() => _hasKitchen = v), colorScheme, const Color(0xFFD9A44A)),
            _roomToggle(context, Icons.weekend_rounded, l10n.livingRoom, _hasLivingRoom, (v) => setState(() => _hasLivingRoom = v), colorScheme, const Color(0xFF4A90D9)),
            _roomToggle(context, Icons.garage_rounded, l10n.garage, _hasGarage, (v) => setState(() => _hasGarage = v), colorScheme, const Color(0xFF888888)),
            _roomToggle(context, Icons.yard_rounded, l10n.garden, _hasGarden, (v) => setState(() => _hasGarden = v), colorScheme, const Color(0xFF4AD94A)),
            _roomToggle(context, Icons.balcony_rounded, l10n.balcony, _hasBalcony, (v) => setState(() => _hasBalcony = v), colorScheme, const Color(0xFF9B59B6)),
          ],
        ),
      ],
    );
  }

  Widget _buildStep4(BuildContext context, AppLocalizations l10n, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepHeader(context, Icons.style_rounded, l10n.step4Style, 'Choose your house style and quality', colorScheme),
        const SizedBox(height: 28),

        Text(l10n.houseStyle, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),

        // Style grid
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.8,
          children: AppConstants.houseStyles.map((style) {
            final isSelected = _selectedStyle == style['id'];
            return _styleCard(context, style, isSelected, colorScheme);
          }).toList(),
        ),

        const SizedBox(height: 24),

        Text(l10n.constructionQuality, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),

        // Quality selector
        ...AppConstants.constructionQualities.map((quality) {
          final isSelected = _selectedQuality == quality['id'];
          final multiplier = quality['multiplier'] as double;
          return GestureDetector(
            onTap: () => setState(() => _selectedQuality = quality['id'] as String),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? colorScheme.primary.withOpacity(0.1) : colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? colorScheme.primary : colorScheme.outline,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Radio<String>(
                    value: quality['id'] as String,
                    groupValue: _selectedQuality,
                    onChanged: (v) => setState(() => _selectedQuality = v!),
                    activeColor: colorScheme.primary,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          quality['name'] as String,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          quality['description'] as String,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected ? colorScheme.primary : colorScheme.outline.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${multiplier}x',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildNavigation(
    BuildContext context,
    AppLocalizations l10n,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 12, 24, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(top: BorderSide(color: colorScheme.outline, width: 0.5)),
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _goToStep(_currentStep - 1),
                icon: const Icon(Icons.arrow_back_rounded),
                label: Text(l10n.back),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: () {
                if (!_validateCurrentStep()) return;
                if (_currentStep < _totalSteps - 1) {
                  _goToStep(_currentStep + 1);
                } else {
                  _createProject();
                }
              },
              icon: Icon(
                _currentStep == _totalSteps - 1
                    ? Icons.auto_awesome_rounded
                    : Icons.arrow_forward_rounded,
              ),
              label: Text(
                _currentStep == _totalSteps - 1 ? l10n.generatePlan : l10n.next,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepHeader(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    ColorScheme colorScheme,
  ) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: colorScheme.primary, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCounterCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required int value,
    required int min,
    required int max,
    required ColorScheme colorScheme,
    required ValueChanged<int> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.titleSmall),
          ),
          _counterButton(
            icon: Icons.remove_rounded,
            onPressed: value > min ? () => onChanged(value - 1) : null,
            colorScheme: colorScheme,
          ),
          Container(
            width: 40,
            alignment: Alignment.center,
            child: Text(
              '$value',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: colorScheme.primary,
              ),
            ),
          ),
          _counterButton(
            icon: Icons.add_rounded,
            onPressed: value < max ? () => onChanged(value + 1) : null,
            colorScheme: colorScheme,
          ),
        ],
      ),
    );
  }

  Widget _counterButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required ColorScheme colorScheme,
  }) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: onPressed != null ? colorScheme.primary : colorScheme.outline.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(icon, size: 16),
        onPressed: onPressed,
        color: onPressed != null ? Colors.white : colorScheme.onSurfaceVariant,
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildSliderCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required int value,
    required int min,
    required int max,
    required ColorScheme colorScheme,
    required Color color,
    required ValueChanged<int> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 8),
              Text(title, style: Theme.of(context).textTheme.titleSmall),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$value',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          Slider(
            value: value.toDouble(),
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: max - min,
            activeColor: color,
            inactiveColor: color.withOpacity(0.2),
            onChanged: (v) => onChanged(v.round()),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(max - min + 1, (i) {
              return Text(
                '${min + i}',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  color: colorScheme.onSurfaceVariant,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _roomToggle(
    BuildContext context,
    IconData icon,
    String label,
    bool value,
    ValueChanged<bool> onChanged,
    ColorScheme colorScheme,
    Color color,
  ) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: value ? color.withOpacity(0.12) : colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value ? color : colorScheme.outline,
            width: value ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: value ? color : colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: value ? FontWeight.w600 : FontWeight.w400,
                  color: value ? color : colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Icon(
              value ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              size: 18,
              color: value ? color : colorScheme.outline,
            ),
          ],
        ),
      ),
    );
  }

  Widget _styleCard(
    BuildContext context,
    Map<String, String> style,
    bool isSelected,
    ColorScheme colorScheme,
  ) {
    final Map<String, IconData> styleIcons = {
      'modern': Icons.architecture_rounded,
      'contemporary': Icons.space_dashboard_rounded,
      'traditional': Icons.account_balance_rounded,
      'colonial': Icons.villa_rounded,
      'mediterranean': Icons.temple_buddhist_rounded,
      'craftsman': Icons.handyman_rounded,
      'ranch': Icons.home_rounded,
      'victorian': Icons.castle_rounded,
    };

    return GestureDetector(
      onTap: () => setState(() => _selectedStyle = style['id']!),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary.withOpacity(0.1) : colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              styleIcons[style['id']] ?? Icons.home_rounded,
              size: 28,
              color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 4),
            Text(
              style['name']!,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? colorScheme.primary : colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

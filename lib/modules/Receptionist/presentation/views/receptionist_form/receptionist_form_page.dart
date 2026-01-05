import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:ocurithm/core/widgets/height_spacer.dart';
import 'package:ocurithm/core/widgets/text_field.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ocurithm/generated/l10n.dart';
import 'package:ocurithm/modules/Receptionist/presentation/manager/receptionist_actions_cubit/receptionist_actions_cubit.dart';
import 'package:ocurithm/modules/Receptionist/presentation/manager/get_single_receptionist_cubit/get_single_receptionist_cubit.dart';
import 'package:ocurithm/modules/Clinics/presentation/manager/get_clinics_cubit/get_clinics_cubit.dart';
import 'package:ocurithm/modules/Branch/presentation/manager/get_branches_cubit/get_branches_cubit.dart';
import 'package:ocurithm/modules/Receptionist/presentation/manager/get_capabilities_cubit/get_capabilities_cubit.dart';
import 'package:ocurithm/core/Network/shared.dart';
import 'package:ocurithm/core/utils/services_locator.dart';
import 'package:ocurithm/core/widgets/capabilities_section.dart';
import 'package:ocurithm/Services/whatsapp_confirmation.dart';
import 'package:password_generator/password_generator.dart';
import '../../../../../core/widgets/DropdownPackage.dart';
import '../../../../Branch/data/model/branches_model.dart';
import '../../../data/models/receptionists_model.dart';
import '../../../../../../modules/Login/data/model/login_response.dart';

/// Form mode enum
enum ReceptionistFormMode { add, edit, view }

/// Unified Receptionist Form Page
/// Handles add, edit, and view modes in a single page
class ReceptionistFormPage extends StatelessWidget {
  final ReceptionistFormMode mode;
  final String? receptionistId;

  const ReceptionistFormPage({
    Key? key,
    required this.mode,
    this.receptionistId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<ReceptionistActionsCubit>(),
        ),
        if (mode != ReceptionistFormMode.add)
          BlocProvider(
            create: (_) => sl<GetSingleReceptionistCubit>()
              ..add(GetReceptionistByIdEvent(receptionistId!)),
          ),
        BlocProvider(
          create: (_) => sl<GetClinicsCubit>()..add(GetAllClinicsEvent()),
        ),
        BlocProvider(
          create: (_) => sl<GetBranchesCubit>(),
        ),
        // Only fetch capabilities in edit/view modes
        BlocProvider(
          create: (_) =>
              sl<GetCapabilitiesCubit>()..add(GetAllCapabilitiesEvent()),
        ),
      ],
      child: ReceptionistFormView(mode: mode, receptionistId: receptionistId),
    );
  }
}

class ReceptionistFormView extends StatefulWidget {
  final ReceptionistFormMode mode;
  final String? receptionistId;

  const ReceptionistFormView({
    Key? key,
    required this.mode,
    this.receptionistId,
  }) : super(key: key);

  @override
  State<ReceptionistFormView> createState() => _ReceptionistFormViewState();
}

class _ReceptionistFormViewState extends State<ReceptionistFormView> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _passwordController;

  // Form state
  String? _imageUrl;
  DateTime? _birthDate;
  String? _selectedClinicId;
  // String? _selectedBranchId;
  Branch? selectedBranch;
  List<Capability> _selectedCapabilities = [];

  bool _obscurePassword = true;
  late bool _isReadOnlyState;
  Receptionist? _loadedReceptionist;

  // Validation flags
  bool _isNameValid = true;
  bool _isPhoneValid = true;
  bool _isPasswordValid = true;
  bool _isBirthDateValid = true;

  // Password generator
  final _passwordGenerator = PasswordGenerator(
    length: 8,
    hasCapitalLetters: true,
    hasNumbers: true,
    hasSmallLetters: true,
    hasSymbols: true,
  );

  @override
  void initState() {
    super.initState();
    _isReadOnlyState = widget.mode == ReceptionistFormMode.view;
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();

    // Load data for edit/view modes
    if (widget.mode != ReceptionistFormMode.add) {
      _loadReceptionistData();
    }
  }

  void _loadReceptionistData() {
    // Data will be loaded via GetSingleReceptionistCubit
    // and populated in the BlocListener
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _isReadOnly => _isReadOnlyState;
  bool get _isAddMode => widget.mode == ReceptionistFormMode.add;

  String get _pageTitle {
    switch (widget.mode) {
      case ReceptionistFormMode.add:
        return 'Add Receptionist';
      case ReceptionistFormMode.edit:
        return 'Edit Receptionist';
      case ReceptionistFormMode.view:
        return 'Receptionist Details';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(_pageTitle),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Edit button in view mode
          if (widget.mode != ReceptionistFormMode.add)
            IconButton(
              onPressed: () {
                setState(() {
                  _isReadOnlyState = !_isReadOnlyState;
                  // If reverting to read-only, reset form data
                  if (_isReadOnlyState && _loadedReceptionist != null) {
                    _populateForm(_loadedReceptionist!);
                  }
                });
              },
              icon: Icon(
                _isReadOnly ? Icons.edit : Icons.close,
              ),
            ),
        ],
      ),
      body: MultiBlocListener(
        listeners: [
          // Listen to single receptionist fetch (for edit/view)
          if (widget.mode != ReceptionistFormMode.add)
            BlocListener<GetSingleReceptionistCubit,
                GetSingleReceptionistState>(
              listener: (context, state) {
                if (state.isSuccess && state.receptionist != null) {
                  _populateForm(state.receptionist!);
                }
              },
            ),
          // Listen to capabilities fetch to map them if receptionist is already loaded
          if (widget.mode != ReceptionistFormMode.add)
            BlocListener<GetCapabilitiesCubit, GetCapabilitiesState>(
              listener: (context, state) {
                if (state.isSuccess &&
                    state.capabilities != null &&
                    _loadedReceptionist != null) {
                  _mapCapabilities(_loadedReceptionist!, state.capabilities!);
                }
              },
            ),
          // Listen to actions (add/update)
          BlocListener<ReceptionistActionsCubit, ReceptionistActionsState>(
            listener: (context, state) async {
              if (state.isAddSuccess || state.isUpdateSuccess) {
                // Send WhatsApp message only for add success
                if (state.isAddSuccess && _isAddMode) {
                  await WhatsAppConfirmation().sendWhatsAppMessage(
                    _phoneController.text,
                    "Welcome to our clinics ❤️ .\n You can now sign in, by downloading Ocurithm application. \n Your credentials: \n username: ${_phoneController.text} \n password: ${_passwordController.text} \n Thank you.",
                  );
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.successMessage ?? 'Success'),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.of(context)
                    .pop(true); // Return true to indicate success
              } else if (state.isAddError || state.isUpdateError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage ?? 'Error occurred'),
                    backgroundColor: Colors.red,
                  ),
                );
              } else if (state.noConnection) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No internet connection'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
          ),
        ],
        child: widget.mode == ReceptionistFormMode.add
            ? _buildForm(context, theme, isDark)
            : BlocBuilder<GetSingleReceptionistCubit,
                GetSingleReceptionistState>(
                builder: (context, singleState) {
                  if (singleState.isLoading) {
                    return _buildFormWithShimmer(context, theme, isDark);
                  }

                  if (singleState.isError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline,
                              size: 64, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(singleState.errorMessage ??
                              'Failed to load receptionist'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              context.read<GetSingleReceptionistCubit>().add(
                                    GetReceptionistByIdEvent(
                                        widget.receptionistId!),
                                  );
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  return _buildForm(context, theme, isDark);
                },
              ),
      ),
      bottomNavigationBar:
          _isReadOnly ? null : _buildBottomBar(context, theme, isDark),
    );
  }

  Widget _buildShimmer(Widget child, ThemeData theme, bool isDark) {
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[700]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[600]! : Colors.grey[100]!,
      child: child,
    );
  }

  Widget _buildFormWithShimmer(
      BuildContext context, ThemeData theme, bool isDark) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Image Shimmer
          Center(
            child: _buildShimmer(
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.cardColor,
                ),
              ),
              theme,
              isDark,
            ),
          ),
          const HeightSpacer(size: 24),

          // Name Field Shimmer
          _buildShimmer(
            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: theme.cardColor,
              ),
            ),
            theme,
            isDark,
          ),
          const HeightSpacer(size: 20),

          // Phone Field Shimmer
          _buildShimmer(
            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: theme.cardColor,
              ),
            ),
            theme,
            isDark,
          ),
          const HeightSpacer(size: 20),

          // Clinic Dropdown Shimmer (if user has permission)
          if (CacheHelper.getStringList(key: "capabilities")
              .contains("manageCapabilities"))
            _buildShimmer(
              Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: theme.cardColor,
                ),
              ),
              theme,
              isDark,
            ),
          if (CacheHelper.getStringList(key: "capabilities")
              .contains("manageCapabilities"))
            const HeightSpacer(size: 20),

          // Branch Dropdown Shimmer
          _buildShimmer(
            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: theme.cardColor,
              ),
            ),
            theme,
            isDark,
          ),
          const HeightSpacer(size: 20),

          // Capabilities Shimmer
          _buildShimmer(
            Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: theme.cardColor,
              ),
            ),
            theme,
            isDark,
          ),
          const HeightSpacer(size: 20),

          // Birth Date Shimmer
          _buildShimmer(
            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: theme.cardColor,
              ),
            ),
            theme,
            isDark,
          ),
          const HeightSpacer(size: 24),
        ],
      ),
    );
  }

  Widget _buildForm(BuildContext context, ThemeData theme, bool isDark) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Image
            Center(
              child: ProfileImagePicker(
                initialImageUrl: _imageUrl,
                readOnly: _isReadOnly,
                onDelete: () {
                  setState(() {
                    _imageUrl = null;
                  });
                },
                onImageUploaded: (String url) {
                  setState(() {
                    _imageUrl = url;
                  });
                },
              ),
            ),
            const HeightSpacer(size: 24),

            // Name Field
            _buildTextField(
              controller: _nameController,
              hintText: S.of(context).fullName,
              icon: 'assets/icons/profile.svg',
              isValid: _isNameValid,
              readOnly: _isReadOnly,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  setState(() => _isNameValid = false);
                  return S.of(context).mustUsername;
                }
                setState(() => _isNameValid = true);
                return null;
              },
            ),
            const HeightSpacer(size: 20),

            // Phone Field
            _buildTextField(
              controller: _phoneController,
              hintText: S.of(context).phone,
              icon: 'assets/icons/phone_number.svg',
              keyboardType: TextInputType.phone,
              isValid: _isPhoneValid,
              readOnly: _isReadOnly,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  setState(() => _isPhoneValid = false);
                  return S.of(context).mustPhone;
                } else if (!RegExp(r'^01[0125][0-9]{8}$').hasMatch(value)) {
                  setState(() => _isPhoneValid = false);
                  return S.of(context).invalidPhoneNumber;
                }
                setState(() => _isPhoneValid = true);
                return null;
              },
            ),
            const HeightSpacer(size: 20),

            // Password Field (Add mode only)
            if (_isAddMode) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 4,
                    child: _buildPasswordField(theme),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    flex: 1,
                    child: _buildPasswordGeneratorButton(theme, isDark),
                  ),
                ],
              ),
              const HeightSpacer(size: 20),
            ],

            // Clinic Dropdown (if user has permission)
            if (CacheHelper.getStringList(key: "capabilities")
                .contains("manageCapabilities"))
              _buildClinicDropdown(context, theme, isDark),

            // Branch Dropdown
            _buildBranchDropdown(context, theme, isDark),
            const HeightSpacer(size: 20),

            // Capabilities Multi-Select (hidden in add mode)
            if (!_isAddMode)
              _buildCapabilitiesSection(context, theme, isDark,
                  capabilities: GetSingleReceptionistCubit.get(context)
                      .state
                      .receptionist
                      ?.capabilities),
            if (!_isAddMode) const HeightSpacer(size: 20),

            // Birth Date Picker
            _buildBirthDatePicker(context, theme, isDark),
            const HeightSpacer(size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required String icon,
    required bool isValid,
    required String? Function(String?) validator,
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return TextField2(
      controller: controller,
      required: true,
      type: keyboardType,
      hintText: hintText,
      fillColor: theme.cardColor,
      borderColor: primaryColor,
      radius: 30,
      readOnly: readOnly,
      suffixIcon: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
        child: SvgPicture.asset(
          icon,
          color: primaryColor,
        ),
      ),
      isShadow: isValid,
      validator: validator,
    );
  }

  Widget _buildPasswordField(ThemeData theme) {
    return TextField2(
      controller: _passwordController,
      required: true,
      hintText: S.of(context).password,
      fillColor: theme.cardColor,
      borderColor: theme.primaryColor,
      radius: 30,
      isPassword: _obscurePassword,
      suffixIcon: IconButton(
        onPressed: () {
          setState(() {
            _obscurePassword = !_obscurePassword;
          });
        },
        icon: Icon(
          _obscurePassword ? Icons.visibility_off : Icons.visibility,
        ),
        color: theme.primaryColor,
      ),
      isShadow: _isPasswordValid,
      validator: (value) {
        if (value == null || value.isEmpty) {
          setState(() => _isPasswordValid = false);
          return S.of(context).mustPassword;
        }
        if (value.length < 6) {
          setState(() => _isPasswordValid = false);
          return 'Password must be at least 6 characters';
        }
        setState(() => _isPasswordValid = true);
        return null;
      },
    );
  }

  Widget _buildPasswordGeneratorButton(ThemeData theme, bool isDark) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.cardColor,
          boxShadow: [
            BoxShadow(
              color:
                  isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade200,
              spreadRadius: 2,
              blurRadius: 3,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: IconButton(
          onPressed: () {
            final generatedPassword = _passwordGenerator.generatePassword();
            final entropy = generatedPassword.checkStrength();
            if (entropy >= 28) {
              setState(() {
                _passwordController.text = generatedPassword;
              });
            }
          },
          icon: SvgPicture.asset(
            'assets/icons/password.svg',
            color: theme.primaryColor,
          ),
        ),
      ),
    );
  }

  Widget _buildClinicDropdown(
      BuildContext context, ThemeData theme, bool isDark) {
    return BlocBuilder<GetClinicsCubit, GetClinicsState>(
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.only(bottom: 20.h),
          child: DropdownItem(
            radius: 30,
            color: theme.cardColor,
            isShadow: true,
            iconData: Icon(
              Icons.arrow_drop_down_circle,
              color: theme.primaryColor,
            ),
            items: state.clinics?.clinics ?? [],
            isValid: true,
            validateText: 'Clinic must not be empty',
            selectedValue: _selectedClinicId != null
                ? state.clinics?.clinics
                    .firstWhere((c) => c.id == _selectedClinicId)
                    .name
                : null,
            hintText: 'Select Clinic',
            itemAsString: (item) => item.name.toString(),
            readOnly: _isReadOnly,
            onItemSelected: (item) {
              setState(() {
                _selectedClinicId = item.id;
                selectedBranch = null; // Reset branch
              });
              // Load branches for selected clinic
              context.read<GetBranchesCubit>().add(
                    SetClinicFilterEvent(_selectedClinicId),
                  );
            },
            isLoading: state.isLoading,
          ),
        );
      },
    );
  }

  Widget _buildBranchDropdown(
      BuildContext context, ThemeData theme, bool isDark) {
    return BlocBuilder<GetBranchesCubit, GetBranchesState>(
      builder: (context, state) {
        return DropdownItem(
          radius: 30,
          color: theme.cardColor,
          isShadow: true,
          iconData: Icon(
            Icons.arrow_drop_down_circle,
            color: theme.primaryColor,
          ),
          items: state.branches?.branches ?? [],
          isValid: true,
          validateText: S.of(context).mustBranch,
          selectedValue: selectedBranch != null
              ? state.branches?.branches
                  .firstWhere((b) => b.id == selectedBranch?.id)
                  .name
              : null,
          hintText: 'Select Branch',
          itemAsString: (item) => item.name.toString(),
          readOnly: _isReadOnly,
          onItemSelected: (item) {
            setState(() {
              selectedBranch = item;
            });
          },
          isLoading: state.isLoading,
        );
      },
    );
  }

  Widget _buildCapabilitiesSection(
      BuildContext context, ThemeData theme, bool isDark,
      {List<Capability>? capabilities}) {
    return BlocBuilder<GetCapabilitiesCubit, GetCapabilitiesState>(
      builder: (context, state) {
        if (state.isLoading) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: CircularProgressIndicator(color: theme.primaryColor),
            ),
          );
        }

        if (state.isError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 8),
                  Text(
                    state.errorMessage ?? 'Failed to load capabilities',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        if (state.isSuccess && state.capabilities != null) {
          return CapabilitiesSection(
            capabilities: state.capabilities!,
            readOnly: _isReadOnly,
            initialSelectedCapabilities: capabilities ?? [],
            onSelectionChanged: (newSelection) {
              setState(() {
                _selectedCapabilities = newSelection;
              });
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildBirthDatePicker(
      BuildContext context, ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(thickness: 0.4, color: theme.dividerColor),
        const HeightSpacer(size: 16),
        Text(
          S.of(context).dateOfBirth,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const HeightSpacer(size: 12),
        InkWell(
          onTap: _isReadOnly
              ? null
              : () async {
                  final selectedDate = await showDatePicker(
                    context: context,
                    initialDate: _birthDate ?? DateTime(2000),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now()
                        .subtract(const Duration(days: 6570)), // 18 years
                    builder: (context, child) {
                      return Theme(
                        data: theme.copyWith(
                          colorScheme: ColorScheme.light(
                            primary: theme.primaryColor,
                            onPrimary: Colors.white,
                            onSurface: theme.textTheme.bodyLarge?.color ??
                                Colors.black,
                          ),
                          textButtonTheme: TextButtonThemeData(
                            style: TextButton.styleFrom(
                              foregroundColor: theme.primaryColor,
                            ),
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );

                  if (selectedDate != null) {
                    setState(() {
                      _birthDate = selectedDate;
                      _isBirthDateValid = true;
                    });
                  }
                },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color:
                    !_isBirthDateValid ? Colors.redAccent : Colors.transparent,
                width: 1,
              ),
              boxShadow: isDark
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        spreadRadius: 1,
                        blurRadius: 3,
                      ),
                    ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      _birthDate != null
                          ? '${_birthDate!.day}'
                          : S.of(context).dd,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                ),
                Container(
                  width: 2,
                  height: 30,
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      _birthDate != null
                          ? '${_birthDate!.month}'
                          : S.of(context).mm,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                ),
                Container(
                  width: 2,
                  height: 30,
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      _birthDate != null
                          ? '${_birthDate!.year}'
                          : S.of(context).yy,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (!_isBirthDateValid)
          Padding(
            padding: EdgeInsets.only(left: 12.w, top: 8.h),
            child: Text(
              S.of(context).mustBirth,
              style: TextStyle(
                fontSize: 12,
                color: Colors.red.shade700,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context, ThemeData theme, bool isDark) {
    return BlocBuilder<ReceptionistActionsCubit, ReceptionistActionsState>(
      builder: (context, state) {
        final isLoading = state.isLoading;

        return Container(
          padding: EdgeInsets.all(16.w),
          child: SafeArea(
            child: ElevatedButton(
              onPressed: isLoading ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      _isAddMode ? 'Add Receptionist' : 'Update Receptionist',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }

  void _handleSubmit() {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate birth date
    if (_birthDate == null) {
      setState(() => _isBirthDateValid = false);
      return;
    }

    // Validate branch selection
    if (selectedBranch == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a branch'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Create receptionist object
    final receptionist = Receptionist(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _isAddMode ? _passwordController.text : null,
      branch: selectedBranch,
      birthDate: _birthDate,
      image: _imageUrl,
      capability: _selectedCapabilities.map((c) => c.id).toList(),
    );


    // Dispatch event
    if (_isAddMode) {
      context.read<ReceptionistActionsCubit>().add(
            AddReceptionistEvent(receptionist),
          );
    } else {
      context.read<ReceptionistActionsCubit>().add(
            UpdateReceptionistEvent(
              receptionistId: widget.receptionistId!,
              receptionist: receptionist,
            ),
          );
    }
  }

  void _populateForm(Receptionist receptionist) {
    setState(() {
      _nameController.text = receptionist.name ?? '';
      _phoneController.text = receptionist.phone ?? '';
      _imageUrl = receptionist.image;
      _birthDate = receptionist.birthDate;
      selectedBranch = receptionist.branch;
      _selectedClinicId = receptionist.clinic?.id;
      _loadedReceptionist = receptionist;

      // map capability IDs to objects
      final capabilitiesState = context.read<GetCapabilitiesCubit>().state;
      if (capabilitiesState.capabilities != null) {
        _mapCapabilities(receptionist, capabilitiesState.capabilities!);
      }
    });

    // Load branches if clinic is set
    if (_selectedClinicId != null) {
      context.read<GetBranchesCubit>().add(
            SetClinicFilterEvent(_selectedClinicId),
          );
    }
  }

  void _mapCapabilities(
      Receptionist receptionist, List<Capability> allCapabilities) {
    if (receptionist.capability != null &&
        receptionist.capability!.isNotEmpty) {
      setState(() {
        _selectedCapabilities = allCapabilities
            .where((cap) => receptionist.capability!
                .any((id) => id.toString() == cap.id.toString()))
            .toList();
      });
    } else {
      setState(() {
        _selectedCapabilities = [];
      });
    }
  }
}

// Profile Image Picker Widget (reused from existing code)
class ProfileImagePicker extends StatefulWidget {
  final Function(String) onImageUploaded;
  final String? initialImageUrl;
  final bool? readOnly;
  final Function() onDelete;

  const ProfileImagePicker({
    Key? key,
    required this.onImageUploaded,
    this.initialImageUrl,
    this.readOnly = false,
    required this.onDelete,
  }) : super(key: key);

  @override
  State<ProfileImagePicker> createState() => _ProfileImagePickerState();
}

class _ProfileImagePickerState extends State<ProfileImagePicker> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  bool _isImageDeleted = false;

  void _handleDelete() {
    setState(() {
      _imageFile = null;
      _isImageDeleted = true;
    });
    widget.onDelete();
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      final url = await CloudinaryService.uploadImage(_imageFile!);

      if (url != null) {
        widget.onImageUploaded(url);
      } else {
        _showError('Failed to upload image');
      }
    } catch (e) {
      _showError('Error uploading image: $e');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: _uploadImage,
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final sizeInBytes = await file.length();
        final sizeInMb = sizeInBytes / (1024 * 1024);

        if (sizeInMb > 10) {
          _showError('Image size should be less than 10MB');
          return;
        }

        setState(() {
          _imageFile = file;
        });
        await _uploadImage();
      }
    } catch (e) {
      _showError('Failed to pick image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: _isUploading
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: theme.primaryColor),
                      const SizedBox(height: 8),
                      Text(
                        'Uploading...',
                        style: TextStyle(
                          color: theme.textTheme.bodySmall?.color,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                )
              : ClipOval(
                  child: _imageFile != null
                      ? Image.file(
                          _imageFile!,
                          fit: BoxFit.cover,
                          width: 120,
                          height: 120,
                        )
                      : (!_isImageDeleted && widget.initialImageUrl != null)
                          ? Image.network(
                              widget.initialImageUrl!,
                              fit: BoxFit.cover,
                              width: 120,
                              height: 120,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.person,
                                      size: 60, color: Colors.grey),
                            )
                          : const Icon(Icons.person,
                              size: 60, color: Colors.grey),
                ),
        ),
        if (!_isUploading && widget.readOnly != true)
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: () => _showImageSourceDialog(_handleDelete),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showImageSourceDialog(Function() onDelete) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('Select Image Source'),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.photo, color: CupertinoColors.activeBlue),
                SizedBox(width: 8),
                Text('Choose from Gallery'),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera);
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.camera, color: CupertinoColors.activeBlue),
                SizedBox(width: 8),
                Text('Take a Photo'),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              onDelete();
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.delete, color: CupertinoColors.activeBlue),
                SizedBox(width: 8),
                Text('Delete Photo'),
              ],
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(
            'Cancel',
            style: TextStyle(
              color: CupertinoColors.destructiveRed,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

// Cloudinary Service (reused from existing code)
class CloudinaryService {
  static const String cloudName = 'dxsrhu3ku';
  static const String uploadPreset = 'ocurithm';
  static const String _baseUrl = 'https://api.cloudinary.com/v1_1/$cloudName';

  static Future<String?> uploadImage(File imageFile) async {
    try {
      final url = Uri.parse('$_baseUrl/image/upload');
      final request = http.MultipartRequest('POST', url);

      request.fields['upload_preset'] = uploadPreset;
      request.fields['folder'] = 'public';
      request.fields['timestamp'] =
          DateTime.now().millisecondsSinceEpoch.toString();

      final bytes = await imageFile.readAsBytes();
      final multipartFile = http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: imageFile.path.split('/').last,
      );
      request.files.add(multipartFile);

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse['secure_url'] as String;
      } else {
        throw Exception('Failed to upload image: ${response.body}');
      }
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }
}

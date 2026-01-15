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
import 'package:ocurithm/modules/Doctor/presentation/manager/doctor_actions_cubit/doctor_actions_cubit.dart';
import 'package:ocurithm/modules/Doctor/presentation/manager/get_single_doctor_cubit/get_single_doctor_cubit.dart';
import 'package:ocurithm/modules/Clinics/presentation/manager/get_clinics_cubit/get_clinics_cubit.dart';
import 'package:ocurithm/modules/Branch/presentation/manager/get_branches_cubit/get_branches_cubit.dart';
import 'package:ocurithm/modules/Receptionist/presentation/manager/get_capabilities_cubit/get_capabilities_cubit.dart';
import 'package:ocurithm/core/Network/shared.dart';
import 'package:ocurithm/core/utils/services_locator.dart';
import 'package:ocurithm/core/widgets/capabilities_section.dart';
import 'package:ocurithm/Services/whatsapp_confirmation.dart';
import 'package:password_generator/password_generator.dart';
import 'package:get/get.dart' as getx;
import '../../../../../core/widgets/DropdownPackage.dart';
import '../../../data/model/doctor_model.dart';
import '../../../../Clinics/data/model/clinics_model.dart';
import '../../../../../../modules/Login/data/model/login_response.dart';
import '../../manager/doctor_branch_actions_cubit/doctor_branch_actions_cubit.dart';
import 'widgets/add_doctor_branch_dialog.dart';

/// Form mode enum
enum DoctorFormMode { add, edit, view }

/// Unified Doctor Form Page
/// Handles add, edit, and view modes in a single page
class DoctorFormPage extends StatelessWidget {
  final DoctorFormMode mode;
  final String? doctorId;

  const DoctorFormPage({
    Key? key,
    required this.mode,
    this.doctorId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<DoctorActionsCubit>(),
        ),
        if (mode != DoctorFormMode.add)
          BlocProvider(
            create: (_) =>
                sl<GetSingleDoctorCubit>()..add(GetDoctorByIdEvent(doctorId!)),
          ),
        BlocProvider(
          create: (_) => sl<GetClinicsCubit>()..add(GetAllClinicsEvent()),
        ),
        BlocProvider(
          create: (_) => sl<DoctorBranchActionsCubit>(),
        ),
        BlocProvider(
          create: (_) => sl<GetBranchesCubit>(),
        ),
        // Fetch capabilities for doctors as well
        BlocProvider(
          create: (_) =>
              sl<GetCapabilitiesCubit>()..add(GetAllCapabilitiesEvent()),
        ),
      ],
      child: DoctorFormView(mode: mode, doctorId: doctorId),
    );
  }
}

class DoctorFormView extends StatefulWidget {
  final DoctorFormMode mode;
  final String? doctorId;

  const DoctorFormView({
    Key? key,
    required this.mode,
    this.doctorId,
  }) : super(key: key);

  @override
  State<DoctorFormView> createState() => _DoctorFormViewState();
}

class _DoctorFormViewState extends State<DoctorFormView> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _passwordController;
  late TextEditingController _qualificationsController;

  // Form state
  String? _imageUrl;
  DateTime? _birthDate;
  String? _selectedClinicId;
  List<Capability> _selectedCapabilities = [];

  bool _obscurePassword = true;
  late bool _isReadOnlyState;
  Doctor? _loadedDoctor;

  // Validation flags
  bool _isNameValid = true;
  bool _isPhoneValid = true;
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
    _isReadOnlyState = widget.mode == DoctorFormMode.view;
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();
    _qualificationsController = TextEditingController();

    // Load data for edit/view modes
    if (widget.mode != DoctorFormMode.add) {
      _loadDoctorData();
    }
  }

  void _loadDoctorData() {
    // Data will be loaded via GetSingleDoctorCubit
    // and populated in the BlocListener
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _qualificationsController.dispose();
    super.dispose();
  }

  bool get _isReadOnly => _isReadOnlyState;
  bool get _isAddMode => widget.mode == DoctorFormMode.add;

  String get _pageTitle {
    switch (widget.mode) {
      case DoctorFormMode.add:
        return 'Add Doctor';
      case DoctorFormMode.edit:
        return 'Edit Doctor';
      case DoctorFormMode.view:
        return 'Doctor Details';
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
          if (widget.mode != DoctorFormMode.add)
            IconButton(
              onPressed: () {
                setState(() {
                  _isReadOnlyState = !_isReadOnlyState;
                  // If reverting to read-only, reset form data
                  if (_isReadOnlyState && _loadedDoctor != null) {
                    _populateForm(_loadedDoctor!);
                  }
                });
              },
              icon: Icon(
                _isReadOnly ? Icons.edit : Icons.close,
              ),
            ),
          // Add Branch button
          if (widget.mode != DoctorFormMode.add &&
              CacheHelper.getStringList(key: "capabilities")
                  .contains("manageDoctors") &&
              _loadedDoctor != null)
            IconButton(
              onPressed: () {
                _showAddBranchDialog(context);
              },
              icon: SvgPicture.asset(
                "assets/icons/add_branch.svg",
                colorFilter: ColorFilter.mode(
                    isDark ? Colors.white : Colors.black, BlendMode.srcIn),
              ),
            ),
        ],
      ),
      body: MultiBlocListener(
        listeners: [
          // Listen to single doctor fetch (for edit/view)
          if (widget.mode != DoctorFormMode.add)
            BlocListener<GetSingleDoctorCubit, GetSingleDoctorState>(
              listener: (context, state) {
                if (state.isSuccess && state.doctor != null) {
                  _populateForm(state.doctor!);
                }
              },
            ),
          // Listen to capabilities fetch to map them if doctor is already loaded
          if (widget.mode != DoctorFormMode.add)
            BlocListener<GetCapabilitiesCubit, GetCapabilitiesState>(
              listener: (context, state) {
                if (state.isSuccess &&
                    state.capabilities != null &&
                    _loadedDoctor != null) {
                  _mapCapabilities(_loadedDoctor!, state.capabilities!);
                }
              },
            ),
          // Listen to actions (add/update)
          BlocListener<DoctorActionsCubit, DoctorActionsState>(
            listener: (context, state) async {
              if (state.isSuccess &&
                  (state.actionType == DoctorActionType.add ||
                      state.actionType == DoctorActionType.update)) {
                // Send WhatsApp message only for add success
                if (state.actionType == DoctorActionType.add && _isAddMode) {
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

                // Refresh list if manager is available in context (it might not be if we popped)
                // But usually we return result
                Navigator.of(context).pop(true);
              } else if (state.isError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage ?? 'Error occurred'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
          BlocListener<DoctorBranchActionsCubit, DoctorBranchActionsState>(
            listener: (context, state) {
              if (state.isSuccess) {
                // Refresh doctor data
                _loadDoctorData();
                getx.Get.snackbar(
                  "Success",
                  state.successMessage ?? "Branch operation successful",
                  backgroundColor: theme.primaryColor,
                  colorText: Colors.white,
                );
              } else if (state.isError) {
                getx.Get.snackbar(
                  "Error",
                  state.errorMessage ?? "An error occurred",
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
          ),
        ],
        child: widget.mode == DoctorFormMode.add
            ? _buildForm(context, theme, isDark)
            : BlocBuilder<GetSingleDoctorCubit, GetSingleDoctorState>(
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
                              'Failed to load doctor'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              context.read<GetSingleDoctorCubit>().add(
                                    GetDoctorByIdEvent(widget.doctorId!),
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

          // Qualifications Field Shimmer
          _buildShimmer(
            Container(
              width: double.infinity,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: theme.cardColor,
              ),
            ),
            theme,
            isDark,
          ),
          const HeightSpacer(size: 20),

          // Clinic Dropdown Shimmer (if user has permission)
          if (CacheHelper.getStringList(key: "capabilities")
              .contains("manageCapability"))
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
              .contains("manageCapability"))
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

            // Qualifications Field (Multi-line text field)
            _buildQualificationsField(theme),
            const HeightSpacer(size: 20),

            // Clinic Dropdown (if user has permission)
            if (CacheHelper.getStringList(key: "capabilities")
                .contains("manageCapability"))
              _buildClinicDropdown(context, theme, isDark),

            // Capabilities Multi-Select (hidden in add mode)
            if (!_isAddMode)
              _buildCapabilitiesSection(context, theme, isDark,
                  capabilities: GetSingleDoctorCubit.get(context)
                      .state
                      .doctor
                      ?.capabilities),
            if (!_isAddMode) const HeightSpacer(size: 20),

            // Birth Date Picker
            _buildBirthDatePicker(context, theme, isDark),
            const HeightSpacer(size: 24),

            // Branches Section (only in edit/view modes)
            if (!_isAddMode) ..._buildBranchesSection(context, theme, isDark),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          hintText,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const HeightSpacer(size: 8),
        TextField2(
          controller: controller,
          required: true,
          type: keyboardType,
          hintText: hintText,
          fillColor: theme.cardColor,
          borderColor: primaryColor,
          border: primaryColor,
          radius: 30,
          readOnly: readOnly,
          suffixIcon: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
            child: SvgPicture.asset(
              icon,
              color: primaryColor,
            ),
          ),
          isShadow: false,
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildPasswordField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).password,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const HeightSpacer(size: 8),
        TextField2(
          controller: _passwordController,
          required: true,
          hintText: S.of(context).password,
          fillColor: theme.cardColor,
          borderColor: theme.primaryColor,
          border: theme.primaryColor,
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
          isShadow: false,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return S.of(context).mustPassword;
            }
            if (value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
        ),
      ],
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

  Widget _buildQualificationsField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Qualifications",
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const HeightSpacer(size: 8),
        Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextFormField(
            controller: _qualificationsController,
            readOnly: _isReadOnly,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Qualifications',
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.primaryColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.primaryColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.primaryColor, width: 2),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Qualifications are required';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildClinicDropdown(
      BuildContext context, ThemeData theme, bool isDark) {
    return BlocBuilder<GetClinicsCubit, GetClinicsState>(
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.only(bottom: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Clinic",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const HeightSpacer(size: 8),
              DropdownItem(
                radius: 30,
                color: theme.cardColor,
                border: theme.primaryColor,
                isShadow: false,
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
                  });
                  // Load branches for selected clinic
                  context.read<GetBranchesCubit>().add(
                        SetClinicFilterEvent(_selectedClinicId),
                      );
                },
                isLoading: state.isLoading,
              ),
            ],
          ),
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
                          colorScheme: theme.colorScheme.copyWith(
                            primary: theme.primaryColor,
                            onPrimary: Colors.white,
                            surface: theme.cardColor,
                            onSurface: theme.textTheme.bodyLarge?.color,
                          ),
                          dialogBackgroundColor: theme.cardColor,
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
                color: _isBirthDateValid ? theme.primaryColor : Colors.red,
              ),
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
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context, ThemeData theme, bool isDark) {
    return BlocBuilder<DoctorActionsCubit, DoctorActionsState>(
      builder: (context, state) {
        return Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.grey.shade300,
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: state.isLoading ? null : _handleSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 14.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 0,
            ),
            child: state.isLoading
                ? SizedBox(
                    height: 20.h,
                    width: 20.w,
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    _isAddMode ? 'Add Doctor' : 'Update Doctor',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        );
      },
    );
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate birth date
    if (_birthDate == null) {
      setState(() => _isBirthDateValid = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select birth date'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate clinic selection (if user has permission)
    if (CacheHelper.getStringList(key: "capabilities")
            .contains("manageCapability") &&
        _selectedClinicId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a clinic'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Create Doctor object
    final doctor = Doctor(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _isAddMode ? _passwordController.text : null,
      qualifications: _qualificationsController.text.trim(),
      birthDate: _birthDate,
      image: _imageUrl,
      clinic: _selectedClinicId != null
          ? Clinic(id: _selectedClinicId, name: null)
          : null,
      capability: _selectedCapabilities.map((c) => c.id).toList(),
    );

    // Dispatch appropriate event
    if (_isAddMode) {
      context.read<DoctorActionsCubit>().add(AddDoctorEvent(doctor));
    } else {
      context.read<DoctorActionsCubit>().add(
            UpdateDoctorEvent(
              doctorId: widget.doctorId!,
              doctor: doctor,
            ),
          );
    }
  }

  void _populateForm(Doctor doctor) {
    setState(() {
      _loadedDoctor = doctor;
      _nameController.text = doctor.name ?? '';
      _phoneController.text = doctor.phone ?? '';
      _qualificationsController.text = doctor.qualifications ?? '';
      _birthDate = doctor.birthDate;
      _imageUrl = doctor.image;
      _selectedClinicId = doctor.clinic?.id;

      // Load branches if clinic is selected
      if (_selectedClinicId != null) {
        context.read<GetBranchesCubit>().add(
              SetClinicFilterEvent(_selectedClinicId),
            );
      }
    });

    // Map capabilities if they're available
    final capabilitiesState = context.read<GetCapabilitiesCubit>().state;
    if (capabilitiesState.isSuccess && capabilitiesState.capabilities != null) {
      _mapCapabilities(doctor, capabilitiesState.capabilities!);
    }
  }

  void _mapCapabilities(Doctor doctor, List<Capability> allCapabilities) {
    if (doctor.capabilities == null || doctor.capabilities!.isEmpty) {
      return;
    }

    setState(() {
      _selectedCapabilities = allCapabilities.where((cap) {
        return doctor.capabilities!.any((docCap) {
          // Robust ID matching
          return docCap.id.toString() == cap.id.toString();
        });
      }).toList();
    });
  }

  void _showAddBranchDialog(BuildContext context,
      {BranchElement? branchToEdit}) {
    if (_loadedDoctor?.clinic?.id == null) {
      getx.Get.snackbar("Error", "Doctor clinic not found",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    getx.Get.dialog(
      BlocProvider.value(
        value: context.read<DoctorBranchActionsCubit>(),
        child: BlocProvider.value(
          value: context.read<GetBranchesCubit>(),
          child: AddDoctorBranchDialog(
            doctorId: widget.doctorId!,
            clinicId: _loadedDoctor!.clinic!.id!,
            existingBranches: _loadedDoctor!.branches ?? [],
            initialBranch: branchToEdit,
          ),
        ),
      ),
    );
  }

  void _confirmDeleteBranch(BuildContext context, BranchElement branch) {
    getx.Get.defaultDialog(
      title: "Delete Branch",
      middleText: "Are you sure you want to remove this branch?",
      confirmTextColor: Colors.white,
      onConfirm: () {
        context.read<DoctorBranchActionsCubit>().add(
              DeleteDoctorBranchEvent(
                doctorId: widget.doctorId!,
                branchId:
                    branch.branch?.id?.toString() ?? branch.branchId ?? '',
              ),
            );
        getx.Get.back();
      },
      onCancel: () {},
    );
  }

  // Build Branches Section
  List<Widget> _buildBranchesSection(
      BuildContext context, ThemeData theme, bool isDark) {
    return [
      Divider(
        thickness: 0.4,
        color: theme.dividerColor,
      ),
      const HeightSpacer(size: 20),
      Text(
        'Branches',
        style: TextStyle(
          color: theme.textTheme.bodyLarge?.color,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
      ),
      const HeightSpacer(size: 10),
      BlocBuilder<GetSingleDoctorCubit, GetSingleDoctorState>(
        builder: (context, state) {
          if (state.isLoading || _loadedDoctor == null) {
            return _buildShimmer(
              Container(
                width: MediaQuery.sizeOf(context).width,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: theme.cardColor,
                ),
              ),
              theme,
              isDark,
            );
          }

          final branches = _loadedDoctor!.branches ?? [];

          if (branches.isEmpty) {
            return Center(
              child: Column(
                children: [
                  const HeightSpacer(size: 20),
                  SvgPicture.asset(
                    "assets/icons/branch.svg",
                    colorFilter: ColorFilter.mode(
                      theme.textTheme.bodyMedium?.color?.withOpacity(0.5) ??
                          Colors.grey,
                      BlendMode.srcIn,
                    ),
                    width: 50,
                    height: 50,
                  ),
                  const HeightSpacer(size: 12),
                  Text(
                    "No Branches Available",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color:
                          theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const HeightSpacer(size: 20),
                ],
              ),
            );
          }

          // Display branches inline (without old cubit dependency)
          return ListView.builder(
            padding: const EdgeInsets.all(0),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: branches.length,
            itemBuilder: (context, index) {
              final branchData = branches[index];
              final branch = branchData.branch;
              final availableDays = List<String>.from(branchData.availableDays);

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: theme.cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Branch header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              branch?.code ?? 'N/A',
                              style: TextStyle(
                                color: theme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              branch?.name ?? 'N/A',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: theme.textTheme.bodyLarge?.color,
                              ),
                            ),
                          ),
                          // Edit/Delete Menu
                          if (widget.mode != DoctorFormMode.add &&
                              CacheHelper.getStringList(key: "capabilities")
                                  .contains("manageDoctors"))
                            PopupMenuButton<String>(
                              icon: Icon(
                                Icons.more_vert,
                                color: theme.textTheme.bodyMedium?.color,
                              ),
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _showAddBranchDialog(context,
                                      branchToEdit: branchData);
                                } else if (value == 'delete') {
                                  _confirmDeleteBranch(context, branchData);
                                }
                              },
                              itemBuilder: (BuildContext context) {
                                return [
                                  PopupMenuItem<String>(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit,
                                            size: 20,
                                            color: theme.primaryColor),
                                        const SizedBox(width: 8),
                                        const Text('Edit'),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem<String>(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        const Icon(Icons.delete,
                                            size: 20, color: Colors.red),
                                        const SizedBox(width: 8),
                                        const Text('Delete',
                                            style:
                                                TextStyle(color: Colors.red)),
                                      ],
                                    ),
                                  ),
                                ];
                              },
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Branch hours
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 20,
                            color: theme.textTheme.bodyMedium?.color
                                ?.withOpacity(0.7),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Branch Hours:',
                            style: TextStyle(
                              color: theme.textTheme.bodyMedium?.color
                                  ?.withOpacity(0.7),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${branch?.openTime ?? ""} - ${branch?.closeTime ?? ""}',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Available hours
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 20,
                            color: theme.textTheme.bodyMedium?.color
                                ?.withOpacity(0.7),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Available Hours:',
                            style: TextStyle(
                              color: theme.textTheme.bodyMedium?.color
                                  ?.withOpacity(0.7),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${branchData.availableFrom ?? ""} - ${branchData.availableTo ?? ""}',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Working days
                      Text(
                        'Working Days:',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: List<String>.from(branch?.workDays ?? [])
                            .map((day) {
                          final isAvailable = availableDays.contains(day);
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isAvailable
                                  ? theme.primaryColor
                                  : theme.textTheme.bodyMedium?.color
                                      ?.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              day.substring(0, 1).toUpperCase() +
                                  day.substring(1),
                              style: TextStyle(
                                color: isAvailable
                                    ? Colors.white
                                    : theme.textTheme.bodyMedium?.color
                                        ?.withOpacity(0.6),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      const HeightSpacer(size: 20),
    ];
  }
}

// Profile Image Picker Widget (reused from Receptionist)
class ProfileImagePicker extends StatefulWidget {
  final String? initialImageUrl;
  final bool readOnly;
  final VoidCallback onDelete;
  final Function(String) onImageUploaded;

  const ProfileImagePicker({
    Key? key,
    this.initialImageUrl,
    required this.readOnly,
    required this.onDelete,
    required this.onImageUploaded,
  }) : super(key: key);

  @override
  State<ProfileImagePicker> createState() => _ProfileImagePickerState();
}

class _ProfileImagePickerState extends State<ProfileImagePicker> {
  File? _imageFile;
  bool _isUploading = false;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _imageUrl = widget.initialImageUrl;
  }

  @override
  void didUpdateWidget(ProfileImagePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialImageUrl != oldWidget.initialImageUrl) {
      setState(() {
        _imageUrl = widget.initialImageUrl;
        _imageFile = null;
      });
    }
  }

  Future<void> _pickImage() async {
    if (widget.readOnly) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      await _uploadImage();
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://ocurithm.onrender.com/api/v1/upload'),
      );

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          _imageFile!.path,
        ),
      );

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonData = json.decode(responseData);

      if (response.statusCode == 200 && jsonData['url'] != null) {
        setState(() {
          _imageUrl = jsonData['url'];
          _isUploading = false;
        });
        widget.onImageUploaded(jsonData['url']);
      } else {
        throw Exception('Failed to upload image');
      }
    } catch (e) {
      log('Error uploading image: $e');
      setState(() {
        _isUploading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _deleteImage() {
    if (widget.readOnly) return;

    setState(() {
      _imageFile = null;
      _imageUrl = null;
    });
    widget.onDelete();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.cardColor,
            border: Border.all(
              color: theme.primaryColor.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.grey.shade200,
                spreadRadius: 2,
                blurRadius: 5,
              ),
            ],
          ),
          child: _isUploading
              ? Center(
                  child: CircularProgressIndicator(
                    color: theme.primaryColor,
                  ),
                )
              : _imageFile != null
                  ? ClipOval(
                      child: Image.file(
                        _imageFile!,
                        fit: BoxFit.cover,
                        width: 100,
                        height: 100,
                      ),
                    )
                  : _imageUrl != null && _imageUrl!.isNotEmpty
                      ? ClipOval(
                          child: Image.network(
                            _imageUrl!,
                            fit: BoxFit.cover,
                            width: 100,
                            height: 100,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.person,
                                size: 50,
                                color: theme.primaryColor,
                              );
                            },
                          ),
                        )
                      : Icon(
                          Icons.person,
                          size: 50,
                          color: theme.primaryColor,
                        ),
        ),
        if (!widget.readOnly)
          Positioned(
            bottom: 0,
            right: 0,
            child: Row(
              children: [
                if (_imageUrl != null || _imageFile != null)
                  GestureDetector(
                    onTap: _deleteImage,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 3,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.primaryColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 3,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

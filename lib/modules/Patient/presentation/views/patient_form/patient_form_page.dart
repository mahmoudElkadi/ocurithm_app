import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ocurithm/core/utils/services_locator.dart';
import 'package:ocurithm/core/widgets/DropdownPackage.dart';
import 'package:ocurithm/core/widgets/height_spacer.dart';
import 'package:ocurithm/generated/l10n.dart';
import 'package:ocurithm/modules/Branch/data/model/branches_model.dart';
import 'package:ocurithm/modules/Clinics/presentation/manager/get_clinics_cubit/get_clinics_cubit.dart';
import 'package:ocurithm/modules/Branch/presentation/manager/get_branches_cubit/get_branches_cubit.dart';
import 'package:ocurithm/modules/Patient/data/model/patients_model.dart';
import 'package:ocurithm/modules/Patient/data/model/patient_examination.dart';
import 'package:ocurithm/modules/Patient/presentation/manager/get_single_patient_cubit/get_single_patient_cubit.dart';
import 'package:ocurithm/modules/Patient/presentation/manager/patient_actions_cubit/patient_actions_cubit.dart';
import 'package:ocurithm/modules/Patient/presentation/manager/get_patient_examinations_cubit/get_patient_examinations_cubit.dart';
import 'package:ocurithm/core/Network/shared.dart';
import 'package:password_generator/password_generator.dart';
import 'package:ocurithm/core/utils/constant.dart';
import 'package:ocurithm/modules/Patient/data/model/nationality_model.dart';
import 'package:flutter_intl_phone_field/flutter_intl_phone_field.dart';
import 'package:ocurithm/modules/Clinics/data/model/clinics_model.dart';
import '../../../../Analysis/presentation/views/analysis_view.dart';
import '../examination_view/one_examination_view.dart';

enum PatientFormMode { add, edit, view }

class PatientFormPage extends StatelessWidget {
  final PatientFormMode mode;
  final String? patientId;

  const PatientFormPage({
    super.key,
    required this.mode,
    this.patientId,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<PatientActionsCubit>()),
        if (mode != PatientFormMode.add) ...[
          BlocProvider(
            create: (_) => sl<GetSinglePatientCubit>()
              ..add(GetPatientByIdEvent(patientId!)),
          ),
          BlocProvider(
            create: (_) =>
                sl<GetPatientExaminationsCubit>()..getExaminations(patientId!),
          ),
        ],
        BlocProvider(
            create: (_) => sl<GetClinicsCubit>()..add(GetAllClinicsEvent())),
        BlocProvider(create: (_) => sl<GetBranchesCubit>()),
      ],
      child: PatientFormView(mode: mode, patientId: patientId),
    );
  }
}

class PatientFormView extends StatefulWidget {
  final PatientFormMode mode;
  final String? patientId;

  const PatientFormView({super.key, required this.mode, this.patientId});

  @override
  State<PatientFormView> createState() => _PatientFormViewState();
}

class _PatientFormViewState extends State<PatientFormView> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _addressController;
  late TextEditingController _nationalIdController;

  String? _phoneNumber;
  DateTime? _birthDate;
  String? _selectedGender;
  Nationality? _selectedNationality;

  String? _selectedClinicId;
  Branch? _selectedBranch;

  bool _obscurePassword = true;
  late bool _isReadOnlyState;
  Patient? _loadedPatient;

  final _passwordGenerator = PasswordGenerator(
    length: 8,
    hasCapitalLetters: true,
    hasNumbers: true,
    hasSmallLetters: true,
    hasSymbols: true,
  );

  bool _isBirthDateValid = true;
  bool _isGenderValid = true;
  bool _isClinicValid = true;
  bool _isBranchValid = true;
  bool _isNationalityValid = true;

  @override
  void initState() {
    super.initState();
    _isReadOnlyState = widget.mode == PatientFormMode.view;
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _addressController = TextEditingController();
    _nationalIdController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _addressController.dispose();
    _nationalIdController.dispose();
    super.dispose();
  }

  void _populateForm(Patient patient) {
    _loadedPatient = patient;
    _nameController.text = patient.name ?? '';
    _emailController.text = patient.email ?? '';
    _addressController.text = patient.address ?? '';
    _nationalIdController.text = patient.nationalId ?? '';
    _phoneNumber = patient.phone;
    _birthDate = patient.birthDate;
    _selectedGender = patient.gender;

    if (patient.nationality != null) {
      try {
        _selectedNationality = nationalities.firstWhere((n) =>
            n.name == patient.nationality ||
            n.value.toLowerCase() == patient.nationality?.toLowerCase());
      } catch (e) {
        // ignore
      }
    }

    if (patient.clinic != null) {
      _selectedClinicId = patient.clinic!.id;
      if (context.mounted) {
        context
            .read<GetBranchesCubit>()
            .add(SetClinicFilterEvent(_selectedClinicId));
      }
    }

    _selectedBranch = patient.branch;

    setState(() {});
  }

  String get _pageTitle {
    switch (widget.mode) {
      case PatientFormMode.add:
        return 'Add Patient';
      case PatientFormMode.edit:
        return 'Edit Patient';
      case PatientFormMode.view:
        return 'Patient Details';
    }
  }

  bool get _isReadOnly => _isReadOnlyState;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(_pageTitle),
        elevation: 0,
        actions: [
          if (widget.mode != PatientFormMode.add)
            IconButton(
              onPressed: () {
                setState(() {
                  _isReadOnlyState = !_isReadOnlyState;
                  if (_isReadOnlyState && _loadedPatient != null) {
                    _populateForm(_loadedPatient!);
                  }
                });
              },
              icon: Icon(_isReadOnly ? Icons.edit : Icons.close),
            ),
          if (widget.mode != PatientFormMode.add && widget.patientId!=null)
            IconButton(
              onPressed: () {
                Get.to(()=>AnalysisView(patientId:widget.patientId.toString() ));
              },
              icon: const Icon(Icons.analytics_outlined),
            ),
        ],
      ),
      body: MultiBlocListener(
        listeners: [
          if (widget.mode != PatientFormMode.add)
            BlocListener<GetSinglePatientCubit, GetSinglePatientState>(
              listener: (context, state) {
                if (state.isSuccess && state.patient != null) {
                  _populateForm(state.patient!);
                }
              },
            ),
          BlocListener<PatientActionsCubit, PatientActionsState>(
            listener: (context, state) {
              if (state.isSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(state.successMessage ?? 'Success'),
                    backgroundColor: Colors.green));
                Navigator.pop(context, true);
              } else if (state.isError) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(state.errorMessage ?? 'Error'),
                    backgroundColor: Colors.red));
              }
            },
          )
        ],
        child: widget.mode == PatientFormMode.add
            ? _buildForm(context, theme, isDark)
            : BlocBuilder<GetSinglePatientCubit, GetSinglePatientState>(
                builder: (context, state) {
                  if (state.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state.isError) {
                    return Center(child: Text(state.errorMessage ?? 'Error'));
                  }
                  return _buildForm(context, theme, isDark);
                },
              ),
      ),
      bottomNavigationBar:
          !_isReadOnly ? _buildBottomBar(context, theme) : null,
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
            if (CacheHelper.getStringList(key: "capabilities")
                .contains("manageCapability"))
              _buildClinicDropdown(theme),
            _buildBranchDropdown(theme),
            const HeightSpacer(size: 20),
            _buildLabel(S.of(context).fullName, theme),
            _buildCustomTextField(
              controller: _nameController,
              hintText: S.of(context).fullName,
              icon: 'assets/icons/profile.svg',
              showBorder: true,
              validator: (v) => v!.isEmpty ? S.of(context).mustUsername : null,
            ),
            const HeightSpacer(size: 20),
            _buildLabel(S.of(context).emailAddress, theme),
            _buildCustomTextField(
                controller: _emailController,
                hintText: S.of(context).emailAddress,
                icon: 'assets/icons/email.svg',
                keyboardType: TextInputType.emailAddress,
                showBorder: true,
                required: false,
                validator: (v) {
                  if (v!.isNotEmpty &&
                      !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
                    return S.of(context).invalidEmail;
                  }
                  return null;
                }),
            const HeightSpacer(size: 20),
            _buildLabel(S.of(context).phone, theme),
            _buildPhoneField(theme),
            const HeightSpacer(size: 20),
            if (widget.mode == PatientFormMode.add) ...[
              _buildLabel(S.of(context).password, theme),
              _buildPasswordField(theme, isDark),
              const HeightSpacer(size: 20),
            ] else if (_loadedPatient?.serialNumber != null) ...[
              _buildSerialNumber(theme),
              const HeightSpacer(size: 20),
            ],
            _buildLabel(S.of(context).address, theme),
            _buildCustomTextField(
              controller: _addressController,
              hintText: S.of(context).address,
              icon: 'assets/icons/home.svg',
              showBorder: true, // Always bordered as per request
              required: false,
              validator: (v) => null,
            ),
            const HeightSpacer(size: 20),
            _buildLabel(S.of(context).nationalId, theme),
            _buildCustomTextField(
              controller: _nationalIdController,
              hintText: S.of(context).nationalId,
              icon: 'assets/icons/national_id.svg',
              keyboardType: TextInputType.number,
              showBorder: true, // Always bordered
              validator: (v) => v!.isEmpty ? S.of(context).mustNotEmpty : null,
            ),
            const HeightSpacer(size: 20),
            _buildLabel("Nationality", theme),
            _buildNationalityDropdown(theme),
            const HeightSpacer(size: 20),
            _buildBirthDatePicker(context, theme, isDark),
            const HeightSpacer(size: 20),
            _buildLabel(S.of(context).gender, theme),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: Text(S.of(context).male),
                    value: 'Male',
                    groupValue: _selectedGender,
                    onChanged: _isReadOnly
                        ? null
                        : (v) => setState(() => _selectedGender = v),
                    activeColor: theme.primaryColor,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: Text(S.of(context).female),
                    value: 'Female',
                    groupValue: _selectedGender,
                    onChanged: _isReadOnly
                        ? null
                        : (v) => setState(() => _selectedGender = v),
                    activeColor: theme.primaryColor,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
            if (!_isGenderValid)
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(S.of(context).mustNotEmpty,
                    style: const TextStyle(color: Colors.red, fontSize: 12)),
              ),
            if (widget.mode != PatientFormMode.add) ...[
              const HeightSpacer(size: 20),
              Divider(color: theme.dividerColor),
              const HeightSpacer(size: 20),
              _buildExaminationsList(theme),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(text,
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildSerialNumber(ThemeData theme) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: theme.cardColor,
          border: Border.all(color: theme.primaryColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_loadedPatient?.serialNumber ?? "N/A",
                style: theme.textTheme.bodyLarge),
            SvgPicture.asset("assets/icons/password.svg"),
          ],
        ));
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String hintText,
    required String icon,
    bool required = true,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    bool showBorder = true,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);
    final borderColor = showBorder ? theme.primaryColor : Colors.transparent;

    return TextFormField(
      controller: controller,
      readOnly: _isReadOnly,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      style: theme.textTheme.bodyLarge,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: theme.cardColor,
        contentPadding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: borderColor)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: borderColor)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: theme.primaryColor)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Colors.red)),
        suffixIcon: suffixIcon ??
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                child: SvgPicture.asset(icon, height: 20, width: 20)),
      ),
    );
  }

  Widget _buildExaminationsList(ThemeData theme) {
    return BlocBuilder<GetPatientExaminationsCubit,
        GetPatientExaminationsState>(builder: (context, state) {
      if (state.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }
      if (state.examinations == null ||
          (state.examinations?.examinations.isEmpty ?? true)) {
        return const SizedBox.shrink();
      }
      final list = state.examinations!.examinations;
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text("Examinations",
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(width: 20),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: theme.primaryColor, shape: BoxShape.circle),
            child: Text('${list.length}',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          )
        ]),
        const SizedBox(height: 10),
        ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final exam = list[index];
              return _buildExaminationCard(exam, theme);
            })
      ]);
    });
  }

  String _formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) return 'N/A';
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      return DateFormat('MMM dd, yyyy • hh:mm a').format(dateTime);
    } catch (_) {
      return dateTimeStr;
    }
  }

  Widget _buildExaminationCard(Examination exam, ThemeData theme) {
    return Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.primaryColor.withValues(alpha:0.3)),
        ),
        child: InkWell(
            onTap: () {
              if (CacheHelper.getStringList(key: "capabilities")
                  .contains("showExaminations")) {
                Get.to(() => OneExaminationView(id: exam.id.toString()));
              }
            },
            child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(children: [
                  Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withValues(alpha:0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.visibility_outlined,
                        color: theme.primaryColor, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(exam.type?.name ?? 'N/A',
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(_formatDateTime(exam.createdAt?.toString()),
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                ]))));
  }

  Widget _buildPhoneField(ThemeData theme) {
    return IntlPhoneField(
      initialValue: _phoneNumber ?? '',
      decoration: InputDecoration(
        hintText: S.of(context).phone,
        fillColor: theme.cardColor,
        filled: true,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 15.w),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: theme.primaryColor)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: theme.primaryColor)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: theme.primaryColor)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Colors.red)),
        suffixIcon: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: SvgPicture.asset("assets/icons/phone_number.svg", height: 15, width: 15),
        ),
      ),
      initialCountryCode: 'EG',
      dropdownIconPosition: IconPosition.leading,
      languageCode: "en",
      enabled: !_isReadOnly,
      onChanged: (phone) {
        _phoneNumber = phone.completeNumber;
      },
    );
  }

  Widget _buildPasswordField(ThemeData theme, bool isDark) {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: _buildCustomTextField(
            controller: _passwordController,
            hintText: S.of(context).password,
            icon: 'assets/icons/password.svg',
            obscureText: _obscurePassword,
            showBorder: true,
            suffixIcon: IconButton(
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
              icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility),
              color: theme.primaryColor,
            ),
            validator: (value) =>
                value!.isEmpty ? S.of(context).mustPassword : null,
          ),
        ),
        if (!_isReadOnly) ...[
          SizedBox(width: 8.w),
          Expanded(
            flex: 1,
            child: _buildPasswordGeneratorButton(theme, isDark),
          ),
        ]
      ],
    );
  }

  Widget _buildPasswordGeneratorButton(ThemeData theme, bool isDark) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(1),
        decoration:
            BoxDecoration(shape: BoxShape.circle, color: theme.cardColor),
        child: IconButton(
          onPressed: () {
            final generated = _passwordGenerator.generatePassword();
            if (generated.checkStrength() >= 28) {
              setState(() => _passwordController.text = generated);
            }
          },
          icon: SvgPicture.asset('assets/icons/password.svg'),
        ),
      ),
    );
  }

  Widget _buildClinicDropdown(ThemeData theme) {
    return BlocBuilder<GetClinicsCubit, GetClinicsState>(
        builder: (context, state) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel("Clinic", theme),
          DropdownItem(
            radius: 30,
            color: theme.cardColor,
            isShadow: false,
            border: theme.primaryColor,
            iconData:
                Icon(Icons.arrow_drop_down_circle, color: theme.primaryColor),
            items: state.clinics?.clinics ?? [],
            isValid: _isClinicValid,
            validateText: 'Must select Clinic',
            selectedValue: _selectedClinicId,
            hintText: 'Select Clinic',
            itemAsString: (item) => item.name.toString(),
            onItemSelected: (item) {
              setState(() {
                _selectedClinicId = item.id;
                _selectedBranch = null;
              });
              context
                  .read<GetBranchesCubit>()
                  .add(SetClinicFilterEvent(_selectedClinicId));
            },
            readOnly: _isReadOnly,
            isLoading: state.isLoading,
          ),
          const HeightSpacer(size: 20),
        ],
      );
    });
  }

  Widget _buildBranchDropdown(ThemeData theme) {
    return BlocBuilder<GetBranchesCubit, GetBranchesState>(
        builder: (context, state) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel("Branch", theme),
          DropdownItem(
            radius: 30,
            color: theme.cardColor,
            isShadow: false,
            border: theme.primaryColor,
            iconData:
                Icon(Icons.arrow_drop_down_circle, color: theme.primaryColor),
            items: state.branches?.branches ?? [],
            isValid: _isBranchValid,
            validateText: S.of(context).mustBranch,
            selectedValue: _selectedBranch?.name,
            hintText: 'Select Branch',
            itemAsString: (item) => item.name.toString(),
            onItemSelected: (item) => setState(() => _selectedBranch = item),
            readOnly: _isReadOnly,
            isLoading: state.isLoading,
          ),
        ],
      );
    });
  }

  Widget _buildNationalityDropdown(ThemeData theme) {
    return DropdownItem<Nationality>(
      radius: 30,
      color: theme.cardColor,
      isShadow: false,
      border: theme.primaryColor,
      iconData: Icon(Icons.arrow_drop_down_circle, color: theme.primaryColor),
      items: nationalities,
      isValid: _isNationalityValid,
      validateText: 'Nationality must not be Empty',
      selectedValue: _selectedNationality?.name,
      hintText: 'Select Nationality',
      itemAsString: (item) => item.name,
      onItemSelected: (item) => setState(() => _selectedNationality = item),
      readOnly: _isReadOnly,
      isLoading: false,
    );
  }

  Widget _buildBirthDatePicker(
      BuildContext context, ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(S.of(context).dateOfBirth, theme),
        InkWell(
          onTap: _isReadOnly
              ? null
              : () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _birthDate ?? DateTime(2000),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                    builder: (context, child) => Theme(
                      data: theme.copyWith(
                        colorScheme: ColorScheme.light(
                            primary: theme.primaryColor,
                            onPrimary: Colors.white,
                            surface: theme.cardColor,
                            onSurface: theme.textTheme.bodyLarge!.color!),
                      ),
                      child: child!,
                    ),
                  );
                  if (date != null) {
                    setState(() {
                      _birthDate = date;
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
                  color: _isBirthDateValid ? theme.primaryColor : Colors.red),
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
                            style: theme.textTheme.titleMedium))),
                Container(
                    width: 2,
                    height: 30,
                    decoration: BoxDecoration(
                        color: theme.dividerColor,
                        borderRadius: BorderRadius.circular(30))),
                Expanded(
                    child: Center(
                        child: Text(
                            _birthDate != null
                                ? '${_birthDate!.month}'
                                : S.of(context).mm,
                            style: theme.textTheme.titleMedium))),
                Container(
                    width: 2,
                    height: 30,
                    decoration: BoxDecoration(
                        color: theme.dividerColor,
                        borderRadius: BorderRadius.circular(30))),
                Expanded(
                    child: Center(
                        child: Text(
                            _birthDate != null
                                ? '${_birthDate!.year}'
                                : S.of(context).yy,
                            style: theme.textTheme.titleMedium))),
              ],
            ),
          ),
        ),
        if (!_isBirthDateValid)
          Padding(
              padding: const EdgeInsets.only(top: 8, left: 12),
              child: Text(S.of(context).mustBirth,
                  style: const TextStyle(color: Colors.red, fontSize: 12))),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context, ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: const [
          BoxShadow(
              color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: _submitForm,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.primaryColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            padding: EdgeInsets.symmetric(vertical: 16.h),
          ),
          child: Text(
            widget.mode == PatientFormMode.add
                ? S.of(context).add
                : S.of(context).confirm,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    // Validate
    if (!_formKey.currentState!.validate()) return;

    // Manual Validation
    setState(() {
      _isClinicValid = _selectedClinicId != null ||
          !CacheHelper.getStringList(key: "capabilities")
              .contains("manageCapability");
      _isBranchValid = _selectedBranch != null;
      _isNationalityValid = _selectedNationality != null;
      _isBirthDateValid = _birthDate != null;
      _isGenderValid = _selectedGender != null;
    });

    if (!_isClinicValid ||
        !_isBranchValid ||
        !_isNationalityValid ||
        !_isBirthDateValid ||
        !_isGenderValid) {
      return;
    }

    final patient = Patient(
      name: _nameController.text,
      email: _emailController.text,
      phone: _phoneNumber,
      password: _passwordController.text,
      address: _addressController.text,
      nationalId: _nationalIdController.text,
      nationality: _selectedNationality?.name,
      birthDate: _birthDate,
      gender: _selectedGender,
      clinic: Clinic(id: _selectedClinicId, name: ""),
      branch: _selectedBranch,
    );

    if (widget.mode == PatientFormMode.add) {
      context.read<PatientActionsCubit>().add(AddPatientEvent(patient));
    } else {
      context
          .read<PatientActionsCubit>()
          .add(UpdatePatientEvent(widget.patientId!, patient));
    }
  }
}

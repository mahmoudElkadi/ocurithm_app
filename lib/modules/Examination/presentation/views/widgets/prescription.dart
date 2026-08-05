import 'package:flutter/material.dart' hide Action;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ocurithm/core/utils/colors.dart';
import 'package:ocurithm/core/utils/services_locator.dart';
import 'package:ocurithm/core/utils/snackbar_service.dart';
import 'package:ocurithm/core/widgets/height_spacer.dart';
import 'package:ocurithm/modules/Examination/presentation/manager/examination_actions_cubit/examination_actions_cubit.dart';
import 'package:ocurithm/modules/Examination/presentation/views/widgets/prescription_pdf.dart';
import 'package:ocurithm/modules/Make_Appointment/presentation/views/make_appointment_view.dart';
import 'package:ocurithm/modules/Patient/data/model/one_exam.dart'
    hide Appointment;
import 'package:rxdart/rxdart.dart'; // For robust stream handling

import '../../../../../core/utils/format_helper.dart';
import '../../../../../core/widgets/DropdownPackage.dart';
import '../../../../../core/widgets/confirmation_popuo.dart';
import '../../../../../core/widgets/custom_column_section.dart';
import '../../../../../core/widgets/custom_freeze_loading.dart';
import '../../../../Analysis/data/models/analysis_model.dart'
    as analysis_model; // Added for type safety
import '../../../../Analysis/presentation/manager/analysis_cubit/get_analysis_cubit.dart';
import '../../../../Analysis/presentation/views/widgets/analysis_view_body.dart'
    as analysis_view; // Aliased
import '../../../../Analysis/presentation/views/widgets/chart_selection_dialog.dart';
import '../../../../Appointment/data/models/appointment_model.dart';
import '../../../../Appointment/presentation/manager/Appointment cubit/appointment_cubit.dart';
import '../../../../Doctor/data/model/doctor_model.dart';
import '../../../../Medicine/data/model/medicine_model.dart' as medicineModel
    show CommercialName; // Aliased to avoid conflict
import '../../../../Medicine/presentation/manager/get_medicines_cubit/get_medicines_cubit.dart';
import 'add_medicine_sheet.dart';
import 'examination_values_picker.dart';

class MedicalTreeForm extends StatelessWidget {
  const MedicalTreeForm(
      {super.key, required this.examination, this.doctor, this.appointment});

  final Appointment? appointment;
  final Examination? examination;
  final Doctor? doctor;

  @override
  Widget build(BuildContext context) {
    final patientId = examination?.patient?.id ?? appointment?.patient;
    return BlocProvider(
      create: (context) {
        final cubit = sl<GetAnalysisCubit>();
        if (patientId != null) {
          cubit.add(GetPatientAnalysisEvent(patientId: patientId.toString()));
        }
        return cubit;
      },
      child: _MedicalTreeFormBody(
        examination: examination,
        doctor: doctor,
        appointment: appointment,
      ),
    );
  }
}

class _MedicalTreeFormBody extends StatefulWidget {
  const _MedicalTreeFormBody(
      {required this.examination, this.doctor, this.appointment});

  final Appointment? appointment;
  final Examination? examination;
  final Doctor? doctor;

  @override
  State<_MedicalTreeFormBody> createState() => _MedicalTreeFormBodyState();
}

class _MedicalTreeFormBodyState extends State<_MedicalTreeFormBody> {
  String? selectedMainOption;
  String? selectedGlassesType;
  final TextEditingController IPDController = TextEditingController();
  final TextEditingController typeOfLens = TextEditingController();
  final TextEditingController diagnosisController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  void _onPrintPressed({
    required String actionName,
    required bool showPrescriptionTable,
    List<Medicine>? prescriptionList,
  }) async {
    final currentAction = getActionByOption(actionName);
    if (currentAction == null) return;

    final analysisCubit = context.read<GetAnalysisCubit>();
    var analysisState = analysisCubit.state;

    // Robust wait for analysis data if not already successful
    if (!analysisState.isSuccess &&
        (analysisState.isInitial || analysisState.isLoading)) {
      // If still initial, trigger fetch manually if patientId is available
      if (analysisState.isInitial) {
        final patientId =
            widget.examination?.patient?.id ?? widget.appointment?.patient;
        if (patientId != null) {
          analysisCubit
              .add(GetPatientAnalysisEvent(patientId: patientId.toString()));
        }
      }

      customLoading(context, "Preparing analysis report...");

      try {
        // Use RxDart to include current state and wait for completion
        analysisState = await analysisCubit.stream
            .startWith(analysisCubit.state)
            .firstWhere((s) => s.isSuccess || s.isError || s.noConnection)
            .timeout(const Duration(seconds: 7));
      } catch (e) {
        analysisState = analysisCubit.state;
      }

      if (mounted) Navigator.pop(context); // Dismiss loading
    }

    if (analysisState.isSuccess && analysisState.analysis != null) {
      await showDialog<bool>(
        context: context,
        builder: (context) => ChartSelectionDialog(
          analysis: analysisState.analysis!,
          currentEyeSelection: analysis_view.EyeSelection.both,
          onSelectionConfirmed: (selectedKeys, eyeSelection) {
            _printNormally(
              currentAction,
              showPrescriptionTable,
              prescriptionList,
              analysis: analysisState.analysis,
              selectedChartKeys: selectedKeys,
              eyeSelection: eyeSelection,
            );
          },
        ),
      );
    } else {
      _printNormally(currentAction, showPrescriptionTable, prescriptionList);
    }
  }

  void _printNormally(
    Action action,
    bool showPrescriptionTable,
    List<Medicine>? prescriptionList, {
    analysis_model.AnalysisModel? analysis,
    Set<String>? selectedChartKeys,
    analysis_view.EyeSelection? eyeSelection,
  }) {
    generateAndPrintPrescription(
      examination: ExaminationModel(
        examination: widget.examination,
        doctor: widget.doctor,
      ),
      prescriptionList: prescriptionList,
      showPrescriptionTable: showPrescriptionTable,
      action: action,
      diagnosis: unDiagnosedYet ? null : diagnosisController.text,
      analysis: analysis,
      selectedChartKeys: selectedChartKeys,
      selectedExaminationFieldIds: selectedExaminationFieldIds,
      eyeSelection: eyeSelection,
    );
  }

  /// Examination readings chosen for print. A printing choice rather than part of
  /// the clinical record, so it lives for this session only and is not persisted.
  final Set<String> selectedExaminationFieldIds = <String>{};

  // Add these to your state class
  final List<String> selectedMainOptions = [];
  final List<Action> prescriptionsList = [];

// Add a method to check if an option is selected
  bool isOptionSelected(String option) {
    return selectedMainOptions.contains(option);
  }

// Add a method to toggle selection
  // Update toggleMainOption to initialize eye selection
  void toggleMainOption(String option) {
    setState(() {
      if (selectedMainOptions.contains(option)) {
        // Remove option and its prescription
        selectedMainOptions.remove(option);
        handleOptionDeselection(option);
        // Remove eye selection for this option
        eyeSelections.remove(option);
      } else {
        // Add new option
        selectedMainOptions.add(option);
        // Initialize empty prescription and eye selection for this option
        prescriptionsList.add(Action(
          action: option.toLowerCase(),
          data: '',
          metaData: [],
          eye: null,
        ));
      }
    });
  }

  void handleOptionDeselection(String option) {
    setState(() {
      // Remove prescription for this option

      eyeSelections.remove(option);

      prescriptionsList.removeWhere((p) => p.action == option.toLowerCase());
      selectedMainOptions.remove(option);

      // Clear associated data based on the option type
      switch (option) {
        case 'Prescribe glasses':
          IPDController.clear();
          selectedGlassesType = null;
          selectedGlassesValue = null;
          break;

        case 'Prescribe medications':
          medicationsList.clear();
          break;

        case 'Refer to investigations':
          // Reset investigation checkboxes
          investigationOptions.updateAll((key, value) => false);
          cornealOptions.updateAll((key, value) => false);
          biometryTypes.updateAll((key, value) => false);
          biometryFeatures.updateAll((key, value) => false);
          break;

        case 'Refer to lasers':
          selectedLaserOption = null;
          break;

        case 'Keratoconus':
          selectedKeratoconusOption = null;
          break;

        case 'Refer to OR':
          selectedOROption = null;
          cataractSurgeryOptions.updateAll((key, value) => false);
          injectionOptions.updateAll((key, value) => false);
          selectedOption = null;
          typeOfLens.clear();
          break;

        case 'Book next appointment':
          selectedDate = null;
          selectedTime = null;
          selectedAppointmentType = null;
          break;
      }

      // Clear eye selection if no options remain that need it
      if (!selectedMainOptions.any((option) =>
          option != 'Prescribe glasses' && option != 'Prescribe medications')) {
        selectedeye = null;
      }

      // If this was the currently selected option, clear it
      if (selectedMainOption == option) {
        selectedMainOption = null;
      }
    });
  }

  void updatePrescriptionInList(String action) {
    final prescriptionObject = generatePrescriptionObject(action);
    final index =
        prescriptionsList.indexWhere((p) => p.action == action.toLowerCase());

    if (index != -1) {
      setState(() {
        prescriptionsList[index] = prescriptionObject;
      });
    }
  }

  // Investigation checkboxes
  final Map<String, bool> investigationOptions = {
    'Corneal': false,
    'Cataract': false,
    'B-scan ultransonography': false,
    'Colored fundoscopy': false,
    'FFA': false,
    'OCT': false,
    'OCTA': false,
    'GCC': false,
    'RNFL': false,
    'Visual field': false,
    'IOP measurement': false,
  };

  // Corneal sub-options
  final Map<String, bool> cornealOptions = {
    'Topography': false,
    'Pentacam': false,
  };

  // Cataract sub-options
  final Map<String, bool> biometryTypes = {
    'Ultrasound': false,
    'Optical': false,
  };

  final Map<String, bool> biometryFeatures = {
    'Biometry': false,
  };

  // Laser options
  final List<String> laserOptions = [
    'Laser refractive surgery',
    'LASIK',
    'PRK',
    'FemtoLASIK',
    'FemtoSMILE'
  ];

  // Keratoconus options
  final List<String> keratoconusOptions = ['CXL', 'Athens protocol', 'Intacs'];

  // OR options
  final List<String> orOptions = [
    'Cataract surgery',
    'Intravitreal injection',
    'Retinal surgery',
    'Glaucoma surgery',
    'Other surgery'
  ];
  final List<String> eyes = ['OD', 'OS', 'BL'];

  // Cataract surgery options
  final Map<String, bool> cataractSurgeryOptions = {
    'Phaco': false,
    'Extracap': false,
  };

  // Intravitreal injection options
  final Map<String, bool> injectionOptions = {
    'Eylea': false,
    'Lucentis': false,
    'Avastin': false,
    'Ziv-aflibercept': false,
    'Vabysmo': false,
    'VsiqqOO': false,
    'Ozurdex': false,
  };

  String? selectedOption; // Store the selected key instead of a Map

  // Appointment types
  final List<String> appointmentTypes = ['As before', 'New appointment'];

  String? selectedLaserOption;
  String? selectedKeratoconusOption;
  String? selectedOROption;
  String? selectedeye;
  String? selectedAppointmentType;

  // Main category icons
  final Map<String, IconData> categoryIcons = {
    'Prescribe glasses': Icons.visibility,
    'Prescribe medications': Icons.medication,
    'Refer to investigations': Icons.science,
    'Refer to lasers': Icons.flash_on,
    'Keratoconus': Icons.remove_red_eye,
    'Refer to OR': Icons.local_hospital,
    'Book next appointment': Icons.calendar_today,
  };

  // Main categories
  final List<String> mainOptions = [
    'Prescribe glasses',
    'Prescribe medications',
    'Refer to investigations',
    'Refer to lasers',
    'Keratoconus',
    'Refer to OR',
    'Book next appointment'
  ];
  bool unDiagnosedYet = false;

  // Glasses prescription details
  final List<String> glassesTypes = [
    'Near vision',
    'Far vision',
    'IPD',
    'Remarks'
  ];
  String? selectedGlassesValue;

  /// [action] is `'save'` for a draft the doctor will come back to, or `'create'`
  /// to finalize the visit. The backend keeps the appointment in `Saved` for a
  /// draft and only counts the prescription on `'create'`.
  Map<String, dynamic> getFinalizationData({String action = 'create'}) {
    return {
      'diagnosis':
          unDiagnosedYet ? null : diagnosisController.text.toLowerCase(),
      'medicine': medicationsList.map((m) => m.toJson()).toList(),
      'actions': prescriptionsList.map((action) => action.toJson()).toList(),
      'action': action,
    };
  }

  /// Whether the submit currently in flight is a draft save; drives whether the
  /// success handler closes the visit or leaves the doctor on the step.
  bool _isDraftSave = false;

  /// Fold the currently selected options into `prescriptionsList` so both Save and
  /// Finalize send what is on screen.
  void _syncSelectedPrescriptions() {
    for (final option in selectedMainOptions) {
      final currentPrescription = generatePrescriptionObject(option);
      final existingIndex =
          prescriptionsList.indexWhere((p) => p.action == option.toLowerCase());

      if (existingIndex != -1) {
        prescriptionsList[existingIndex] = currentPrescription;
      } else {
        prescriptionsList.add(currentPrescription);
      }
    }
  }

  Action? getActionByOption(String option) {
    for (var option in selectedMainOptions) {
      final currentPrescription = generatePrescriptionObject(option);
      final existingIndex =
          prescriptionsList.indexWhere((p) => p.action == option.toLowerCase());

      if (existingIndex != -1) {
        prescriptionsList[existingIndex] = currentPrescription;
      } else {
        prescriptionsList.add(currentPrescription);
      }
    }

    final index = prescriptionsList.indexWhere(
        (prescription) => prescription.action == option.toLowerCase());

    if (index != -1) {
      return prescriptionsList[index];
    }

    return null;
  }

  Action generatePrescriptionObject(String option) {
    Action prescription = Action(
        action: option.toLowerCase(),
        data: '',
        metaData: [],
        eye: eyeSelections[option]?.toLowerCase());

    switch (option) {
      case 'Prescribe glasses':
        prescription.data = IPDController.text.toLowerCase();
        break;

      case 'Prescribe medications':
        prescription.medicine = medicationsList;
        break;

      case 'Refer to investigations':
        List<String> metadata = [];

        // Add main investigation options
        investigationOptions.forEach((key, value) {
          if (value) {
            metadata.add(key.toLowerCase());

            // Add sub-options for Corneal
            if (key == 'Corneal') {
              cornealOptions.forEach((subKey, subValue) {
                if (subValue) metadata.add(subKey.toLowerCase());
              });
            }

            // Add sub-options for Cataract
            if (key == 'Cataract') {
              if (biometryFeatures['Biometry'] == true) {
                metadata.add('biometry');
                biometryTypes.forEach((subKey, subValue) {
                  if (subValue) metadata.add(subKey.toLowerCase());
                });
              }
            }
          }
        });

        prescription.metaData = metadata;
        break;

      case 'Refer to lasers':
        if (selectedLaserOption != null) {
          prescription.data = selectedLaserOption!.toLowerCase();
        }
        break;

      case 'Keratoconus':
        if (selectedKeratoconusOption != null) {
          prescription.data = selectedKeratoconusOption!.toLowerCase();
        }
        break;

      case 'Refer to OR':
        if (selectedOROption != null) {
          prescription.data = selectedOROption!.toLowerCase();
          List<String> metadata = [];

          if (selectedOROption == 'Cataract surgery') {
            if (selectedOption != null) {
              metadata.add(selectedOption!.toLowerCase());
            }
            if (typeOfLens.text.isNotEmpty) {
              metadata.add(typeOfLens.text.toLowerCase());
            }
          }

          if (selectedOROption == 'Intravitreal injection') {
            injectionOptions.forEach((key, value) {
              if (value) metadata.add(key.toLowerCase());
            });
          }

          prescription.metaData = metadata;
        }
        break;

      case 'Book next appointment':
        if (selectedDate != null) {
          prescription.data = _formatAppointmentDateTime();
        }
        break;
    }

    return prescription;
  }

  final List<Medicine> medicationsList = [];
  final TextEditingController medicationNameController =
      TextEditingController();
  final TextEditingController medicationDosageController =
      TextEditingController();
  final TextEditingController medicationDurationController =
      TextEditingController();

  String? selectedMedicineId; // Store selected medicine ID

  @override
  void dispose() {
    IPDController.dispose();
    diagnosisController.dispose();
    typeOfLens.dispose();
    medicationNameController.dispose();
    medicationDosageController.dispose();
    medicationDurationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ExaminationActionsCubit, ExaminationActionsState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          if (state.status == ExaminationActionsStatus.loading) {
            customLoading(context, "");
          } else {
            // Attempt to dismiss the loading dialog.
            // Using rootNavigator: true because showDialog usually uses the root navigator.
            // wrapping in a try-catch to avoid crashing if pop fails, though unlikely.
            try {
              Navigator.of(context, rootNavigator: true).pop();
            } catch (e) {
              // log error
            }

            if (state.status == ExaminationActionsStatus.success) {
              // Mirror the status the backend just set, so the queue does not show a
              // half-finished visit as done.
              final appointmentId =
                  widget.examination?.appointment?.id ?? widget.appointment?.id;
              if (appointmentId != null) {
                context
                    .read<AppointmentCubit>()
                    .add(LocalUpdateAppointmentStatusEvent(
                      id: appointmentId.toString(),
                      status: _isDraftSave ? 'Saved' : 'Completed',
                    ));
              }

              // Both paths return to the appointment list — a draft leaves the
              // visit in Saved so it can be reopened and carried on later.
              if (mounted) {
                Navigator.of(context).pop(true);
                Navigator.of(context).pop(true);
              }

              SnackbarService.showSuccess(
                context,
                message: state.message ??
                    (_isDraftSave
                        ? "Progress saved"
                        : "Finalized Successfully"),
              );
              _isDraftSave = false;
            } else if (state.status == ExaminationActionsStatus.error ||
                state.status == ExaminationActionsStatus.noConnection) {
              SnackbarService.showError(
                context,
                message: state.error ??
                    (_isDraftSave
                        ? "Failed to save progress. Please try again."
                        : "Failed to finalize visit. Please try again."),
              );
              // Stay on the step. Popping here used to throw the doctor out of the
              // screen on a failed submit, losing everything they had entered.
              _isDraftSave = false;
            }
          }
        },
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;

            await showConfirmationDialog(
              context: context,
              title: "Discard Finalization",
              message:
                  "Are you sure you want to go back? Any unsaved changes in this finalization step will be lost.",
              confirmText: "Go Back",
              cancelText: "Stay",
              confirmColor: Colors.red,
              icon: Icons.warning_amber_rounded,
              onConfirm: () => Navigator.pop(context),
            );
          },
          child: Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colorz.primaryColor),
                onPressed: () {
                  Navigator.maybePop(context);
                },
              ),
              title: Column(
                spacing: 10,
                children: [
                  Text('Visit Finalization',
                      style: TextStyle(color: Colorz.primaryColor)),
                  Container(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      width: MediaQuery.of(context).size.width,
                      height: 3,
                      decoration: BoxDecoration(
                        color: Colorz.primaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ))
                ],
              ),
              actions: const [
                SizedBox.shrink(),
              ],
            ),
            body: SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFinalDiagnosisForm(),
                  SizedBox(height: 20.h),
                  _buildMainOptions(),
                  if (selectedMainOptions.isNotEmpty)
                    Column(
                      children: [
                        SizedBox(height: 20.h),
                        ExaminationValuesPicker(
                          measurements:
                              widget.examination?.measurements ?? const [],
                          selectedIds: selectedExaminationFieldIds,
                          onChanged: (next) => setState(() {
                            selectedExaminationFieldIds
                              ..clear()
                              ..addAll(next);
                          }),
                        ),
                        _buildSaveProgressButton(context),
                        SizedBox(height: 12.h),
                        _buildSaveButton(context),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ));
  }

  Future<void> clearOrOptions() async {
    cataractSurgeryOptions.updateAll((key, value) => false);
    injectionOptions.updateAll((key, value) => false);
    selectedOption = null;
  }

  Widget _buildMainOptions() {
    return Column(
      children: mainOptions.map((category) {
        final isSelected = isOptionSelected(category);

        return Column(
          children: [
            // Main Option Card
            Card(
              margin: EdgeInsets.only(bottom: isSelected ? 0 : 10.h),
              elevation: isSelected ? 2 : 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8.r),
                  topRight: Radius.circular(8.r),
                  bottomLeft: Radius.circular(isSelected ? 0 : 8.r),
                  bottomRight: Radius.circular(isSelected ? 0 : 8.r),
                ),
                side: BorderSide(
                  color: isSelected ? Colorz.primaryColor : Colors.transparent,
                  width: 2,
                ),
              ),
              child: InkWell(
                onTap: () => toggleMainOption(category),
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Row(
                    children: [
                      Icon(
                        categoryIcons[category],
                        size: 24.sp,
                        color: isSelected
                            ? Colorz.primaryColor
                            : Theme.of(context).iconTheme.color,
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Text(
                          category,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: isSelected
                                ? Colorz.primaryColor
                                : Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_circle,
                          color: Colorz.primaryColor,
                          size: 20.sp,
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // Form Content for Selected Option
            if (isSelected)
              Card(
                margin: EdgeInsets.only(bottom: 10.h),
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(8.r),
                    bottomRight: Radius.circular(8.r),
                  ),
                  side: BorderSide(
                    color: Colorz.primaryColor,
                    width: 2,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: _buildFormContent(category),
                ),
              ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildFormContent(String category) {
    Widget formContent;
    switch (category) {
      case 'Prescribe glasses':
        formContent = _buildGlassesPrescriptionForm();
        break;
      case 'Prescribe medications':
        formContent = _buildMedicationForm();
        break;
      case 'Refer to investigations':
        formContent = _buildInvestigationsForm();
        break;
      case 'Refer to lasers':
        formContent = _buildLaserOptionsForm();
        break;
      case 'Keratoconus':
        formContent = _buildKeratoconusForm();
        break;
      case 'Refer to OR':
        formContent = _buildORForm();
        break;
      case 'Book next appointment':
        formContent = _buildAppointmentForm();
        break;
      default:
        formContent = const SizedBox.shrink();
    }

    return Column(
      children: [
        // Eye Selection for applicable options
        if (category != 'Prescribe glasses' &&
            category != 'Prescribe medications')
          Column(
            children: [
              eyeForm(category), // Pass the current category
              SizedBox(height: 16.h),
            ],
          ),
        formContent,
      ],
    );
  }

  void updatePrescription() {
    // Update prescription when form fields change
    for (var option in selectedMainOptions) {
      final currentPrescription = generatePrescriptionObject(option);
      final index =
          prescriptionsList.indexWhere((p) => p.action == option.toLowerCase());

      if (index != -1) {
        prescriptionsList[index] = currentPrescription;
      } else {
        prescriptionsList.add(currentPrescription);
      }
    }
  }

  Widget _buildFormContainer({required String title, required Widget child}) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colorz.primaryColor,
              ),
            ),
            Divider(height: 24.h),
            child,
          ],
        ),
      ),
    );
  }

  // Widget _buildSelectedOptionContent() {
  //   switch (selectedMainOption) {
  //     case 'Prescribe glasses':
  //       return _buildGlassesPrescriptionForm();
  //     case 'Prescribe medications':
  //       return _buildMedicationForm();
  //     case 'Refer to investigations':
  //       return _buildInvestigationsForm();
  //     case 'Refer to lasers':
  //       return _buildLaserOptionsForm();
  //     case 'Keratoconus':
  //       return _buildKeratoconusForm();
  //     case 'Refer to OR':
  //       return _buildORForm();
  //     case 'Book next appointment':
  //       return _buildAppointmentForm();
  //     default:
  //       return const SizedBox.shrink();
  //   }
  // }

  Widget _buildGlassesPrescriptionForm() {
    return Column(
      children: [
        Card(
          margin: EdgeInsets.only(bottom: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "IPD",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colorz.primaryColor,
                  ),
                ),
                Divider(height: 24.h),
                TextField(
                  controller: IPDController,
                  maxLines: 1,
                  decoration: _getInputDecoration('Enter IPD...'),
                ),
                const HeightSpacer(size: 10),
                Row(
                  spacing: 10,
                  children: [
                    Expanded(
                      child: Column(
                        spacing: 6,
                        children: [
                          BuildExaminationSection(
                            title: 'Right eye',
                            sectionIndex: 2,
                            data: {
                              'Spherical': FormatHelper.formatPositiveValue(
                                  widget.examination?.measurements[1]
                                          .refinedRefractionSpherical ??
                                      ''),
                              'Cylindrical': FormatHelper.formatPositiveValue(
                                  widget.examination?.measurements[1]
                                          .refinedRefractionCylindrical ??
                                      ''),
                              'Axis': widget.examination?.measurements[1]
                                      .refinedRefractionAxis ??
                                  'N/A',
                              'NearVision': FormatHelper.formatPositiveValue(
                                  widget.examination?.measurements[1]
                                          .nearVisionAddition ??
                                      'N/A'),
                            },
                            isLeft: false,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        spacing: 6,
                        children: [
                          BuildExaminationSection(
                            title: 'left eye',
                            sectionIndex: 2,
                            data: {
                              'Spherical': FormatHelper.formatPositiveValue(
                                  widget.examination?.measurements[0]
                                          .refinedRefractionSpherical ??
                                      '-'),
                              'Cylindrical': FormatHelper.formatPositiveValue(
                                  widget.examination?.measurements[0]
                                          .refinedRefractionCylindrical ??
                                      '-'),
                              'Axis': widget.examination?.measurements[0]
                                      .refinedRefractionAxis ??
                                  '-',
                              'NearVision': FormatHelper.formatPositiveValue(
                                  widget.examination?.measurements[0]
                                          .nearVisionAddition ??
                                      '-'),
                            },
                            isLeft: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        ElevatedButton.icon(
            label: const Text("Print",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colorz.primaryColor,
            ),
            icon: const Icon(Icons.print, color: Colors.white),
            onPressed: () => _onPrintPressed(
                actionName: 'prescribe glasses', showPrescriptionTable: true)),
      ],
    );
  }

  Widget _buildFinalDiagnosisForm() {
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Final Diagnosis",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colorz.primaryColor,
              ),
            ),
            Divider(height: 24.h),
            _buildCheckbox(
                title: "Undiagnosed Yet",
                value: unDiagnosedYet,
                onChanged: (value) {
                  unDiagnosedYet = value ?? false;
                  setState(() {});
                }),
            if (!unDiagnosedYet)
              TextField(
                controller: diagnosisController,
                maxLines: 1,
                decoration: _getInputDecoration('Enter Diagnosis...'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationForm() {
    return Column(
      children: [
        _buildFormContainer(
          title: 'Medication Prescription',
          child: Column(
            children: [
              // Display added medications
              if (medicationsList.isNotEmpty)
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Medications List
                      SizedBox(
                        height: 200,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(12),
                          itemCount: medicationsList.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final medication = medicationsList[index];
                            return Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: Theme.of(context).dividerColor),
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(context)
                                        .shadowColor
                                        .withValues(alpha: 0.1),
                                    spreadRadius: 1,
                                    blurRadius: 3,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Medication Details
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Name
                                          _buildMedicationField(
                                            'Name',
                                            medication.name ?? '',
                                            Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge
                                                    ?.color ??
                                                Colors.black,
                                          ),
                                          const SizedBox(height: 8),
                                          // Dosage
                                          _buildMedicationField(
                                            'Dosage',
                                            medication.dosage ?? '',
                                            Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge
                                                    ?.color ??
                                                Colors.black,
                                          ),
                                          const SizedBox(height: 8),
                                          // Duration
                                          _buildMedicationField(
                                            'Duration',
                                            medication.duration ?? '',
                                            Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge
                                                    ?.color ??
                                                Colors.black,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    // Delete Button
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          medicationsList.removeAt(index);
                                          updatePrescription();
                                        });
                                      },
                                      borderRadius: BorderRadius.circular(20),
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.red[50],
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Icon(
                                          Icons.delete_outline,
                                          color: Colors.red[600],
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      label: const Text("Add Row",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.green,
                      ),
                      icon: const Icon(Icons.add, color: Colors.white),
                      onPressed: () => _showMedicationPopup(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      label: const Text("Print",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colorz.primaryColor,
                      ),
                      icon: const Icon(Icons.print, color: Colors.white),
                      onPressed: () => _onPrintPressed(
                          actionName: 'prescribe medications',
                          showPrescriptionTable: false,
                          prescriptionList: medicationsList),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMedicationField(String title, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title:',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).hintColor,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  void _showMedicationPopup() {
    // Clear the controllers and selection
    medicationNameController.clear();
    medicationDosageController.clear();
    medicationDurationController.clear();
    selectedMedicineId = null;
    // Whatever the doctor last typed into the search box. Kept so a name that is
    // not in the catalog can be offered to the "Add" flow rather than discarded.
    String typedMedicineName = '';

    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<GetMedicinesCubit>(),
        child: StatefulBuilder(
          builder: (dialogContext, setDialogState) => AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          title: Text(
            'Add Medication',
            style:
                TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Dropdown for Medicine Name
              BlocBuilder<GetMedicinesCubit, GetMedicinesState>(
                builder: (context, state) {
                  return FlutterDropdownSearch<medicineModel.CommercialName>(
                    hintText: "Select Medicine",
                    isLoading: state.status == GetMedicinesStatus.loading,
                    items: state.medicines,
                    isShadow: false,
                    border: Theme.of(context).dividerColor,
                    itemAsString: (item) => item.name ?? '',
                    onChanged: (value) {
                      setDialogState(() {
                        typedMedicineName = value;
                        // Typing again invalidates any earlier pick: the row must
                        // never carry a name without the catalog id that goes with
                        // it, or the server has no commercial name to prescribe.
                        medicationNameController.clear();
                        selectedMedicineId = null;
                      });
                      context
                          .read<GetMedicinesCubit>()
                          .getMedicines(search: value);
                    },
                    onItemSelected: (selectedItem) {
                      setDialogState(() {
                        medicationNameController.text = selectedItem.name ?? '';
                        selectedMedicineId = selectedItem.id;
                        typedMedicineName = selectedItem.name ?? '';
                      });
                    },
                  );
                },
              ),
              _buildUnresolvedMedicineNotice(
                dialogContext,
                typedName: typedMedicineName,
                isResolved: selectedMedicineId != null,
                onResolved: (created) {
                  setDialogState(() {
                    medicationNameController.text = created.name ?? '';
                    selectedMedicineId = created.id;
                    typedMedicineName = created.name ?? '';
                  });
                  // Refresh the catalog so the new entry shows up in the search.
                  context
                      .read<GetMedicinesCubit>()
                      .getMedicines(search: created.name);
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: medicationDosageController,
                decoration: _getInputDecoration('Dosage'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: medicationDurationController,
                decoration: _getInputDecoration('Duration'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancel',
                style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color),
              ),
            ),
            ElevatedButton(
              // A medicine is only prescribable once it resolves to a catalog
              // entry. Without the id the server has no commercial name to
              // record, which is what used to file the free text as an
              // active ingredient instead.
              onPressed: selectedMedicineId == null
                  ? null
                  : () {
                      setState(() {
                        medicationsList.add(Medicine(
                            name: medicationNameController.text,
                            dosage: medicationDosageController.text,
                            duration: medicationDurationController.text,
                            medicineId: selectedMedicineId // Pass the ID
                            ));
                        updatePrescription();
                      });
                      Navigator.pop(dialogContext);
                    },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colorz.primaryColor),
              child:
                  const Text('Confirm', style: TextStyle(color: Colors.white)),
            ),
          ],
          ),
        ),
      ),
    );
  }

  /// Shown when the doctor has typed a name that has not resolved to a catalog
  /// entry, offering the Add flow instead of silently letting it through.
  Widget _buildUnresolvedMedicineNotice(
    BuildContext dialogContext, {
    required String typedName,
    required bool isResolved,
    required void Function(medicineModel.CommercialName) onResolved,
  }) {
    if (isResolved || typedName.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(dialogContext);

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.error.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: theme.colorScheme.error.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.warning_amber_rounded,
                size: 18, color: theme.colorScheme.error),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Not in the catalog yet.',
                style:
                    TextStyle(fontSize: 12, color: theme.colorScheme.error),
              ),
            ),
            TextButton(
              onPressed: () async {
                final created = await showAddMedicineSheet(
                  dialogContext,
                  initialName: typedName.trim(),
                );
                if (created != null) {
                  onResolved(created);
                }
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: const Size(0, 28),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Add',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colorz.primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void removePrescription(String action) {
    setState(() {
      prescriptionsList.removeWhere((p) => p.action == action.toLowerCase());
      selectedMainOptions.remove(action);
      if (selectedMainOption == action) {
        selectedMainOption = null;
      }
    });
  }

  Widget _buildInvestigationsForm() {
    return Column(
      children: [
        _buildFormContainer(
          title: 'Investigations',
          child: Column(
            children: investigationOptions.entries.map((entry) {
              return Column(
                children: [
                  _buildCheckbox(
                    title: entry.key,
                    value: entry.value,
                    onChanged: (value) {
                      setState(() {
                        investigationOptions[entry.key] = value ?? false;
                        if (value == false && entry.key == 'Corneal') {
                          cornealOptions['Topography'] = false;
                          cornealOptions['Pentacam'] = false;
                        }
                        if (value == false && entry.key == 'Cataract') {
                          biometryFeatures['Biometry'] = false;
                          biometryTypes['Ultrasound'] = false;
                          biometryTypes['Optical'] = false;
                        }
                        // Update prescription after changing investigation options
                        updatePrescriptionInList('Refer to investigations');
                      });
                    },
                  ),
                  if (entry.key == 'Corneal' && entry.value)
                    Padding(
                      padding: EdgeInsets.only(left: 32.w),
                      child: Column(
                        children: cornealOptions.entries.map((option) {
                          return _buildCheckbox(
                            title: option.key,
                            value: option.value,
                            onChanged: (value) {
                              setState(() {
                                cornealOptions[option.key] = value ?? false;
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  if (entry.key == 'Cataract' && entry.value)
                    Padding(
                      padding: EdgeInsets.only(left: 32.w),
                      child: Column(
                        children: biometryFeatures.entries.map((option) {
                          return _buildCheckbox(
                            title: option.key,
                            value: option.value,
                            onChanged: (value) {
                              setState(() {
                                biometryFeatures[option.key] = value ?? false;
                                if (value == false &&
                                    option.key == 'Biometry') {
                                  // biometryTypes['Ultrasound'] = false;
                                  // biometryTypes['Optical'] = false;
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  if (entry.key == 'Cataract' &&
                      entry.value &&
                      biometryFeatures['Biometry']!)
                    Padding(
                      padding: EdgeInsets.only(left: 64.w),
                      child: Column(
                        children: biometryTypes.entries.map((option) {
                          return _buildCheckbox(
                            title: option.key,
                            value: option.value,
                            onChanged: (value) {
                              setState(() {
                                biometryTypes[option.key] = value ?? false;
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
        ElevatedButton.icon(
            label: const Text("Print",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colorz.primaryColor,
            ),
            icon: const Icon(Icons.print, color: Colors.white),
            onPressed: () => _onPrintPressed(
                actionName: 'refer to investigations',
                showPrescriptionTable: false)),
      ],
    );
  }

  Widget _buildCheckbox({
    required String title,
    required bool value,
    required Function(bool?) onChanged,
  }) {
    return CheckboxListTile(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15.sp,
          color: value
              ? Colorz.primaryColor
              : Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
      value: value,
      activeColor: Colorz.primaryColor,
      controlAffinity: ListTileControlAffinity.leading,
      onChanged: onChanged,
    );
  }

  Widget _buildRadioButton({
    required String title,
    required bool value,
    required String? groupValue, // Add groupValue parameter
    required Function(String?) onChanged, // Change onChanged to handle String
  }) {
    return RadioListTile<String>(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15.sp,
          color: title == groupValue
              ? Colorz.primaryColor
              : Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
      value: title,
      // Use the title as the value
      groupValue: groupValue,
      // Compare with groupValue
      activeColor: Colorz.primaryColor,
      controlAffinity: ListTileControlAffinity.leading,
      onChanged: onChanged,
    );
  }

  Widget _buildLaserOptionsForm() {
    return Column(
      children: [
        _buildFormContainer(
          title: 'Laser Options',
          child: _buildDropdown(
            items: laserOptions,
            value: selectedLaserOption,
            onChanged: (value) => setState(() => selectedLaserOption = value),
            hint: 'Select laser option',
          ),
        ),
        ElevatedButton.icon(
            label: const Text("Print",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colorz.primaryColor,
            ),
            icon: const Icon(Icons.print, color: Colors.white),
            onPressed: () => _onPrintPressed(
                actionName: 'refer to lasers', showPrescriptionTable: false)),
      ],
    );
  }

  Widget _buildKeratoconusForm() {
    return Column(
      children: [
        _buildFormContainer(
          title: 'Keratoconus Options',
          child: _buildDropdown(
            items: keratoconusOptions,
            value: selectedKeratoconusOption,
            onChanged: (value) =>
                setState(() => selectedKeratoconusOption = value),
            hint: 'Select keratoconus option',
          ),
        ),
        //Keratoconus
        ElevatedButton.icon(
            label: const Text("Print",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colorz.primaryColor,
            ),
            icon: const Icon(Icons.print, color: Colors.white),
            onPressed: () => _onPrintPressed(
                actionName: 'keratoconus', showPrescriptionTable: false)),
      ],
    );
  }

  final Map<String, String?> eyeSelections = {};

  Widget eyeForm(String currentOption) {
    return _buildDropdown(
      items: eyes,
      value: eyeSelections[currentOption],
      onChanged: (value) async {
        await clearOrOptions();
        setState(() {
          eyeSelections[currentOption] = value;
          // Update prescription when eye selection changes
          updatePrescriptionInList(currentOption);
        });
      },
      hint: 'Select eye',
    );
  }

  Widget _buildORForm() {
    return Column(
      children: [
        _buildFormContainer(
          title: 'OR Options',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDropdown(
                items: orOptions,
                value: selectedOROption,
                onChanged: (value) async {
                  await clearOrOptions();

                  setState(() {
                    selectedOROption = value;
                  });
                },
                hint: 'Select OR option',
              ),
              SizedBox(height: 16.h),
              if (selectedOROption == 'Cataract surgery') ...[
                ...cataractSurgeryOptions.entries.map((entry) {
                  return _buildRadioButton(
                    title: entry.key,
                    value: entry.value,
                    groupValue:
                        selectedOption, // Pass the currently selected option
                    onChanged: (value) {
                      setState(() {
                        // Reset all values to false
                        cataractSurgeryOptions.forEach((key, _) {
                          cataractSurgeryOptions[key] = false;
                        });
                        // Set only the selected one to true
                        if (value != null) {
                          selectedOption = value;
                          cataractSurgeryOptions[value] = true;
                        }
                      });
                    },
                  );
                }),
                SizedBox(height: 16.h),
                TextField(
                  controller: typeOfLens,
                  maxLines: 1,
                  decoration: _getInputDecoration('Type Of Lens...'),
                ),
              ],
              if (selectedOROption == 'Intravitreal injection') ...[
                ...injectionOptions.entries.map((entry) {
                  return _buildCheckbox(
                    title: entry.key,
                    value: entry.value,
                    onChanged: (value) {
                      setState(() {
                        injectionOptions[entry.key] = value ?? false;
                      });
                    },
                  );
                }),
              ],
            ],
          ),
        ),
        ElevatedButton.icon(
            label: const Text("Print",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colorz.primaryColor,
            ),
            icon: const Icon(Icons.print, color: Colors.white),
            onPressed: () => _onPrintPressed(
                actionName: 'refer to or', showPrescriptionTable: false)),
      ],
    );
  }

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  Widget _buildAppointmentForm() {
    return Column(
      children: [
        _buildFormContainer(
          title: 'Next Appointment',
          child: Column(
            children: [
              InkWell(
                onTap: () async {
                  widget.appointment?.datetime = null;
                  final result = await Get.to(() => MakeAppointmentView(
                        appointment: widget.appointment,
                      ));

                  // If appointment was created successfully, get the selected date/time
                  if (result != null && result is DateTime) {
                    setState(() {
                      selectedDate = result;
                      selectedTime = TimeOfDay.fromDateTime(result);
                    });
                  }
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).dividerColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: Colorz.primaryColor),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          selectedDate != null
                              ? _formatAppointmentDateTime()
                              : 'Select appointment date and time',
                          style: TextStyle(
                            color: selectedDate != null
                                ? Theme.of(context).textTheme.bodyLarge?.color
                                : Theme.of(context).hintColor,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        ElevatedButton.icon(
            label: const Text("Print",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colorz.primaryColor,
            ),
            icon: const Icon(Icons.print, color: Colors.white),
            onPressed: () => _onPrintPressed(
                actionName: 'book next appointment',
                showPrescriptionTable: false)),
      ],
    );
  }

// Add this method to format the date and time
  String _formatAppointmentDateTime() {
    if (selectedDate == null) return '';

    // Format date
    String formattedDate =
        '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}';

    // Format time
    String period = selectedTime!.period == DayPeriod.am ? 'AM' : 'PM';
    int hour = selectedTime!.hourOfPeriod;
    String minute = selectedTime!.minute.toString().padLeft(2, '0');
    String formattedTime = '$hour:$minute $period';

    return '$formattedDate $formattedTime';
  }

  Widget _buildDropdown({
    required List<String> items,
    required String? value,
    required Function(String?) onChanged,
    required String hint,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: _getInputDecoration(hint),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  InputDecoration _getInputDecoration(String label) {
    return InputDecoration(
      hintText: label,
      labelStyle: TextStyle(color: Theme.of(context).hintColor),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: BorderSide(color: Theme.of(context).dividerColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: BorderSide(color: Colorz.primaryColor),
      ),
    );
  }

  /// Saves the finalization as a draft and returns to the appointment list. The
  /// visit stays in Saved, so a doctor can reopen it to add, remove or amend
  /// actions across several passes before finalizing.
  Widget _buildSaveProgressButton(BuildContext context) {
    return SizedBox(
      height: 48,
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          _syncSelectedPrescriptions();
          _isDraftSave = true;
          context.read<ExaminationActionsCubit>().makeFinalization(
                id: widget.examination?.id ?? '',
                data: getFinalizationData(action: 'save'),
              );
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: Colorz.primaryColor,
          side: BorderSide(color: Colorz.primaryColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.save_outlined, size: 20),
        label: const Text(
          'Save Progress',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return BlocBuilder<ExaminationActionsCubit, ExaminationActionsState>(
      builder: (context, state) => Container(
        height: 54,
        width: double.infinity,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colorz.primaryColor.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colorz.primaryColor,
                Colorz.primaryColor.withBlue(200),
              ],
            )),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              _syncSelectedPrescriptions();

              final finalizationData = getFinalizationData();
              final diagnosis = diagnosisController.text.isNotEmpty
                  ? diagnosisController.text
                  : 'Not specified';

              showConfirmationDialog(
                context: context,
                title: "Finalize Visit",
                icon: Icons.assignment_turned_in_rounded,
                confirmColor: Colorz.primaryColor,
                confirmText: "Finalize",
                text: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Review the summary below before completing the visit. This action cannot be undone.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colorz.primaryColor.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: Colorz.primaryColor.withValues(alpha: 0.1)),
                      ),
                      child: Column(
                        children: [
                          _buildSummaryRow(Icons.description_outlined,
                              "Diagnosis", diagnosis),
                          if (medicationsList.isNotEmpty)
                            _buildSummaryRow(
                                Icons.medication_outlined,
                                "Medications",
                                "${medicationsList.length} prescribed"),
                          if (selectedMainOptions.isNotEmpty)
                            _buildSummaryRow(Icons.list_alt_rounded, "Actions",
                                "${selectedMainOptions.length} categories"),
                        ],
                      ),
                    ),
                  ],
                ),
                onConfirm: () async {
                  _isDraftSave = false;
                  customLoading(context, "");
                  // bool value = await InternetConnection().hasInternetAccess;
                  // if (!value) {
                  //   Navigator.pop(context);
                  //   SnackbarService.showWarning(context, message: 'No Internet Connection');
                  //   return;
                  // }

                  // Send the entire prescriptions list

                  context.read<ExaminationActionsCubit>().makeFinalization(
                      id: widget.examination?.id ?? '', data: finalizationData);
                },
                onCancel: () {
                  // Redundant pop removed to fix the bug where the page closed
                },
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline, color: Colors.white, size: 22),
                SizedBox(width: 10),
                Text(
                  'Finalize Visit',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colorz.primaryColor),
          const SizedBox(width: 10),
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

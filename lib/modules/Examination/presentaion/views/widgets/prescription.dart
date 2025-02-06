import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:ocurithm/core/utils/colors.dart';
import 'package:ocurithm/core/widgets/height_spacer.dart';
import 'package:ocurithm/modules/Examination/presentaion/views/widgets/prescription_pdf.dart';
import 'package:ocurithm/modules/Patient/data/model/one_exam.dart';

import '../../../../../core/widgets/confirmation_popuo.dart';
import '../../../../../core/widgets/custom_column_section.dart';
import '../../../../../core/widgets/custom_freeze_loading.dart';
import '../../../../Doctor/data/model/doctor_model.dart';
import '../../../data/repos/examination_repo_impl.dart';
import '../../manager/examination_cubit.dart';
import '../../manager/examination_state.dart';

class MedicalTreeForm extends StatefulWidget {
  const MedicalTreeForm({super.key, required this.examination, this.doctor});

  final Examination? examination;
  final Doctor? doctor;

  @override
  State<MedicalTreeForm> createState() => _MedicalTreeFormState();
}

class _MedicalTreeFormState extends State<MedicalTreeForm> {
  String? selectedMainOption;
  String? selectedGlassesType;
  final TextEditingController prescriptionController = TextEditingController();
  final TextEditingController IPDController = TextEditingController();
  final TextEditingController typeOfLens = TextEditingController();
  final TextEditingController diagnosisController = TextEditingController();

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
  final List<String> laserOptions = ['Laser refractive surgery', 'LASIK', 'PRK', 'FemtoLASIK', 'FemtoSMILE'];

  // Keratoconus options
  final List<String> keratoconusOptions = ['CXL', 'Athens protocol', 'Intacs'];

  // OR options
  final List<String> orOptions = ['Cataract surgery', 'Intravitreal injection', 'Retinal surgery', 'Glaucoma surgery', 'Other surgery'];
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
  final List<String> glassesTypes = ['Near vision', 'Far vision', 'IPD', 'Remarks'];
  String? selectedGlassesValue;

  Map<String, dynamic> generatePrescriptionObject() {
    Map<String, dynamic> prescription = {
      'action': selectedMainOption?.toLowerCase() ?? '',
      'data': '',
      'metaData': [],
      'diagnosis': unDiagnosedYet ? null : diagnosisController.text.toLowerCase(),
      'eye': selectedeye?.toLowerCase()
    };

    switch (selectedMainOption) {
      case 'Prescribe glasses':
        prescription['data'] = IPDController.text.toLowerCase();
        break;

      case 'Prescribe medications':
        prescription['data'] = prescriptionController.text.toLowerCase();
        break;

      case 'Refer to investigations':
        // Main investigation options
        prescription['metaData'] = [
          ...investigationOptions.entries.where((entry) => entry.value).map((entry) => entry.key.toLowerCase()),

          // Corneal sub-options
          if (investigationOptions['Corneal'] == true)
            ...cornealOptions.entries.where((entry) => entry.value).map((entry) => entry.key.toLowerCase()),

          // Cataract sub-options
          if (investigationOptions['Cataract'] == true) ...[
            if (biometryFeatures['Biometry'] == true) 'biometry',
            ...biometryTypes.entries.where((entry) => entry.value).map((entry) => entry.key.toLowerCase()),
          ]
        ];
        break;

      case 'Refer to lasers':
        final selectedLaserOption = this.selectedLaserOption;
        if (selectedLaserOption != null) {
          prescription['data'] = selectedLaserOption.toLowerCase();
        }
        break;

      case 'Keratoconus':
        if (selectedKeratoconusOption != null) {
          prescription['data'] = selectedKeratoconusOption?.toLowerCase();
        }
        break;

      case 'Refer to OR':
        if (selectedOROption != null) {
          prescription['data'] = selectedOROption?.toLowerCase();
        }
        prescription['metaData'] = [
          if (selectedOROption == 'Cataract surgery') selectedOption,
          typeOfLens.text,
          if (selectedOROption == 'Intravitreal injection')
            ...injectionOptions.entries.where((entry) => entry.value).map((entry) => entry.key.toLowerCase()),
        ];
        break;

      case 'Book next appointment':
        if (selectedMainOption == 'Book next appointment' && selectedDate != null) {
          prescription['data'] = _formatAppointmentDateTime();
        }
        break;
    }

    log(prescription.toString());

    return prescription;
  }

  @override
  void dispose() {
    prescriptionController.dispose();
    IPDController.dispose();
    diagnosisController.dispose();
    typeOfLens.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ExaminationCubit(ExaminationRepoImpl()),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: SizedBox.shrink(),
          title: Column(
            spacing: 10,
            children: [
              Text('Visit Finalization', style: TextStyle(color: Colorz.primaryColor)),
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
          actions: [
            IconButton(
                icon: Icon(Icons.picture_as_pdf),
                color: Colorz.primaryColor,
                onPressed: () {
                  log("sss" + generatePrescriptionObject()['diagnosis']);
                  generateAndPrintPrescription(
                      ExaminationModel(
                          examination: widget.examination,
                          doctor: widget.doctor,
                          finalization: Finalization(
                              action: generatePrescriptionObject()['action'],
                              eye: generatePrescriptionObject()['eye'],
                              data: generatePrescriptionObject()['data'],
                              diagnosis: generatePrescriptionObject()['diagnosis'],
                              metaData: generatePrescriptionObject()['metaData'])),
                      showPrescriptionTable: selectedMainOption == 'Prescribe glasses');
                }),
          ],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFinalDiagnosisForm(),
              _buildMainOptions(),
              SizedBox(height: 20.h),
              if (selectedMainOption != null) _buildSelectedOptionContent(),
              if (selectedMainOption != null && selectedMainOption != 'Prescribe glasses' && selectedMainOption != 'Prescribe medications') eyeForm(),
              if (selectedMainOption != null) SizedBox(height: 20.h),
              if (selectedMainOption != null) _buildSaveButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _clearAllData() async {
    // Clear text controllers
    prescriptionController.clear();
    IPDController.clear();
    typeOfLens.clear();

    // Clear all investigation options
    investigationOptions.updateAll((key, value) => false);
    cornealOptions.updateAll((key, value) => false);
    biometryTypes.updateAll((key, value) => false);
    biometryFeatures.updateAll((key, value) => false);

    // Clear selected values
    selectedGlassesType = null;
    selectedLaserOption = null;
    selectedKeratoconusOption = null;
    selectedOROption = null;
    selectedAppointmentType = null;
    selectedGlassesValue = null;

    // Clear maps
    cataractSurgeryOptions.updateAll((key, value) => false);
    injectionOptions.updateAll((key, value) => false);
  }

  Future<void> clearOrOptions() async {
    cataractSurgeryOptions.updateAll((key, value) => false);
    injectionOptions.updateAll((key, value) => false);
    selectedOption = null;
  }

  Widget _buildMainOptions() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: mainOptions.length,
      itemBuilder: (context, index) {
        final category = mainOptions[index];
        final isSelected = selectedMainOption == category;

        return Card(
          margin: EdgeInsets.only(bottom: 10.h),
          elevation: isSelected ? 2 : 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
            side: BorderSide(
              color: isSelected ? Colorz.primaryColor : Colors.transparent,
              width: 2,
            ),
          ),
          child: InkWell(
            onTap: () async {
              await _clearAllData();
              setState(() => selectedMainOption = category);
            },
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  Icon(
                    categoryIcons[category],
                    size: 24.sp,
                    color: isSelected ? Colorz.primaryColor : Colors.grey[600],
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Text(
                      category,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected ? Colorz.primaryColor : Colors.black87,
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
        );
      },
    );
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

  Widget _buildSelectedOptionContent() {
    switch (selectedMainOption) {
      case 'Prescribe glasses':
        return _buildGlassesPrescriptionForm();
      case 'Prescribe medications':
        return _buildMedicationForm();
      case 'Refer to investigations':
        return _buildInvestigationsForm();
      case 'Refer to lasers':
        return _buildLaserOptionsForm();
      case 'Keratoconus':
        return _buildKeratoconusForm();
      case 'Refer to OR':
        return _buildORForm();
      case 'Book next appointment':
        return _buildAppointmentForm();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildGlassesPrescriptionForm() {
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
            HeightSpacer(size: 10),
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
                          'Spherical': widget.examination?.measurements?[1].refinedRefractionSpherical ?? 'N/A',
                          'Cylindrical': widget.examination?.measurements?[1].refinedRefractionCylindrical ?? 'N/A',
                          'Axis': widget.examination?.measurements?[1].refinedRefractionAxis ?? 'N/A',
                          'NearVision': widget.examination?.measurements?[1].nearVisionAddition ?? 'N/A',
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
                          'Spherical': widget.examination?.measurements?[0].refinedRefractionSpherical ?? 'N/A',
                          'Cylindrical': widget.examination?.measurements?[0].refinedRefractionCylindrical ?? 'N/A',
                          'Axis': widget.examination?.measurements?[0].refinedRefractionAxis ?? 'N/A',
                          'NearVision': widget.examination?.measurements?[0].nearVisionAddition ?? 'N/A',
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
    return _buildFormContainer(
      title: 'Medication Prescription',
      child: TextField(
        controller: prescriptionController,
        maxLines: 5,
        decoration: _getInputDecoration('Enter prescription details...'),
      ),
    );
  }

  Widget _buildInvestigationsForm() {
    return _buildFormContainer(
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
                            if (value == false && option.key == 'Biometry') {
                              // biometryTypes['Ultrasound'] = false;
                              // biometryTypes['Optical'] = false;
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
              if (entry.key == 'Cataract' && entry.value && biometryFeatures['Biometry']!)
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
          color: value ? Colorz.primaryColor : Colors.black87,
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
          color: title == groupValue ? Colorz.primaryColor : Colors.black87,
        ),
      ),
      value: title, // Use the title as the value
      groupValue: groupValue, // Compare with groupValue
      activeColor: Colorz.primaryColor,
      controlAffinity: ListTileControlAffinity.leading,
      onChanged: onChanged,
    );
  }

  Widget _buildLaserOptionsForm() {
    return _buildFormContainer(
      title: 'Laser Options',
      child: _buildDropdown(
        items: laserOptions,
        value: selectedLaserOption,
        onChanged: (value) => setState(() => selectedLaserOption = value),
        hint: 'Select laser option',
      ),
    );
  }

  Widget _buildKeratoconusForm() {
    return _buildFormContainer(
      title: 'Keratoconus Options',
      child: _buildDropdown(
        items: keratoconusOptions,
        value: selectedKeratoconusOption,
        onChanged: (value) => setState(() => selectedKeratoconusOption = value),
        hint: 'Select keratoconus option',
      ),
    );
  }

  Widget eyeForm() {
    return _buildDropdown(
      items: eyes,
      value: selectedeye,
      onChanged: (value) async {
        await clearOrOptions();

        setState(() {
          selectedeye = value;
        });
      },
      hint: 'Select eye',
    );
  }

  Widget _buildORForm() {
    return _buildFormContainer(
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
                groupValue: selectedOption, // Pass the currently selected option
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
            }).toList(),
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
            }).toList(),
          ],
        ],
      ),
    );
  }

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  Widget _buildAppointmentForm() {
    return _buildFormContainer(
      title: 'Next Appointment',
      child: Column(
        children: [
          InkWell(
            onTap: () => _showDateTimePicker(),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: Colorz.primaryColor),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      selectedDate != null ? _formatAppointmentDateTime() : 'Select appointment date and time',
                      style: TextStyle(
                        color: selectedDate != null ? Colors.black87 : Colors.grey[600],
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
    );
  }

// Add this method to handle date and time picking
  void _showDateTimePicker() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colorz.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: Colorz.primaryColor,
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: Colors.black,
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        setState(() {
          selectedDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          selectedTime = pickedTime;
        });
      }
    }
  }

// Add this method to format the date and time
  String _formatAppointmentDateTime() {
    if (selectedDate == null) return '';

    // Format date
    String formattedDate = '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}';

    // Format time
    String period = selectedTime!.period == DayPeriod.am ? 'AM' : 'PM';
    int hour = selectedTime!.hourOfPeriod;
    String minute = selectedTime!.minute.toString().padLeft(2, '0');
    String formattedTime = '$hour:$minute $period';

    return 'As before $formattedDate $formattedTime';
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
      labelStyle: TextStyle(color: Colors.grey[700]),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: BorderSide(color: Colorz.primaryColor),
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return BlocBuilder<ExaminationCubit, ExaminationState>(
      builder: (context, state) => Container(
        height: 45,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
              colors: [
                Colorz.primaryColor,
                Color.lerp(Colorz.primaryColor, Colors.black, 0.2)!,
                Color.lerp(Colorz.primaryColor, Colors.black, 0.3)!,
                Color.lerp(Colorz.primaryColor, Colors.black, 0.4)!,
              ],
            )),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              final prescriptionObject = generatePrescriptionObject();
              showConfirmationDialog(
                context: context,
                title: "Visit Finalization",
                message: "Are you sure you want to Make Finalization?",
                onConfirm: () async {
                  customLoading(context, "");
                  bool value = await InternetConnection().hasInternetAccess;
                  if (!value) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('No Internet Connection', style: TextStyle(color: Colors.white)),
                      backgroundColor: Colors.red,
                    ));
                    return;
                  }
                  ExaminationCubit.get(context).makeFinalization(context: context, id: widget.examination?.id ?? '', data: prescriptionObject);
                },
                onCancel: () {
                  Navigator.pop(context);
                },
              );
            },
            borderRadius: BorderRadius.circular(8),
            child: const Center(
              child: Text(
                'Finalize Visit',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

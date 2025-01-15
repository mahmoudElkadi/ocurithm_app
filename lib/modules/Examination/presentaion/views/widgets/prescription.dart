import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PrescriptionTreatmentPage extends StatefulWidget {
  const PrescriptionTreatmentPage({Key? key}) : super(key: key);

  @override
  State<PrescriptionTreatmentPage> createState() => _PrescriptionTreatmentPageState();
}

class _PrescriptionTreatmentPageState extends State<PrescriptionTreatmentPage> {
  String? selectedTreatmentType;
  final TextEditingController dosageController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  // Treatment options
  final List<String> treatmentTypes = [
    'Medication',
    'Exercise',
    'Dietary Recommendations',
    'Eye Drops',
    'Contact Lenses',
  ];

  // Medication frequency options
  final List<String> frequencies = ['Once daily', 'Twice daily', 'Three times daily', 'Four times daily'];
  String? selectedFrequency;

  // Exercise duration options
  final List<String> durations = ['10 minutes', '15 minutes', '20 minutes', '30 minutes'];
  String? selectedDuration;

  // Contact lens types
  final List<String> lensTypes = ['Daily', 'Weekly', 'Monthly', 'Extended Wear'];
  String? selectedLensType;

  // Dietary preferences
  Map<String, bool> dietaryRestrictions = {
    'Low Sodium': false,
    'Sugar-Free': false,
    'High Protein': false,
    'Vitamin Rich': false,
  };

  @override
  void dispose() {
    dosageController.dispose();
    notesController.dispose();
    super.dispose();
  }

  Widget _buildMedicationFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dosage TextField
        Container(
          margin: EdgeInsets.symmetric(vertical: 8.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: dosageController,
            decoration: InputDecoration(
              labelText: 'Dosage',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            ),
          ),
        ),

        // Frequency Dropdown
        Container(
          margin: EdgeInsets.symmetric(vertical: 8.h),
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            value: selectedFrequency,
            decoration: const InputDecoration(
              labelText: 'Frequency',
              border: InputBorder.none,
            ),
            items: frequencies.map((String frequency) {
              return DropdownMenuItem<String>(
                value: frequency,
                child: Text(frequency),
              );
            }).toList(),
            onChanged: (String? value) {
              setState(() {
                selectedFrequency = value;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseFields() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: selectedDuration,
        decoration: const InputDecoration(
          labelText: 'Exercise Duration',
          border: InputBorder.none,
        ),
        items: durations.map((String duration) {
          return DropdownMenuItem<String>(
            value: duration,
            child: Text(duration),
          );
        }).toList(),
        onChanged: (String? value) {
          setState(() {
            selectedDuration = value;
          });
        },
      ),
    );
  }

  Widget _buildDietaryFields() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: dietaryRestrictions.entries.map((entry) {
          return CheckboxListTile(
            title: Text(entry.key),
            value: entry.value,
            onChanged: (bool? value) {
              setState(() {
                dietaryRestrictions[entry.key] = value ?? false;
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContactLensFields() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: selectedLensType,
        decoration: const InputDecoration(
          labelText: 'Lens Type',
          border: InputBorder.none,
        ),
        items: lensTypes.map((String type) {
          return DropdownMenuItem<String>(
            value: type,
            child: Text(type),
          );
        }).toList(),
        onChanged: (String? value) {
          setState(() {
            selectedLensType = value;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prescription Treatment'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Treatment Type Dropdown
              Container(
                margin: EdgeInsets.only(bottom: 16.h),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: DropdownButtonFormField<String>(
                  value: selectedTreatmentType,
                  decoration: const InputDecoration(
                    labelText: 'Treatment Type',
                    border: InputBorder.none,
                  ),
                  items: treatmentTypes.map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      selectedTreatmentType = value;
                    });
                  },
                ),
              ),

              // Dynamic Fields based on selection
              if (selectedTreatmentType != null) ...[
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Column(
                    key: ValueKey<String>(selectedTreatmentType!),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (selectedTreatmentType == 'Medication') _buildMedicationFields(),
                      if (selectedTreatmentType == 'Exercise') _buildExerciseFields(),
                      if (selectedTreatmentType == 'Dietary Recommendations') _buildDietaryFields(),
                      if (selectedTreatmentType == 'Contact Lenses') _buildContactLensFields(),
                    ],
                  ),
                ),
              ],

              // Notes TextField
              Container(
                margin: EdgeInsets.symmetric(vertical: 16.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: notesController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Additional Notes',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  ),
                ),
              ),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Implement save functionality
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Save Prescription'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

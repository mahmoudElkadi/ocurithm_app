import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ocurithm/core/utils/format_helper.dart';

import '../../../../../core/utils/colors.dart';
import '../../../../Patient/data/model/patients_model.dart';
import '../../../../Patient/presentation/views/Patient Details/presentation/view/patient_details_view.dart';

class PatientDetailsBottomSheet extends StatefulWidget {
  final Patient? patient;

  const PatientDetailsBottomSheet({super.key, this.patient});

  @override
  State<PatientDetailsBottomSheet> createState() => _PatientDetailsBottomSheetState();
}

class _PatientDetailsBottomSheetState extends State<PatientDetailsBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          const Text(
            'Patient Details',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),

          // Patient Name
          Row(
            children: [
              Icon(
                Icons.person,
                color: Colorz.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Name: ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              Expanded(
                child: Text(
                  widget.patient?.name ?? 'Unknown',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Patient Phone
          Row(
            children: [
              Icon(
                Icons.phone,
                color: Colorz.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Phone: ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              Text(
                widget.patient?.phone ?? 'No Phone',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Patient Age
          Row(
            children: [
              Icon(
                Icons.cake,
                color: Colorz.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Age: ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              Text(
                FormatHelper.calculateAge(widget.patient?.birthDate),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // View Details Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                if (widget.patient != null) {
                  await Get.to(() => PatientDetailsView(patient: widget.patient, id: widget.patient!.id.toString()));
                  setState(() {});
                }
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colorz.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
              ),
              child: const Text(
                'View Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

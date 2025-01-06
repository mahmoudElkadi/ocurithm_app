import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ocurithm/core/Network/shared.dart';
import 'package:ocurithm/core/utils/colors.dart';
import 'package:ocurithm/modules/Patient/presentation/manager/patient_cubit.dart';

import '../../../../../../data/model/patient_examination.dart';
import 'one_examination_view.dart';

class ExaminationListView extends StatelessWidget {
  final List<Examination> examinations;
  final PatientCubit cubit;

  const ExaminationListView({
    Key? key,
    required this.examinations,
    required this.cubit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          spacing: 20,
          children: [
            const Text(
              'Examinations',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1F36),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colorz.primaryColor,
                shape: BoxShape.circle,
              ),
              child: Text(
                '${examinations.length}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          ],
        ),
        const SizedBox(height: 8),
        const SizedBox(height: 8),
        ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
          itemCount: examinations.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final examination = examinations[index];
            return ExaminationCard(
              type: examination.type?.name,
              createdAt: '${examination.createdAt ?? ""}',
              id: examination.id.toString(),
              cubit: cubit,
            );
          },
        ),
      ],
    );
  }
}

class ExaminationCard extends StatelessWidget {
  final String? type;
  final String? createdAt;
  final String id;
  final PatientCubit cubit;

  const ExaminationCard({
    Key? key,
    this.type,
    this.createdAt,
    required this.id,
    required this.cubit,
  }) : super(key: key);

  String formatDateTime(String dateTimeStr) {
    final dateTime = DateTime.parse(dateTimeStr);
    return DateFormat('MMM dd, yyyy • hh:mm a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              if (CacheHelper.getStringList(key: "capabilities").contains("showExaminations")) {
                Get.to(() => OneExaminationView(
                      id: id,
                    ));
              }
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.visibility_outlined,
                      color: Color(0xFF6366F1),
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          type ?? 'N/A',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          createdAt != null && createdAt != '' ? formatDateTime(createdAt!) : 'N/A',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF64748B),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

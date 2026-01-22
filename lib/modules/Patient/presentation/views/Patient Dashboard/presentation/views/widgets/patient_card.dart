import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:shimmer/shimmer.dart';

import '../../../../../../../../../core/widgets/confirmation_popuo.dart';

import '../../../../../../../../../core/widgets/height_spacer.dart';
import '../../../../../../../../../core/widgets/pagination.dart';

import '../../../../../../../../core/Network/shared.dart';
import '../../../../../../data/model/patients_model.dart';
import '../../../../../manager/get_patients_cubit/get_patients_cubit.dart';
import '../../../../../manager/patient_actions_cubit/patient_actions_cubit.dart';
import '../../../../patient_form/patient_form_page.dart';

class PatientCard extends StatelessWidget {
  const PatientCard({
    super.key,
    required this.isLoading,
    this.patient,
  });

  final bool isLoading;
  final Patient? patient;

  Widget _buildShimmer(BuildContext context, Widget child) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[700]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[600]! : Colors.grey[100]!,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () async {
        log("message ${patient?.toJson().toString()}");
        if (patient?.id != null) {
          bool? result = await Get.to(() => PatientFormPage(
              mode: PatientFormMode.view, patientId: patient!.id!));
          if (result == true) {
            context.read<GetPatientsCubit>().add(GetAllPatientsEvent());
          }
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.all(16.h),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : theme.primaryColor.withValues(alpha: 0.08),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              isLoading
                  ? _buildShimmer(
                      context,
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.cardColor,
                        ),
                      ),
                    )
                  : Container(
                      height: 56,
                      width: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.primaryColor,
                            theme.primaryColor.withValues(alpha: 0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: theme.primaryColor.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          patient?.name?.isNotEmpty == true
                              ? patient!.name![0].toUpperCase()
                              : 'P',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    isLoading
                        ? _buildShimmer(
                            context,
                            Container(
                              width: 140,
                              height: 18,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: theme.cardColor,
                              ),
                            ),
                          )
                        : Text(
                            patient?.name ?? "N/A",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              textStyle: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                    const SizedBox(height: 6),
                    isLoading
                        ? _buildShimmer(
                            context,
                            Container(
                              width: 100,
                              height: 14,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: theme.cardColor,
                              ),
                            ),
                          )
                        : Row(
                            children: [
                              Icon(
                                Icons.phone_outlined,
                                size: 14,
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                patient?.phone ?? "N/A",
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color:
                                      isDark ? Colors.white70 : Colors.black54,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                  ],
                ),
              ),
              if (CacheHelper.getStringList(key: "capabilities")
                      .contains("managePatients") &&
                  !isLoading)
                Row(
                  children: [
                    IconButton(
                        onPressed: () async {
                          showConfirmationDialog(
                            context: context,
                            title: "Delete Patient",
                            message:
                                "Are you sure you want to delete ${patient?.name ?? "this patient"}?",
                            onConfirm: () async {
                              Navigator.pop(
                                  context); // Close confirmation dialog
                              context
                                  .read<PatientActionsCubit>()
                                  .add(DeletePatientEvent(patient!.id!));
                            },
                            onCancel: () => Navigator.pop(context),
                          );
                        },
                        icon: Icon(
                          Icons.delete_outline,
                          color: Colors.red[400],
                          size: 22,
                        )),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.grey,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class PatientListView extends StatelessWidget {
  const PatientListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetPatientsCubit, GetPatientsState>(
      builder: (context, state) {
        if (state.isLoading) {
          return _buildLoadingList();
        } else if (state.patients == null ||
            (state.patients?.patients.isEmpty ?? true)) {
          return _buildEmptyState();
        } else {
          return _buildPatientList(context, state);
        }
      },
    );
  }

  Widget _buildLoadingList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) => const PatientCard(isLoading: true),
      separatorBuilder: (context, index) => const HeightSpacer(size: 20),
      itemCount: 4,
    );
  }

  Widget _buildPatientList(BuildContext context, GetPatientsState state) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) => Column(
        children: [
          PatientCard(
            patient: state.patients!.patients[index],
            isLoading: false,
          ),
          state.patients!.patients.length != index + 1
              ? const SizedBox.shrink()
              : state.patients?.totalPages != null &&
                      state.patients!.totalPages! > 1
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20)
                          .copyWith(bottom: 20),
                      child: CustomPagination(
                          currentPage: state.page,
                          totalPages:
                              int.parse('${state.patients?.totalPages ?? 0}'),
                          onPageChanged: (int newPage) {
                            context
                                .read<GetPatientsCubit>()
                                .add(SetPageEvent(newPage));
                            context
                                .read<GetPatientsCubit>()
                                .add(GetAllPatientsEvent());
                          }),
                    )
                  : const HeightSpacer(size: 10),
        ],
      ),
      separatorBuilder: (context, index) => const HeightSpacer(size: 20),
      itemCount: state.patients!.patients.length,
    );
  }

  Widget _buildEmptyState() {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const HeightSpacer(size: 30),
              Icon(
                Icons.inbox_outlined,
                size: 70,
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No Patient found',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Patient will appear here',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color:
                      theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

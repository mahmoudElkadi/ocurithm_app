import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:intl/intl.dart';

import 'package:ocurithm/core/utils/colors.dart';
import 'package:ocurithm/core/utils/format_helper.dart';
import 'package:ocurithm/core/utils/services_locator.dart';
import 'package:ocurithm/modules/Patient/data/model/patient_examination.dart';
import 'package:ocurithm/modules/Patient/data/model/patients_model.dart';
import 'package:ocurithm/modules/Patient/presentation/manager/get_one_examination_cubit/get_one_examination_cubit.dart';
import 'package:ocurithm/modules/Patient/presentation/manager/get_patient_examinations_cubit/get_patient_examinations_cubit.dart';
import 'package:ocurithm/modules/Patient/presentation/manager/get_single_patient_cubit/get_single_patient_cubit.dart';
import 'package:ocurithm/modules/Patient/presentation/views/examination_view/one_examination_content.dart';
import 'package:shimmer/shimmer.dart';

class PatientDetailsBottomSheet extends StatefulWidget {
  final String patientId;

  const PatientDetailsBottomSheet({Key? key, required this.patientId})
      : super(key: key);

  @override
  State<PatientDetailsBottomSheet> createState() =>
      _PatientDetailsBottomSheetState();
}

class _PatientDetailsBottomSheetState extends State<PatientDetailsBottomSheet> {
  String? _selectedExaminationId;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<GetSinglePatientCubit>()
            ..add(GetPatientByIdEvent(widget.patientId)),
        ),
        BlocProvider(
          create: (_) => sl<GetPatientExaminationsCubit>()
            ..getExaminations(widget.patientId),
        ),
      ],
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        padding: EdgeInsets.fromLTRB(10.w, 20.h, 10.w, 0),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 10.h),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_selectedExaminationId != null)
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _selectedExaminationId = null;
                      });
                    },
                    icon: Icon(Icons.arrow_back,
                        color: Theme.of(context).iconTheme.color),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                Expanded(
                  child: Text(
                    _selectedExaminationId != null
                        ? 'Examination Details'
                        : 'Patient Profile',
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                    textAlign: _selectedExaminationId != null
                        ? TextAlign.center
                        : TextAlign.start,
                  ),
                ),
                if (_selectedExaminationId != null)
                  // Pivot to keep title centered if back button exists
                  SizedBox(width: 24.w)
                else
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                            color: Theme.of(context)
                                .disabledColor
                                .withOpacity(0.1),
                            shape: BoxShape.circle),
                        child: const Icon(
                          Icons.close,
                          size: 18,
                        )),
                  )
              ],
            ),
            SizedBox(height: 20.h),

            // Content
            Expanded(
              child: _selectedExaminationId != null
                  ? _buildExaminationDetails()
                  : _buildPatientProfile(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientProfile() {
    return Column(
      children: [
        // Patient Card
        const _PatientInfoCard(),

        SizedBox(height: 25.h),

        // Examinations Section
        _ExaminationsSection(onExaminationSelected: (id) {
          setState(() {
            _selectedExaminationId = id;
          });
        }),
        SizedBox(height: 20.h),
      ],
    );
  }

  Widget _buildExaminationDetails() {
    return BlocProvider(
      create: (context) =>
          sl<GetOneExaminationCubit>()..getExamination(_selectedExaminationId!),
      child: BlocBuilder<GetOneExaminationCubit, GetOneExaminationState>(
        builder: (context, state) {
          if (state.isLoading) {
            return _buildDetailsShimmerLoading(context);
          }
          if (state.errorMessage != null) {
            return Center(child: Text(state.errorMessage!));
          }
          if (state.examination != null) {
            return OneExaminationContent(examination: state.examination!);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildDetailsShimmerLoading(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      enabled: true,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mock Patient Info Card
            Container(
              width: double.infinity,
              height: 140.h,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            SizedBox(height: 16.h),

            // Mock Finalization Section
            Container(
              width: double.infinity,
              height: 60.h,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            SizedBox(height: 16.h),

            // Mock History Section
            Container(
              width: double.infinity,
              height: 60.h,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            SizedBox(height: 16.h),

            // Mock Eye Sections
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: List.generate(
                        3,
                        (index) => Container(
                              margin: EdgeInsets.only(bottom: 10.h),
                              height: 100.h,
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(16),
                              ),
                            )),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    children: List.generate(
                        3,
                        (index) => Container(
                              margin: EdgeInsets.only(bottom: 10.h),
                              height: 100.h,
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(16),
                              ),
                            )),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _PatientInfoCard extends StatelessWidget {
  const _PatientInfoCard();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetSinglePatientCubit, GetSinglePatientState>(
      builder: (context, state) {
        if (state.isLoading) {
          return _buildShimmerLoading(context);
        } else if (state.isSuccess && state.patient != null) {
          return _buildPatientCard(context, state.patient!);
        } else if (state.isError) {
          return Center(
              child: Text(state.errorMessage ?? 'Error loading patient'));
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildShimmerLoading(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: double.infinity,
        height: 140.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Theme.of(context).cardColor,
        ),
      ),
    );
  }

  Widget _buildPatientCard(BuildContext context, Patient patient) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            Colorz.primaryColor.withOpacity(0.9),
            Colorz.primaryColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colorz.primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.name ?? 'Unknown',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 5.h),
                    Row(
                      children: [
                        Icon(Icons.perm_identity,
                            color: Colors.white70, size: 16.sp),
                        SizedBox(width: 5.w),
                        Text(
                          patient.serialNumber ?? 'N/A',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset(
                  "assets/icons/patient.svg",
                  color: Colors.white,
                  height: 24.h,
                  width: 24.w,
                ),
              )
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoItem(
                icon: Icons.phone_rounded,
                value: patient.phone ?? 'N/A',
              ),
              _buildInfoItem(
                icon: Icons.cake_rounded,
                value: '${FormatHelper.calculateAge(patient.birthDate)} Yrs',
              ),
              _buildInfoItem(
                icon: Icons.wc_rounded,
                value: patient.gender ?? 'N/A',
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildInfoItem({required IconData icon, required String value}) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 16.sp),
        ),
        SizedBox(width: 8.w),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _ExaminationsSection extends StatelessWidget {
  final Function(String) onExaminationSelected;

  const _ExaminationsSection({required this.onExaminationSelected});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BlocBuilder<GetPatientExaminationsCubit, GetPatientExaminationsState>(
              builder: (context, state) {
            int count = 0;
            if (state.examinations?.examinations?.examinations != null) {
              count = state.examinations!.examinations!.examinations.length;
            }

            return Row(
              children: [
                Text(
                  "Examinations",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                SizedBox(width: 10.w),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colorz.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      color: Colorz.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
              ],
            );
          }),
          SizedBox(height: 15.h),
          Expanded(
            child: BlocBuilder<GetPatientExaminationsCubit,
                GetPatientExaminationsState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return ListView.separated(
                    itemCount: 3,
                    separatorBuilder: (_, __) => SizedBox(height: 12.h),
                    itemBuilder: (_, __) => _buildShimmerItem(context),
                  );
                }

                if (state.examinations == null ||
                    (state.examinations?.examinations?.examinations.isEmpty ??
                        true)) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.folder_open_rounded,
                            size: 50.sp, color: Colors.grey[300]),
                        SizedBox(height: 10.h),
                        Text(
                          "No examinations found",
                          style: TextStyle(
                              color: Colors.grey[500], fontSize: 14.sp),
                        ),
                      ],
                    ),
                  );
                }

                final list = state.examinations!.examinations!.examinations;
                return ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final exam = list[index];
                    return _buildExaminationItem(context, exam);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerItem(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 70.h,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }

  Widget _buildExaminationItem(BuildContext context, Examination exam) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (exam.id != null) {
              onExaminationSelected(exam.id!);
            }
          },
          child: Padding(
            padding: EdgeInsets.all(15.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: Colorz.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SvgPicture.asset(
                    "assets/icons/examination.svg",
                    color: Colorz.primaryColor,
                    width: 20.w,
                    height: 20.h,
                  ),
                ),
                SizedBox(width: 15.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exam.type?.name ?? 'General Examination',
                        style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color:
                                Theme.of(context).textTheme.bodyLarge?.color),
                      ),
                      SizedBox(height: 5.h),
                      Row(
                        children: [
                          Icon(Icons.calendar_today_rounded,
                              size: 12.sp, color: Colors.grey),
                          SizedBox(width: 5.w),
                          Text(
                            _formatDate(exam.createdAt.toString()),
                            style: TextStyle(
                                fontSize: 12.sp, color: Colors.grey[600]),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded,
                    size: 16.sp, color: Colors.grey[400]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final DateTime date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy, hh:mm a').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}

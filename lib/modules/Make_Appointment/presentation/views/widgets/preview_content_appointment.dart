import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:ocurithm/core/utils/network_connection.dart';
import 'package:ocurithm/core/utils/snackbar_service.dart';
import 'package:ocurithm/core/widgets/custom_freeze_loading.dart';
import 'package:ocurithm/modules/Appointment/data/models/appointment_model.dart';

import '../../../../../core/utils/colors.dart';
import '../../../data/models/make_appointment_model.dart';
import '../../manager/Make Appointment cubit/make_appointment_cubit.dart';

class AppointmentPreviewContent extends StatefulWidget {
  final bool isUpdated;
  final Appointment? appointment;

  const AppointmentPreviewContent({
    super.key,
    this.isUpdated = false,
    this.appointment,
  });

  @override
  State<AppointmentPreviewContent> createState() =>
      _AppointmentPreviewContentState();
}

class _AppointmentPreviewContentState extends State<AppointmentPreviewContent> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MakeAppointmentCubit, MakeAppointmentState>(
      listener: (context, state) {
        if (state.status == MakeAppointmentStatus.loading) {
          customLoading(context, "Saving appointment...");
        } else if (state.status == MakeAppointmentStatus.success) {
          // Dismiss the loading dialog first
          // Using rootNavigator: true to target the dialog
          Navigator.of(context, rootNavigator: true).pop();

          SnackbarService.showSuccess(context,
              message: widget.isUpdated
                  ? "Appointment Updated successfully"
                  : "Appointment created successfully");

          // Use a small delay for the final pop to ensure the dialog pop is finished
          // and we are not in a build/layout cycle
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              // Return the selected date/time when appointment is created successfully
              Navigator.pop(context, state.selectedTime);
            }
          });
        } else if (state.status == MakeAppointmentStatus.error) {
          Navigator.of(context, rootNavigator: true).pop(); // Dismiss loading
          SnackbarService.showError(context,
              message: state.errorMessage ?? "An error occurred");
        }
      },
      builder: (context, state) => Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Column(
                children: [
                  _buildPreviewCard(context, state),
                  SizedBox(height: 20.h),
                  _buildNoteField(context),
                ],
              ),
            ),
          ),
          _buildBottomButtons(context, state),
        ],
      ),
    );
  }

  Widget _buildPreviewCard(BuildContext context, MakeAppointmentState state) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 5,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildPreviewHeader(),
          Divider(
            height: 1.h,
            thickness: 1,
            color: Colors.grey[200],
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: _buildPreviewDetails(state),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewHeader() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colorz.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.calendar_today,
              color: Colorz.primaryColor,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Appointment Details',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colorz.primaryColor,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Please review your appointment details',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewDetails(MakeAppointmentState state) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          _buildDetailItem(
            icon: Icons.person,
            title: 'Doctor',
            value: state.selectedDoctor?.name ?? "N/A",
            iconColor: Colorz.primaryColor,
            isDark: isDark,
          ),
          _buildDivider(isDark: isDark),
          _buildDetailItem(
            icon: Icons.person_outline,
            title: 'Patient',
            value: state.selectedPatient?.name ?? "N/A",
            iconColor: Colors.green,
            isDark: isDark,
          ),
          _buildDivider(isDark: isDark),
          _buildDetailItem(
            icon: Icons.location_on,
            title: 'Branch',
            value: state.selectedBranch?.name ?? "N/A",
            iconColor: Colors.red,
            isDark: isDark,
          ),
          _buildDivider(isDark: isDark),
          _buildDetailItem(
            icon: Icons.medical_services,
            title: 'Examination',
            value: '${state.selectedExaminationType?.name ?? "N/A"} '
                '(${state.selectedExaminationType?.duration ?? "N/A"} min)',
            iconColor: Colors.purple,
            isDark: isDark,
          ),
          _buildDivider(isDark: isDark),
          _buildDetailItem(
            icon: Icons.payment,
            title: 'Payment Method',
            value: state.selectedPaymentMethod?.title ?? "N/A",
            iconColor: Colors.orange,
            isDark: isDark,
          ),
          _buildDivider(isDark: isDark),
          _buildDetailItem(
            icon: Icons.attach_money,
            title: 'Price',
            value: '\$${state.selectedExaminationType?.price ?? "N/A"}',
            iconColor: Colors.green,
            isDark: isDark,
          ),
          _buildDivider(isDark: isDark),
          _buildDetailItem(
            icon: Icons.date_range,
            title: 'Date',
            value: state.selectedTime != null
                ? DateFormat('yyyy-MM-dd HH:mm a').format(state.selectedTime!)
                : "N/A",
            iconColor: Colorz.primaryColor,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider({bool isDark = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Divider(
        height: 1.h,
        thickness: 1,
        color: isDark ? Colors.grey[700] : Colors.grey[100],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String title,
    required String value,
    required Color iconColor,
    required bool isDark,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              icon,
              size: 20.sp,
              color: iconColor,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 13.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteField(BuildContext context) {
    // Note controller is still in cubit for text editing handling
    final cubit = context.read<MakeAppointmentCubit>();
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Additional Notes',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: 8.h),
          TextField(
            controller: cubit.noteController,
            maxLines: 3,
            style: TextStyle(
                fontSize: 15.sp, color: isDark ? Colors.white : Colors.black),
            decoration: InputDecoration(
              hintText: 'Add a note (optional)',
              hintStyle: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[400],
                fontSize: 15.sp,
              ),
              filled: true,
              fillColor: isDark ? Colors.grey[800] : Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.all(16.w),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context, MakeAppointmentState state) {
    final cubit = context.read<MakeAppointmentCubit>();
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                cubit.add(PreviousStepEvent());
              },
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                side: BorderSide(
                  color: Colorz.primaryColor,
                ),
              ),
              child: Text(
                'Previous',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colorz.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: ElevatedButton(
              onPressed: () async {
                bool connection = await NetworkStatus().hasInternetConnection();
                if (!connection) {
                  SnackbarService.showError(
                    context,
                    message: "No internet connection",
                  );
                } else {
                  if (widget.isUpdated == true) {
                    cubit.add(EditAppointmentEvent(
                      model: MakeAppointmentModel(
                          id: widget.appointment?.id,
                          doctor: state.selectedDoctor?.id,
                          branch: state.selectedBranch?.id,
                          datetime: state.selectedTime?.toUtc(),
                          paymentMethod: state.selectedPaymentMethod?.id,
                          examinationType: state.selectedExaminationType?.id,
                          patient: state.selectedPatient?.id,
                          status: "Scheduled",
                          clinic: state.selectedClinic?.id,
                          note: cubit.noteController.text),
                    ));
                  } else {
                    cubit.add(CreateAppointmentEvent(
                        note: cubit.noteController.text));
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                backgroundColor: Colorz.primaryColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                widget.isUpdated == true ? 'Update' : 'Submit',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

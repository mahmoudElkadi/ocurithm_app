import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:intl/intl.dart';
import 'package:ocurithm/core/widgets/custom_freeze_loading.dart';

import '../../../../../core/utils/colors.dart';
import '../../manager/Make Appointment cubit/make_appointment_cubit.dart';
import '../../manager/Make Appointment cubit/make_appointment_state.dart';

class AppointmentPreviewContent extends StatefulWidget {
  const AppointmentPreviewContent({
    Key? key,
  }) : super(key: key);

  @override
  State<AppointmentPreviewContent> createState() => _AppointmentPreviewContentState();
}

class _AppointmentPreviewContentState extends State<AppointmentPreviewContent> {
  @override
  Widget build(BuildContext context) {
    final cubit = MakeAppointmentCubit.get(context);
    return BlocBuilder<MakeAppointmentCubit, MakeAppointmentState>(
      builder: (context, state) => Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Column(
                children: [
                  _buildPreviewCard(context, cubit),
                  SizedBox(height: 20.h),
                  _buildNoteField(cubit),
                ],
              ),
            ),
          ),
          _buildBottomButtons(context, cubit),
        ],
      ),
    );
  }

  Widget _buildPreviewCard(BuildContext context, MakeAppointmentCubit cubit) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
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
            child: _buildPreviewDetails(cubit),
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
              color: Colorz.primaryColor.withOpacity(0.1),
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

  Widget _buildPreviewDetails(MakeAppointmentCubit cubit) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          _buildDetailItem(
            icon: Icons.person,
            title: 'Doctor',
            value: cubit.selectedDoctor?.name ?? "N/A",
            iconColor: Colorz.primaryColor,
          ),
          _buildDivider(),
          _buildDetailItem(
            icon: Icons.person_outline,
            title: 'Patient',
            value: cubit.selectedPatient?.name ?? "N/A",
            iconColor: Colors.green,
          ),
          _buildDivider(),
          _buildDetailItem(
            icon: Icons.location_on,
            title: 'Branch',
            value: cubit.selectedBranch?.name ?? "N/A",
            iconColor: Colors.red,
          ),
          _buildDivider(),
          _buildDetailItem(
            icon: Icons.medical_services,
            title: 'Examination',
            value: '${cubit.selectedExaminationType?.name ?? "N/A"} '
                '(${cubit.selectedExaminationType?.duration ?? "N/A"} min)',
            iconColor: Colors.purple,
          ),
          _buildDivider(),
          _buildDetailItem(
            icon: Icons.payment,
            title: 'Payment Method',
            value: cubit.selectedPaymentMethod?.title ?? "N/A",
            iconColor: Colors.orange,
          ),
          _buildDivider(),
          _buildDetailItem(
            icon: Icons.attach_money,
            title: 'Price',
            value: '\$${cubit.selectedExaminationType?.price ?? "N/A"}',
            iconColor: Colors.green,
          ),
          _buildDivider(),
          _buildDetailItem(
            icon: Icons.date_range,
            title: 'Date',
            value: cubit.selectedTime != null ? DateFormat('yyyy-MM-dd HH:mm a').format(cubit.selectedTime!) : "N/A",
            iconColor: Colorz.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Divider(
        height: 1.h,
        thickness: 1,
        color: Colors.grey[100],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String title,
    required String value,
    required Color iconColor,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
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
                    color: Colors.grey[600],
                    fontSize: 13.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteField(MakeAppointmentCubit cubit) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
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
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8.h),
          TextField(
            controller: cubit.noteController,
            maxLines: 3,
            style: TextStyle(fontSize: 15.sp),
            decoration: InputDecoration(
              hintText: 'Add a note (optional)',
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: 15.sp,
              ),
              filled: true,
              fillColor: Colors.grey[50],
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

  Widget _buildBottomButtons(BuildContext context, MakeAppointmentCubit cubit) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
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
                cubit.changeStep(1);
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
                customLoading(context, "");
                bool connection = await InternetConnection().hasInternetAccess;
                if (!connection) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "No internet connection",
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else {
                  cubit.makeAppointment(context: context);
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
                'Submit',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

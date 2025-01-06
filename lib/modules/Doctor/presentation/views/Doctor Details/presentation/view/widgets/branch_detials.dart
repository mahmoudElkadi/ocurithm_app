import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:ocurithm/core/Network/shared.dart';
import 'package:ocurithm/core/utils/app_style.dart';

import '../../../../../../../../core/utils/colors.dart';
import '../../../../../../../../core/widgets/confirmation_popuo.dart';
import '../../../../../../../../core/widgets/custom_freeze_loading.dart';
import '../../../../../../data/model/doctor_model.dart';
import '../../../../../manager/doctor_cubit.dart';
import '../../../../../manager/doctor_state.dart';

class DoctorBranchesView extends StatelessWidget {
  final List<BranchElement> branches;
  final DoctorCubit cubit;
  final String doctorId;

  const DoctorBranchesView({
    Key? key,
    required this.branches,
    required this.cubit,
    required this.doctorId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return branches.isEmpty
        ? Align(
            alignment: Alignment.center,
            child: Column(
              spacing: 12,
              children: [
                SvgPicture.asset(
                  "assets/icons/branch.svg",
                  colorFilter: ColorFilter.mode(Colors.grey, BlendMode.srcIn),
                  width: 50,
                  height: 50,
                ),
                Text("No Branches Available", textAlign: TextAlign.center, style: appStyle(context, 18, Colorz.grey, FontWeight.w500)),
              ],
            ))
        : ListView.builder(
            padding: const EdgeInsets.all(0),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: branches.length,
            itemBuilder: (context, index) {
              final branch = branches[index];
              return _BranchCard(
                branchData: branch,
                cubit: cubit,
                doctorId: doctorId,
              );
            },
          );
  }
}

class _BranchCard extends StatelessWidget {
  final BranchElement branchData;
  final DoctorCubit cubit;
  final String doctorId;

  const _BranchCard({
    Key? key,
    required this.branchData,
    required this.cubit,
    required this.doctorId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final branch = branchData.branch;
    final availableDays = List<String>.from(branchData.availableDays);

    return BlocBuilder<DoctorCubit, DoctorState>(
      bloc: cubit,
      builder: (context, state) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Material(
          borderRadius: BorderRadius.circular(16),
          elevation: 2,
          color: Colors.white,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colorz.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        branch?.code ?? 'N/A',
                        style: TextStyle(
                          color: Colorz.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        branch?.name ?? 'N/A',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (CacheHelper.getStringList(key: "capabilities").contains("manageDoctors"))
                      Material(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.white,
                        child: InkWell(
                          onTap: () {
                            showConfirmationDialog(
                              context: context,
                              title: "Delete Branch",
                              message: "Do you want to Delete ${branch?.name ?? "this Branch"}?",
                              onConfirm: () async {
                                customLoading(context, "");
                                bool connection = await InternetConnection().hasInternetAccess;
                                if (!connection) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                    content: Text(
                                      "No Internet Connection",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    backgroundColor: Colors.red,
                                  ));
                                } else {
                                  await cubit.deleteBranch(context: context, doctorId: doctorId, branchId: branch!.id.toString());
                                }
                              },
                              onCancel: () {
                                Navigator.pop(context);
                              },
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: Icon(
                              Icons.delete_forever,
                              color: Colorz.redColor,
                            ),
                          ),
                        ),
                      )
                  ],
                ),
                const SizedBox(height: 16),
                _InfoRow(
                  icon: Icons.access_time,
                  label: 'Branch Hours:',
                  value: '${branch?.openTime ?? ""} - ${branch?.closeTime ?? ""}',
                ),
                const SizedBox(height: 8),
                _InfoRow(
                  icon: Icons.schedule,
                  label: 'Available Hours:',
                  value: '${branchData.availableFrom ?? ""} - ${branchData.availableTo ?? ""}',
                ),
                const SizedBox(height: 16),
                const Text(
                  'Working Days:',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List<String>.from(branch!.workDays ?? []).map((day) {
                    final isAvailable = availableDays.contains(day);
                    return _DayChip(
                      day: day,
                      isAvailable: isAvailable,
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _DayChip extends StatelessWidget {
  final String day;
  final bool isAvailable;

  const _DayChip({
    Key? key,
    required this.day,
    required this.isAvailable,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: isAvailable ? Colorz.primaryColor : Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        day.substring(0, 1).toUpperCase() + day.substring(1),
        style: TextStyle(
          color: isAvailable ? Colors.white : Colors.grey[600],
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

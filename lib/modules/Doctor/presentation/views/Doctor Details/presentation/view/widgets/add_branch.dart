import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:ocurithm/modules/Doctor/data/model/doctor_model.dart';

import '../../../../../../../../Services/time_parser.dart';
import '../../../../../../../../core/utils/colors.dart';
import '../../../../../../../../core/widgets/DropdownPackage.dart';
import '../../../../../../../../core/widgets/choose_hours_range.dart';
import '../../../../../../../../core/widgets/custom_freeze_loading.dart';
import '../../../../../../../../core/widgets/work_day_selector.dart';
import '../../../../../../../../generated/l10n.dart';
import '../../../../../manager/doctor_cubit.dart';
import '../../../../../manager/doctor_state.dart';

class AddBranch extends StatefulWidget {
  const AddBranch({super.key, required this.cubit, required this.id, required this.clinic});
  final DoctorCubit cubit;
  final String id;
  final String clinic;

  @override
  State<AddBranch> createState() => _AddBranchState();
}

class _AddBranchState extends State<AddBranch> {
  @override
  void initState() {
    super.initState();
    widget.cubit.getBranches(clinic: widget.clinic);
    widget.cubit.availableFrom = "08:00";
    widget.cubit.availableTo = "18:00";
    log(widget.clinic);
    log(widget.id);
  }

  @override
  void dispose() {
    widget.cubit.chooseBranch = true;
    widget.cubit.chooseTime = true;
    widget.cubit.chooseDays = true;
    widget.cubit.selectedBranch = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(10),
      child: SingleChildScrollView(
        // Added to handle overflow
        child: BlocBuilder<DoctorCubit, DoctorState>(
          bloc: widget.cubit,
          builder: (context, state) => Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colorz.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Wrap(
              // Using Wrap instead of Column for better flexibility
              runSpacing: 20, // Vertical spacing between elements
              alignment: WrapAlignment.center,
              children: [
                const Text("Add Branch", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                DropdownItem(
                  radius: 30,
                  color: Colorz.white,
                  isShadow: true,
                  iconData: Icon(
                    Icons.arrow_drop_down_circle,
                    color: Colorz.primaryColor,
                  ),
                  items: widget.cubit.branches?.branches,
                  isValid: widget.cubit.chooseBranch,
                  validateText: S.of(context).mustBranch,
                  selectedValue: widget.cubit.selectedBranch?.name,
                  hintText: 'Select Branch',
                  itemAsString: (item) => item.name.toString(),
                  onItemSelected: (item) {
                    setState(() {
                      if (item != "Not Found") {
                        widget.cubit.chooseBranch = true;
                        widget.cubit.selectedBranch = item;
                        log(widget.cubit.selectedBranch.toString());
                        log(widget.cubit.chooseDays.toString());
                      }
                    });
                  },
                  isLoading: widget.cubit.loading,
                ),
                if (widget.cubit.selectedBranch != null) ...[
                  Wrap(
                    runSpacing: 16, // Spacing between work days and hours selector
                    children: [
                      WorkDaysSelector(
                        radius: 30,
                        isShadow: true,
                        border: Colors.transparent,
                        onDaysSelected: (List<String> days) {
                          setState(() {
                            widget.cubit.availableDays = days;
                          });
                          print('Selected days: ${widget.cubit.availableDays}');
                        },
                        isValid: widget.cubit.chooseDays,
                        initialSelectedDays: [],
                        enabledDays: widget.cubit.selectedBranch?.workDays,
                        icon: Icon(
                          Icons.arrow_drop_down_circle,
                          color: Colorz.primaryColor,
                        ),
                      ),
                      BusinessHoursSelector(
                        onTimeRangeSelected: (openTime, closeTime) {
                          print('Business hours: ${openTime.format(context)} - ${closeTime.format(context)}');
                          widget.cubit.availableFrom = '${openTime.hour.toString().padLeft(2, '0')}:${openTime.minute.toString().padLeft(2, '0')}';
                          widget.cubit.availableTo = '${closeTime.hour.toString().padLeft(2, '0')}:${closeTime.minute.toString().padLeft(2, '0')}';
                        },
                        icon: Icon(
                          Icons.arrow_drop_down_circle,
                          color: Colorz.primaryColor,
                        ),
                        radius: 30,
                        isValid: widget.cubit.chooseTime,
                        isShadow: true,
                        border: Colors.transparent,
                        startEnabledTime: TimeParser.stringToTimeOfDay(widget.cubit.selectedBranch?.openTime),
                        endEnabledTime: TimeParser.stringToTimeOfDay(widget.cubit.selectedBranch?.closeTime),
                      ),
                    ],
                  ),
                ],
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: const StadiumBorder(),
                        backgroundColor: Colorz.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () async {
                        // First validate branch selection and times
                        if (!widget.cubit.validateAddBranch()) {
                          Get.snackbar('Error', 'Please fill all required fields',
                              icon: Icon(Icons.error, color: Colorz.white), backgroundColor: Colorz.errorColor, colorText: Colorz.white);
                          return;
                        }

                        // Create a new branch element for validation
                        final newBranchSchedule = BranchElement(
                            branch: widget.cubit.selectedBranch,
                            availableFrom: widget.cubit.availableFrom,
                            availableTo: widget.cubit.availableTo,
                            availableDays: widget.cubit.availableDays,
                            id: null,
                            branchId: widget.cubit.selectedBranch?.id);

                        // Get existing branches for the doctor
                        final existingBranches = widget.cubit.doctor?.branches ?? [];

                        // Check for schedule conflicts
                        if (BranchScheduleValidator.hasScheduleConflict(existingBranches, newBranchSchedule)) {
                          Get.snackbar('Schedule Conflict', 'This schedule overlaps with existing branch assignments',
                              icon: Icon(Icons.error, color: Colorz.white), backgroundColor: Colorz.errorColor, colorText: Colorz.white);
                          return;
                        }

                        // Validate branch hours
                        final branchOpenTime = TimeComparer.parseTimeString(widget.cubit.selectedBranch?.openTime ?? "08:00");
                        final branchCloseTime = TimeComparer.parseTimeString(widget.cubit.selectedBranch?.closeTime ?? "18:00");
                        final doctorAvailableFrom = TimeComparer.parseTimeString(widget.cubit.availableFrom ?? "08:00");
                        final doctorAvailableTo = TimeComparer.parseTimeString(widget.cubit.availableTo ?? "18:00");

                        // Check if doctor's available time is within branch hours
                        if (TimeComparer.compareTimeOfDay(doctorAvailableFrom, branchOpenTime) < 0 ||
                            TimeComparer.compareTimeOfDay(doctorAvailableTo, branchCloseTime) > 0) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Please select a time between ${_formatTime(branchOpenTime)} and ${_formatTime(branchCloseTime)}'),
                            backgroundColor: Colors.red,
                          ));
                          return;
                        }

                        // Check internet connection
                        customLoading(context, "");
                        bool isConnection = await InternetConnection().hasInternetAccess;

                        if (!isConnection) {
                          Navigator.of(context).pop();
                          Get.snackbar(
                            "Error",
                            "No Internet Connection",
                            backgroundColor: Colorz.errorColor,
                            colorText: Colorz.white,
                            icon: Icon(Icons.error, color: Colorz.white),
                          );
                          return;
                        }

                        // If all validations pass, proceed with adding the branch
                        widget.cubit.addBranch(
                          context: context,
                          doctorId: widget.id,
                          branchId: widget.cubit.selectedBranch!.id.toString(),
                        );
                      },
                      child: Text("Add Branch", style: TextStyle(color: Colorz.white, fontSize: 16, fontWeight: FontWeight.w500))),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class TimeComparer {
  static TimeOfDay parseTimeString(String timeStr) {
    try {
      // Handle both "HH:mm" and "H:mm" formats
      final parts = timeStr.trim().split(':');
      if (parts.length == 2) {
        final hour = int.parse(parts[0].trim());
        final minute = int.parse(parts[1].trim());
        return TimeOfDay(hour: hour, minute: minute);
      }
      log('Invalid time format: $timeStr');
      return const TimeOfDay(hour: 0, minute: 0);
    } catch (e) {
      log('Error parsing time: $timeStr, error: $e');
      return const TimeOfDay(hour: 0, minute: 0);
    }
  }

  static int compareTimeOfDay(TimeOfDay time1, TimeOfDay time2) {
    try {
      final minutes1 = time1.hour * 60 + time1.minute;
      final minutes2 = time2.hour * 60 + time2.minute;
      return minutes1.compareTo(minutes2);
    } catch (e) {
      log('Error comparing times: $e');
      return 0;
    }
  }

  static String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class BranchScheduleValidator {
  static bool hasScheduleConflict(List<BranchElement> existingBranches, BranchElement newBranch) {
    for (var existing in existingBranches) {
      // Check if there are any overlapping days
      final overlappingDays = existing.availableDays.where((day) => newBranch.availableDays.contains(day)).toList();

      if (overlappingDays.isEmpty) continue;

      // If there are overlapping days, check time conflicts
      final existingStart = TimeComparer.parseTimeString(existing.availableFrom ?? "00:00");
      final existingEnd = TimeComparer.parseTimeString(existing.availableTo ?? "00:00");
      final newStart = TimeComparer.parseTimeString(newBranch.availableFrom ?? "00:00");
      final newEnd = TimeComparer.parseTimeString(newBranch.availableTo ?? "00:00");

      // Check if times overlap
      if (_doTimesOverlap(existingStart, existingEnd, newStart, newEnd)) {
        return true; // Conflict found
      }
    }
    return false; // No conflicts
  }

  static bool _doTimesOverlap(TimeOfDay start1, TimeOfDay end1, TimeOfDay start2, TimeOfDay end2) {
    final start1Minutes = start1.hour * 60 + start1.minute;
    final end1Minutes = end1.hour * 60 + end1.minute;
    final start2Minutes = start2.hour * 60 + start2.minute;
    final end2Minutes = end2.hour * 60 + end2.minute;
    return start1Minutes < end2Minutes && start2Minutes < end1Minutes;
  }
}

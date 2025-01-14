import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:ocurithm/core/widgets/custom_freeze_loading.dart';

import '../../../../../../../../Services/time_parser.dart';
import '../../../../../../../../core/utils/colors.dart';
import '../../../../../../../../core/widgets/DropdownPackage.dart';
import '../../../../../../../../core/widgets/choose_hours_range.dart';
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
                        // Parse times first
                        final branchOpenTime = TimeComparer.parseTimeString(widget.cubit.selectedBranch?.openTime ?? "08:00");
                        final branchCloseTime = TimeComparer.parseTimeString(widget.cubit.selectedBranch?.closeTime ?? "18:00");
                        final doctorAvailableFrom = TimeComparer.parseTimeString(widget.cubit.availableFrom ?? "08:00");
                        final doctorAvailableTo = TimeComparer.parseTimeString(widget.cubit.availableTo ?? "18:00");

                        // Validate branch first
                        if (widget.cubit.validateAddBranch()) {
                          // Check if doctor's available time is within branch hours
                          if (TimeComparer.compareTimeOfDay(doctorAvailableFrom, branchOpenTime) >= 0 &&
                              TimeComparer.compareTimeOfDay(doctorAvailableTo, branchCloseTime) <= 0) {
                            log("Validation passed, checking connection...");

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

                            log("Connection OK, adding branch...");
                            widget.cubit.addBranch(
                              context: context,
                              doctorId: widget.id,
                              branchId: widget.cubit.selectedBranch!.id.toString(),
                            );
                          } else {
                            // Show the snackbar using ScaffoldMessenger

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Please select a time between ${_formatTime(branchOpenTime)} and ${_formatTime(branchCloseTime)}',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } else {
                          // Show validation error if validateAddBranch() returns false
                          Get.snackbar('Please fill all required fields', 'please try again',
                              icon: Icon(Icons.error, color: Colorz.white), backgroundColor: Colorz.errorColor, colorText: Colorz.white);
                          // ScaffoldMessenger.of(context).showSnackBar(
                          //   const SnackBar(
                          //     content: Text('Please fill all required fields'),
                          //     backgroundColor: Colors.red,
                          //   ),
                          // );
                        }
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

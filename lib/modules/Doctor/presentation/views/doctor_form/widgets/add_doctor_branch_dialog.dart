import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:ocurithm/modules/Doctor/data/model/doctor_model.dart';
import 'package:ocurithm/modules/Branch/data/model/branches_model.dart';
import 'package:ocurithm/core/utils/colors.dart';
import 'package:ocurithm/core/widgets/DropdownPackage.dart';
import 'package:ocurithm/core/widgets/choose_hours_range.dart';
import 'package:ocurithm/core/widgets/custom_buttons.dart';
import 'package:ocurithm/core/widgets/work_day_selector.dart';
import 'package:ocurithm/generated/l10n.dart';
import 'package:ocurithm/modules/Doctor/presentation/manager/doctor_branch_actions_cubit/doctor_branch_actions_cubit.dart';
import 'package:ocurithm/modules/Branch/presentation/manager/get_branches_cubit/get_branches_cubit.dart';
import 'package:ocurithm/Services/time_parser.dart';

class AddDoctorBranchDialog extends StatefulWidget {
  final String doctorId;
  final String clinicId;
  final List<BranchElement> existingBranches;
  final BranchElement? initialBranch; // If editing

  const AddDoctorBranchDialog({
    Key? key,
    required this.doctorId,
    required this.clinicId,
    required this.existingBranches,
    this.initialBranch,
  }) : super(key: key);

  @override
  State<AddDoctorBranchDialog> createState() => _AddDoctorBranchDialogState();
}

class _AddDoctorBranchDialogState extends State<AddDoctorBranchDialog> {
  Branch? _selectedBranch;
  String _availableFrom = "08:00";
  String _availableTo = "18:00";
  List<String> _availableDays = [];

  // Validation state
  bool _chooseBranch = true;
  bool _chooseTime = true;
  bool _chooseDays = true;

  List<String> _initialSelectedDays = [];

  @override
  void initState() {
    super.initState();
    // Fetch branches for the clinic
    context.read<GetBranchesCubit>().add(SetClinicFilterEvent(widget.clinicId));

    if (widget.initialBranch != null) {
      _selectedBranch = widget.initialBranch!.branch;
      _availableFrom = widget.initialBranch!.availableFrom ?? "08:00";
      _availableTo = widget.initialBranch!.availableTo ?? "18:00";
      _availableDays = List.from(widget.initialBranch!.availableDays);
      _initialSelectedDays = List.from(widget.initialBranch!.availableDays);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      backgroundColor: theme.cardColor,
      insetPadding: const EdgeInsets.all(10),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.initialBranch != null ? "Edit Branch" : "Add Branch",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 20),

              // Branch Dropdown
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Branch",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  BlocBuilder<GetBranchesCubit, GetBranchesState>(
                    builder: (context, state) {
                      return DropdownItem(
                        radius: 30,
                        color: isDark
                            ? Colors.grey[800]!.withOpacity(0.5)
                            : Colorz.white,
                        isShadow: false,
                        border: theme.primaryColor,
                        iconData: Icon(
                          Icons.arrow_drop_down_circle,
                          color: theme.primaryColor,
                        ),
                        items: state.branches?.branches,
                        isValid: _chooseBranch,
                        validateText: S.of(context).mustBranch,
                        readOnly: widget.initialBranch !=
                            null, // Read-only if editing
                        selectedValue: _selectedBranch?.name,
                        hintText: 'Select Branch',
                        itemAsString: (item) => item.name.toString(),
                        onItemSelected: (item) {
                          setState(() {
                            if (item != "Not Found") {
                              _chooseBranch = true;
                              _selectedBranch = item;
                              // Initialize times with branch times
                              _availableFrom = item.openTime ?? '08:00';
                              _availableTo = item.closeTime ?? '18:00';
                            }
                          });
                        },
                        isLoading: state.state == GetBranchesStatus.loading,
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 20),

              if (_selectedBranch != null) ...[
                // Work Days Selector
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Working Days",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    WorkDaysSelector(
                      radius: 30,
                      isShadow: false,
                      border: theme.primaryColor,
                      onDaysSelected: (List<String> days) {
                        setState(() {
                          _availableDays = days;
                        });
                      },
                      isValid: _chooseDays,
                      initialSelectedDays: _initialSelectedDays,
                      enabledDays: _selectedBranch?.workDays,
                      icon: Icon(
                        Icons.arrow_drop_down_circle,
                        color: theme.primaryColor,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Business Hours Selector
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Business Hours",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    BusinessHoursSelector(
                      onTimeRangeSelected: (openTime, closeTime) {
                        setState(() {
                          _availableFrom =
                              '${openTime.hour.toString().padLeft(2, '0')}:${openTime.minute.toString().padLeft(2, '0')}';
                          _availableTo =
                              '${closeTime.hour.toString().padLeft(2, '0')}:${closeTime.minute.toString().padLeft(2, '0')}';
                        });
                      },
                      initialOpenTime:
                          TimeParser.stringToTimeOfDay(_availableFrom),
                      initialCloseTime:
                          TimeParser.stringToTimeOfDay(_availableTo),
                      icon: Icon(
                        Icons.arrow_drop_down_circle,
                        color: theme.primaryColor,
                      ),
                      radius: 30,
                      isValid: _chooseTime,
                      isShadow: false,
                      border: theme.primaryColor,
                      startEnabledTime: TimeParser.stringToTimeOfDay(
                          _selectedBranch?.openTime),
                      endEnabledTime: TimeParser.stringToTimeOfDay(
                          _selectedBranch?.closeTime),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
              ],

              SizedBox(
                width: double.infinity,
                child: BlocConsumer<DoctorBranchActionsCubit,
                    DoctorBranchActionsState>(
                  listener: (context, state) {
                    if (state.isSuccess) {
                      Navigator.pop(context); // Close dialog
                    } else if (state.isError) {
                      Get.snackbar(
                        "Error",
                        state.errorMessage ?? "An error occurred",
                        backgroundColor: Colorz.errorColor,
                        colorText: Colorz.white,
                        icon: const Icon(Icons.error, color: Colors.white),
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state.isLoading) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: CircularProgressIndicator(
                              color: theme.primaryColor),
                        ),
                      );
                    }
                    return CoolDownButton(
                      onTap: _handleSubmit,
                      text: widget.initialBranch != null
                          ? 'Update Branch'
                          : 'Add Branch',
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    // Validation
    bool isValid = true;
    setState(() {
      if (_selectedBranch == null) {
        _chooseBranch = false;
        isValid = false;
      }
      if (_availableDays.isEmpty) {
        _chooseDays = false;
        isValid = false;
      } else {
        _chooseDays = true;
      }
      // Time validation logic is handled by the widget mostly, but we should check if set
      _chooseTime = true;
    });

    if (!isValid) return;

    // Check internet
    bool connection = await InternetConnection().hasInternetAccess;
    if (!connection) {
      Get.snackbar(
        "Error",
        "No Internet Connection",
        backgroundColor: Colorz.errorColor,
        colorText: Colorz.white,
        icon: const Icon(Icons.error, color: Colors.white),
      );
      return;
    }

    // Conflict check
    final newBranchSchedule = BranchElement(
        branch: _selectedBranch,
        availableFrom: _availableFrom,
        availableTo: _availableTo,
        availableDays: _availableDays,
        id: "temp",
        branchId: "temp");

    // Filter out current branch if editing
    final otherBranches = widget.existingBranches
        .where((b) =>
            widget.initialBranch == null || b.id != widget.initialBranch!.id)
        .toList();

    if (BranchScheduleValidator.hasScheduleConflict(
        otherBranches, newBranchSchedule)) {
      Get.snackbar(
        "Schedule Conflict",
        "This schedule overlaps with existing branch assignments",
        backgroundColor: Colorz.errorColor,
        colorText: Colorz.white,
        icon: const Icon(Icons.error, color: Colors.white),
      );
      return;
    }

    // Time boundary check
    final branchOpenTime =
        TimeComparer.parseTimeString(_selectedBranch?.openTime ?? "08:00");
    final branchCloseTime =
        TimeComparer.parseTimeString(_selectedBranch?.closeTime ?? "18:00");
    final doctorAvailableFrom = TimeComparer.parseTimeString(_availableFrom);
    final doctorAvailableTo = TimeComparer.parseTimeString(_availableTo);

    if (TimeComparer.compareTimeOfDay(doctorAvailableFrom, branchOpenTime) <
            0 ||
        TimeComparer.compareTimeOfDay(doctorAvailableTo, branchCloseTime) > 0) {
      Get.snackbar(
        "Invalid Time",
        "Please select a time between ${_formatTime(branchOpenTime)} and ${_formatTime(branchCloseTime)}",
        backgroundColor: Colorz.errorColor,
        colorText: Colorz.white,
        icon: const Icon(Icons.error, color: Colors.white),
      );
      return;
    }

    // Submit Action
    if (widget.initialBranch != null) {
      // Edit
      context.read<DoctorBranchActionsCubit>().add(
            EditDoctorBranchEvent(
              doctorId: widget.doctorId,
              branchId: _selectedBranch!.id
                  .toString(), // The API usually uses branchId for edits as well in this context? Let's check logic.
              // Wait, editBranch in repo takes branchId, doctorId, availableFrom...
              // The old code used widget.cubit.selectedBranch!.id.toString().
              availableFrom: _availableFrom,
              availableTo: _availableTo,
              availableDays: _availableDays,
            ),
          );
    } else {
      // Add
      context.read<DoctorBranchActionsCubit>().add(
            AddDoctorBranchEvent(
              doctorId: widget.doctorId,
              branchId: _selectedBranch!.id.toString(),
              availableFrom: _availableFrom,
              availableTo: _availableTo,
              availableDays: _availableDays,
            ),
          );
    }
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
      final parts = timeStr.trim().split(':');
      if (parts.length == 2) {
        final hour = int.parse(parts[0].trim());
        final minute = int.parse(parts[1].trim());
        return TimeOfDay(hour: hour, minute: minute);
      }
      return const TimeOfDay(hour: 0, minute: 0);
    } catch (e) {
      return const TimeOfDay(hour: 0, minute: 0);
    }
  }

  static int compareTimeOfDay(TimeOfDay time1, TimeOfDay time2) {
    final minutes1 = time1.hour * 60 + time1.minute;
    final minutes2 = time2.hour * 60 + time2.minute;
    return minutes1.compareTo(minutes2);
  }
}

class BranchScheduleValidator {
  static bool hasScheduleConflict(
      List<BranchElement> existingBranches, BranchElement newBranch) {
    for (var existing in existingBranches) {
      final overlappingDays = existing.availableDays
          .where((day) => newBranch.availableDays.contains(day))
          .toList();

      if (overlappingDays.isEmpty) continue;

      final existingStart =
          TimeComparer.parseTimeString(existing.availableFrom ?? "00:00");
      final existingEnd =
          TimeComparer.parseTimeString(existing.availableTo ?? "00:00");
      final newStart =
          TimeComparer.parseTimeString(newBranch.availableFrom ?? "00:00");
      final newEnd =
          TimeComparer.parseTimeString(newBranch.availableTo ?? "00:00");

      if (_doTimesOverlap(existingStart, existingEnd, newStart, newEnd)) {
        return true;
      }
    }
    return false;
  }

  static bool _doTimesOverlap(
      TimeOfDay start1, TimeOfDay end1, TimeOfDay start2, TimeOfDay end2) {
    final start1Minutes = start1.hour * 60 + start1.minute;
    final end1Minutes = end1.hour * 60 + end1.minute;
    final start2Minutes = start2.hour * 60 + start2.minute;
    final end2Minutes = end2.hour * 60 + end2.minute;
    return start1Minutes < end2Minutes && start2Minutes < end1Minutes;
  }
}

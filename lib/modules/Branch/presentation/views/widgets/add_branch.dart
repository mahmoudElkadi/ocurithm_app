import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:ocurithm/core/widgets/custom_freeze_loading.dart';

import '../../../../../../core/utils/colors.dart';
import '../../../../../core/widgets/DropdownPackage.dart';
import '../../../data/model/add_branch_model.dart';
import '../../manager/branch_cubit.dart';
import '../../manager/branch_state.dart';

class FormData {
  String code;
  String name;
  String address;
  String phone;

  FormData({
    this.code = '',
    this.name = '',
    this.address = '',
    this.phone = '',
  });
}

class FormPopupDialog extends StatefulWidget {
  final Function(FormData) onSubmit;
  final AdminBranchCubit cubit;

  const FormPopupDialog({
    Key? key,
    required this.onSubmit,
    required this.cubit,
  }) : super(key: key);

  @override
  State<FormPopupDialog> createState() => _FormPopupDialogState();
}

class _FormPopupDialogState extends State<FormPopupDialog> {
  final _formKey = GlobalKey<FormState>();
  final _data = FormData();

  // Controllers for text fields
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  List selectedDays = [];
  String openingTime = "";
  String closingTime = "";

  @override
  void initState() {
    super.initState();
    widget.cubit.getClinics();
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      customLoading(context, "");
      bool connection = await InternetConnection().hasInternetAccess;
      if (!connection) {
        Navigator.of(context).pop();
        Get.snackbar(
          "Error",
          "No Internet Connection",
          backgroundColor: Colorz.errorColor,
          colorText: Colorz.white,
          icon: Icon(Icons.error, color: Colorz.white),
        );
        return;
      } else {
        AddBranchModel model = AddBranchModel(
            code: _codeController.text.trim(),
            name: _nameController.text.trim(),
            address: _addressController.text.trim(),
            workDays: selectedDays,
            openTime: openingTime,
            closeTime: closingTime,
            clinic: selectedClinic,
            phone: _phoneController.text.trim());

        await widget.cubit.addBranch(addBranchModel: model, context: context);
      }

      // Navigator.of(context).pop();
    }
  }

  var selectedClinic;
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: BlocBuilder<AdminBranchCubit, AdminBranchState>(
        bloc: widget.cubit,
        builder: (context, state) => Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Add New Branch',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      splashRadius: 20,
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 16),

                // Form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Code TextField
                      DropdownItem(
                        radius: 8,
                        border: Colorz.grey,
                        color: Colorz.white,
                        isShadow: false,
                        height: 14,
                        iconData: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Colorz.grey,
                        ),

                        items: widget.cubit.clinics?.clinics,
                        // isValid: widget.cubit.chooseBranch,
                        // validateText: S.of(context).mustBranch,
                        selectedValue: selectedClinic,
                        hintText: 'Select Clinic',
                        itemAsString: (item) => item.name.toString(),
                        onItemSelected: (item) {
                          setState(() {
                            if (item != "Not Found") {
                              selectedClinic = item.id;
                              log(selectedClinic.toString());
                            }
                          });
                        },
                        isLoading: widget.cubit.clinics == null,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _codeController,
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                          hintText: 'Enter code',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          prefixIcon: Icon(
                            Icons.code,
                            color: Colorz.grey,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a code';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Name TextField
                      TextFormField(
                        controller: _nameController,
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                          hintText: 'Enter name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.person, color: Colors.grey),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Address TextField
                      TextFormField(
                        controller: _addressController,
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                          hintText: 'Enter address',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          prefixIcon: Icon(Icons.location_on, color: Colors.grey),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Phone TextField
                      TextFormField(
                        controller: _phoneController,
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                          hintText: 'Enter phone number',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.phone, color: Colors.grey),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                        ),
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      WorkDaysSelector(
                        onDaysSelected: (List days) {
                          setState(() {
                            selectedDays = days;
                          });
                          print('Selected days: $selectedDays');
                        },
                        initialSelectedDays: [], // Optiona l
                      ),
                      const SizedBox(height: 16),

                      BusinessHoursSelector(
                        onTimeRangeSelected: (openTime, closeTime) {
                          print('Business hours: ${openTime.format(context)} - ${closeTime.format(context)}');
                          openingTime = openTime.toString();
                          closingTime = closeTime.toString();
                        },
                      ),

                      const SizedBox(height: 24),

                      // Submit Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: _submitForm,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                              backgroundColor: Colorz.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Submit',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Example usage:
void showFormPopup(BuildContext context, AdminBranchCubit cubit) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return FormPopupDialog(
        cubit: cubit,
        onSubmit: (FormData data) {
          // Handle the submitted data
          print('Code: ${data.code}');
          print('Name: ${data.name}');
          print('Address: ${data.address}');
          print('Phone: ${data.phone}');
        },
      );
    },
  );
}

// Example button to show the popup:

class WorkDaysSelector extends StatefulWidget {
  final Function(List<String>) onDaysSelected;
  final List? initialSelectedDays;

  const WorkDaysSelector({
    Key? key,
    required this.onDaysSelected,
    this.initialSelectedDays,
  }) : super(key: key);

  @override
  State<WorkDaysSelector> createState() => _WorkDaysSelectorState();
}

class _WorkDaysSelectorState extends State<WorkDaysSelector> {
  bool _isExpanded = false;
  final List<String> _daysOfWeek = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

  // Make sure it's initialized as an empty list
  List<String> _selectedDays = [];

  @override
  void initState() {
    super.initState();
    // Initialize selected days with proper error handling
    try {
      if (widget.initialSelectedDays != null) {
        _selectedDays = List<String>.from(widget.initialSelectedDays!);
      }
    } catch (e) {
      print("Error initializing days: $e");
      _selectedDays = [];
    }
  }

  void _toggleDay(String day) {
    try {
      setState(() {
        if (_selectedDays.contains(day)) {
          _selectedDays.removeWhere((selectedDay) => selectedDay == day);
        } else {
          _selectedDays.add(day);
        }
        // Notify parent widget of changes
        widget.onDaysSelected(List<String>.from(_selectedDays));
      });
    } catch (e) {
      print("Error toggling day: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header section
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: Colors.grey,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Work Days',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (!_isExpanded)
                          Text(
                            _getSelectedDaysPreview(),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Days selection section
          AnimatedCrossFade(
            firstChild: const SizedBox(height: 0),
            secondChild: _buildDaysGrid(),
            crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  Widget _buildDaysGrid() {
    return Column(
      children: [
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: _daysOfWeek.map((day) => _buildDayItem(day)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDayItem(String day) {
    // Explicitly check if the day is in _selectedDays
    bool isSelected = _selectedDays.contains(day);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _toggleDay(day),
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 140, // Fixed width for consistent sizing
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? Colorz.primaryColor.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isSelected ? Colorz.primaryColor : Colors.grey.shade300,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: isSelected,
                  onChanged: (bool? value) {
                    _toggleDay(day);
                  },
                  activeColor: Colorz.primaryColor,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                day.substring(0, 3),
                style: TextStyle(
                  fontSize: 14,
                  color: isSelected ? Colorz.primaryColor : Colors.black87,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getSelectedDaysPreview() {
    if (_selectedDays.isEmpty) {
      return 'No days selected';
    } else if (_selectedDays.length == 7) {
      return 'All days';
    } else {
      return _selectedDays.map((day) => day.substring(0, 3)).join(', ');
    }
  }
}

class BusinessHoursSelector extends StatefulWidget {
  final TimeOfDay? initialOpenTime;
  final TimeOfDay? initialCloseTime;
  final Function(TimeOfDay, TimeOfDay) onTimeRangeSelected;

  const BusinessHoursSelector({
    Key? key,
    this.initialOpenTime,
    this.initialCloseTime,
    required this.onTimeRangeSelected,
  }) : super(key: key);

  @override
  State<BusinessHoursSelector> createState() => _BusinessHoursSelectorState();
}

class _BusinessHoursSelectorState extends State<BusinessHoursSelector> {
  bool _isExpanded = false;
  late TimeOfDay _openTime;
  late TimeOfDay _closeTime;

  @override
  void initState() {
    super.initState();
    _openTime = widget.initialOpenTime ?? const TimeOfDay(hour: 9, minute: 0);
    _closeTime = widget.initialCloseTime ?? const TimeOfDay(hour: 17, minute: 0);
  }

  Future<void> _selectTime(BuildContext context, bool isOpenTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isOpenTime ? _openTime : _closeTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,
              hourMinuteShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: Colorz.primaryColor,
                  width: 1,
                ),
              ),
              hourMinuteColor: Colorz.primaryColor.withOpacity(0.1),
              hourMinuteTextStyle: TextStyle(
                color: Colorz.primaryColor,
                fontSize: 58,
                fontWeight: FontWeight.w800,
              ),
              timeSelectorSeparatorColor: WidgetStateProperty.all(Colors.black),
              hourMinuteTextColor: Colorz.primaryColor,
              dayPeriodColor: Colorz.primaryColor.withOpacity(0.1),
              dialHandColor: Colorz.primaryColor,
              dayPeriodTextColor: Colorz.primaryColor,
              cancelButtonStyle: TextButton.styleFrom(
                foregroundColor: Colorz.primaryColor,
              ),
              confirmButtonStyle: TextButton.styleFrom(
                foregroundColor: Colorz.primaryColor,
              ),
              dayPeriodShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: Colorz.primaryColor,
                  width: 1,
                ),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isOpenTime) {
          _openTime = picked;
        } else {
          _closeTime = picked;
        }
        widget.onTimeRangeSelected(_openTime, _closeTime);
        WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
      });
    }
  }

  String _formatTimeRange() {
    return '${_formatTime(_openTime)} - ${_formatTime(_closeTime)}';
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour == 0
        ? 12
        : time.hour > 12
            ? time.hour - 12
            : time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    color: Colors.grey,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Business Hours',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (!_isExpanded)
                          Text(
                            _formatTimeRange(),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Expandable Content
          AnimatedCrossFade(
            firstChild: const SizedBox(height: 0),
            secondChild: Column(
              children: [
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      _buildTimeSelector(
                        title: 'Opening Time',
                        time: _openTime,
                        onTap: () => _selectTime(context, true),
                        icon: Icons.wb_sunny_outlined,
                      ),
                      const SizedBox(height: 12),
                      _buildTimeSelector(
                        title: 'Closing Time',
                        time: _closeTime,
                        onTap: () => _selectTime(context, false),
                        icon: Icons.nightlight_outlined,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSelector({
    required String title,
    required TimeOfDay time,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: Colorz.primaryColor,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatTime(time),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.access_time_rounded,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}

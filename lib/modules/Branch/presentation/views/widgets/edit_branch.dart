import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:ocurithm/core/widgets/no_internet.dart';
import 'package:ocurithm/modules/Clinics/data/model/clinics_model.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../../core/utils/colors.dart';
import '../../../../../../core/widgets/custom_freeze_loading.dart';
import '../../../../../Services/time_parser.dart';
import '../../../../../core/widgets/DropdownPackage.dart';
import '../../../data/model/add_branch_model.dart';
import '../../manager/branch_cubit.dart';
import '../../manager/branch_state.dart';
import 'add_branch.dart';

class EditBranchDialog extends StatefulWidget {
  final AdminBranchCubit cubit;
  final String id;

  const EditBranchDialog({
    super.key,
    required this.cubit,
    required this.id,
  });

  @override
  State<EditBranchDialog> createState() => _EditBranchDialogState();
}

class _EditBranchDialogState extends State<EditBranchDialog> {
  final _formKey = GlobalKey<FormState>();

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
    fetchData();
  }

  fetchData() async {
    await widget.cubit.getBranch(id: widget.id);
    if (widget.cubit.branch != null) {
      _codeController.text = widget.cubit.branch?.code ?? '';
      _nameController.text = widget.cubit.branch?.name ?? '';
      _addressController.text = widget.cubit.branch?.address ?? '';
      _phoneController.text = widget.cubit.branch?.phone ?? '';

      selectedDays = widget.cubit.branch?.workDays ?? [];
      //   selectedClinic = widget.cubit.branch?.clinic;
      openingTime = widget.cubit.branch?.openTime ?? '';
      closingTime = widget.cubit.branch?.closeTime ?? '';
    }
    setState(() {});
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
            clinic: selectedClinic?.id,
            phone: _phoneController.text.trim());

        await widget.cubit.updateBranch(id: widget.id, addBranchModel: model, context: context);
      }
    }
  }

  Widget _buildShimmer(Widget child) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: child,
    );
  }

  Clinic? selectedClinic;
  bool readOnly = true;

  @override
  Widget build(BuildContext context) {
    bool isLoading = widget.cubit.branch == null;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: BlocBuilder<AdminBranchCubit, AdminBranchState>(
        bloc: widget.cubit,
        builder: (BuildContext context, state) => Container(
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
                      'Branch',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (readOnly == true)
                      IconButton(
                        onPressed: () {
                          setState(() {
                            readOnly = !readOnly;
                          });
                        },
                        icon: const Icon(Icons.edit),
                        splashRadius: 20,
                      )
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
                      isLoading
                          ? _buildShimmer(Container(
                              width: MediaQuery.sizeOf(context).width,
                              height: 60,
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(8)),
                                color: Colors.white,
                              ),
                            ))
                          : DropdownItem(
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
                              selectedValue: selectedClinic?.name,
                              hintText: 'Select Clinic',
                              itemAsString: (item) => item.name.toString(),
                              onItemSelected: (item) {
                                setState(() {
                                  if (item != "Not Found") {
                                    selectedClinic = item;
                                    log(selectedClinic.toString());
                                  }
                                });
                              },
                              isLoading: widget.cubit.clinics == null,
                            ),
                      const SizedBox(height: 16),
                      isLoading
                          ? _buildShimmer(Container(
                              width: MediaQuery.sizeOf(context).width,
                              height: 60,
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(8)),
                                color: Colors.white,
                              ),
                            ))
                          : TextFormField(
                              controller: _codeController,
                              cursorColor: Colors.black,
                              readOnly: readOnly,
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
                      isLoading
                          ? _buildShimmer(Container(
                              width: MediaQuery.sizeOf(context).width,
                              height: 60,
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(8)),
                                color: Colors.white,
                              ),
                            ))
                          : TextFormField(
                              controller: _nameController,
                              cursorColor: Colors.black,
                              readOnly: readOnly,
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
                      isLoading
                          ? _buildShimmer(Container(
                              width: MediaQuery.sizeOf(context).width,
                              height: 60,
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(8)),
                                color: Colors.white,
                              ),
                            ))
                          : TextFormField(
                              controller: _addressController,
                              cursorColor: Colors.black,
                              readOnly: readOnly,
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
                      isLoading
                          ? _buildShimmer(Container(
                              width: MediaQuery.sizeOf(context).width,
                              height: 60,
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(8)),
                                color: Colors.white,
                              ),
                            ))
                          : TextFormField(
                              controller: _phoneController,
                              cursorColor: Colors.black,
                              readOnly: readOnly,
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

                      isLoading
                          ? _buildShimmer(Container(
                              width: MediaQuery.sizeOf(context).width,
                              height: 60,
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(8)),
                                color: Colors.white,
                              ),
                            ))
                          : WorkDaysSelector(
                              onDaysSelected: (List days) {
                                setState(() {
                                  selectedDays = days;
                                });
                                print('Selected days: $selectedDays');
                              },
                              initialSelectedDays: widget.cubit.branch!.workDays, // Optional
                            ),
                      const SizedBox(height: 16),

                      isLoading
                          ? _buildShimmer(Container(
                              width: MediaQuery.sizeOf(context).width,
                              height: 60,
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(8)),
                                color: Colors.white,
                              ),
                            ))
                          : BusinessHoursSelector(
                              onTimeRangeSelected: (openTime, closeTime) {
                                print('Business hours: ${openTime} - ${closeTime}');
                                openingTime = openTime.toString();
                                closingTime = closeTime.toString();
                              },
                              initialOpenTime: TimeParser.parseTimeString(widget.cubit.branch!.openTime.toString()),
                              initialCloseTime: TimeParser.parseTimeString(widget.cubit.branch!.closeTime.toString()),
                            ),
                      const SizedBox(height: 24),

                      // Submit Button
                      if (readOnly != true)
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
void editBranch(BuildContext context, AdminBranchCubit cubit, String id) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return cubit.connection != false
          ? EditBranchDialog(
              cubit: cubit,
              id: id,
            )
          : NoInternet(
              withImage: false,
              onPressed: () {
                cubit.getBranch(id: id);
              },
            );
    },
  );
}

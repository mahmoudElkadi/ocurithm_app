import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:ocurithm/core/Network/shared.dart';
import 'package:ocurithm/core/widgets/custom_freeze_loading.dart';
import 'package:ocurithm/modules/Examination%20Type/data/model/examination_type_model.dart';
import 'package:ocurithm/modules/Examination%20Type/presentation/manager/examination_type_cubit.dart';
import 'package:ocurithm/modules/Examination%20Type/presentation/manager/examination_type_state.dart';

import '../../../../../../core/utils/colors.dart';
import '../../../../../core/widgets/DropdownPackage.dart';
import '../../../../../core/widgets/custom_buttons.dart';
import '../../../../Clinics/data/model/clinics_model.dart';

class FormPopupDialog extends StatefulWidget {
  final ExaminationTypeCubit cubit;

  const FormPopupDialog({
    Key? key,
    required this.cubit,
  }) : super(key: key);

  @override
  State<FormPopupDialog> createState() => _FormPopupDialogState();
}

class _FormPopupDialogState extends State<FormPopupDialog> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  final _priceController = TextEditingController();
  final _nameController = TextEditingController();
  final _durationController = TextEditingController();

  @override
  void dispose() {
    _priceController.dispose();
    _nameController.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (CacheHelper.getStringList(key: "capabilities").contains("manageCapabilities")) {
      if (widget.cubit.clinics == null) {
        widget.cubit.getClinics();
      }
    } else {
      selectedClinic = CacheHelper.getUser("user")?.clinic;
    }
  }

  void _submitForm() async {
    setState(() {
      _clinicValidation = selectedClinic != null;
    });
    if (_formKey.currentState!.validate() && _clinicValidation) {
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
        ExaminationType model = ExaminationType(
          clinic: selectedClinic,
          name: _nameController.text.trim(),
          price: num.parse(_priceController.text),
          duration: num.parse(_durationController.text),
        );

        await widget.cubit.addExaminationType(examinationType: model, context: context);
      }

      // Navigator.of(context).pop();
    }
  }

  Clinic? selectedClinic;
  bool _clinicValidation = true;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: BlocBuilder<ExaminationTypeCubit, ExaminationTypeState>(
        bloc: widget.cubit,
        builder: (context, state) => SingleChildScrollView(
          child: Container(
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Add Examination Type',
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
                      if (CacheHelper.getStringList(key: "capabilities").contains("manageCapabilities"))
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
                          isValid: _clinicValidation,
                          validateText: 'Please enter a clinic',
                          selectedValue: selectedClinic?.name,
                          hintText: 'Select Clinic',
                          prefixIcon: Icon(Icons.local_hospital_outlined, color: Colorz.grey),
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
                      TextFormField(
                        controller: _nameController,
                        cursorColor: Colors.black,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'Enter name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.e_mobiledata, color: Colors.grey),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _priceController,
                        cursorColor: Colors.black,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Enter Price',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          prefixIcon: Icon(
                            Icons.monetization_on,
                            color: Colorz.grey,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a Price';
                          }

                          // Convert string to double
                          double? price = double.tryParse(value);

                          // Check if it's a valid number and if it's less than or equal to zero
                          if (price == null) {
                            return 'Please enter a valid number';
                          }

                          if (price <= 0) {
                            return 'Price must be greater than zero';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _durationController,
                        cursorColor: Colors.black,
                        keyboardType: TextInputType.number,
                        // Add input formatter to only allow integer numbers
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly, // This ensures only digits can be entered
                        ],
                        decoration: InputDecoration(
                          hintText: 'Enter Duration',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          prefixIcon: Icon(
                            Icons.timer,
                            color: Colorz.grey,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a Duration';
                          }

                          // Convert string to integer
                          int? duration = int.tryParse(value);

                          // Check if it's a valid integer
                          if (duration == null) {
                            return 'Please enter a valid integer';
                          }

                          // Check if it's greater than zero
                          if (duration <= 0) {
                            return 'Duration must be greater than zero';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Submit Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CoolDownButton(
                            onTap: _submitForm,
                            text: 'Submit',
                          )
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
void showFormPopup(BuildContext context, ExaminationTypeCubit cubit) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return FormPopupDialog(
        cubit: cubit,
      );
    },
  );
}

// Example button to show the popup:

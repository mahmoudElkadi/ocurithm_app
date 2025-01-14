import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:ocurithm/core/widgets/custom_freeze_loading.dart';

import '../../../../../../core/utils/colors.dart';
import '../../../../../core/Network/shared.dart';
import '../../../../../core/widgets/DropdownPackage.dart';
import '../../../../Clinics/data/model/clinics_model.dart';
import '../../../data/model/payment_method_model.dart';
import '../../manager/payment_method_cubit.dart';
import '../../manager/payment_method_state.dart';

class FormPopupDialog extends StatefulWidget {
  final PaymentMethodCubit cubit;

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
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();

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
        PaymentMethod model = PaymentMethod(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          clinic: selectedClinic,
        );

        await widget.cubit.addPaymentMethod(paymentMethod: model, context: context);
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
      child: BlocBuilder<PaymentMethodCubit, PaymentMethodState>(
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Add Payment Method',
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
                      controller: _titleController,
                      cursorColor: Colors.black,
                      decoration: InputDecoration(
                        hintText: 'Enter Title',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.credit_card, color: Colors.grey),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a Title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      cursorColor: Colors.black,
                      decoration: InputDecoration(
                        hintText: 'Enter Description',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        prefixIcon: Icon(
                          Icons.description,
                          color: Colorz.grey,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a Description';
                        }
                        return null;
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
    );
  }
}

// Example usage:
void showFormPopup(BuildContext context, PaymentMethodCubit cubit) {
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

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:ocurithm/core/widgets/no_internet.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../../core/utils/colors.dart';
import '../../../../../../core/widgets/custom_freeze_loading.dart';
import '../../../../../core/Network/shared.dart';
import '../../../../../core/widgets/DropdownPackage.dart';
import '../../../../../core/widgets/custom_buttons.dart';
import '../../../../Clinics/data/model/clinics_model.dart';
import '../../../data/model/payment_method_model.dart';
import '../../manager/payment_method_cubit.dart';
import '../../manager/payment_method_state.dart';

class EditPaymentMethodDialog extends StatefulWidget {
  final PaymentMethodCubit cubit;
  final String id;

  const EditPaymentMethodDialog({
    super.key,
    required this.cubit,
    required this.id,
  });

  @override
  State<EditPaymentMethodDialog> createState() => _EditPaymentMethodDialogState();
}

class _EditPaymentMethodDialogState extends State<EditPaymentMethodDialog> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  fetchData() async {
    await widget.cubit.getPaymentMethod(id: widget.id);
    if (widget.cubit.paymentMethod != null) {
      _titleController.text = widget.cubit.paymentMethod?.title ?? '';
      _descriptionController.text = widget.cubit.paymentMethod?.description ?? '';
      selectedClinic = widget.cubit.paymentMethod?.clinic;
    }

    setState(() {});
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();

    super.dispose();
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
          clinic: selectedClinic,
          description: _descriptionController.text.trim(),
        );

        await widget.cubit.updatePaymentMethod(id: widget.id, paymentMethod: model, context: context);
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

  bool readOnly = true;

  Clinic? selectedClinic;
  bool _clinicValidation = true;
  @override
  Widget build(BuildContext context) {
    bool isLoading = widget.cubit.paymentMethod == null;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: BlocBuilder<PaymentMethodCubit, PaymentMethodState>(
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
                      'Payment Method',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        if (readOnly == true)
                          IconButton(
                            onPressed: () {
                              setState(() {
                                readOnly = !readOnly;
                              });
                              if (CacheHelper.getStringList(key: "capabilities").contains("manageCapabilities")) {
                                if (widget.cubit.clinics == null) {
                                  widget.cubit.getClinics();
                                }
                              } else {
                                selectedClinic = widget.cubit.paymentMethod?.clinic ?? CacheHelper.getUser("user")?.clinic;
                              }
                            },
                            icon: const Icon(Icons.edit),
                            splashRadius: 20,
                          ),
                        IconButton(
                          onPressed: () {
                            Get.back();
                          },
                          icon: const Icon(Icons.close),
                          splashRadius: 20,
                        ),
                      ],
                    )
                  ],
                ),
                const Divider(),
                const SizedBox(height: 16),

                // Form
                isLoading
                    ? _buildShimmer(Container(
                        width: MediaQuery.sizeOf(context).width,
                        height: 60,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          color: Colors.white,
                        ),
                      ))
                    : Form(
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
                              readOnly: CacheHelper.getStringList(key: "capabilities").contains("manageCapabilities") ? readOnly : true,
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
                                    controller: _titleController,
                                    cursorColor: Colors.black,
                                    readOnly: readOnly,
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
                                    controller: _descriptionController,
                                    cursorColor: Colors.black,
                                    readOnly: readOnly,
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
                            if (readOnly != true)
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
void editPaymentMethod(BuildContext context, PaymentMethodCubit cubit, String id) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return cubit.connection != false
          ? EditPaymentMethodDialog(
              cubit: cubit,
              id: id,
            )
          : NoInternet(
              withImage: false,
              onPressed: () {
                cubit.getPaymentMethod(id: id);
              },
            );
    },
  );
}

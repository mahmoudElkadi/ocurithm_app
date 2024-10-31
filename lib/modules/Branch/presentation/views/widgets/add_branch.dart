import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:ocurithm/core/widgets/custom_freeze_loading.dart';

import '../../../../../../core/utils/colors.dart';
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
            phone: _phoneController.text.trim());

        await widget.cubit.addBranch(addBranchModel: model, context: context);
      }

      // Navigator.of(context).pop();
    }
  }

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

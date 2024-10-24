import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../../core/utils/colors.dart';
import '../../manager/branch_cubit.dart';
import 'add_branch.dart';

class EditBranchDialog extends StatefulWidget {
  final Function(FormData) onSubmit;

  const EditBranchDialog({
    Key? key,
    required this.onSubmit,
  }) : super(key: key);

  @override
  State<EditBranchDialog> createState() => _EditBranchDialogState();
}

class _EditBranchDialogState extends State<EditBranchDialog> {
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

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _data.code = _codeController.text.trim();
      _data.name = _nameController.text.trim();
      _data.address = _addressController.text.trim();
      _data.phone = _phoneController.text.trim();

      widget.onSubmit(_data);
      Navigator.of(context).pop();
    }
  }

  bool readOnly = true;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
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

                    TextFormField(
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
                    TextFormField(
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
                    TextFormField(
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
                    TextFormField(
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
    );
  }
}

// Example usage:
void EditBranch(BuildContext context, AdminBranchCubit cubit) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return EditBranchDialog(
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:ocurithm/core/widgets/no_internet.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../../core/utils/colors.dart';
import '../../../../../../core/widgets/custom_freeze_loading.dart';
import '../../../data/model/clinics_model.dart';
import '../../manager/clinic_cubit.dart';
import '../../manager/clinic_state.dart';

class EditClinicDialog extends StatefulWidget {
  final ClinicCubit cubit;
  final String id;

  const EditClinicDialog({
    super.key,
    required this.cubit,
    required this.id,
  });

  @override
  State<EditClinicDialog> createState() => _EditClinicDialogState();
}

class _EditClinicDialogState extends State<EditClinicDialog> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  fetchData() async {
    await widget.cubit.getClinic(id: widget.id);
    if (widget.cubit.clinic != null) {
      _nameController.text = widget.cubit.clinic?.name ?? '';
      _descriptionController.text = widget.cubit.clinic?.description ?? '';
    }
    setState(() {});
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();

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
        Clinic model = Clinic(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
        );

        await widget.cubit.updateClinic(id: widget.id, clinic: model, context: context);
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

  @override
  Widget build(BuildContext context) {
    bool isLoading = widget.cubit.clinic == null;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: BlocBuilder<ClinicCubit, ClinicState>(
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
                      'Clinic Details',
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
                          : TextFormField(
                              controller: _nameController,
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
                                if (value == null || value.isEmpty) {
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
                                if (value == null || value.isEmpty) {
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
void editClinic(BuildContext context, ClinicCubit cubit, String id) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return cubit.connection != false
          ? EditClinicDialog(
              cubit: cubit,
              id: id,
            )
          : NoInternet(
              withImage: false,
              onPressed: () {
                cubit.getClinic(id: id);
              },
            );
    },
  );
}

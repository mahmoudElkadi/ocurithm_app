import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:ocurithm/core/widgets/no_internet.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../../core/utils/colors.dart';
import '../../../../../../core/widgets/custom_freeze_loading.dart';
import '../../../data/model/examination_type_model.dart';
import '../../manager/examination_type_cubit.dart';
import '../../manager/examination_type_state.dart';

class EditExaminationTypeDialog extends StatefulWidget {
  final ExaminationTypeCubit cubit;
  final String id;

  const EditExaminationTypeDialog({
    super.key,
    required this.cubit,
    required this.id,
  });

  @override
  State<EditExaminationTypeDialog> createState() => _EditExaminationTypeDialogState();
}

class _EditExaminationTypeDialogState extends State<EditExaminationTypeDialog> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  final _priceController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  fetchData() async {
    await widget.cubit.getExaminationType(id: widget.id);
    if (widget.cubit.examinationType != null) {
      _priceController.text = '${widget.cubit.examinationType?.price ?? ''}';
      _nameController.text = widget.cubit.examinationType?.name ?? '';
    }
    setState(() {});
  }

  @override
  void dispose() {
    _priceController.dispose();
    _nameController.dispose();

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
        ExaminationType model = ExaminationType(
          name: _nameController.text.trim(),
          price: num.parse(_priceController.text),
        );

        await widget.cubit.updateExaminationType(id: widget.id, examinationType: model, context: context);
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
    bool isLoading = widget.cubit.examinationType == null;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: BlocBuilder<ExaminationTypeCubit, ExaminationTypeState>(
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
                      'Examination Type',
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
                              controller: _priceController,
                              cursorColor: Colors.black,
                              readOnly: readOnly,
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
void editExaminationType(BuildContext context, ExaminationTypeCubit cubit, String id) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return cubit.connection != false
          ? EditExaminationTypeDialog(
              cubit: cubit,
              id: id,
            )
          : NoInternet(
              withImage: false,
              onPressed: () {
                cubit.getExaminationType(id: id);
              },
            );
    },
  );
}

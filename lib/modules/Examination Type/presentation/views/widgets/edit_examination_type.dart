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
  final _durationController = TextEditingController();

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
      _durationController.text = '${widget.cubit.examinationType?.duration ?? ''}';
      selectedClinic = widget.cubit.examinationType?.clinic;
    }

    setState(() {});
  }

  @override
  void dispose() {
    _priceController.dispose();
    _nameController.dispose();
    _durationController.dispose();

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
        ExaminationType model = ExaminationType(
          clinic: selectedClinic,
          name: _nameController.text.trim(),
          price: num.parse(_priceController.text),
          duration: num.parse(_durationController.text),
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
  Clinic? selectedClinic;
  bool _clinicValidation = true;
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
                                selectedClinic = widget.cubit.examinationType?.clinic ?? CacheHelper.getUser("user")?.clinic;
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
                        )
                      ],
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
                              readOnly: CacheHelper.getStringList(key: "capabilities").contains("manageCapabilities") ? readOnly : true,
                              prefixIcon: Icon(Icons.local_hospital_outlined, color: Colorz.grey),
                              items: widget.cubit.clinics?.clinics,
                              isValid: _clinicValidation,
                              validateText: 'Please enter a clinic',
                              selectedValue: selectedClinic?.name,
                              hintText: 'Select Clinic',
                              itemAsString: (item) => item.name.toString(),
                              onItemSelected: (item) {
                                setState(() {
                                  if (item != "Not Found") {
                                    selectedClinic = item;
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
                                if (value == null || value.trim().isEmpty) {
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
                              controller: _durationController,
                              cursorColor: Colors.black,
                              readOnly: readOnly,
                              keyboardType: TextInputType.number,
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
void editExaminationType(BuildContext context, ExaminationTypeCubit cubit, String id) {
  showDialog(
    barrierDismissible: false,
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

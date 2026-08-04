import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/core/utils/capability_services.dart';
import 'package:ocurithm/modules/Clinics/data/model/clinics_model.dart'
    as clinic_model;
import 'package:ocurithm/modules/Clinics/presentation/manager/get_clinics_cubit/get_clinics_cubit.dart';

import '../../../../../../core/Network/shared.dart';
import '../../../../../core/utils/app_style.dart';
import '../../../../../core/utils/snackbar_service.dart';
import '../../../../../core/widgets/DropdownPackage.dart';
import '../../../../../core/widgets/custom_freeze_loading.dart';
import '../../../../../core/widgets/height_spacer.dart';
import '../../../../../core/widgets/text_field.dart';
import '../../../data/model/active_ingredient_model.dart';
import '../../../data/model/medicine_model.dart';
import '../../manager/get_active_ingredients_cubit/get_active_ingredients_cubit.dart';
import '../../manager/get_medicines_cubit/get_medicines_cubit.dart';
import '../../manager/medicine_actions_cubit/medicine_actions_cubit.dart';
import 'package:ocurithm/core/utils/capability_keys.dart';

enum MedicineFormType { medicine, activeIngredient }

class MedicineBottomSheet extends StatefulWidget {
  final CommercialName? medicine;
  final ActiveIngredient? activeIngredient;
  final bool isEdit;
  final bool isDetails;
  final MedicineFormType initialType;

  const MedicineBottomSheet({
    super.key,
    this.medicine,
    this.activeIngredient,
    this.isEdit = false,
    this.isDetails = false,
    this.initialType = MedicineFormType.medicine,
  });

  @override
  State<MedicineBottomSheet> createState() => _MedicineBottomSheetState();
}

class _MedicineBottomSheetState extends State<MedicineBottomSheet> {
  late MedicineFormType _currentType;
  final _formKey = GlobalKey<FormState>();

  // Medicine Fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _concentrationController =
      TextEditingController();
  ActiveIngredient? _selectedActiveIngredient;

  // Active Ingredient Fields
  final TextEditingController _aiNameController = TextEditingController();
  clinic_model.Clinic? _selectedClinic;
  bool _clinicValidation = true;

  late MedicineFormType _visibleType;

  void _onTextChanged() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _currentType = widget.initialType;
    _visibleType = widget.initialType;
    if (widget.medicine != null) {
      _nameController.text = widget.medicine!.name ?? '';
      _descriptionController.text = widget.medicine!.description ?? '';
      _concentrationController.text = widget.medicine!.concentration ?? '';
      if (widget.medicine!.parentId != null) {
        _selectedActiveIngredient = ActiveIngredient(
          id: widget.medicine!.parentId!.id,
          name: widget.medicine!.parentId!.name,
        );
      }
      if (widget.medicine!.clinic != null) {
        _selectedClinic = clinic_model.Clinic(
          id: widget.medicine!.clinic!.id,
          name: widget.medicine!.clinic!.name,
        );
      }
    }
    if (widget.activeIngredient != null) {
      _aiNameController.text = widget.activeIngredient!.name ?? '';
      if (widget.activeIngredient!.clinic != null) {
        _selectedClinic = clinic_model.Clinic(
          id: widget.activeIngredient!.clinic!.id,
          name: widget.activeIngredient!.clinic!.name,
        );
      }
    }

    // Enforce type if in specific mode
    if (widget.medicine != null) {
      _currentType = MedicineFormType.medicine;
    } else if (widget.activeIngredient != null) {
      _currentType = MedicineFormType.activeIngredient;
    }

    _nameController.addListener(_onTextChanged);
    _concentrationController.addListener(_onTextChanged);
    _aiNameController.addListener(_onTextChanged);

    // Fetch active ingredients for the dropdown (non-paginated)
    if (_visibleType == MedicineFormType.medicine) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<GetActiveIngredientsCubit>().getActiveIngredients(
              pagination: false,
              clinic: _selectedClinic?.id,
            );
      });
    }
  }

  @override
  void dispose() {
    _nameController.removeListener(_onTextChanged);
    _concentrationController.removeListener(_onTextChanged);
    _aiNameController.removeListener(_onTextChanged);
    _nameController.dispose();
    _descriptionController.dispose();
    _concentrationController.dispose();
    _aiNameController.dispose();
    super.dispose();
  }

  bool get _hasManageCapability =>
      CapabilityServices.hasCapability(CapabilityKeys.manageCapability);

  bool _isFormValid() {
    if (_visibleType == MedicineFormType.medicine) {
      return (widget.isEdit ||
              !_hasManageCapability ||
              _selectedClinic != null) &&
          (widget.isEdit || _selectedActiveIngredient != null) &&
          _nameController.text.trim().isNotEmpty &&
          _concentrationController.text.trim().isNotEmpty;
    } else {
      return (widget.isEdit ||
              !_hasManageCapability ||
              _selectedClinic != null) &&
          _aiNameController.text.trim().isNotEmpty;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocConsumer<MedicineActionsCubit, MedicineActionsState>(
      listener: (context, state) {
        if (state.status == MedicineActionsStatus.success) {
          // Trigger refreshes before popping
          context.read<GetMedicinesCubit>().getMedicines(isRefresh: true);
          context.read<GetActiveIngredientsCubit>().getActiveIngredients(
                pagination: false,
                clinic: _selectedClinic?.id,
              );

          Navigator.pop(context); // Pop loading
          Navigator.pop(context); // Pop BottomSheet
          SnackbarService.showSuccess(context,
              message: state.successMessage ?? "Success");
        } else if (state.status == MedicineActionsStatus.error ||
            state.status == MedicineActionsStatus.noConnection) {
          Navigator.pop(context); // Pop loading
          SnackbarService.showError(context,
              message: state.errorMessage ?? "An error occurred");
        }
      },
      builder: (context, state) {
        return GestureDetector(
          onTap: () =>
              WidgetsBinding.instance.focusManager.primaryFocus!.unfocus(),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xff1f1f1f) : Colors.white,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 60,
                      height: 4,
                      decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                              color: Colors.grey, shape: BoxShape.circle),
                          child: Icon(
                            Icons.close,
                            size: 18,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),

                    // Only show toggle if NOT edit/details
                    if (!widget.isEdit && !widget.isDetails) ...[
                      _buildAnimatedToggle(isDark),
                      const HeightSpacer(size: 20),
                    ],
                    if (_visibleType == MedicineFormType.medicine)
                      _buildMedicineForm(isDark)
                    else
                      _buildActiveIngredientForm(isDark),
                    const HeightSpacer(size: 20),
                    if (!widget.isDetails) _buildSubmitButton(state, isDark),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedToggle(bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 45,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[200],
        borderRadius: BorderRadius.circular(25),
      ),
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: _currentType == MedicineFormType.medicine
                ? 0
                : MediaQuery.of(context).size.width * 0.43,
            right: _currentType == MedicineFormType.medicine
                ? MediaQuery.of(context).size.width * 0.43
                : 0,
            top: 0,
            bottom: 0,
            child: Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _currentType = MedicineFormType.medicine;
                    });

                    Future.delayed(const Duration(milliseconds: 300), () {
                      if (mounted) {
                        setState(() {
                          _visibleType = MedicineFormType.medicine;
                        });
                      }
                    });
                  },
                  child: Center(
                    child: Text(
                      "Add Medicine",
                      style: appStyle(
                          context,
                          14,
                          _currentType == MedicineFormType.medicine
                              ? Colors.white
                              : (isDark ? Colors.white : Colors.black),
                          FontWeight.w600),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(
                        () => _currentType = MedicineFormType.activeIngredient);
                    Future.delayed(const Duration(milliseconds: 300), () {
                      if (mounted) {
                        setState(() =>
                            _visibleType = MedicineFormType.activeIngredient);
                      }
                    });
                  },
                  child: Center(
                    child: Text(
                      "Add Ingredient",
                      style: appStyle(
                          context,
                          14,
                          _currentType == MedicineFormType.activeIngredient
                              ? Colors.white
                              : (isDark ? Colors.white : Colors.black),
                          FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMedicineForm(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (CapabilityServices.hasCapability('manageCapability') &&
            !widget.isEdit &&
            !widget.isDetails) ...[
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 5),
            child: Text("Clinic",
                style: appStyle(context, 14,
                    isDark ? Colors.white70 : Colors.black54, FontWeight.bold)),
          ),
          _buildClinicDropdown(isDark, onMedicineForm: true),
          const HeightSpacer(size: 15),
        ],
        if (!widget.isEdit || widget.isDetails)
          BlocBuilder<GetActiveIngredientsCubit, GetActiveIngredientsState>(
            builder: (context, state) {
              List<ActiveIngredient> items = [];
              bool isLoading = false;
              if (state.status == GetActiveIngredientsStatus.success) {
                items = state.activeIngredients;
              } else if (state.status == GetActiveIngredientsStatus.loading) {
                isLoading = true;
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, bottom: 5),
                    child: Text("Active Ingredient",
                        style: appStyle(
                            context,
                            18,
                            Theme.of(context).primaryColor == Colors.black
                                ? Colors.black
                                : Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color ??
                                    Colors.black,
                            FontWeight.bold)),
                  ),
                  DropdownItem<ActiveIngredient>(
                    radius: 10,
                    color: isDark ? const Color(0xff2C2C2C) : Colors.white,
                    border: isDark ? Colors.grey[700] : Colors.grey[400],
                    isShadow: false,
                    items: items,
                    itemAsString: (ActiveIngredient u) => u.name ?? "",
                    selectedValue: _selectedActiveIngredient?.name,
                    hintText: "Select Active Ingredient",
                    onItemSelected: (ActiveIngredient item) {
                      setState(() {
                        _selectedActiveIngredient = item;
                      });
                    },
                    isLoading: isLoading,
                    readOnly: widget.isDetails,
                    isValid: true,
                    validateText: "Required",
                  ),
                ],
              );
            },
          ),
        const HeightSpacer(size: 15),
        _buildTextField(
          controller: _nameController,
          label: "Name",
          hintText: "Enter medicine name",
          isDark: isDark,
          required: true,
        ),
        const HeightSpacer(size: 15),
        _buildTextField(
          controller: _descriptionController,
          label: "Description",
          hintText: "Enter description",
          isDark: isDark,
          maxLines: 3,
        ),
        const HeightSpacer(size: 15),
        _buildTextField(
          controller: _concentrationController,
          label: "Concentration",
          hintText: "Enter concentration",
          isDark: isDark,
          required: true,
        ),
      ],
    );
  }

  Widget _buildActiveIngredientForm(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (CapabilityServices.hasCapability('manageCapability') &&
            !widget.isEdit &&
            !widget.isDetails) ...[
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 5),
            child: Text("Clinic",
                style: appStyle(context, 14,
                    isDark ? Colors.white70 : Colors.black54, FontWeight.bold)),
          ),
          _buildClinicDropdown(isDark),
        ],
        if (CapabilityServices.hasCapability('manageCapability') &&
            !widget.isEdit &&
            !widget.isDetails)
          const HeightSpacer(size: 15),
        _buildTextField(
          controller: _aiNameController,
          label: "Name",
          hintText: "Enter ingredient name",
          isDark: isDark,
          required: true,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required bool isDark,
    bool required = false,
    int maxLines = 1,
  }) {
    return TextField2(
      controller: controller,
      text: label,
      hintText: hintText,
      required: required,
      readOnly: widget.isDetails,
      fillColor: isDark ? const Color(0xff2C2C2C) : Colors.white,
      borderColor: isDark ? Colors.grey[700] : Colors.grey[400],
      border: isDark ? Colors.grey[700] : Colors.grey[400],
      isShadow: false,
      radius: 10,
      maxLines: maxLines,
    );
  }

  Widget _buildSubmitButton(MedicineActionsState state, bool isDark) {
    bool isLoading = state.status == MedicineActionsStatus.loading;
    String text = widget.isEdit ? "Update" : "Add";

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: (isLoading || !_isFormValid()) ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
            : Text(text,
                style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      customLoading(context, widget.isEdit ? "Updating..." : "Adding...");
      if (_currentType == MedicineFormType.medicine) {
        if (!widget.isEdit && _selectedActiveIngredient == null) {
          Navigator.pop(context);
          SnackbarService.showWarning(context,
              message: "Please select an Active Ingredient");
          return;
        }

        bool needsClinic = CacheHelper.getStringList(key: "capabilities")
            .contains(CapabilityKeys.manageCapability);
        if (!widget.isEdit && needsClinic && _selectedClinic == null) {
          Navigator.pop(context);
          setState(() {
            _clinicValidation = false;
          });
          return;
        }

        final medicine = CommercialName(
          name: _nameController.text,
          description: _descriptionController.text,
          concentration: _concentrationController.text,
          parentId: _selectedActiveIngredient != null
              ? ParentId(
                  id: _selectedActiveIngredient!.id,
                  name: _selectedActiveIngredient!.name,
                  isActiveIngredient: true,
                  isCommercialName: false,
                )
              : null,
          deletedAt: null,
          deletedBy: null,
          clinic: _selectedClinic,
          isActive: true,
          createdAt: null,
          updatedAt: null,
          isActiveIngredient: false,
          isCommercialName: true,
          id: null,
          createdBy: null,
          updatedBy: null,
        );

        if (widget.isEdit && widget.medicine != null) {
          context.read<MedicineActionsCubit>().updateMedicine(
              widget.medicine!.id!,
              CommercialName(
                name: _nameController.text,
                description: _descriptionController.text,
                concentration: _concentrationController.text,
              ));
        } else {
          context.read<MedicineActionsCubit>().createMedicine(medicine);
        }
      } else {
        bool needsClinic = CacheHelper.getStringList(key: "capabilities")
            .contains(CapabilityKeys.manageCapability);

        if (!widget.isEdit && needsClinic && _selectedClinic == null) {
          Navigator.pop(context);
          setState(() {
            _clinicValidation = false;
          });
          return;
        }

        final activeIngredient = ActiveIngredient(
          name: _aiNameController.text,
          clinic: _selectedClinic != null
              ? clinic_model.Clinic(
                  id: _selectedClinic!.id, name: _selectedClinic!.name)
              : null,
        );

        if (widget.isEdit && widget.activeIngredient != null) {
          context.read<MedicineActionsCubit>().updateActiveIngredient(
              widget.activeIngredient!.id!,
              ActiveIngredient(
                name: _aiNameController.text,
              ));
        } else {
          context
              .read<MedicineActionsCubit>()
              .createActiveIngredient(activeIngredient);
        }
      }
    }
  }

  Widget _buildClinicDropdown(bool isDark, {bool onMedicineForm = false}) {
    return BlocConsumer<GetClinicsCubit, GetClinicsState>(
      listener: (context, clinicsState) {
        // Optional: Pre-select if only one clinic or something?
      },
      builder: (context, clinicsState) {
        return DropdownItem<clinic_model.Clinic>(
          radius: 10,
          border: isDark ? Colors.grey[700] : Colors.grey[400],
          color: isDark ? const Color(0xff2C2C2C) : Colors.white,
          isShadow: false,
          items: clinicsState.clinics?.clinics ?? [],
          isValid: _clinicValidation,
          validateText: 'Please choose a clinic',
          selectedValue: _selectedClinic?.name,
          hintText: 'Select Clinic',
          itemAsString: (clinic_model.Clinic item) => item.name.toString(),
          onItemSelected: (clinic_model.Clinic item) {
            setState(() {
              _selectedClinic = item;
              _clinicValidation = true;
              // If on Medicine Form, fetch Active Ingredients for this clinic
              if (onMedicineForm) {
                _selectedActiveIngredient = null; // Reset selection
                context.read<GetActiveIngredientsCubit>().getActiveIngredients(
                      pagination: false,
                      clinic: item.id,
                    );
              }
            });
          },
          isLoading: clinicsState.isLoading,
        );
      },
    );
  }
}

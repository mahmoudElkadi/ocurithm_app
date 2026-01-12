import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/utils/app_style.dart';
import '../../../../../core/widgets/DropdownPackage.dart';
import '../../../../../core/widgets/text_field.dart';
import '../../../../../core/widgets/height_spacer.dart';
import '../../../data/model/active_ingredient_model.dart';
import '../../../data/model/medicine_model.dart';
import '../../manager/get_active_ingredients_cubit/get_active_ingredients_cubit.dart';
import '../../manager/medicine_actions_cubit/medicine_actions_cubit.dart';

enum MedicineFormType { medicine, activeIngredient }

class MedicineBottomSheet extends StatefulWidget {
  final Medicine? medicine;
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

  late MedicineFormType _visibleType;

  @override
  void initState() {
    super.initState();
    _currentType = widget.initialType;
    _visibleType = widget.initialType;
    if (widget.medicine != null) {
      _nameController.text = widget.medicine!.name ?? '';
      _descriptionController.text = widget.medicine!.description ?? '';
      _concentrationController.text = widget.medicine!.concentration ?? '';
      _selectedActiveIngredient = widget.medicine!.activeIngredient;
    }
    if (widget.activeIngredient != null) {
      _aiNameController.text = widget.activeIngredient!.name ?? '';
    }

    // Enforce type if in specific mode
    if (widget.medicine != null) {
      _currentType = MedicineFormType.medicine;
    } else if (widget.activeIngredient != null) {
      _currentType = MedicineFormType.activeIngredient;
    }

    // Fetch active ingredients for dropdown if needed
    if (_currentType == MedicineFormType.medicine) {
      context.read<GetActiveIngredientsCubit>().getActiveIngredients();
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocConsumer<MedicineActionsCubit, MedicineActionsState>(
      listener: (context, state) {
        if (state is MedicineActionsSuccess) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is MedicineActionsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xff1f1f1f) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
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
                      borderRadius: BorderRadius.circular(8)
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight ,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Container(
                        padding:  EdgeInsets.all(4) ,
                        decoration: BoxDecoration(
                            color: Colors.grey,
                            shape: BoxShape.circle
                        ),
                        child: Icon(
                          Icons.close,
                          size: 18,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                  Stack(
                    children: [
                      // Only show toggle and padding if NOT edit/details
                      if (!widget.isEdit && !widget.isDetails)
                        _buildAnimatedToggle(isDark),
                      // If it IS edit/details, we might need some top padding to avoid close button overlapping content,
                      // or just the close button row.
                      if (widget.isEdit || widget.isDetails)
                        const SizedBox(
                            height: 40,
                            width: double
                                .infinity), // Spacer for title/close button area
                    ],
                  ),
                  const HeightSpacer(size: 20),
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
                        context
                            .read<GetActiveIngredientsCubit>()
                            .getActiveIngredients();
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
      children: [
        BlocBuilder<GetActiveIngredientsCubit, GetActiveIngredientsState>(
          builder: (context, state) {
            List<ActiveIngredient> items = [];
            bool isLoading = false;
            if (state is GetActiveIngredientsLoaded) {
              items = state.activeIngredients;
            } else if (state is GetActiveIngredientsLoading) {
              isLoading = true;
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!widget.isDetails)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, bottom: 5),
                    child: Text("Active Ingredient",
                        style: appStyle(
                            context,
                            14,
                            isDark ? Colors.white70 : Colors.black54,
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
        ),
      ],
    );
  }

  Widget _buildActiveIngredientForm(bool isDark) {
    return Column(
      children: [
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
    bool isLoading = state is MedicineActionsLoading;
    String text = widget.isEdit ? "Update" : "Add";

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : _submit,
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
      if (_currentType == MedicineFormType.medicine) {
        if (_selectedActiveIngredient == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please select an Active Ingredient")),
          );
          return;
        }

        final medicine = Medicine(
          name: _nameController.text,
          description: _descriptionController.text,
          concentration: _concentrationController.text,
          parentId: _selectedActiveIngredient?.id,
        );

        if (widget.isEdit && widget.medicine != null) {
          context
              .read<MedicineActionsCubit>()
              .updateMedicine(widget.medicine!.id!, medicine);
        } else {
          context.read<MedicineActionsCubit>().createMedicine(medicine);
        }
      } else {
        final activeIngredient = ActiveIngredient(
          name: _aiNameController.text,
        );

        if (widget.isEdit && widget.activeIngredient != null) {
          context.read<MedicineActionsCubit>().updateActiveIngredient(
              widget.activeIngredient!.id!, activeIngredient);
        } else {
          context
              .read<MedicineActionsCubit>()
              .createActiveIngredient(activeIngredient);
        }
      }
    }
  }
}

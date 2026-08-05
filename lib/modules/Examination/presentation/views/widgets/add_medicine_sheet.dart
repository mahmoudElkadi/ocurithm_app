import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/colors.dart';
import '../../../../../core/utils/services_locator.dart';
import '../../../../Medicine/data/model/active_ingredient_model.dart';
import '../../../../Medicine/data/model/medicine_model.dart';
import '../../../../Medicine/data/repos/medicine_repo.dart';
import '../../../../Medicine/presentation/manager/get_active_ingredients_cubit/get_active_ingredients_cubit.dart';

/// Adds a medicine to the catalog from inside the prescription step.
///
/// Doctors prescribe commercial names, never active ingredients, so a new name
/// always has to be filed under an ingredient. The flow is: type a name that is
/// not in the catalog → Add → choose an ingredient (or create one) → the new
/// commercial name is created under it and returned ready to prescribe.
///
/// Returns the created [CommercialName], or null if the doctor backed out.
Future<CommercialName?> showAddMedicineSheet(
  BuildContext context, {
  required String initialName,
}) {
  return showModalBottomSheet<CommercialName>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider(
      create: (_) =>
          GetActiveIngredientsCubit(medicineRepo: sl.call<MedicineRepo>())
            ..getActiveIngredients(pagination: false),
      child: _AddMedicineSheet(initialName: initialName),
    ),
  );
}

class _AddMedicineSheet extends StatefulWidget {
  const _AddMedicineSheet({required this.initialName});

  final String initialName;

  @override
  State<_AddMedicineSheet> createState() => _AddMedicineSheetState();
}

class _AddMedicineSheetState extends State<_AddMedicineSheet> {
  late final TextEditingController _nameController =
      TextEditingController(text: widget.initialName);
  final TextEditingController _concentrationController =
      TextEditingController();
  final TextEditingController _newIngredientController =
      TextEditingController();

  ActiveIngredient? _selectedIngredient;
  bool _isCreatingIngredient = false;
  bool _isSubmitting = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _concentrationController.dispose();
    _newIngredientController.dispose();
    super.dispose();
  }

  bool get _canSubmit {
    if (_isSubmitting) return false;
    if (_nameController.text.trim().isEmpty) return false;
    if (_concentrationController.text.trim().isEmpty) return false;
    return _isCreatingIngredient
        ? _newIngredientController.text.trim().isNotEmpty
        : _selectedIngredient != null;
  }

  Future<void> _submit() async {
    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    final repo = sl.call<MedicineRepo>();

    try {
      var ingredient = _selectedIngredient;

      // A brand-new ingredient has to exist before the commercial name can point
      // at it; the server derives the clinic from the caller in both cases.
      if (_isCreatingIngredient) {
        ingredient = await repo.createActiveIngredient(
          activeIngredient: ActiveIngredient(
            name: _newIngredientController.text.trim(),
            isActive: true,
          ),
        );
      }

      if (ingredient?.id == null) {
        throw Exception('Could not resolve the active ingredient');
      }

      final created = await repo.createMedicine(
        commercialName: CommercialName(
          name: _nameController.text.trim(),
          concentration: _concentrationController.text.trim(),
          parentId: ParentId(
            id: ingredient!.id,
            name: ingredient.name,
            isActiveIngredient: true,
            isCommercialName: false,
          ),
          isActive: true,
          isActiveIngredient: false,
          isCommercialName: true,
        ),
      );

      if (!mounted) return;
      Navigator.of(context).pop(created);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Add Medicine to Catalog',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'The medicine is saved as a commercial name under the active '
                'ingredient you choose.',
                style: TextStyle(fontSize: 13, color: theme.hintColor),
              ),
              const SizedBox(height: 20),
              _label('Commercial Name'),
              TextField(
                controller: _nameController,
                decoration: _decoration('e.g. Ciloxan'),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              _label('Concentration'),
              TextField(
                controller: _concentrationController,
                decoration: _decoration('e.g. 0.3% / 5 mg/ml'),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _label('Active Ingredient'),
                  TextButton(
                    onPressed: _isSubmitting
                        ? null
                        : () => setState(() {
                              _isCreatingIngredient = !_isCreatingIngredient;
                            }),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 28),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      _isCreatingIngredient ? 'Choose existing' : '+ New',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colorz.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              if (_isCreatingIngredient)
                TextField(
                  controller: _newIngredientController,
                  decoration: _decoration('e.g. Ciprofloxacin'),
                  onChanged: (_) => setState(() {}),
                )
              else
                _buildIngredientPicker(theme),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: TextStyle(fontSize: 13, color: theme.colorScheme.error),
                ),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSubmitting
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _canSubmit ? _submit : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colorz.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Add'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIngredientPicker(ThemeData theme) {
    return BlocBuilder<GetActiveIngredientsCubit, GetActiveIngredientsState>(
      builder: (context, state) {
        if (state.status == GetActiveIngredientsStatus.loading) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: LinearProgressIndicator(),
          );
        }

        final ingredients = state.activeIngredients;
        if (ingredients.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'No active ingredients yet — use "+ New" to create one.',
              style: TextStyle(fontSize: 13, color: theme.hintColor),
            ),
          );
        }

        return DropdownButtonFormField<ActiveIngredient>(
          initialValue: _selectedIngredient,
          isExpanded: true,
          decoration: _decoration('Select active ingredient'),
          items: ingredients
              .map(
                (ingredient) => DropdownMenuItem<ActiveIngredient>(
                  value: ingredient,
                  child: Text(
                    ingredient.name ?? '-',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: _isSubmitting
              ? null
              : (value) => setState(() => _selectedIngredient = value),
        );
      },
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      );

  InputDecoration _decoration(String hint) => InputDecoration(
        hintText: hint,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colorz.primaryColor),
        ),
      );
}

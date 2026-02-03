import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/widgets/height_spacer.dart';
import '../../../../../core/widgets/search_fileld.dart';
import '../../manager/get_examination_types_cubit/get_examination_types_cubit.dart';
import 'examination_type_card.dart';

/// Examination Type View Body - Contains search field and examination type list
/// Uses GetExaminationTypesCubit for fetching and searching examination types
class ExaminationTypeViewBody extends StatefulWidget {
  const ExaminationTypeViewBody({super.key});

  @override
  State<ExaminationTypeViewBody> createState() =>
      _ExaminationTypeViewBodyState();
}

class _ExaminationTypeViewBodyState extends State<ExaminationTypeViewBody> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetExaminationTypesCubit, GetExaminationTypesState>(
      builder: (context, state) {
        // If no connection, show only the no-internet widget centered
        if (state.noConnection) {
          return const ExaminationTypeListView();
        }

        // Otherwise show search field and list
        return Column(
          children: [
            _buildSearchField(),
            const HeightSpacer(size: 10),
            const ExaminationTypeListView(),
          ],
        );
      },
    );
  }

  Widget _buildSearchField() {
    final cubit = context.read<GetExaminationTypesCubit>();

    return SearchField(
      searchController: _searchController,
      onTextFieldChanged: () async {
        // Use debounced search from cubit
        cubit.onSearchChanged(_searchController.text);
      },
      onClose: () async {
        _searchController.clear();
        cubit.onSearchChanged('');
      },
    );
  }
}

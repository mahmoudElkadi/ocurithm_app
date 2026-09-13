import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/core/widgets/no_internet.dart';

import '../../../../../core/widgets/height_spacer.dart';
import '../../../../../core/widgets/search_fileld.dart';
import '../../manager/get_save_reasons_cubit/get_save_reasons_cubit.dart';
import 'save_reason_card.dart';

/// Search field plus the save-reason list.
class SaveReasonViewBody extends StatefulWidget {
  const SaveReasonViewBody({super.key});

  @override
  State<SaveReasonViewBody> createState() => _SaveReasonViewBodyState();
}

class _SaveReasonViewBodyState extends State<SaveReasonViewBody> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetSaveReasonsCubit, GetSaveReasonsState>(
      builder: (context, state) {
        if (state.noConnection) {
          return NoInternet(
            onPressed: () => context
                .read<GetSaveReasonsCubit>()
                .add(const GetAllSaveReasonsEvent()),
          );
        }

        return Column(
          children: [
            _buildSearchField(),
            const HeightSpacer(size: 10),
            const SaveReasonListView(),
          ],
        );
      },
    );
  }

  Widget _buildSearchField() {
    final cubit = context.read<GetSaveReasonsCubit>();

    return SearchField(
      searchController: _searchController,
      onTextFieldChanged: () async {
        cubit.onSearchChanged(_searchController.text);
      },
      onClose: () {
        _searchController.clear();
        cubit.onSearchChanged('');
      },
    );
  }
}

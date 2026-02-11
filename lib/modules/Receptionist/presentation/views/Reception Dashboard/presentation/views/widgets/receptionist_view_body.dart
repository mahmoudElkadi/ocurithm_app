import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/modules/Receptionist/presentation/views/Reception%20Dashboard/presentation/views/widgets/receptionist_card.dart';
import 'package:ocurithm/core/widgets/height_spacer.dart';
import 'package:ocurithm/core/widgets/search_fileld.dart';
import 'package:ocurithm/modules/Receptionist/presentation/manager/get_receptionists_cubit/get_receptionists_cubit.dart';

class ReceptionistViewBody extends StatefulWidget {
  const ReceptionistViewBody({super.key});

  @override
  State<ReceptionistViewBody> createState() => _ReceptionistViewBodyState();
}

class _ReceptionistViewBodyState extends State<ReceptionistViewBody> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GetReceptionistsCubit, GetReceptionistsState>(
      listenWhen: (previous, current) => previous.search != current.search,
      listener: (context, state) {
        if (state.search == '' || state.search == null) {
          _searchController.text = '';
        } else if (_searchController.text != state.search) {
          _searchController.text = state.search!;
        }
      },
      child: BlocBuilder<GetReceptionistsCubit, GetReceptionistsState>(
        builder: (context, state) => Column(
          children: [
            _buildSearchField(context),
            const HeightSpacer(size: 10),
            const ReceptionistListView(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return SearchField(
      onTextFieldChanged: ()async {
        // Use debounced search from cubit
        context.read<GetReceptionistsCubit>().onSearchChanged(
              _searchController.text,
            );
      },
      searchController: _searchController,
      onClose: () {
        _searchController.clear();
        context.read<GetReceptionistsCubit>().add(
              SetSearchEvent(''),
            );
        context.read<GetReceptionistsCubit>().add(
              GetAllReceptionistsEvent(),
            );
      },
    );
  }
}

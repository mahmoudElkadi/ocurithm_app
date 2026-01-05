import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
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
    return BlocBuilder<GetReceptionistsCubit, GetReceptionistsState>(
      builder: (context, state) => Column(
        children: [
          _buildSearchField(context),
          const HeightSpacer(size: 10),
          Expanded(
            child: CustomMaterialIndicator(
              onRefresh: () async {
                try {
                  _searchController.clear();
                  context.read<GetReceptionistsCubit>().add(
                        ResetReceptionistFilters(),
                      );
                } catch (e) {
                  // Handle error
                }
              },
              indicatorBuilder:
                  (BuildContext context, IndicatorController controller) {
                return const Image(image: AssetImage("assets/icons/logo.png"));
              },
              child: const ReceptionistListView(),
            ),
          ),
        ],
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

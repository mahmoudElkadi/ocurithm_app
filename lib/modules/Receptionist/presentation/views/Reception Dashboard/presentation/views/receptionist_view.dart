import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ocurithm/core/widgets/manage_capabilities.dart';
import 'package:ocurithm/core/widgets/no_internet.dart';
import 'package:ocurithm/core/widgets/scaffold_style.dart';
import 'package:ocurithm/modules/Receptionist/presentation/views/Reception%20Dashboard/presentation/views/widgets/receptionist_view_body.dart';
import 'package:ocurithm/core/Network/shared.dart';
import 'package:ocurithm/core/utils/services_locator.dart';
import 'package:ocurithm/modules/Receptionist/presentation/manager/get_receptionists_cubit/get_receptionists_cubit.dart';
import 'package:ocurithm/modules/Receptionist/presentation/manager/receptionist_actions_cubit/receptionist_actions_cubit.dart';
import 'package:ocurithm/modules/Receptionist/presentation/views/receptionist_form/receptionist_form_page.dart';

class ReceptionistView extends StatelessWidget {
  const ReceptionistView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              sl<GetReceptionistsCubit>()..add(GetAllReceptionistsEvent()),
        ),
        BlocProvider(
          create: (context) => sl<ReceptionistActionsCubit>(),
        ),
      ],
      child: BlocConsumer<GetReceptionistsCubit, GetReceptionistsState>(
        listener: (context, state) {
          // Handle any state changes if needed
        },
        builder: (BuildContext context, GetReceptionistsState state) {
          return CustomScaffold(
            title: "Receptionists",
            actions: [
                manageCapability(
                  capability: "manageReciptionists",
                  child: IconButton(
                    onPressed: () async {
                      // Navigate to add receptionist form
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ReceptionistFormPage(
                            mode: ReceptionistFormMode.add,
                          ),
                        ),
                      );

                      // Refresh list if receptionist was added
                      if (result == true) {
                        context.read<GetReceptionistsCubit>().add(
                              GetAllReceptionistsEvent(),
                            );
                      }
                    },
                    icon: SvgPicture.asset(
                      "assets/icons/add_user.svg",
                      color: theme.primaryColor,
                    ),
                  ),
                ),
            ],
            body: state.noConnection
                ? NoInternet(
                    onPressed: () {
                      context.read<GetReceptionistsCubit>().add(
                            GetAllReceptionistsEvent(),
                          );
                    },
                  )
                : const ReceptionistViewBody(),
          );
        },
      ),
    );
  }
}

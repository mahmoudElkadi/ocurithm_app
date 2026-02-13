import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ocurithm/core/utils/services_locator.dart';
import 'package:ocurithm/core/widgets/DropdownPackage.dart';
import 'package:ocurithm/core/widgets/pagination.dart';
import 'package:ocurithm/modules/Doctor/presentation/manager/get_doctor_examinations_cubit/get_doctor_examinations_cubit.dart'
    as doc_bloc;
import 'package:ocurithm/modules/Patient/data/model/patient_examination.dart';
import 'package:ocurithm/modules/Patient/data/model/patients_model.dart';
import 'package:ocurithm/modules/Patient/presentation/manager/get_patients_cubit/get_patients_cubit.dart';
import 'package:ocurithm/modules/Patient/presentation/views/examination_view/one_examination_view.dart';

class DoctorExaminationsSection extends StatelessWidget {
  const DoctorExaminationsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<doc_bloc.GetDoctorExaminationsBloc,
        doc_bloc.GetDoctorExaminationsState>(
      builder: (context, state) {
        final theme = Theme.of(context);
        final list = state.examinations?.examinations ?? [];
        final totalCount = state.examinations?.total ?? 0;
        final totalPages = state.examinations?.totalPages ?? 1;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text("Doctor Examinations",
                        style: theme.textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 12),
                    if (state.status ==
                        doc_bloc.GetDoctorExaminationsStatus.loading)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: theme.primaryColor, shape: BoxShape.circle),
                        child: Text('$totalCount',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12)),
                      ),
                  ],
                ),
                GestureDetector(
                  onTap:() => _showFilterSheet(context) ,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      border: Border.all(color: theme.dividerColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(child: Icon(Icons.tune)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (state.status == doc_bloc.GetDoctorExaminationsStatus.loading &&
                list.isEmpty)
              const Center(child: CircularProgressIndicator())
            else if (list.isEmpty)
              Center(
                  child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                    "No examinations found checking filters or adding new one",
                    style: theme.textTheme.bodyLarge),
              ))
            else ...[
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  return _ExaminationCard(exam: list[index]);
                },
              ),
              if (totalPages > 1) ...[
                const SizedBox(height: 20),
                CustomPagination(
                  currentPage: state.page,
                  totalPages: totalPages is int
                      ? totalPages
                      : int.tryParse(totalPages.toString()) ?? 1,
                  onPageChanged: (page) {
                    context
                        .read<doc_bloc.GetDoctorExaminationsBloc>()
                        .add(doc_bloc.SetPageEvent(page));
                  },
                ),
              ],
            ],
          ],
        );
      },
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return BlocProvider.value(
          value: context.read<doc_bloc.GetDoctorExaminationsBloc>(),
          child: BlocProvider(
            create: (_) => sl<GetPatientsCubit>(),
            child: const _FilterSheetContent(),
          ),
        );
      },
    );
  }
}

class _FilterSheetContent extends StatefulWidget {
  const _FilterSheetContent();

  @override
  State<_FilterSheetContent> createState() => _FilterSheetContentState();
}

class _FilterSheetContentState extends State<_FilterSheetContent> {
  DateTime? _startDate;
  DateTime? _endDate;
  Patient? _selectedPatient;
  late TextEditingController _dateController;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<doc_bloc.GetDoctorExaminationsBloc>();
    if (bloc.state.startDateFilter != null) {
      _startDate = DateTime.tryParse(bloc.state.startDateFilter!);
    }
    if (bloc.state.endDateFilter != null) {
      _endDate = DateTime.tryParse(bloc.state.endDateFilter!);
    }
    // Load selected patient from bloc state
    if (bloc.state.patientIdFilter != null) {
      final patientsCubit = context.read<GetPatientsCubit>();
      final patients = patientsCubit.state.patients?.patients ?? [];
      _selectedPatient = patients.firstWhere(
        (p) => p.id == bloc.state.patientIdFilter,
        orElse: () => patients.first,
      );
    }
    _dateController = TextEditingController(
      text: _formatDateRange(_startDate, _endDate),
    );
  }

  String _formatDateRange(DateTime? start, DateTime? end) {
    if (start == null && end == null) return '';
    if (start != null && end == null)
      return DateFormat('yyyy-MM-dd').format(start);
    if (start != null && end != null) {
      return '${DateFormat('yyyy-MM-dd').format(start)} - ${DateFormat('yyyy-MM-dd').format(end)}';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Filter Examinations",
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text("Date Range", style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          TextField(
            controller: _dateController,
            readOnly: true,
            decoration: InputDecoration(
              hintText: "Select Date Range",
              prefixIcon: const Icon(Icons.calendar_today),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onTap: () async {
              final result = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
                initialDateRange: _startDate != null && _endDate != null
                    ? DateTimeRange(start: _startDate!, end: _endDate!)
                    : null,
              );
              if (result != null) {
                setState(() {
                  _startDate = result.start;
                  _endDate = result.end;
                  _dateController.text = _formatDateRange(_startDate, _endDate);
                });
              }
            },
          ),
          const SizedBox(height: 20),
          Text("Patient", style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          BlocBuilder<GetPatientsCubit, GetPatientsState>(
            builder: (context, state) {
              return DropdownItem<Patient>(
                radius: 10,
                hintText: "Select Patient",
                items: state.patients?.patients ?? [],
                itemAsString: (u) => u.name ?? '',
                onItemSelected: (p) => setState(() => _selectedPatient = p),
                isLoading: state.state == GetPatientsStatus.loading,
                onChanged: (val) {
                  context.read<GetPatientsCubit>().onSearchChanged(val);
                },
                selectedValue: _selectedPatient?.name,
              );
            },
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // Clear local state variables
                    setState(() {
                      _startDate = null;
                      _endDate = null;
                      _selectedPatient = null;
                      _dateController.text = '';
                    });
                    // Reset filters in the bloc
                    context
                        .read<doc_bloc.GetDoctorExaminationsBloc>()
                        .add(doc_bloc.ResetFiltersEvent());
                    Navigator.pop(context);
                  },
                  child: const Text("Reset"),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    context
                        .read<doc_bloc.GetDoctorExaminationsBloc>()
                        .add(doc_bloc.SetFiltersEvent(
                          patientId: _selectedPatient?.id,
                          startDate: _startDate != null
                              ? DateFormat('yyyy-MM-dd').format(_startDate!)
                              : null,
                          endDate: _endDate != null
                              ? DateFormat('yyyy-MM-dd').format(_endDate!)
                              : null,
                        ));
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Apply Filter"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExaminationCard extends StatelessWidget {
  final Examination exam;

  const _ExaminationCard({required this.exam});

  String _formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) return 'N/A';
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      return DateFormat('MMM dd, yyyy • hh:mm a').format(dateTime);
    } catch (_) {
      return dateTimeStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.primaryColor.withValues(alpha: 0.3)),
      ),
      child: InkWell(
        onTap: () {
          if (exam.id != null) {
            Get.to(() => OneExaminationView(id: exam.id!));
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.visibility_outlined,
                    color: theme.primaryColor, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(exam.type?.name ?? 'N/A',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(_formatDateTime(exam.createdAt?.toString()),
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: Colors.grey)),
                    if (exam.patient != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.person,
                              size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(exam.patient?.name ?? 'Unknown Patient',
                              style: theme.textTheme.bodySmall
                                  ?.copyWith(color: Colors.grey)),
                        ],
                      )
                    ]
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

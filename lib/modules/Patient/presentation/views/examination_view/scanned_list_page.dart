import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ocurithm/core/utils/colors.dart';
import 'package:ocurithm/core/utils/services_locator.dart';
import 'package:ocurithm/core/widgets/DropdownPackage.dart';
import 'package:ocurithm/core/widgets/pagination.dart';
import 'package:ocurithm/core/widgets/custom_date_picker.dart';
import 'package:ocurithm/modules/Doctor/data/model/doctor_model.dart';
import 'package:ocurithm/modules/Doctor/presentation/manager/get_doctors_cubit/get_doctors_cubit.dart';
import 'package:ocurithm/core/utils/snackbar_service.dart';
import 'package:ocurithm/core/widgets/custom_freeze_loading.dart';
import 'package:ocurithm/core/widgets/confirmation_popuo.dart';
import 'package:ocurithm/modules/Patient/data/model/scan_records_model.dart';
import 'package:ocurithm/modules/Patient/presentation/manager/get_patient_scans_cubit/get_patient_scans_cubit.dart';
import 'package:ocurithm/modules/Patient/presentation/manager/scan_actions_cubit/scan_actions_cubit.dart';
import 'package:ocurithm/modules/Patient/presentation/views/examination_view/scan_details_page.dart';
import 'package:ocurithm/core/widgets/dicom_image_widget.dart';
import 'package:ocurithm/core/widgets/fullscreen_image_viewer.dart';
import 'package:ocurithm/core/widgets/real_dicom_viewer.dart';

class ScannedListPage extends StatefulWidget {
  final String patientId;
  final String? patientName;

  const ScannedListPage({
    super.key,
    required this.patientId,
    this.patientName,
  });

  @override
  State<ScannedListPage> createState() => _ScannedListPageState();
}

class _ScannedListPageState extends State<ScannedListPage> {
  Doctor? _selectedDoctor;
  DateTime? _fromDate;
  DateTime? _toDate;
  bool _showFilters = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => sl<GetPatientScansCubit>()
            ..add(FetchPatientScansEvent(patientId: widget.patientId)),
        ),
        BlocProvider(
          create: (context) => sl<GetDoctorsCubit>()..add(GetAllDoctorsEvent()),
        ),
        BlocProvider(create: (context) => sl<ScanActionsCubit>()),
      ],
      child: Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FE),
        appBar: _buildAppBar(isDark),
        body: BlocListener<ScanActionsCubit, ScanActionsState>(
          listener: (context, state) {
            if (state.state == ScanActionsStatus.loading) {
              customLoading(context, "Deleting Scan...");
            } else if (state.state == ScanActionsStatus.success) {
              Navigator.of(context, rootNavigator: true).pop();
              context.read<GetPatientScansCubit>().add(
                    FetchPatientScansEvent(
                        patientId: widget.patientId, page: 1),
                  );
              SnackbarService.showSuccess(context,
                  message: state.successMessage ?? "Scan deleted");
            } else if (state.state == ScanActionsStatus.error) {
              Navigator.of(context, rootNavigator: true).pop();
              SnackbarService.showError(context,
                  message: state.errorMessage ?? "Delete failed");
            }
          },
          child: Builder(builder: (context) {
            return Column(
              children: [
                _buildFilterSection(context, isDark),
                Expanded(
                  child:
                      BlocBuilder<GetPatientScansCubit, GetPatientScansState>(
                    builder: (context, state) {
                      if (state.state == GetPatientScansStatus.loading) {
                        return _buildShimmerList(isDark);
                      }

                      if (state.state == GetPatientScansStatus.error) {
                        return _buildErrorState(
                            context, state.errorMessage, isDark);
                      }

                      if (state.state == GetPatientScansStatus.noConnection) {
                        return _buildNoConnectionState(context, isDark);
                      }

                      final scans = state.scanRecords?.scans ?? [];

                      if (scans.isEmpty) {
                        return _buildEmptyState(isDark);
                      }

                      return Column(
                        children: [
                          Expanded(
                            child: RefreshIndicator(
                              onRefresh: () async {
                                context.read<GetPatientScansCubit>().add(
                                      FetchPatientScansEvent(
                                        patientId: widget.patientId,
                                        page: 1,
                                      ),
                                    );
                              },
                              child: ListView.builder(
                                controller: _scrollController,
                                padding: const EdgeInsets.all(16),
                                physics: const BouncingScrollPhysics(),
                                itemCount: scans.length,
                                itemBuilder: (context, index) {
                                  return _buildScanCard(
                                      context, scans[index], isDark);
                                },
                              ),
                            ),
                          ),
                          if ((state.scanRecords?.totalPages ?? 1) > 1)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: CustomPagination(
                                currentPage: state.currentPage,
                                totalPages: state.scanRecords?.totalPages ?? 1,
                                onPageChanged: (page) {
                                  context.read<GetPatientScansCubit>().add(
                                        FetchPatientScansEvent(
                                          patientId: widget.patientId,
                                          page: page,
                                        ),
                                      );
                                },
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Scan Records",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          if (widget.patientName != null)
            Text(
              widget.patientName!,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
        ],
      ),
      centerTitle: false,
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: isDark ? Colors.white : Colors.black87,
      actions: [
        IconButton(
          icon: Icon(
            _showFilters ? Icons.filter_alt : Icons.filter_alt_outlined,
            color: _showFilters ? Colorz.primaryColor : null,
          ),
          onPressed: () {
            setState(() {
              _showFilters = !_showFilters;
            });
            if (_showFilters && _scrollController.hasClients) {
              _scrollController.animateTo(
                0.0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          },
          tooltip: "Toggle Filters",
        ),
      ],
    );
  }

  Widget _buildFilterSection(BuildContext context, bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _showFilters ? null : 0,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: _showFilters ? 1.0 : 0.0,
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.filter_list,
                        color: Colorz.primaryColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      "Filter Scans",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedDoctor = null;
                          _fromDate = null;
                          _toDate = null;
                        });
                        context.read<GetPatientScansCubit>().add(
                              ResetFiltersEvent(patientId: widget.patientId),
                            );
                      },
                      child: Text(
                        "Clear",
                        style: TextStyle(color: Colorz.primaryColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Doctor Filter
                BlocBuilder<GetDoctorsCubit, GetDoctorsState>(
                  builder: (context, state) {
                    final doctors = state.doctors?.doctors ?? [];
                    return DropdownItem<Doctor>(
                      hintText: "Filter by Doctor",
                      items: doctors,
                      isLoading: state.state == GetDoctorsStatus.loading,
                      itemAsString: (doctor) => doctor.name ?? "",
                      selectedValue: _selectedDoctor?.name,
                      onItemSelected: (doctor) {
                        setState(() {
                          _selectedDoctor = doctor;
                        });
                      },
                      prefixIcon: Icon(Icons.person_outline,
                          color: Colorz.primaryColor),
                      isShadow: false,
                      color: isDark ? Colors.grey[850] : Colors.grey[50],
                    );
                  },
                ),
                const SizedBox(height: 16),
                // Date Range
                Row(
                  children: [
                    Expanded(
                      child: _buildDateField(
                        context: context,
                        label: "From Date",
                        date: _fromDate,
                        isDark: isDark,
                        onTap: () async {
                          final picked = await CustomDatePicker.show(
                            context: context,
                            initialDate: _fromDate ?? DateTime.now(),
                          );
                          if (picked != null) {
                            setState(() {
                              _fromDate = picked;
                            });
                          }
                        },
                        onClear: () {
                          setState(() {
                            _fromDate = null;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDateField(
                        context: context,
                        label: "To Date",
                        date: _toDate,
                        isDark: isDark,
                        onTap: () async {
                          final picked = await CustomDatePicker.show(
                            context: context,
                            initialDate: _toDate ?? DateTime.now(),
                          );
                          if (picked != null) {
                            setState(() {
                              _toDate = picked;
                            });
                          }
                        },
                        onClear: () {
                          setState(() {
                            _toDate = null;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Apply Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<GetPatientScansCubit>().add(
                            FetchPatientScansEvent(
                              patientId: widget.patientId,
                              page: 1,
                              doctorId: _selectedDoctor?.id,
                              fromDate:
                                  _fromDate?.toIso8601String().split('T').first,
                              toDate:
                                  _toDate?.toIso8601String().split('T').first,
                            ),
                          );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colorz.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      "Apply Filters",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateField({
    required BuildContext context,
    required String label,
    required DateTime? date,
    required bool isDark,
    required VoidCallback onTap,
    required VoidCallback onClear,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[850] : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, size: 18, color: Colorz.primaryColor),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                date != null ? DateFormat('MMM dd, yyyy').format(date) : label,
                style: TextStyle(
                  color: date != null
                      ? (isDark ? Colors.white : Colors.black87)
                      : Colors.grey,
                  fontSize: 13,
                ),
              ),
            ),
            if (date != null)
              GestureDetector(
                onTap: onClear,
                child: const Icon(Icons.close, size: 18, color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanCard(BuildContext context, ScanRecord scan, bool isDark) {
    final dateFormatter = DateFormat('MMM dd, yyyy');
    final timeFormatter = DateFormat('hh:mm a');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colorz.primaryColor.withValues(alpha: 0.1),
                  Colors.transparent,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colorz.primaryColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.document_scanner_outlined,
                    color: Colorz.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        scan.scanDate != null
                            ? dateFormatter.format(scan.scanDate!)
                            : "No Date",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      if (scan.scanDate != null)
                        Text(
                          timeFormatter.format(scan.scanDate!),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.redAccent, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    showConfirmationDialog(
                      context: context,
                      title: "Delete Scan Record?",
                      message: "Are you sure you want to delete this scan?",
                      confirmText: "Delete",
                      confirmColor: Colors.redAccent,
                      icon: Icons.delete_forever,
                      onConfirm: () {
                        context.read<ScanActionsCubit>().add(
                              DeleteScanEvent(
                                  patientId: widget.patientId,
                                  scanId: scan.id ?? ""),
                            );
                      },
                    );
                  },
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colorz.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.image, size: 14, color: Colorz.primaryColor),
                      const SizedBox(width: 4),
                      Text(
                        "${scan.files.length}",
                        style: TextStyle(
                          color: Colorz.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Doctor
                if (scan.doctor != null)
                  Row(
                    children: [
                      Icon(Icons.person_outline,
                          size: 18, color: Colors.grey[500]),
                      const SizedBox(width: 8),
                      Text(
                        "Dr. ${scan.doctor!.name ?? 'Unknown'}",
                        style: TextStyle(
                          color: isDark ? Colors.grey[300] : Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                if (scan.comment != null && scan.comment!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.notes, size: 18, color: Colors.grey[500]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          scan.comment!,
                          style: TextStyle(
                            color: isDark ? Colors.grey[300] : Colors.grey[700],
                            fontSize: 14,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                if (scan.files.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 70,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: scan.files.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 8),
                      itemBuilder: (context, fileIndex) {
                        final file = scan.files[fileIndex];
                        final isDicom =
                            file.key?.toLowerCase().endsWith('.dcm') == true ||
                                file.url?.toLowerCase().endsWith('.dcm') ==
                                    true;
                        final allImageUrls = scan.files
                            .where((f) => f.url != null)
                            .map((f) => f.url!)
                            .toList();

                        return GestureDetector(
                          onTap: () {
                            if (file.url != null) {
                              if (isDicom) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RealDicomViewer(
                                      url: file.url,
                                      showMetadata: true,
                                      heroTag:
                                          file.url ?? "list_${scan.id}_$fileIndex",
                                    ),
                                  ),
                                );
                              } else {
                                final initialIdx = allImageUrls.indexOf(file.url!);
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    opaque: false,
                                    barrierColor: Colors.transparent,
                                    pageBuilder: (context, _, __) =>
                                        FullscreenImageViewer(
                                      imageUrls: allImageUrls,
                                      initialIndex: initialIdx != -1 ? initialIdx : 0,
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                          child: Hero(
                            tag: file.url ?? "list_${scan.id}_$fileIndex",
                            child: Container(
                              width: 70,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.grey[800]!
                                      : Colors.grey[200]!,
                                ),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: isDicom
                                  ? DicomImageWidget(
                                      url: file.url,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context) =>
                                          _buildErrorPlaceholder(isDark),
                                    )
                                  : Image.network(
                                      file.url ?? "",
                                      fit: BoxFit.cover,
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return _buildImagePlaceholder(isDark);
                                      },
                                      errorBuilder: (context, error,
                                              stackTrace) =>
                                          _buildErrorPlaceholder(isDark),
                                    ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                // View Details Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ScanDetailsPage(
                            patientId: widget.patientId,
                            scanId: scan.id ?? "",
                          ),
                        ),
                      );

                      if (result == true && context.mounted) {
                        context.read<GetPatientScansCubit>().add(
                              FetchPatientScansEvent(
                                patientId: widget.patientId,
                                page: 1,
                              ),
                            );
                      }
                    },
                    icon: const Icon(Icons.visibility_outlined, size: 18),
                    label: const Text("View Scan Details"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colorz.primaryColor,
                      side: BorderSide(
                          color: Colorz.primaryColor.withValues(alpha: 0.5)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerList(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[900] : Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Shimmer.fromColors(
            baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
            highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 70,
                  decoration: const BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 150,
                        height: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        height: 12,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 200,
                        height: 12,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.document_scanner_outlined,
            size: 80,
            color: isDark ? Colors.grey[700] : Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            "No Scan Records Found",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Scan records for this patient will appear here",
            style: TextStyle(
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String? message, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 60,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            "Error Loading Scans",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message ?? "An unexpected error occurred",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              context.read<GetPatientScansCubit>().add(
                    FetchPatientScansEvent(patientId: widget.patientId),
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colorz.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }

  Widget _buildNoConnectionState(BuildContext context, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.wifi_off,
            size: 60,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            "No Internet Connection",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Please check your connection and try again",
            style: TextStyle(color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              context.read<GetPatientScansCubit>().add(
                    FetchPatientScansEvent(patientId: widget.patientId),
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colorz.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder(bool isDark) {
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: Container(color: Colors.grey),
    );
  }

  Widget _buildErrorPlaceholder(bool isDark) {
    return Container(
      color: isDark ? Colors.grey[900] : Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image_outlined, color: Colors.grey[400]),
          const SizedBox(height: 4),
          const Text("DCM/Unknown",
              style: TextStyle(fontSize: 8, color: Colors.grey)),
        ],
      ),
    );
  }
}

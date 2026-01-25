import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:ocurithm/core/utils/colors.dart';
import 'package:ocurithm/core/utils/services_locator.dart';
import 'package:ocurithm/core/utils/snackbar_service.dart';
import 'package:ocurithm/core/widgets/custom_freeze_loading.dart';
import 'package:ocurithm/core/widgets/confirmation_popuo.dart';
import 'package:ocurithm/modules/Patient/data/model/scan_records_model.dart';
import 'package:ocurithm/modules/Patient/presentation/manager/get_scan_details_cubit/get_scan_details_cubit.dart';
import 'package:ocurithm/modules/Patient/presentation/manager/scan_actions_cubit/scan_actions_cubit.dart';
import 'package:ocurithm/modules/Patient/presentation/manager/scan_pdf_service.dart';
import 'package:shimmer/shimmer.dart';

class ScanDetailsPage extends StatelessWidget {
  final String patientId;
  final String scanId;

  const ScanDetailsPage({
    super.key,
    required this.patientId,
    required this.scanId,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => sl<GetScanDetailsCubit>()
            ..add(FetchScanDetailsEvent(patientId: patientId, scanId: scanId)),
        ),
        BlocProvider(create: (context) => sl<ScanActionsCubit>()),
      ],
      child: BlocListener<ScanActionsCubit, ScanActionsState>(
        listener: (context, state) {
          if (state.state == ScanActionsStatus.loading) {
            customLoading(context, "Deleting Scan...");
          } else if (state.state == ScanActionsStatus.success) {
            Navigator.of(context, rootNavigator: true).pop(); // Close loading
            Navigator.of(context)
                .pop(true); // Return to list with refresh signal
            SnackbarService.showSuccess(context,
                message: state.successMessage ?? "Scan deleted");
          } else if (state.state == ScanActionsStatus.error) {
            Navigator.of(context, rootNavigator: true).pop(); // Close loading
            SnackbarService.showError(context,
                message: state.errorMessage ?? "Delete failed");
          }
        },
        child: Scaffold(
          backgroundColor:
              isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FE),
          appBar: AppBar(
            title: const Text("Scan Details",
                style: TextStyle(fontWeight: FontWeight.bold)),
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            foregroundColor: isDark ? Colors.white : Colors.black87,
            actions: [
              _buildPrintButton(context),
              _buildDeleteButton(),
            ],
          ),
          body: BlocBuilder<GetScanDetailsCubit, GetScanDetailsState>(
            builder: (context, state) {
              if (state.state == GetScanDetailsStatus.loading) {
                return _buildShimmerDetails(isDark);
              }

              if (state.state == GetScanDetailsStatus.error) {
                return _buildErrorState(context, state.errorMessage, isDark);
              }

              final scan = state.scanRecord;
              if (scan == null) return const SizedBox();

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopInfoCard(scan, isDark),
                    _buildSectionTitle("Notes", Icons.notes, isDark),
                    _buildNotesCard(scan, isDark),
                    _buildSectionTitle("Images (${scan.files.length})",
                        Icons.collections_outlined, isDark),
                    _buildImagesGrid(scan, isDark),
                    const SizedBox(height: 40),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPrintButton(BuildContext context) {
    return BlocBuilder<GetScanDetailsCubit, GetScanDetailsState>(
      builder: (context, state) {
        if (state.scanRecord == null) return const SizedBox();
        return IconButton(
          icon: const Icon(Icons.print_outlined),
          onPressed: () {
            SnackbarService.showSuccess(context,
                message: "Generating PDF report...");
            ScanPdfService.generateAndPrintPdf(
              scan: state.scanRecord!,
              patientName: state.scanRecord?.patient?.name ?? "Patient",
            );
          },
        );
      },
    );
  }

  Widget _buildDeleteButton() {
    return Builder(builder: (context) {
      return IconButton(
        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
        onPressed: () async {
          showConfirmationDialog(
            context: context,
            title: "Delete Scan Record?",
            message:
                "This action cannot be undone. Are you sure you want to permanently delete this scan?",
            confirmText: "Delete",
            confirmColor: Colors.redAccent,
            icon: Icons.delete_forever,
            onConfirm: () {
              context.read<ScanActionsCubit>().add(
                    DeleteScanEvent(patientId: patientId, scanId: scanId),
                  );
            },
          );
        },
      );
    });
  }

  Widget _buildSectionTitle(String title, IconData icon, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colorz.primaryColor),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopInfoCard(ScanRecord scan, bool isDark) {
    final dateStr = scan.scanDate != null
        ? DateFormat('EEEE, MMMM dd, yyyy').format(scan.scanDate!)
        : "No Date";
    final timeStr = scan.scanDate != null
        ? DateFormat('hh:mm a').format(scan.scanDate!)
        : "";

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colorz.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.calendar_today, color: Colorz.primaryColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateStr,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      timeStr,
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.person_pin, color: Colors.orange),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Referring Doctor",
                      style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                    ),
                    Text(
                      "Dr. ${scan.doctor?.name ?? 'Unknown'}",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotesCard(ScanRecord scan, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
      ),
      child: Text(
        (scan.comment == null || scan.comment!.isEmpty)
            ? "No clinical notes provided for this scan."
            : scan.comment!,
        style: TextStyle(
          fontSize: 15,
          color: isDark ? Colors.grey[300] : Colors.grey[700],
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildImagesGrid(ScanRecord scan, bool isDark) {
    if (scan.files.isEmpty) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(40),
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.grey[50],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
              style: BorderStyle.solid),
        ),
        child: Column(
          children: [
            Icon(Icons.image_not_supported_outlined,
                size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text("No images available",
                style: TextStyle(color: Colors.grey[500])),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: scan.files.length,
      itemBuilder: (context, index) {
        final file = scan.files[index];
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                file.url ?? "",
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _buildImagePlaceholder(isDark);
                },
                errorBuilder: (context, error, stackTrace) =>
                    _buildErrorPlaceholder(isDark),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent
                      ],
                    ),
                  ),
                  child: Text(
                    "Image ${index + 1}",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
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

  Widget _buildShimmerDetails(bool isDark) {
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
                height: 180,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24))),
            const SizedBox(height: 24),
            Container(
                height: 120,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20))),
            const SizedBox(height: 24),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12),
              itemCount: 4,
              itemBuilder: (_, __) => Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String? message, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text("Something went wrong",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87)),
            const SizedBox(height: 8),
            Text(message ?? "Failed to load scan details",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[500])),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.read<GetScanDetailsCubit>().add(
                  FetchScanDetailsEvent(patientId: patientId, scanId: scanId)),
              child: const Text("Try Again"),
            ),
          ],
        ),
      ),
    );
  }
}

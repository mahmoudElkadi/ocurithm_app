import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ocurithm/core/utils/colors.dart';
import 'package:ocurithm/core/utils/services_locator.dart';

import '../../../data/model/save_reason_model.dart';
import '../../../data/repos/save_reason_repo.dart';

/// The outcome of asking why a visit is being parked.
///
/// A null result from [promptForSaveReason] means the user backed out and nothing
/// should be saved; a result with a null [id] means the clinic has no reasons
/// configured, so the save proceeds without one.
class SaveReasonPick {
  const SaveReasonPick(this.id);

  final String? id;
}

/// Asks the doctor to pick a save reason before a draft save.
///
/// Fetches the catalog first so a clinic that has not configured any reasons is
/// never shown an empty sheet — it just saves, exactly as it did before.
Future<SaveReasonPick?> promptForSaveReason(BuildContext context) async {
  List<SaveReason> reasons;

  try {
    final result = await sl<SaveReasonRepo>().getAllSaveReasons();
    reasons = result.saveReasons ?? [];
  } catch (_) {
    // A catalog we cannot read must not stand between a doctor and their save.
    return const SaveReasonPick(null);
  }

  if (reasons.isEmpty) {
    return const SaveReasonPick(null);
  }

  if (!context.mounted) return null;

  final selected = await showModalBottomSheet<SaveReason>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => _SaveReasonSheet(reasons: reasons),
  );

  if (selected == null) return null;
  return SaveReasonPick(selected.id);
}

class _SaveReasonSheet extends StatefulWidget {
  const _SaveReasonSheet({required this.reasons});

  final List<SaveReason> reasons;

  @override
  State<_SaveReasonSheet> createState() => _SaveReasonSheetState();
}

class _SaveReasonSheetState extends State<_SaveReasonSheet> {
  SaveReason? _selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Why are you saving this visit?',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Pick a reason so the clinic can see why the examination was left open.',
            style: TextStyle(fontSize: 13.sp, color: Colors.grey),
          ),
          SizedBox(height: 12.h),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: widget.reasons.length,
              separatorBuilder: (_, __) => SizedBox(height: 8.h),
              itemBuilder: (context, index) {
                final reason = widget.reasons[index];
                final isSelected = _selected?.id == reason.id;

                return InkWell(
                  onTap: () => setState(() => _selected = reason),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 12.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? Colorz.primaryColor
                            : Theme.of(context)
                                .dividerColor
                                .withValues(alpha: 0.3),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          color: isSelected ? Colorz.primaryColor : Colors.grey,
                          size: 20.sp,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            reason.name ?? 'N/A',
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.color,
                            ),
                          ),
                        ),
                        if ((reason.price ?? 0) > 0)
                          Text(
                            '${reason.price}',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colorz.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _selected == null
                      ? null
                      : () => Navigator.pop(context, _selected),
                  child: const Text(
                    'Save',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// A circular filter-trigger icon button with an optional active-filter-count
/// badge, matching web's "Filters (N)" affordance.
class FilterIconButton extends StatelessWidget {
  final VoidCallback onTap;
  final int activeCount;
  final IconData icon;

  const FilterIconButton({
    super.key,
    required this.onTap,
    required this.activeCount,
    this.icon = Icons.tune,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(icon, color: Theme.of(context).primaryColor, size: 24),
            if (activeCount > 0)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints:
                      const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Text(
                    "$activeCount",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

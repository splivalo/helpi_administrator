import 'package:flutter/material.dart';

import 'package:helpi_admin/app/theme.dart';
import 'package:helpi_admin/core/l10n/app_strings.dart';
import 'package:helpi_admin/core/models/admin_models.dart';
import 'package:helpi_admin/core/widgets/shared_widgets.dart';

/// Reusable reviews section used by both student-detail and senior-detail.
///
/// Parameterised on [title], [avgRating], and [reviewerName] to
/// accommodate the different contexts (student shows senior name, senior
/// shows student name).
class ReviewsSection extends StatelessWidget {
  const ReviewsSection({
    super.key,
    required this.title,
    required this.avgRating,
    required this.reviews,
    required this.reviewerName,
  });

  final String title;
  final double avgRating;
  final List<ReviewModel> reviews;
  final String Function(ReviewModel review) reviewerName;

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
      return SectionCard(
        title: title,
        icon: Icons.star,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Column(
                children: [
                  const Icon(
                    Icons.star_border,
                    size: 36,
                    color: HelpiTheme.border,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.seniorNoReviews,
                    style: TextStyle(
                      color: HelpiColors.of(context).textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return SectionCard(
      title: title,
      icon: Icons.star,
      children: [
        // ── Rating summary ──
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: HelpiTheme.starYellow.withValues(alpha: 0.15),
                border: Border.all(
                  color: HelpiTheme.starYellow.withValues(alpha: 0.3),
                ),
                borderRadius: BorderRadius.circular(
                  HelpiTheme.statusBadgeRadius,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star,
                    size: 18,
                    color: HelpiTheme.starYellow,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    avgRating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Text(
              '${AppStrings.studentTotalRatings}: ${reviews.length}',
              style: TextStyle(
                color: HelpiColors.of(context).textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const Divider(height: 20),
        ...reviews.map(
          (r) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: HelpiColors.of(context).scaffold,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ...List.generate(
                      5,
                      (i) => Icon(
                        i < r.rating ? Icons.star : Icons.star_border,
                        size: 16,
                        color: HelpiTheme.starYellow,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      reviewerName(r),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: HelpiColors.of(context).textSecondary,
                      ),
                    ),
                  ],
                ),
                if (r.comment != null && r.comment!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 100),
                    child: SingleChildScrollView(
                      child: Text(
                        r.comment!,
                        style: const TextStyle(fontSize: 13, height: 1.4),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gp/core/constants/app_colors.dart';
import 'package:gp/l10n/app_localizations.dart';
import 'package:gp/l10n/service_name_l10n.dart';
import 'package:gp/core/theme/app_text_styles.dart';
import 'package:gp/features/become_professional/presentation/pages/edit_certifications_screen.dart';
import 'package:gp/features/become_professional/presentation/pages/edit_details_screen.dart';
import 'package:gp/features/become_professional/presentation/pages/edit_services_screen.dart';
import 'package:gp/features/professionals/domain/entities/professional.dart';
import 'package:gp/features/professionals/domain/entities/review.dart';
import 'package:gp/core/widgets/skeletons/professional_detail_skeleton.dart';
import 'package:gp/features/professionals/presentation/bloc/professionals_bloc.dart';
import 'package:gp/features/professionals/presentation/bloc/professionals_event.dart';
import 'package:gp/features/professionals/presentation/bloc/professionals_state.dart';
import 'package:gp/features/professionals/presentation/widgets/star_rating.dart';

String _localizeDay(String day, AppLocalizations l10n) {
  String translate(String name) {
    switch (name.trim()) {
      case 'Sunday':    return l10n.dayFullSunday;
      case 'Monday':    return l10n.dayFullMonday;
      case 'Tuesday':   return l10n.dayFullTuesday;
      case 'Wednesday': return l10n.dayFullWednesday;
      case 'Thursday':  return l10n.dayFullThursday;
      case 'Friday':    return l10n.dayFullFriday;
      case 'Saturday':  return l10n.dayFullSaturday;
      default:          return name;
    }
  }
  return day.split(' - ').map(translate).join(' - ');
}

String _localizeTime(String time, AppLocalizations l10n) =>
    time.replaceAll('AM', l10n.amLabel).replaceAll('PM', l10n.pmLabel);

class ProfessionalMyProfilePage extends StatefulWidget {
  const ProfessionalMyProfilePage({super.key});

  @override
  State<ProfessionalMyProfilePage> createState() =>
      _ProfessionalMyProfilePageState();
}

class _ProfessionalMyProfilePageState
    extends State<ProfessionalMyProfilePage> {
  int _selectedTab = 0;
  final List<String> _tabs = ['About', 'Services', 'Reviews', 'Certifications'];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    context.read<ProfessionalsBloc>().add(LoadMyProfile());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<ProfessionalsBloc, ProfessionalsState>(
        builder: (context, state) {
          if (state is ProfessionalsLoading) {
            return const ProfessionalDetailSkeleton();
          }

          if (state is ProfessionalsError) {
            return _ErrorView(
              message: state.message,
              onRetry: _loadProfile,
            );
          }

          Professional? professional;
          List<Review> reviews = [];

          if (state is ProfessionalDetailLoaded) {
            professional = state.professional;
            reviews = state.reviews;
          } else if (state is ReviewActionSuccess) {
            professional = state.professional;
            reviews = state.reviews;
          } else if (state is ReviewsLoading) {
            professional = state.professional;
          }

          if (professional == null) {
            return const ProfessionalDetailSkeleton();
          }

          return Column(
            children: [
              _ProfileHeader(professional: professional),
              _TabBar(
                tabs: _tabs,
                selectedIndex: _selectedTab,
                onTabSelected: (i) => setState(() => _selectedTab = i),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: _buildTabContent(context, professional, reviews),
                ),
              ),
              _EditProfileButton(
                professional: professional,
                selectedTab: _selectedTab,
                onSaved: _loadProfile,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTabContent(
    BuildContext context,
    Professional professional,
    List<Review> reviews,
  ) {
    switch (_selectedTab) {
      case 0:
        return _AboutTab(professional: professional);
      case 1:
        return _ServicesTab(professional: professional);
      case 2:
        return _ReviewsTab(professional: professional, reviews: reviews);
      case 3:
        return _CertificationsTab(professional: professional);
      default:
        return const SizedBox.shrink();
    }
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  final Professional professional;

  const _ProfileHeader({required this.professional});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        bottom: 24,
        left: 20,
        right: 20,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(
                  Icons.chevron_left,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 28),
            ],
          ),
          const SizedBox(height: 12),
          Stack(
            children: [
              CircleAvatar(
                radius: 46,
                backgroundColor: AppColors.surface,
                backgroundImage: professional.profileImageUrl != null
                    ? NetworkImage(professional.profileImageUrl!)
                    : null,
                child: professional.profileImageUrl == null
                    ? const Icon(
                        Icons.person,
                        size: 46,
                        color: AppColors.textSecondary,
                      )
                    : null,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            professional.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Professional ${professional.category.displayName}',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatItem(
                icon: Icons.access_time,
                value: '${professional.experienceYears}',
                label: 'Years Exp.',
              ),
              _StatItem(
                icon: Icons.bookmark_border,
                value: professional.distanceKm != null
                    ? professional.distanceKm!.toStringAsFixed(1)
                    : '--',
                label: 'KM Away',
              ),
              _StatItem(
                icon: Icons.star,
                value: professional.rating.toStringAsFixed(1),
                label: 'Rating',
                isStar: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final bool isStar;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    this.isStar = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: isStar ? AppColors.star : AppColors.primaryOrange,
              size: 18,
            ),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}

// ─── Tab Bar ──────────────────────────────────────────────────────────────────

class _TabBar extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const _TabBar({
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(tabs.length, (index) {
            final selected = selectedIndex == index;
            return GestureDetector(
              onTap: () => onTabSelected(index),
              child: Container(
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primaryOrange : AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected
                        ? AppColors.primaryOrange
                        : AppColors.divider,
                  ),
                ),
                child: Text(
                  tabs[index],
                  style: TextStyle(
                    color: selected ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ─── About Tab ────────────────────────────────────────────────────────────────

class _AboutTab extends StatelessWidget {
  final Professional professional;
  const _AboutTab({required this.professional});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionCard(
          icon: Icons.person_outline,
          title: l10n.aboutMe,
          child: Text(
            professional.bio.isNotEmpty
                ? professional.bio
                : l10n.noBioAdded,
            style: AppTextStyles.bodySmall,
          ),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          icon: Icons.bookmark_border,
          title: l10n.serviceAreas,
          child: professional.serviceAreas.isEmpty
              ? Text(l10n.noServiceAreasAdded, style: AppTextStyles.bodySmall)
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: professional.serviceAreas
                      .map(
                        (area) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: Text(
                            area.name,
                            style: AppTextStyles.bodySmall,
                          ),
                        ),
                      )
                      .toList(),
                ),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          icon: Icons.access_time,
          title: l10n.workingHours,
          child: Column(
            children: professional.workingHours.schedules
                .map(
                  (s) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_localizeDay(s.day, l10n), style: AppTextStyles.bodySmall),
                        Text(
                          _localizeTime(s.timeRange, l10n),
                          style: AppTextStyles.bodySmall.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

// ─── Services Tab ─────────────────────────────────────────────────────────────

class _ServicesTab extends StatelessWidget {
  final Professional professional;
  const _ServicesTab({required this.professional});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _SectionCard(
      icon: Icons.settings,
      title: l10n.servicesOffered,
      child: professional.services.isEmpty
          ? Text(l10n.noServicesListedYet, style: AppTextStyles.bodySmall)
          : Column(
              children: professional.services
                  .map(
                    (service) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              localizeServiceName(service.name, l10n, nameAr: service.nameAr),
                              style: AppTextStyles.bodySmall,
                            ),
                          ),
                          Text(
                            service.priceDisplay,
                            style: AppTextStyles.bodySmall.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
    );
  }
}

// ─── Reviews Tab ──────────────────────────────────────────────────────────────

class _ReviewsTab extends StatelessWidget {
  final Professional professional;
  final List<Review> reviews;

  const _ReviewsTab({
    required this.professional,
    required this.reviews,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      icon: Icons.star,
      title: 'Customer Reviews',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Column(
                children: [
                  Text(
                    professional.rating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${professional.reviewCount} Reviews',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [5, 4, 3, 2, 1].map((star) {
                    final count = professional.ratingBreakdown[star] ?? 0;
                    final total =
                        professional.reviewCount == 0 ? 1 : professional.reviewCount;
                    return Row(
                      children: [
                        Text('$star', style: AppTextStyles.bodySmall),
                        const SizedBox(width: 4),
                        const Icon(Icons.star, color: AppColors.star, size: 12),
                        const SizedBox(width: 6),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: count / total,
                              backgroundColor: AppColors.divider,
                              color: AppColors.primaryDark,
                              minHeight: 6,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.divider),
          const SizedBox(height: 8),
          if (reviews.isEmpty)
            Text('No reviews yet.', style: AppTextStyles.bodySmall)
          else
            ...reviews.map((r) => _ReviewItem(review: r)),
        ],
      ),
    );
  }
}

class _ReviewItem extends StatelessWidget {
  final Review review;
  const _ReviewItem({required this.review});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.surface,
              backgroundImage: review.reviewerImageUrl != null
                  ? NetworkImage(review.reviewerImageUrl!)
                  : null,
              child: review.reviewerImageUrl == null
                  ? const Icon(Icons.person,
                      size: 18, color: AppColors.textSecondary)
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(review.reviewerName, style: AppTextStyles.bodyMedium),
                  Row(
                    children: [
                      StarRating(rating: review.rating, size: 13),
                      const SizedBox(width: 6),
                      Text(review.timeAgo, style: AppTextStyles.bodySmall),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(review.comment, style: AppTextStyles.bodySmall),
        const SizedBox(height: 12),
        const Divider(color: AppColors.divider),
        const SizedBox(height: 8),
      ],
    );
  }
}

// ─── Certifications Tab ───────────────────────────────────────────────────────

class _CertificationsTab extends StatelessWidget {
  final Professional professional;
  const _CertificationsTab({required this.professional});

  @override
  Widget build(BuildContext context) {
    final certifications = professional.certifications;

    return Column(
      children: [
        _SectionCard(
          icon: Icons.description_outlined,
          title: 'Professional Certifications',
          child: certifications.isEmpty
              ? Text(
                  'No certifications uploaded yet.',
                  style: AppTextStyles.bodySmall,
                )
              : Column(
                  children: certifications
                      .map(
                        (doc) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.description_outlined,
                                color: AppColors.primaryOrange,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      doc.name,
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.primaryOrange,
                                      ),
                                    ),
                                    if (doc.issuedBy != null)
                                      Text(
                                        doc.issuedBy!,
                                        style: AppTextStyles.bodySmall,
                                      ),
                                    if (doc.issuedLabel.isNotEmpty)
                                      Text(
                                        doc.issuedLabel,
                                        style: AppTextStyles.bodySmall,
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          icon: Icons.verified_user_outlined,
          title: 'Background & Safety',
          child: Column(
            children: [
              _VerificationRow(
                label: 'Background Check',
                verified: professional.isVerified,
              ),
              const SizedBox(height: 8),
              _VerificationRow(
                label: 'Identity Verified',
                verified: professional.isIdentityVerified,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _VerificationRow extends StatelessWidget {
  final String label;
  final bool verified;

  const _VerificationRow({required this.label, required this.verified});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primaryOrange,
            ),
          ),
          Text(
            verified ? 'Verified 2026' : 'Not Verified',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }
}

// ─── Edit Profile Button ──────────────────────────────────────────────────────

class _EditProfileButton extends StatelessWidget {
  final Professional professional;
  final int selectedTab;
  final VoidCallback onSaved;

  const _EditProfileButton({
    required this.professional,
    required this.selectedTab,
    required this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    // Reviews tab (2) is read-only; certifications tab (3) is editable
    if (selectedTab == 2) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _openEditSheet(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryOrange,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Text(
            switch (selectedTab) {
              0 => 'Edit Details',
              1 => 'Edit Services',
              _ => 'Edit Certifications',
            },
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  void _openEditSheet(BuildContext context) {
    final Widget target = switch (selectedTab) {
      0 => EditDetailsScreen(professional: professional),
      1 => EditServicesScreen(professional: professional),
      _ => EditCertificationsScreen(professional: professional),
    };
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => target),
    );
  }
}

// ─── Error View ───────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(message, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryOrange,
            ),
            child: Text(AppLocalizations.of(context)!.retry, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ─── Shared Widgets ───────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryOrange, size: 20),
              const SizedBox(width: 8),
              Text(title, style: AppTextStyles.sectionTitle),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

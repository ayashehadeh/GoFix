import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gp/features/professionals/presentation/bloc/professionals_event.dart';
import 'package:gp/features/professionals/presentation/bloc/professionals_state.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gp/core/constants/app_colors.dart';
import 'package:gp/core/theme/app_text_styles.dart';
import 'package:gp/features/professionals/domain/entities/professional.dart';
import 'package:gp/features/professionals/domain/entities/review.dart';
import 'package:gp/features/professionals/presentation/bloc/professionals_bloc.dart';
import 'package:gp/features/professionals/presentation/widgets/star_rating.dart';

class ProfessionalDetailPage extends StatefulWidget {
  final String professionalId;

  const ProfessionalDetailPage({super.key, required this.professionalId});

  @override
  State<ProfessionalDetailPage> createState() =>
      _ProfessionalDetailPageState();
}

class _ProfessionalDetailPageState extends State<ProfessionalDetailPage> {
  int _selectedTab = 0;
  final List<String> _tabs = ['About', 'Services', 'Reviews', 'Certifications'];

  @override
  void initState() {
    super.initState();
    context
        .read<ProfessionalsBloc>()
        .add(LoadProfessionalDetail(widget.professionalId));
  }

  Future<void> _callProfessional(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<ProfessionalsBloc, ProfessionalsState>(
        listener: (context, state) {
          if (state is ReviewActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.primaryOrange,
              ),
            );
            // Stay on detail page with updated data
            context
                .read<ProfessionalsBloc>()
                .add(LoadProfessionalDetail(widget.professionalId));
          }
        },
        builder: (context, state) {
          if (state is ProfessionalsLoading) {
            return const Center(
              child:
                  CircularProgressIndicator(color: AppColors.primaryOrange),
            );
          }

          if (state is ProfessionalsError) {
            return Center(child: Text(state.message));
          }

          if (state is ProfessionalDetailLoaded ||
              state is ReviewsLoading) {
            final professional = state is ProfessionalDetailLoaded
                ? state.professional
                : (state as ReviewsLoading).professional;
            final reviews = state is ProfessionalDetailLoaded
                ? state.reviews
                : <Review>[];

            return Column(
              children: [
                _DetailHeader(
                  professional: professional,
                  onCall: () => _callProfessional(professional.phone),
                  onFavorite: () => context
                      .read<ProfessionalsBloc>()
                      .add(ToggleFavoriteEvent(professional.id)),
                ),
                // ── Tabs ────────────────────────────────────────
                Container(
                  color: AppColors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(_tabs.length, (index) {
                        final selected = _selectedTab == index;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedTab = index),
                          child: Container(
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 10),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.primaryOrange
                                  : AppColors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: selected
                                    ? AppColors.primaryOrange
                                    : AppColors.divider,
                              ),
                            ),
                            child: Text(
                              _tabs[index],
                              style: TextStyle(
                                color: selected
                                    ? Colors.white
                                    : AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                // ── Tab Content ──────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: _buildTabContent(
                        professional, reviews, state is ReviewsLoading),
                  ),
                ),
                // ── Bottom Actions ───────────────────────────────
                _BottomActions(
                  onBookNow: () {
                    // TODO: Navigate to booking flow
                  },
                  onMessage: () {
                    // TODO: Navigate to chat
                  },
                  onCall: () => _callProfessional(professional.phone),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildTabContent(
      Professional professional, List<Review> reviews, bool isLoadingReviews) {
    switch (_selectedTab) {
      case 0:
        return _AboutTab(professional: professional);
      case 1:
        return _ServicesTab(professional: professional);
      case 2:
        return isLoadingReviews
            ? const Center(
                child:
                    CircularProgressIndicator(color: AppColors.primaryOrange))
            : _ReviewsTab(professional: professional, reviews: reviews);
      case 3:
        return _CertificationsTab(professional: professional);
      default:
        return const SizedBox.shrink();
    }
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _DetailHeader extends StatelessWidget {
  final Professional professional;
  final VoidCallback onCall;
  final VoidCallback onFavorite;

  const _DetailHeader({
    required this.professional,
    required this.onCall,
    required this.onFavorite,
  });

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
          // Back + Favorite
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.chevron_left,
                    color: Colors.white, size: 28),
              ),
              GestureDetector(
                onTap: onFavorite,
                child: Icon(
                  professional.isFavorite
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: AppColors.primaryOrange,
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Profile image
          CircleAvatar(
            radius: 46,
            backgroundColor: AppColors.surface,
            backgroundImage: professional.profileImageUrl != null
                ? NetworkImage(professional.profileImageUrl!)
                : null,
            child: professional.profileImageUrl == null
                ? const Icon(Icons.person,
                    size: 46, color: AppColors.textSecondary)
                : null,
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
          // Stats row
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
                value: professional.distanceKm.toStringAsFixed(1),
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
            Icon(icon,
                color: isStar ? AppColors.star : AppColors.primaryOrange,
                size: 18),
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
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}

// ─── About Tab ────────────────────────────────────────────────────────────────

class _AboutTab extends StatelessWidget {
  final Professional professional;
  const _AboutTab({required this.professional});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // About Me
        _SectionCard(
          icon: Icons.person_outline,
          title: 'About Me',
          child: Text(professional.bio, style: AppTextStyles.bodySmall),
        ),
        const SizedBox(height: 16),
        // Service Areas
        _SectionCard(
          icon: Icons.bookmark_border,
          title: 'Service Areas',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: professional.serviceAreas
                .map((area) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Text(area, style: AppTextStyles.bodySmall),
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: 16),
        // Working Hours
        _SectionCard(
          icon: Icons.access_time,
          title: 'Working Hours',
          child: Column(
            children: professional.workingHours.schedules
                .map((s) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(s.day, style: AppTextStyles.bodySmall),
                          Text(s.timeRange,
                              style: AppTextStyles.bodySmall.copyWith(
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ))
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
    return _SectionCard(
      icon: Icons.settings,
      title: 'Services Offered',
      child: Column(
        children: professional.services
            .map((service) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(service.name, style: AppTextStyles.bodySmall),
                      Text(
                        service.priceDisplay,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }
}

// ─── Reviews Tab ──────────────────────────────────────────────────────────────

class _ReviewsTab extends StatelessWidget {
  final Professional professional;
  final List<Review> reviews;

  const _ReviewsTab(
      {required this.professional, required this.reviews});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      icon: Icons.star,
      title: 'Customer Reviews',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rating summary
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
                  Text('${professional.reviewCount} Reviews',
                      style: AppTextStyles.bodySmall),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [5, 4, 3, 2, 1].map((star) {
                    final count =
                        professional.ratingBreakdown[star] ?? 0;
                    final total = professional.reviewCount == 0
                        ? 1
                        : professional.reviewCount;
                    return Row(
                      children: [
                        Text('$star', style: AppTextStyles.bodySmall),
                        const SizedBox(width: 4),
                        const Icon(Icons.star,
                            color: AppColors.star, size: 12),
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
          // Reviews list
          ...reviews.map((review) => _ReviewItem(review: review)),
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
                  Text(review.reviewerName,
                      style: AppTextStyles.bodyMedium),
                  Row(
                    children: [
                      StarRating(rating: review.rating, size: 13),
                      const SizedBox(width: 6),
                      Text(review.timeAgo,
                          style: AppTextStyles.bodySmall),
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
    return Column(
      children: [
        _SectionCard(
          icon: Icons.description_outlined,
          title: 'Professional Certifications',
          child: Column(
            children: professional.certifications
                .map((cert) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            cert.name,
                            style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.primaryOrange),
                          ),
                          Text(cert.issuedLabel,
                              style: AppTextStyles.bodySmall),
                        ],
                      ),
                    ))
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
          Text(label,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.primaryOrange)),
          Text(
            verified ? 'Verified 2026' : 'Not Verified',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }
}

// ─── Bottom Actions ───────────────────────────────────────────────────────────

class _BottomActions extends StatelessWidget {
  final VoidCallback onBookNow;
  final VoidCallback onMessage;
  final VoidCallback onCall;

  const _BottomActions({
    required this.onBookNow,
    required this.onMessage,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: onBookNow,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text(
                'Book Now',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Message button
          GestureDetector(
            onTap: onMessage,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.divider, width: 1.5),
              ),
              child: const Icon(Icons.chat_bubble_outline,
                  color: AppColors.primaryDark, size: 22),
            ),
          ),
          const SizedBox(width: 10),
          // Call button
          GestureDetector(
            onTap: onCall,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.divider, width: 1.5),
              ),
              child: const Icon(Icons.phone,
                  color: AppColors.primaryDark, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared Section Card ──────────────────────────────────────────────────────

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
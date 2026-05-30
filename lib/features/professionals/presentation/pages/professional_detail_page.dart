import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gp/core/favorites/favorites_cache.dart';
import 'package:gp/features/professionals/presentation/bloc/professionals_event.dart';
import 'package:gp/features/professionals/presentation/bloc/professionals_state.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gp/core/constants/app_colors.dart';
import 'package:gp/core/theme/app_text_styles.dart';
import 'package:gp/features/professionals/domain/entities/professional.dart';
import 'package:gp/features/professionals/domain/entities/review.dart';
import 'package:gp/features/professionals/presentation/bloc/professionals_bloc.dart';
import 'package:gp/features/professionals/presentation/widgets/star_rating.dart';
import 'package:gp/features/bookings/presentation/pages/select_service_screen.dart';
import 'package:gp/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:gp/features/chat/presentation/pages/chat_page.dart';
import 'package:gp/injection_container.dart' as di;
import 'package:gp/l10n/app_localizations.dart';
import 'package:gp/l10n/area_name_l10n.dart';
import 'package:gp/l10n/service_name_l10n.dart';
import 'package:gp/core/widgets/skeletons/professional_detail_skeleton.dart';
import 'package:gp/features/professionals/domain/entities/service_category.dart';

String _localizeDay(String day, AppLocalizations l10n) {
  String translate(String name) {
    switch (name.trim()) {
      case 'Sunday':
        return l10n.dayFullSunday;
      case 'Monday':
        return l10n.dayFullMonday;
      case 'Tuesday':
        return l10n.dayFullTuesday;
      case 'Wednesday':
        return l10n.dayFullWednesday;
      case 'Thursday':
        return l10n.dayFullThursday;
      case 'Friday':
        return l10n.dayFullFriday;
      case 'Saturday':
        return l10n.dayFullSaturday;
      default:
        return name;
    }
  }

  return day.split(' - ').map(translate).join(' - ');
}

String _localizeTime(String time, AppLocalizations l10n) =>
    time.replaceAll('AM', l10n.amLabel).replaceAll('PM', l10n.pmLabel);

String _localizeCategoryName(AppLocalizations l10n, ServiceCategory cat) {
  switch (cat) {
    case ServiceCategory.plumbing:
      return l10n.categoryPlumbing;
    case ServiceCategory.electricalWork:
      return l10n.categoryElectricalWork;
    case ServiceCategory.acRepair:
      return l10n.categoryAcRepair;
    case ServiceCategory.carpentry:
      return l10n.categoryCarpentry;
    case ServiceCategory.painting:
      return l10n.categoryPainting;
    case ServiceCategory.cleaning:
      return l10n.categoryCleaning;
    case ServiceCategory.movingServices:
      return l10n.categoryMovingServices;
    case ServiceCategory.applianceRepair:
      return l10n.categoryApplianceRepair;
  }
}

class ProfessionalDetailPage extends StatefulWidget {
  final String professionalId;

  const ProfessionalDetailPage({super.key, required this.professionalId, required String id});

  @override
  State<ProfessionalDetailPage> createState() => _ProfessionalDetailPageState();
}

class _ProfessionalDetailPageState extends State<ProfessionalDetailPage> {
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    context.read<ProfessionalsBloc>().add(
          LoadProfessionalDetail(widget.professionalId),
        );
  }

  Future<void> _callProfessional(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final tabs = [t.tabAbout, t.tabServices, t.tabReviews, t.tabCertifications];
    return BlocProvider(
      create: (_) => di.sl<ChatBloc>(),
      child: BlocListener<ChatBloc, ChatState>(
        listener: (context, state) {
          if (state is ChatReady) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider(
                  create: (_) => di.sl<ChatBloc>(),
                  child: ChatPage(
                    chatId: state.chat.id,
                    professionalName: state.chat.name,
                  ),
                ),
              ),
            );
          } else if (state is ChatError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: Scaffold(
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
                context.read<ProfessionalsBloc>().add(
                      LoadProfessionalDetail(widget.professionalId),
                    );
              }
            },
            builder: (context, state) {
              if (state is ProfessionalsLoading) {
                return const ProfessionalDetailSkeleton();
              }

              if (state is ProfessionalsError) {
                return Center(child: Text(state.message));
              }

              if (state is ProfessionalDetailLoaded || state is ReviewsLoading) {
                final professional =
                    state is ProfessionalDetailLoaded ? state.professional : (state as ReviewsLoading).professional;
                final reviews = state is ProfessionalDetailLoaded ? state.reviews : <Review>[];

                return Column(
                  children: [
                    _DetailHeader(
                      professional: professional,
                      onCall: () => _callProfessional(professional.phone),
                      onFavorite: () {
                        context.read<ProfessionalsBloc>().add(
                              ToggleFavoriteEvent(professional.id),
                            );
                      },
                    ),
                    // ── Tabs ────────────────────────────────────────
                    Container(
                      color: AppColors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(tabs.length, (index) {
                            final selected = _selectedTab == index;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedTab = index),
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
                                    color: selected ? AppColors.primaryOrange : AppColors.divider,
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
                    ),
                    // ── Tab Content ──────────────────────────────────
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: _buildTabContent(
                          professional,
                          reviews,
                          state is ReviewsLoading,
                        ),
                      ),
                    ),
                    // ── Bottom Actions ───────────────────────────────
                    _BottomActions(
                      professional: professional,
                      onBookNow: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SelectServiceScreen(
                              professionalName: professional.name,
                              professionalRole:
                                  '${t.professionalPrefix} ${_localizeCategoryName(t, professional.category)}',
                              professionalId: professional.id,
                              services: professional.services,
                              workingHours: professional.workingHours,
                            ),
                          ),
                        );
                      },
                      onCall: () => _callProfessional(professional.phone),
                    ),
                  ],
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(
    Professional professional,
    List<Review> reviews,
    bool isLoadingReviews,
  ) {
    switch (_selectedTab) {
      case 0:
        return _AboutTab(professional: professional);
      case 1:
        return _ServicesTab(professional: professional);
      case 2:
        return isLoadingReviews
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryOrange,
                ),
              )
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
              ValueListenableBuilder<Set<String>>(
                valueListenable: FavoritesCache.instance.notifier,
                builder: (_, ids, __) => GestureDetector(
                  onTap: onFavorite,
                  child: Icon(
                    ids.contains(professional.id) ? Icons.favorite : Icons.favorite_border,
                    color: AppColors.primaryOrange,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          CircleAvatar(
            radius: 46,
            backgroundColor: AppColors.surface,
            backgroundImage: professional.profileImageUrl != null ? NetworkImage(professional.profileImageUrl!) : null,
            child: professional.profileImageUrl == null
                ? const Icon(
                    Icons.person,
                    size: 46,
                    color: AppColors.textSecondary,
                  )
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
            '${AppLocalizations.of(context)!.professionalPrefix} ${_localizeCategoryName(AppLocalizations.of(context)!, professional.category)}',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Builder(builder: (ctx) {
            final l = AppLocalizations.of(ctx)!;
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatItem(
                  icon: Icons.access_time,
                  value: '${professional.experienceYears}',
                  label: l.yearsExp,
                ),
                _StatItem(
                  icon: Icons.near_me,
                  value: professional.distanceKm != null
                      ? '${professional.distanceKm!.toStringAsFixed(1)} KM'
                      : '-- KM',
                  label: l.fromBase,
                ),
                _StatItem(
                  icon: Icons.star,
                  value: professional.rating.toStringAsFixed(1),
                  label: l.ratingLabel,
                  isStar: true,
                ),
              ],
            );
          }),
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
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
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
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionCard(
          icon: Icons.person_outline,
          title: l10n.aboutMe,
          child: Text(professional.bio, style: AppTextStyles.bodySmall),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          icon: Icons.bookmark_border,
          title: l10n.serviceAreas,
          child: Wrap(
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
                    child: Text(localizeAreaName(area.name, AppLocalizations.of(context)!, nameAr: area.nameAr), style: AppTextStyles.bodySmall),
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
    return _SectionCard(
      icon: Icons.settings,
      title: AppLocalizations.of(context)!.servicesOffered,
      child: Column(
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
                    Text(localizeServiceName(service.name, AppLocalizations.of(context)!, nameAr: service.nameAr),
                        style: AppTextStyles.bodySmall),
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

  const _ReviewsTab({required this.professional, required this.reviews});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _SectionCard(
      icon: Icons.star,
      title: l10n.customerReviews,
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
                    '${professional.reviewCount} ${l10n.reviewsLabel}',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [5, 4, 3, 2, 1].map((star) {
                    final count = professional.ratingBreakdown[star] ?? 0;
                    final total = professional.reviewCount == 0 ? 1 : professional.reviewCount;
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
              backgroundImage: review.reviewerImageUrl != null ? NetworkImage(review.reviewerImageUrl!) : null,
              child: review.reviewerImageUrl == null
                  ? const Icon(
                      Icons.person,
                      size: 18,
                      color: AppColors.textSecondary,
                    )
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
    final l10n = AppLocalizations.of(context)!;
    final certifications = professional.certifications;

    return Column(
      children: [
        _SectionCard(
          icon: Icons.description_outlined,
          title: l10n.professionalCertifications,
          child: certifications.isEmpty
              ? Text(
                  l10n.noCertificationsYet,
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
                              IconButton(
                                icon: const Icon(
                                  Icons.open_in_new,
                                  color: AppColors.primaryOrange,
                                  size: 20,
                                ),
                                onPressed: () async {
                                  final uri = Uri.parse(doc.fileUrl);
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(
                                      uri,
                                      mode: LaunchMode.externalApplication,
                                    );
                                  }
                                },
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
          title: l10n.backgroundSafety,
          child: Column(
            children: [
              _VerificationRow(
                label: l10n.backgroundCheck,
                verified: professional.isVerified,
              ),
              const SizedBox(height: 8),
              _VerificationRow(
                label: l10n.identityVerifiedLabel,
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
            verified ? AppLocalizations.of(context)!.verifiedLabel : AppLocalizations.of(context)!.notVerifiedLabel,
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }
}

// ─── Bottom Actions ───────────────────────────────────────────────────────────

class _BottomActions extends StatelessWidget {
  final Professional professional;
  final VoidCallback onBookNow;
  final VoidCallback onCall;

  const _BottomActions({
    required this.professional,
    required this.onBookNow,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    final bool canBook = professional.isAvailable;

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Unavailability notice ─────────────────────────────────────
          if (!canBook)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3F3),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.error.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.block_rounded, color: AppColors.error, size: 16),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'This professional is not accepting bookings right now.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // ── Action buttons ────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: canBook ? onBookNow : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canBook ? AppColors.primaryOrange : AppColors.divider,
                    disabledBackgroundColor: AppColors.divider,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    canBook ? AppLocalizations.of(context)!.bookNow : 'Unavailable',
                    style: TextStyle(
                      color: canBook ? Colors.white : AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () {
                  context.read<ChatBloc>().add(
                        GetOrCreateChatEvent(
                          professionalId: professional.id.toString(),
                          professionalName: professional.name,
                        ),
                      );
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.divider, width: 1.5),
                  ),
                  child: const Icon(
                    Icons.chat_bubble_outline,
                    color: AppColors.primaryDark,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 10),
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
                  child: const Icon(
                    Icons.phone_outlined,
                    color: AppColors.primaryDark,
                    size: 22,
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

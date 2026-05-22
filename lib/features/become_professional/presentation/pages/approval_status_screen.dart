import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gp/features/professional_availability/presentation/bloc/availability_bloc.dart';
import 'package:gp/features/professional_availability/presentation/pages/my_availability_screen.dart';
import 'package:gp/injection_container.dart';
import 'package:gp/l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../bloc/application_status_bloc.dart';
import '../bloc/application_status_event.dart';
import '../bloc/application_status_state.dart';
import '../../domain/entities/application_status_entity.dart';
import '../widgets/approval_checklist_item.dart';

/// Entry point — reads the BLoC and delegates to the correct sub-screen.
class ApprovalStatusScreen extends StatelessWidget {
  const ApprovalStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ApplicationStatusBloc, ApplicationStatusState>(
      builder: (context, state) {
        if (state is ApplicationStatusLoading || state is ApplicationStatusInitial) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primaryOrange),
            ),
          );
        }

        if (state is ApplicationStatusError) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: _buildAppBar(context),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.error, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => context.read<ApplicationStatusBloc>().add(const LoadApplicationStatus()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryOrange,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(AppLocalizations.of(context)!.retry, style: const TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (state is ApplicationStatusLoaded) {
          switch (state.status.status) {
            case ProfessionalStatus.approved:
              return _ApprovedScreen(status: state.status);
            case ProfessionalStatus.rejected:
            case ProfessionalStatus.pendingReview:
              return _NotApprovedScreen(status: state.status);
            case ProfessionalStatus.draft:
              return _IncompleteScreen();
          }
        }

        return const SizedBox.shrink();
      },
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: const BackButton(color: AppColors.primaryDark),
      centerTitle: false,
    );
  }
}

// ─── Approved Screen ──────────────────────────────────────────────────────────

class _ApprovedScreen extends StatelessWidget {
  final ApplicationStatusEntity status;
  const _ApprovedScreen({required this.status});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: AppColors.primaryDark),
      ),
      body: RefreshIndicator(
        color: AppColors.primaryOrange,
        onRefresh: () async => context.read<ApplicationStatusBloc>().add(const RefreshApplicationStatus()),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // ── Illustration ────────────────────────────────────────────
              Center(
                child: SvgPicture.asset(
                  'assets/approved_balloons.svg',
                  height: 220,
                ),
              ),
              const SizedBox(height: 28),

              // ── Title ───────────────────────────────────────────────────
              Builder(builder: (context) {
                final t = AppLocalizations.of(context)!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.approved,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      t.approvedMessage,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ── Checklist ──────────────────────────────────────────
                    ApprovalChecklistItem(
                      title: t.profileSubmitted,
                      subtitle: t.profileVerifiedSubtitle,
                      isCompleted: status.hasProfile,
                    ),
                    const SizedBox(height: 16),
                    ApprovalChecklistItem(
                      title: t.identityVerified,
                      subtitle: t.backgroundCheckPassed,
                      isCompleted: status.hasIdentityDocument,
                    ),
                    const SizedBox(height: 40),

                    // ── CTA ────────────────────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => BlocProvider(
                                create: (_) => sl<AvailabilityBloc>(),
                                child: const MyAvailabilityScreen(),
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryOrange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          t.setMyAvailability,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Not Approved Screen (Rejected / PendingReview) ───────────────────────────

class _NotApprovedScreen extends StatelessWidget {
  final ApplicationStatusEntity status;
  const _NotApprovedScreen({required this.status});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: AppColors.primaryDark),
      ),
      body: RefreshIndicator(
        color: AppColors.primaryOrange,
        onRefresh: () async => context.read<ApplicationStatusBloc>().add(const RefreshApplicationStatus()),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // ── Illustration ────────────────────────────────────────────
              Center(
                child: SvgPicture.asset(
                  'assets/notapproved_clock.svg',
                  height: 220,
                ),
              ),
              const SizedBox(height: 28),

              // ── Title ───────────────────────────────────────────────────
              Builder(builder: (context) {
                final t = AppLocalizations.of(context)!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.notApproved,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      status.rejectionReason ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ── Checklist ──────────────────────────────────────────
                    ApprovalChecklistItem(
                      title: t.profileSubmitted,
                      subtitle: t.profileVerifiedSubtitle,
                      isCompleted: status.hasProfile,
                    ),
                    const SizedBox(height: 16),
                    ApprovalChecklistItem(
                      title: t.identityVerified,
                      subtitle: t.backgroundCheckPassed,
                      isCompleted: status.hasIdentityDocument,
                    ),
                    const SizedBox(height: 40),

                    // ── CTA ────────────────────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Navigator.push to DocumentUploadPage
                          // with documentType: DocumentType.identity
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryOrange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          t.resubmitDocuments,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Incomplete / Draft Screen ────────────────────────────────────────────────

class _IncompleteScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: AppColors.primaryDark),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.assignment_outlined,
                size: 56,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 16),
              Builder(builder: (context) {
                final t = AppLocalizations.of(context)!;
                return Column(
                  children: [
                    Text(
                      t.applicationIncomplete,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      t.incompleteApplicationMsg,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryOrange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          t.completeApplication,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

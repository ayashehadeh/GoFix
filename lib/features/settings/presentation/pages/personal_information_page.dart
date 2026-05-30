import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:gp/core/constants/app_colors.dart';
import 'package:gp/features/settings/data/repositories/profile_repository_impl.dart';
import 'package:gp/core/utils/user_info_helper.dart';
import 'package:gp/features/settings/presentation/pages/update_name_page.dart';
import 'package:gp/features/settings/presentation/pages/update_field_page.dart';
import 'package:gp/features/settings/presentation/pages/update_phone_page.dart';
import 'package:gp/features/settings/presentation/pages/update_dob_page.dart';
import 'package:gp/features/settings/presentation/pages/update_gender_page.dart';
import 'package:gp/l10n/app_localizations.dart';
import 'package:gp/core/utils/snackbar_helper.dart';
import 'package:shimmer/shimmer.dart';

class PersonalInformationPage extends StatefulWidget {
  const PersonalInformationPage({super.key});

  @override
  State<PersonalInformationPage> createState() => _PersonalInformationPageState();
}

class _PersonalInformationPageState extends State<PersonalInformationPage> {
  final _repo = ProfileRepositoryImpl(dio: GetIt.instance<Dio>());

  String name = '';
  String phone = '';
  String email = '';
  String dob = '';
  String gender = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final result = await _repo.getProfile();
    result.fold(
      (err) => setState(() => _loading = false),
      (profile) {
        setState(() {
          name = profile.name;
          phone = profile.phone;
          email = profile.email;
          dob = profile.dateOfBirth;
          gender = profile.gender;
          _loading = false;
        });
      },
    );
  }

  Future<void> _updateName(String firstName, String lastName) async {
    final t = AppLocalizations.of(context)!;
    final fullName = '$firstName $lastName'.trim();
    final result = await _repo.updateName(fullName);
    result.fold(
      (err) => _showSnackbar(err, success: false),
      (_) async {
        await UserInfoHelper.setDisplayName(fullName);
        if (mounted) {
          setState(() => name = fullName);
          _showSnackbar(t.nameUpdatedSuccess);
        }
      },
    );
  }

  Future<void> _updatePhone(String val) async {
    final t = AppLocalizations.of(context)!;
    final result = await _repo.updatePhone(val);
    result.fold(
      (err) => _showSnackbar(err, success: false),
      (_) {
        setState(() => phone = val);
        _showSnackbar(t.phoneUpdatedSuccess);
      },
    );
  }

  Future<void> _updateEmail(String val) async {
    final t = AppLocalizations.of(context)!;
    final result = await _repo.updateEmail(val);
    result.fold(
      (err) => _showSnackbar(err, success: false),
      (_) {
        setState(() => email = val);
        _showSnackbar(t.emailUpdatedSuccess);
      },
    );
  }

  Future<void> _updateDob(String val) async {
    final t = AppLocalizations.of(context)!;
    final result = await _repo.updateDateOfBirth(val);
    result.fold(
      (err) => _showSnackbar(err, success: false),
      (_) {
        setState(() => dob = val);
        _showSnackbar(t.dobUpdatedSuccess);
      },
    );
  }

  Future<void> _updateGender(String val) async {
    final t = AppLocalizations.of(context)!;
    final result = await _repo.updateGender(val);
    result.fold(
      (err) => _showSnackbar(err, success: false),
      (_) {
        setState(() => gender = val);
        _showSnackbar(t.genderUpdatedSuccess);
      },
    );
  }

  void _showSnackbar(String message, {bool success = true}) {
    if (success) {
      showSuccessSnackbar(context, message);
    } else {
      showErrorSnackbar(context, message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: AppColors.primaryDark),
        title: Text(
          t.personalInformationTitle,
          style: const TextStyle(
            color: AppColors.primaryDark,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: _loading ? _buildSkeleton() : _buildContent(t),
    );
  }

  // ── Skeleton ─────────────────────────────────────────────────────────────────

  Widget _buildSkeleton() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Column(
              children: List.generate(5, (i) => _SkeletonTile(isLast: i == 4)),
            ),
          ),
        ),
      ],
    );
  }

  // ── Content ──────────────────────────────────────────────────────────────────

  Widget _buildContent(AppLocalizations t) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _InfoTile(
                icon: Icons.person_outline,
                label: t.nameLabelField,
                value: name,
                isLast: false,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UpdateFieldPage(
                        title: t.updateYourName,
                        subtitle: t.namePersonalizeExp,
                        hint: t.enterNewName,
                        onUpdate: _updateName,
                      ),
                    ),
                  );
                },
              ),
              _InfoTile(
                icon: Icons.phone_outlined,
                label: t.phoneNumberField,
                value: phone,
                isLast: false,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UpdatePhonePage(onUpdate: _updatePhone),
                    ),
                  );
                },
              ),
              _InfoTile(
                icon: Icons.email_outlined,
                label: t.emailField,
                value: email,
                isLast: false,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UpdateEmailPage(onUpdate: _updateEmail),
                    ),
                  );
                },
              ),
              _InfoTile(
                icon: Icons.cake_outlined,
                label: t.dateOfBirthField,
                value: dob,
                isLast: false,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UpdateDobPage(
                        currentDob: dob,
                        onUpdate: _updateDob,
                      ),
                    ),
                  );
                },
              ),
              _InfoTile(
                icon: Icons.wc_outlined,
                label: t.genderField,
                value: gender,
                isLast: true,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UpdateGenderPage(
                        currentGender: gender,
                        onUpdate: _updateGender,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Info tile ────────────────────────────────────────────────────────────────

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;
  final VoidCallback onTap;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: isLast ? const BorderRadius.vertical(bottom: Radius.circular(14)) : BorderRadius.zero,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primaryOrange, size: 22),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        value.isNotEmpty ? value : '—',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        if (!isLast) const Divider(height: 1, indent: 52, endIndent: 16),
      ],
    );
  }
}

// ─── Skeleton tile ────────────────────────────────────────────────────────────

class _SkeletonTile extends StatelessWidget {
  final bool isLast;
  const _SkeletonTile({required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 70,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 140,
                      height: 13,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast) Container(height: 1, color: Colors.white),
      ],
    );
  }
}

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:gp/features/settings/data/repositories/profile_repository_impl.dart';
import 'package:gp/features/settings/presentation/pages/update_field_page.dart';
import 'package:gp/features/settings/presentation/pages/update_phone_page.dart';
import 'package:gp/features/settings/presentation/pages/update_dob_page.dart';
import 'package:gp/features/settings/presentation/pages/update_gender_page.dart';
import 'package:gp/l10n/app_localizations.dart';

class PersonalInformationPage extends StatefulWidget {
  const PersonalInformationPage({super.key});

  @override
  State<PersonalInformationPage> createState() =>
      _PersonalInformationPageState();
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

  Future<void> _updateName(String val) async {
    final t = AppLocalizations.of(context)!;
    final result = await _repo.updateName(val);
    result.fold(
      (err) => _showSnackbar(err, success: false),
      (_) {
        setState(() => name = val);
        _showSnackbar(t.nameUpdatedSuccess);
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left,
                  color: Color(0xFF062B4D), size: 28),
              onPressed: () => Navigator.pop(context),
            ),
            Center(
              child: Text(
                t.personalInformationTitle,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF062B4D),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Divider(thickness: 1),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      children: [
                        _InfoTile(
                          label: t.nameLabelField,
                          value: name,
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
                          label: t.phoneNumberField,
                          value: phone,
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => UpdatePhonePage(
                                  onUpdate: _updatePhone,
                                ),
                              ),
                            );
                          },
                        ),
                        _InfoTile(
                          label: t.emailField,
                          value: email,
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => UpdateFieldPage(
                                  title: t.updateYourEmail,
                                  subtitle: t.emailVerificationMsg,
                                  hint: t.enterNewEmail,
                                  onUpdate: _updateEmail,
                                ),
                              ),
                            );
                          },
                        ),
                        _InfoTile(
                          label: t.dateOfBirthField,
                          value: dob,
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
                          label: t.genderField,
                          value: gender,
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
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _InfoTile({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF062B4D))),
                      const SizedBox(height: 4),
                      Text(value,
                          style: const TextStyle(
                              fontSize: 13, color: Colors.grey)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right,
                    color: Color(0xFF062B4D), size: 22),
              ],
            ),
          ),
        ),
        const Divider(height: 1, thickness: 1),
      ],
    );
  }
}
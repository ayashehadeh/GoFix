import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:gp/core/constants/app_colors.dart';
import 'package:gp/core/utils/professional_nav_mixin.dart';
import 'package:gp/core/widgets/gofix_bottom_nav_bar.dart';
import 'package:gp/features/become_professional/domain/entities/application_status_entity.dart';
import 'package:gp/features/become_professional/domain/usecases/get_application_status.dart';
import 'package:gp/features/become_professional/presentation/pages/in_queue_page.dart';
import 'package:gp/features/become_professional/presentation/pages/stepper_screen.dart';
import 'package:gp/features/settings/presentation/pages/personal_information_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gp/injection_container.dart' as di;
import 'package:gp/l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:gp/core/utils/user_info_helper.dart';

// Notifications
import 'package:gp/features/settings/presentation/bloc/notification_settings_bloc.dart';
import 'package:gp/features/settings/presentation/pages/notification_settings_screen.dart';
import 'package:gp/features/settings/domain/usecases/get_notification_settings_usecase.dart';
import 'package:gp/features/settings/domain/usecases/update_notification_settings_usecase.dart';
import 'package:gp/features/settings/data/repositories/notification_settings_repository_impl.dart';
import 'package:gp/features/settings/data/datasources/notification_settings_remote_datasource.dart';

// Set Password
import 'package:gp/features/settings/presentation/bloc/set_password_bloc.dart';
import 'package:gp/features/settings/presentation/pages/verify_current_password_screen.dart';

// Addresses
import 'package:gp/features/settings/presentation/bloc/address_bloc.dart';
import 'package:gp/features/settings/presentation/pages/addresses_screen.dart';
import 'package:gp/features/settings/domain/usecases/address_usecases.dart';
import 'package:gp/features/settings/data/repositories/address_repository_impl.dart';
import 'package:gp/features/settings/data/datasources/address_remote_datasource.dart';

// Account
import 'package:gp/features/settings/presentation/bloc/account_bloc.dart';
import 'package:gp/features/settings/domain/usecases/account_usecases.dart';
import 'package:gp/features/settings/data/repositories/account_repository_impl.dart';
import 'package:gp/features/settings/data/datasources/account_remote_datasource.dart';

// Auth + Locale
import 'package:gp/features/auth/presentation/pages/start_page.dart';
import 'package:gp/core/bloc/locale_bloc.dart';

final _dio = GetIt.instance<Dio>();

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with ProfessionalNavMixin<ProfilePage> {
  String _userName = '';
  @override
  void initState() {
    super.initState();
    loadProfessionalStatus();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    // ADD THIS METHOD
    final name = await UserInfoHelper.getFullName();
    if (mounted) setState(() => _userName = name);
  }

  AccountBloc _createAccountBloc() => AccountBloc(
        logout: LogoutUseCase(
          AccountRepositoryImpl(AccountRemoteDataSourceImpl(dio: _dio)),
        ),
        deleteAccount: DeleteAccountUseCase(
          AccountRepositoryImpl(AccountRemoteDataSourceImpl(dio: _dio)),
        ),
        sendFeedback: SendFeedbackUseCase(
          AccountRepositoryImpl(AccountRemoteDataSourceImpl(dio: _dio)),
        ),
      );

  void _navigateToStart(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const StartPage()),
      (route) => false,
    );
  }

  // ─── Help & Support ───────────────────────────────────────────────────────

  void _showHelpSupport(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              t.helpTitle,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 16),
            _faqItem(t.faq1Q, t.faq1A),
            _faqItem(t.faq2Q, t.faq2A),
            _faqItem(t.faq3Q, t.faq3A),
            _faqItem(t.faq4Q, t.faq4A),
            const SizedBox(height: 12),
            Text(
              t.contactUs,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: const [
                Icon(Icons.email_outlined, color: AppColors.primaryOrange, size: 18),
                SizedBox(width: 8),
                Text('support@gofix.com', style: TextStyle(color: AppColors.primaryDark)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: const [
                Icon(Icons.phone_outlined, color: AppColors.primaryOrange, size: 18),
                SizedBox(width: 8),
                Text('+962 79 000 0000', style: TextStyle(color: AppColors.primaryDark)),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _openBecomeProfessional(BuildContext context) async {
    final navigator = Navigator.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: AppColors.primaryOrange),
      ),
    );

    final result = await di.sl<GetApplicationStatus>()();

    if (!mounted) return;
    navigator.pop();

    result.fold(
      (_) {
        navigator.push(
          MaterialPageRoute(builder: (_) => const StepperScreen()),
        );
      },
      (status) {
        if (status.status == ProfessionalStatus.draft) {
          navigator.push(
            MaterialPageRoute(builder: (_) => const StepperScreen()),
          );
        } else {
          navigator.push(
            MaterialPageRoute(builder: (_) => const InQueuePage()),
          );
        }
      },
    );
  }

  Widget _faqItem(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primaryDark)),
          const SizedBox(height: 4),
          Text(answer, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        ],
      ),
    );
  }

  // ─── Send Feedback ────────────────────────────────────────────────────────

  void _showSendFeedback(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    int selectedStars = 4;
    final feedbackCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => BlocProvider(
        create: (_) => _createAccountBloc(),
        child: StatefulBuilder(
          builder: (context, setState) => BlocConsumer<AccountBloc, AccountState>(
            listener: (context, state) {
              if (state is FeedbackSuccess) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(t.thankYouFeedback),
                    backgroundColor: AppColors.primaryOrange,
                  ),
                );
              }
              if (state is AccountError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            builder: (context, state) {
              final isLoading = state is AccountLoading;
              return Padding(
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 24,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(t.rateExperience,
                        style:
                            const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                    const SizedBox(height: 4),
                    Text(t.feedbackHelps, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return GestureDetector(
                          onTap: () => setState(() => selectedStars = index + 1),
                          child: Icon(
                            index < selectedStars ? Icons.star : Icons.star_border,
                            color: AppColors.primaryOrange,
                            size: 36,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: feedbackCtrl,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: t.shareFeedback,
                        hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                context.read<AccountBloc>().add(
                                      SendFeedbackEvent(
                                        stars: selectedStars,
                                        message: feedbackCtrl.text.trim(),
                                      ),
                                    );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryOrange,
                          disabledBackgroundColor: AppColors.primaryOrange.withOpacity(0.6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          elevation: 0,
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                              )
                            : Text(t.submit,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ─── Delete Account ───────────────────────────────────────────────────────

  void _showDeleteAccount(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => BlocProvider(
        create: (_) => _createAccountBloc(),
        child: BlocConsumer<AccountBloc, AccountState>(
          listener: (context, state) {
            if (state is DeleteAccountSuccess) {
              Navigator.pop(context);
              _navigateToStart(context);
            }
            if (state is AccountError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is AccountLoading;
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                  ),
                  const SizedBox(height: 24),
                  Text(t.deleteAccountTitle,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                  const SizedBox(height: 8),
                  Text(t.deleteAccountMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : () => context.read<AccountBloc>().add(const DeleteAccountEvent()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryOrange,
                        disabledBackgroundColor: AppColors.primaryOrange.withOpacity(0.6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        elevation: 0,
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                          : Text(t.yesDelete,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: Text(t.noKeep,
                          style:
                              const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ─── Language Selector ────────────────────────────────────────────────────

  void _showLanguageSelector(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final localeBloc = context.read<LocaleBloc>();
    final currentLocale = localeBloc.state.locale;
    String selected = currentLocale.languageCode == 'ar' ? 'Arabic' : 'English';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 24),
              Text(t.selectLanguage,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
              const SizedBox(height: 4),
              Text(t.chooseLanguage, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 24),
              Row(
                children: ['English', 'Arabic'].map((lang) {
                  final isSelected = selected == lang;
                  final label = lang == 'English' ? t.english : t.arabic;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => selected = lang),
                      child: Container(
                        margin: EdgeInsets.only(
                          right: lang == 'English' ? 8 : 0,
                          left: lang == 'Arabic' ? 8 : 0,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primaryOrange : Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: isSelected ? AppColors.primaryOrange : Colors.grey[300]!,
                          ),
                        ),
                        child: Text(
                          label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppColors.primaryDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    final locale = selected == 'Arabic' ? const Locale('ar') : const Locale('en');
                    localeBloc.add(ChangeLocaleEvent(locale));
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryOrange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 0,
                  ),
                  child: Text(t.done,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Log Out ──────────────────────────────────────────────────────────────

  void _showLogOut(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => BlocProvider(
        create: (_) => _createAccountBloc(),
        child: BlocConsumer<AccountBloc, AccountState>(
          listener: (context, state) {
            if (state is LogoutSuccess) {
              Navigator.pop(context);
              _navigateToStart(context);
            }
            if (state is AccountError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is AccountLoading;
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                  ),
                  const SizedBox(height: 24),
                  Text(t.logOutTitle,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                  const SizedBox(height: 8),
                  Text(t.logOutMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : () => context.read<AccountBloc>().add(const LogoutEvent()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryOrange,
                        disabledBackgroundColor: AppColors.primaryOrange.withOpacity(0.6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        elevation: 0,
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                          : Text(t.logOut,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: Text(t.cancel,
                          style:
                              const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  Widget _menuItem(
    BuildContext context,
    IconData icon,
    String text, {
    String? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF062B4D)),
            const SizedBox(width: 15),
            Text(text, style: const TextStyle(fontSize: 16, color: Color(0xFF062B4D))),
            const Spacer(),
            trailing != null
                ? Text(trailing, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF062B4D)))
                : const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF062B4D)),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF062B4D)),
      ),
    );
  }

  String _currentLocaleLabel() {
    final code = context.read<LocaleBloc>().state.locale.languageCode;
    return code == 'ar' ? 'AR' : 'EN';
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleBloc, LocaleState>(
      builder: (context, localeState) {
        final t = AppLocalizations.of(context)!;
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _userName.isNotEmpty ? _userName : '...',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF062B4D),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Divider(),
                      _sectionTitle(t.yourAccount),
                      _menuItem(context, Icons.person, t.personalInformation,
                          onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const PersonalInformationPage()),
                              )),
                      _menuItem(context, Icons.notifications, t.notifications,
                          onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BlocProvider(
                                    create: (_) => NotificationSettingsBloc(
                                      getNotificationSettings: GetNotificationSettingsUseCase(
                                        NotificationSettingsRepositoryImpl(
                                          NotificationSettingsRemoteDataSourceImpl(dio: _dio),
                                        ),
                                      ),
                                      updateNotificationSettings: UpdateNotificationSettingsUseCase(
                                        NotificationSettingsRepositoryImpl(
                                          NotificationSettingsRemoteDataSourceImpl(dio: _dio),
                                        ),
                                      ),
                                    )..add(const GetNotificationSettingsEvent()),
                                    child: const NotificationSettingsScreen(),
                                  ),
                                ),
                              )),
                      _menuItem(context, Icons.key, t.password,
                          onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BlocProvider(
                                    create: (_) => di.sl<SetPasswordBloc>(),
                                    child: const VerifyCurrentPasswordScreen(),
                                  ),
                                ),
                              )),
                      _menuItem(context, Icons.location_on, t.yourAddresses,
                          onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BlocProvider(
                                    create: (_) {
                                      final addressRepo = AddressRepositoryImpl(
                                        AddressRemoteDataSourceImpl(dio: _dio),
                                      );
                                      return AddressBloc(
                                        getAddresses: GetAddressesUseCase(addressRepo),
                                        addAddress: AddAddressUseCase(addressRepo),
                                        updateAddress: UpdateAddressUseCase(addressRepo),
                                        deleteAddress: DeleteAddressUseCase(addressRepo),
                                      )..add(const GetAddressesEvent());
                                    },
                                    child: const AddressesScreen(),
                                  ),
                                ),
                              )),
                      _menuItem(context, Icons.cancel, t.deleteAccount, onTap: () => _showDeleteAccount(context)),
                      _menuItem(context, Icons.logout, t.logOut, onTap: () => _showLogOut(context)),
                      const Divider(),
                      _sectionTitle(t.support),
                      _menuItem(context, Icons.help_outline, t.helpAndSupport, onTap: () => _showHelpSupport(context)),
                      _menuItem(context, Icons.build, t.becomeAProfessional,
                          onTap: () => _openBecomeProfessional(context)),
                      _menuItem(context, Icons.feedback, t.sendFeedback, onTap: () => _showSendFeedback(context)),
                      const Divider(),
                      _sectionTitle(t.preferences),
                      _menuItem(context, Icons.language, t.language,
                          trailing: _currentLocaleLabel(), onTap: () => _showLanguageSelector(context)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          bottomNavigationBar: GoFixBottomNavBar(
            currentIndex: 2,
            showDashboard: isProfessional,
            onTap: (index) {
              if (index == 0) Navigator.pushReplacementNamed(context, '/home');
              if (index == 1) Navigator.pushReplacementNamed(context, '/bookings');
              if (index == 2) return;
              if (index == 3) Navigator.pushReplacementNamed(context, '/dashboard');
            },
          ),
        );
      },
    );
  }
}

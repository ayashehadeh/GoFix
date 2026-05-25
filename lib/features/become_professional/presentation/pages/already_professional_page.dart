import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/datasources/become_professional_remote_datasource.dart';
import '../../data/repositories/become_professional_repository_impl.dart';
import '../../domain/usecases/cancel_professional.dart';

class AlreadyProfessionalPage extends StatefulWidget {
  const AlreadyProfessionalPage({super.key});

  @override
  State<AlreadyProfessionalPage> createState() => _AlreadyProfessionalPageState();
}

class _AlreadyProfessionalPageState extends State<AlreadyProfessionalPage> {
  final _cancelUseCase = CancelProfessionalUseCase(
    BecomeProfessionalRepositoryImpl(
      remoteDataSource: BecomeProfessionalRemoteDataSourceImpl(
        dio: GetIt.instance<Dio>(),
      ),
    ),
  );

  bool _isLoading = false;

  void _showCancelConfirmation() {
    final t = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
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
            const SizedBox(height: 24),
            const Icon(Icons.warning_amber_rounded, color: AppColors.primaryOrange, size: 48),
            const SizedBox(height: 16),
            Text(
              t.cancelProfessionalTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              t.cancelProfessionalMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _confirmCancel,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOrange,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 0,
                ),
                child: Text(
                  t.cancelProfessionalConfirm,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
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
                child: Text(
                  t.noKeep,
                  style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmCancel() async {
    Navigator.pop(context); // close bottom sheet
    setState(() => _isLoading = true);

    final result = await _cancelUseCase();

    if (!mounted) return;
    setState(() => _isLoading = false);

    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message), backgroundColor: AppColors.error),
      ),
      (_) => Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 48),
              SvgPicture.asset('assets/approved_balloons.svg', height: 220),
              const SizedBox(height: 32),
              Text(
                t.alreadyProfessionalTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                t.alreadyProfessionalMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.7,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryOrange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: Text(
                    t.done,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primaryOrange))
                    : OutlinedButton(
                        onPressed: _showCancelConfirmation,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryOrange,
                          side: const BorderSide(color: AppColors.primaryOrange, width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text(
                          t.cancelProfessionalButton,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                      ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

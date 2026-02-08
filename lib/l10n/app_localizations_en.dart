// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get hello => 'Hello';

  @override
  String get startSubtitle => 'Let’s build something great together!';

  @override
  String get signIn => 'Sign In';

  @override
  String get signUp => 'Sign Up';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get quickSignIn => 'Just a quick sign-in and you\'re all set';

  @override
  String get enterPhone => 'Enter your phone number';

  @override
  String get phoneHint => '07xxxxxxxx';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get rememberMe => 'Remember me';

  @override
  String get forgotPassword => 'Forget password?';

  @override
  String get newMember => 'New Member?';

  @override
  String get registerNow => 'Register now';

  @override
  String get firstName => 'First Name';

  @override
  String get lastName => 'Last Name';

  @override
  String get enterEmail => 'Enter your email';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get signInSmall => ' Sign in';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get resetPasswordDesc =>
      'Enter the email associated with your account and we’ll send you an email with instructions to reset your password.';

  @override
  String get sendInstructions => 'Send Instructions';

  @override
  String get setNewPassword => 'Set New Password';

  @override
  String get newPassword => 'New Password';

  @override
  String get createStrongPassword => 'Create a strong and unique password.';

  @override
  String get passwordEmpty => 'Password cannot be empty';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

  @override
  String get confirmPasswordRequired => 'Please confirm your password';

  @override
  String get passwordNotMatch => 'Passwords do not match';

  @override
  String get accountCreated => 'Account Created!';

  @override
  String get welcomeToApp => 'Welcome to GoFix..';

  @override
  String get accountCreatedLine1 => 'Your account has been created';

  @override
  String get successfully => 'Successfully!';

  @override
  String get continue1 => 'Continue';

  @override
  String get verifyEmail => 'Verify your E-Mail';

  @override
  String get verifyEmailDesc =>
      'Enter the confirmation code we sent to your email.';

  @override
  String get didNotReceiveCode => 'Didn\'t receive the code?';

  @override
  String get sendAgain => 'Send Again';

  @override
  String get checkYourMail => 'Check Your Mail';

  @override
  String get checkMailDesc =>
      'We have sent you a password recover instructions to your email.';

  @override
  String get checkSpam => 'Did not receive the email? Check your spam filter.';

  @override
  String get passwordChanged => 'Password Changed!';

  @override
  String get noHassle => 'No hassle anymore.';

  @override
  String get passwordResetLine => 'Your password has been reset';
}

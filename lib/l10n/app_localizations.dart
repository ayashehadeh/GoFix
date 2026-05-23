import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get hello;

  /// No description provided for @startSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Let\'s build something great together!'**
  String get startSubtitle;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @quickSignIn.
  ///
  /// In en, this message translates to:
  /// **'Just a quick sign-in and you\'re all set'**
  String get quickSignIn;

  /// No description provided for @enterPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get enterPhone;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'07xxxxxxxx'**
  String get phoneHint;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get rememberMe;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forget password?'**
  String get forgotPassword;

  /// No description provided for @newMember.
  ///
  /// In en, this message translates to:
  /// **'New Member?'**
  String get newMember;

  /// No description provided for @registerNow.
  ///
  /// In en, this message translates to:
  /// **'Register now'**
  String get registerNow;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterEmail;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @signInSmall.
  ///
  /// In en, this message translates to:
  /// **' Sign in'**
  String get signInSmall;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @resetPasswordDesc.
  ///
  /// In en, this message translates to:
  /// **'Enter the email associated with your account and we\'ll send you an email with instructions to reset your password.'**
  String get resetPasswordDesc;

  /// No description provided for @sendInstructions.
  ///
  /// In en, this message translates to:
  /// **'Send Instructions'**
  String get sendInstructions;

  /// No description provided for @setNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Set New Password'**
  String get setNewPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @createStrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Create a strong and unique password.'**
  String get createStrongPassword;

  /// No description provided for @passwordEmpty.
  ///
  /// In en, this message translates to:
  /// **'Password cannot be empty'**
  String get passwordEmpty;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShort;

  /// No description provided for @confirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get confirmPasswordRequired;

  /// No description provided for @passwordNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordNotMatch;

  /// No description provided for @accountCreated.
  ///
  /// In en, this message translates to:
  /// **'Account Created!'**
  String get accountCreated;

  /// No description provided for @welcomeToApp.
  ///
  /// In en, this message translates to:
  /// **'Welcome to GoFix..'**
  String get welcomeToApp;

  /// No description provided for @accountCreatedLine1.
  ///
  /// In en, this message translates to:
  /// **'Your account has been created'**
  String get accountCreatedLine1;

  /// No description provided for @successfully.
  ///
  /// In en, this message translates to:
  /// **'Successfully!'**
  String get successfully;

  /// No description provided for @continue1.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continue1;

  /// No description provided for @verifyEmail.
  ///
  /// In en, this message translates to:
  /// **'Verify your E-Mail'**
  String get verifyEmail;

  /// No description provided for @verifyEmailDesc.
  ///
  /// In en, this message translates to:
  /// **'Enter the confirmation code we sent to your email.'**
  String get verifyEmailDesc;

  /// No description provided for @didNotReceiveCode.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive the code?'**
  String get didNotReceiveCode;

  /// No description provided for @sendAgain.
  ///
  /// In en, this message translates to:
  /// **'Send Again'**
  String get sendAgain;

  /// No description provided for @checkYourMail.
  ///
  /// In en, this message translates to:
  /// **'Check Your Mail'**
  String get checkYourMail;

  /// No description provided for @checkMailDesc.
  ///
  /// In en, this message translates to:
  /// **'We have sent you a password recover instructions to your email.'**
  String get checkMailDesc;

  /// No description provided for @checkSpam.
  ///
  /// In en, this message translates to:
  /// **'Did not receive the email? Check your spam filter.'**
  String get checkSpam;

  /// No description provided for @passwordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password Changed!'**
  String get passwordChanged;

  /// No description provided for @noHassle.
  ///
  /// In en, this message translates to:
  /// **'No hassle anymore.'**
  String get noHassle;

  /// No description provided for @passwordResetLine.
  ///
  /// In en, this message translates to:
  /// **'Your password has been reset'**
  String get passwordResetLine;

  /// No description provided for @yourAccount.
  ///
  /// In en, this message translates to:
  /// **'Your account'**
  String get yourAccount;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal information'**
  String get personalInformation;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @yourAddresses.
  ///
  /// In en, this message translates to:
  /// **'Your addresses'**
  String get yourAddresses;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccount;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logOut;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @helpAndSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpAndSupport;

  /// No description provided for @becomeAProfessional.
  ///
  /// In en, this message translates to:
  /// **'Become a professional'**
  String get becomeAProfessional;

  /// No description provided for @sendFeedback.
  ///
  /// In en, this message translates to:
  /// **'Send Feedback'**
  String get sendFeedback;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred language'**
  String get chooseLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @logOutTitle.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOutTitle;

  /// No description provided for @logOutMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out from your account?'**
  String get logOutMessage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? This action cannot be undone.'**
  String get deleteAccountMessage;

  /// No description provided for @yesDelete.
  ///
  /// In en, this message translates to:
  /// **'Yes, Delete Account'**
  String get yesDelete;

  /// No description provided for @noKeep.
  ///
  /// In en, this message translates to:
  /// **'No, Keep Account'**
  String get noKeep;

  /// No description provided for @rateExperience.
  ///
  /// In en, this message translates to:
  /// **'Rate Your Experience'**
  String get rateExperience;

  /// No description provided for @feedbackHelps.
  ///
  /// In en, this message translates to:
  /// **'Your feedback helps us improve'**
  String get feedbackHelps;

  /// No description provided for @shareFeedback.
  ///
  /// In en, this message translates to:
  /// **'Share your thoughts about the app.'**
  String get shareFeedback;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @thankYouFeedback.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your feedback!'**
  String get thankYouFeedback;

  /// No description provided for @helpTitle.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpTitle;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @faq1Q.
  ///
  /// In en, this message translates to:
  /// **'How do I book a service?'**
  String get faq1Q;

  /// No description provided for @faq1A.
  ///
  /// In en, this message translates to:
  /// **'Go to the home screen, select a category, choose a professional and tap Book Now.'**
  String get faq1A;

  /// No description provided for @faq2Q.
  ///
  /// In en, this message translates to:
  /// **'How do I cancel a booking?'**
  String get faq2Q;

  /// No description provided for @faq2A.
  ///
  /// In en, this message translates to:
  /// **'Go to your bookings, select the booking and tap Cancel.'**
  String get faq2A;

  /// No description provided for @faq3Q.
  ///
  /// In en, this message translates to:
  /// **'How do I contact a professional?'**
  String get faq3Q;

  /// No description provided for @faq3A.
  ///
  /// In en, this message translates to:
  /// **'After booking, you can message the professional directly from the booking details.'**
  String get faq3A;

  /// No description provided for @faq4Q.
  ///
  /// In en, this message translates to:
  /// **'How do I report an issue?'**
  String get faq4Q;

  /// No description provided for @faq4A.
  ///
  /// In en, this message translates to:
  /// **'Go to Help & Support and tap Send Feedback to report any issues.'**
  String get faq4A;

  /// No description provided for @myBookings.
  ///
  /// In en, this message translates to:
  /// **'My Bookings'**
  String get myBookings;

  /// No description provided for @upcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// No description provided for @past.
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get past;

  /// No description provided for @noUpcomingBookings.
  ///
  /// In en, this message translates to:
  /// **'No upcoming bookings'**
  String get noUpcomingBookings;

  /// No description provided for @noPastBookings.
  ///
  /// In en, this message translates to:
  /// **'No past bookings yet'**
  String get noPastBookings;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @bookService.
  ///
  /// In en, this message translates to:
  /// **'Book Service'**
  String get bookService;

  /// No description provided for @bookingDetails.
  ///
  /// In en, this message translates to:
  /// **'Booking Details'**
  String get bookingDetails;

  /// No description provided for @cancelBooking.
  ///
  /// In en, this message translates to:
  /// **'Cancel Booking'**
  String get cancelBooking;

  /// No description provided for @modifyBooking.
  ///
  /// In en, this message translates to:
  /// **'Modify Booking'**
  String get modifyBooking;

  /// No description provided for @confirmPayment.
  ///
  /// In en, this message translates to:
  /// **'Confirm Payment'**
  String get confirmPayment;

  /// No description provided for @paymentConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Payment Confirmed'**
  String get paymentConfirmed;

  /// No description provided for @writeReview.
  ///
  /// In en, this message translates to:
  /// **'Write a Review'**
  String get writeReview;

  /// No description provided for @submitReport.
  ///
  /// In en, this message translates to:
  /// **'Submit Report'**
  String get submitReport;

  /// No description provided for @bookingCancelled.
  ///
  /// In en, this message translates to:
  /// **'Booking cancelled successfully'**
  String get bookingCancelled;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusAccepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get statusAccepted;

  /// No description provided for @statusOnTheWay.
  ///
  /// In en, this message translates to:
  /// **'On The Way'**
  String get statusOnTheWay;

  /// No description provided for @statusArrived.
  ///
  /// In en, this message translates to:
  /// **'Arrived'**
  String get statusArrived;

  /// No description provided for @statusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get statusInProgress;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @statusDeclined.
  ///
  /// In en, this message translates to:
  /// **'Declined'**
  String get statusDeclined;

  /// No description provided for @selectService.
  ///
  /// In en, this message translates to:
  /// **'Select a Service'**
  String get selectService;

  /// No description provided for @scheduledDate.
  ///
  /// In en, this message translates to:
  /// **'Scheduled Date'**
  String get scheduledDate;

  /// No description provided for @scheduledTime.
  ///
  /// In en, this message translates to:
  /// **'Scheduled Time'**
  String get scheduledTime;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @bookingSuccess.
  ///
  /// In en, this message translates to:
  /// **'Booking Successful!'**
  String get bookingSuccess;

  /// No description provided for @modifySuccess.
  ///
  /// In en, this message translates to:
  /// **'Booking Modified Successfully!'**
  String get modifySuccess;

  /// No description provided for @allChats.
  ///
  /// In en, this message translates to:
  /// **'All chats'**
  String get allChats;

  /// No description provided for @searchChats.
  ///
  /// In en, this message translates to:
  /// **'Search chats...'**
  String get searchChats;

  /// No description provided for @noChatsYet.
  ///
  /// In en, this message translates to:
  /// **'No chats yet'**
  String get noChatsYet;

  /// No description provided for @noChatsFound.
  ///
  /// In en, this message translates to:
  /// **'No chats found'**
  String get noChatsFound;

  /// No description provided for @deleteChat.
  ///
  /// In en, this message translates to:
  /// **'Delete chat'**
  String get deleteChat;

  /// No description provided for @deleteChatTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete chat?'**
  String get deleteChatTitle;

  /// No description provided for @deleteChatMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the chat with {name}?'**
  String deleteChatMessage(String name);

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @typeMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get typeMessage;

  /// No description provided for @sendImage.
  ///
  /// In en, this message translates to:
  /// **'Send Image'**
  String get sendImage;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search for a service or professional...'**
  String get searchHint;

  /// No description provided for @recentSearches.
  ///
  /// In en, this message translates to:
  /// **'Recent Searches'**
  String get recentSearches;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResults;

  /// No description provided for @searchResults.
  ///
  /// In en, this message translates to:
  /// **'Search Results'**
  String get searchResults;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotifications;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllRead;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @myJobs.
  ///
  /// In en, this message translates to:
  /// **'My Jobs'**
  String get myJobs;

  /// No description provided for @myEarnings.
  ///
  /// In en, this message translates to:
  /// **'My Earnings'**
  String get myEarnings;

  /// No description provided for @totalRequests.
  ///
  /// In en, this message translates to:
  /// **'Total Requests'**
  String get totalRequests;

  /// No description provided for @scheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get scheduled;

  /// No description provided for @completedJobs.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completedJobs;

  /// No description provided for @jobDetails.
  ///
  /// In en, this message translates to:
  /// **'Job Details'**
  String get jobDetails;

  /// No description provided for @markOnTheWay.
  ///
  /// In en, this message translates to:
  /// **'Mark as On The Way'**
  String get markOnTheWay;

  /// No description provided for @markArrived.
  ///
  /// In en, this message translates to:
  /// **'Mark as Arrived'**
  String get markArrived;

  /// No description provided for @startJob.
  ///
  /// In en, this message translates to:
  /// **'Start Job'**
  String get startJob;

  /// No description provided for @completeJob.
  ///
  /// In en, this message translates to:
  /// **'Complete Job'**
  String get completeJob;

  // ── Filter page ──────────────────────────────────────────────────────────────

  /// No description provided for @applyFilters.
  String get applyFilters;

  /// No description provided for @experienceYears.
  String get experienceYears;

  /// No description provided for @maximumDistance.
  String get maximumDistance;

  /// No description provided for @minimumRating.
  String get minimumRating;

  // ── Booking report ───────────────────────────────────────────────────────────

  /// No description provided for @bookingInformation.
  String get bookingInformation;

  /// No description provided for @reportAnIssue.
  String get reportAnIssue;

  /// No description provided for @reportHelpText.
  String get reportHelpText;

  /// No description provided for @describeIssue.
  String get describeIssue;

  /// No description provided for @issueTitleHint.
  String get issueTitleHint;

  /// No description provided for @describeIssueError.
  String get describeIssueError;

  /// No description provided for @provideDetails.
  String get provideDetails;

  /// No description provided for @provideDetailsHint.
  String get provideDetailsHint;

  /// No description provided for @provideDetailsError.
  String get provideDetailsError;

  /// No description provided for @reportSubmittedSuccess.
  String get reportSubmittedSuccess;

  // ── Booking review ───────────────────────────────────────────────────────────

  /// No description provided for @howWasService.
  String get howWasService;

  /// No description provided for @writeYourFeedback.
  String get writeYourFeedback;

  /// No description provided for @selectRatingError.
  String get selectRatingError;

  /// No description provided for @submitReview.
  String get submitReview;

  /// No description provided for @reviewSubmittedSuccess.
  String get reviewSubmittedSuccess;

  // ── Addresses ────────────────────────────────────────────────────────────────

  /// No description provided for @addresses.
  String get addresses;

  /// No description provided for @add.
  String get add;

  /// No description provided for @noAddressesYet.
  String get noAddressesYet;

  // ── Confirm location ─────────────────────────────────────────────────────────

  /// No description provided for @confirmLocation.
  String get confirmLocation;

  // ── Edit / New address ───────────────────────────────────────────────────────

  /// No description provided for @editAddress.
  String get editAddress;

  /// No description provided for @deleteAddress.
  String get deleteAddress;

  /// No description provided for @deleteAddressConfirm.
  String get deleteAddressConfirm;

  /// No description provided for @newAddress.
  String get newAddress;

  /// No description provided for @saveAddress.
  String get saveAddress;

  /// No description provided for @apartment.
  String get apartment;

  /// No description provided for @house.
  String get house;

  /// No description provided for @area.
  String get area;

  /// No description provided for @buildingName.
  String get buildingName;

  /// No description provided for @apartmentNumber.
  String get apartmentNumber;

  /// No description provided for @floor.
  String get floor;

  /// No description provided for @street.
  String get street;

  /// No description provided for @additionalDirections.
  String get additionalDirections;

  /// No description provided for @required.
  String get required;

  // ── Notification settings ────────────────────────────────────────────────────

  /// No description provided for @notificationSettings.
  String get notificationSettings;

  /// No description provided for @bookingConfirmations.
  String get bookingConfirmations;

  /// No description provided for @bookingConfirmationsDesc.
  String get bookingConfirmationsDesc;

  /// No description provided for @modificationsCancellations.
  String get modificationsCancellations;

  /// No description provided for @modificationsCancellationsDesc.
  String get modificationsCancellationsDesc;

  /// No description provided for @chatMessages.
  String get chatMessages;

  /// No description provided for @chatMessagesDesc.
  String get chatMessagesDesc;

  /// No description provided for @supportComplaints.
  String get supportComplaints;

  /// No description provided for @supportComplaintsDesc.
  String get supportComplaintsDesc;

  /// No description provided for @appFeedback.
  String get appFeedback;

  /// No description provided for @appFeedbackDesc.
  String get appFeedbackDesc;

  // ── Update DOB ───────────────────────────────────────────────────────────────

  /// No description provided for @dateOfBirth.
  String get dateOfBirth;

  /// No description provided for @update.
  String get update;

  /// No description provided for @monthJanuary.
  String get monthJanuary;

  /// No description provided for @monthFebruary.
  String get monthFebruary;

  /// No description provided for @monthMarch.
  String get monthMarch;

  /// No description provided for @monthApril.
  String get monthApril;

  /// No description provided for @monthMay.
  String get monthMay;

  /// No description provided for @monthJune.
  String get monthJune;

  /// No description provided for @monthJuly.
  String get monthJuly;

  /// No description provided for @monthAugust.
  String get monthAugust;

  /// No description provided for @monthSeptember.
  String get monthSeptember;

  /// No description provided for @monthOctober.
  String get monthOctober;

  /// No description provided for @monthNovember.
  String get monthNovember;

  /// No description provided for @monthDecember.
  String get monthDecember;

  // ── Update gender ────────────────────────────────────────────────────────────

  /// No description provided for @gender.
  String get gender;

  /// No description provided for @genderMale.
  String get genderMale;

  /// No description provided for @genderFemale.
  String get genderFemale;

  // ── Update phone ─────────────────────────────────────────────────────────────

  /// No description provided for @updateYourMobileNumber.
  String get updateYourMobileNumber;

  /// No description provided for @weWillSendCode.
  String get weWillSendCode;

  /// No description provided for @phoneNumberRequired.
  String get phoneNumberRequired;

  /// No description provided for @mustBe9Digits.
  String get mustBe9Digits;

  // ── Personal information ─────────────────────────────────────────────────────

  /// No description provided for @personalInformationTitle.
  String get personalInformationTitle;

  /// No description provided for @nameLabelField.
  String get nameLabelField;

  /// No description provided for @phoneNumberField.
  String get phoneNumberField;

  /// No description provided for @emailField.
  String get emailField;

  /// No description provided for @dateOfBirthField.
  String get dateOfBirthField;

  /// No description provided for @genderField.
  String get genderField;

  /// No description provided for @updateYourName.
  String get updateYourName;

  /// No description provided for @namePersonalizeExp.
  String get namePersonalizeExp;

  /// No description provided for @enterNewName.
  String get enterNewName;

  /// No description provided for @updateYourEmail.
  String get updateYourEmail;

  /// No description provided for @emailVerificationMsg.
  String get emailVerificationMsg;

  /// No description provided for @enterNewEmail.
  String get enterNewEmail;

  /// No description provided for @nameUpdatedSuccess.
  String get nameUpdatedSuccess;

  /// No description provided for @phoneUpdatedSuccess.
  String get phoneUpdatedSuccess;

  /// No description provided for @emailUpdatedSuccess.
  String get emailUpdatedSuccess;

  /// No description provided for @dobUpdatedSuccess.
  String get dobUpdatedSuccess;

  /// No description provided for @genderUpdatedSuccess.
  String get genderUpdatedSuccess;

  // ── Become professional ──────────────────────────────────────────────────────

  /// No description provided for @uploadProfilePicture.
  String get uploadProfilePicture;

  /// No description provided for @tapToChoosePhoto.
  String get tapToChoosePhoto;

  /// No description provided for @photoFormatLimit.
  String get photoFormatLimit;

  /// No description provided for @changePhoto.
  String get changePhoto;

  /// No description provided for @uploadedSuccessfully.
  String get uploadedSuccessfully;

  /// No description provided for @takePhoto.
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  String get chooseFromGallery;

  /// No description provided for @savePhoto.
  String get savePhoto;

  /// No description provided for @pleaseChoosePhotoFirst.
  String get pleaseChoosePhotoFirst;

  /// No description provided for @tapToUpload.
  String get tapToUpload;

  /// No description provided for @inQueueTitle.
  String get inQueueTitle;

  /// No description provided for @inQueueMessage.
  String get inQueueMessage;

  /// No description provided for @checkStatus.
  String get checkStatus;

  /// No description provided for @becomeProfessionalTitle.
  String get becomeProfessionalTitle;

  /// No description provided for @verificationUpload.
  String get verificationUpload;

  /// No description provided for @verificationInstructions.
  String get verificationInstructions;

  /// No description provided for @profilePicture.
  String get profilePicture;

  /// No description provided for @uploadId.
  String get uploadId;

  /// No description provided for @uploadCertification.
  String get uploadCertification;

  /// No description provided for @goodConduct.
  String get goodConduct;

  /// No description provided for @pleaseUploadProfilePicture.
  String get pleaseUploadProfilePicture;

  /// No description provided for @pleaseUploadId.
  String get pleaseUploadId;

  /// No description provided for @submitApplication.
  String get submitApplication;

  /// No description provided for @uploaded.
  String get uploaded;

  /// No description provided for @approved.
  String get approved;

  /// No description provided for @approvedMessage.
  String get approvedMessage;

  /// No description provided for @profileSubmitted.
  String get profileSubmitted;

  /// No description provided for @profileVerifiedSubtitle.
  String get profileVerifiedSubtitle;

  /// No description provided for @identityVerified.
  String get identityVerified;

  /// No description provided for @backgroundCheckPassed.
  String get backgroundCheckPassed;

  /// No description provided for @setMyAvailability.
  String get setMyAvailability;

  /// No description provided for @notApproved.
  String get notApproved;

  /// No description provided for @resubmitDocuments.
  String get resubmitDocuments;

  /// No description provided for @applicationIncomplete.
  String get applicationIncomplete;

  /// No description provided for @incompleteApplicationMsg.
  String get incompleteApplicationMsg;

  /// No description provided for @completeApplication.
  String get completeApplication;

  /// No description provided for @setYourAvailability.
  String get setYourAvailability;

  /// No description provided for @availabilityInstructions.
  String get availabilityInstructions;

  /// No description provided for @workingDays.
  String get workingDays;

  /// No description provided for @workingHours.
  String get workingHours;

  /// No description provided for @save.
  String get save;

  /// No description provided for @selectLabel.
  String get selectLabel;

  /// No description provided for @daySun.
  String get daySun;

  /// No description provided for @dayMon.
  String get dayMon;

  /// No description provided for @dayTue.
  String get dayTue;

  /// No description provided for @dayWed.
  String get dayWed;

  /// No description provided for @dayThu.
  String get dayThu;

  /// No description provided for @dayFri.
  String get dayFri;

  /// No description provided for @daySat.
  String get daySat;

  // ── Booking screens ──────────────────────────────────────────────────────────

  /// No description provided for @bookAService.
  String get bookAService;

  /// No description provided for @chooseDateAndTime.
  String get chooseDateAndTime;

  /// No description provided for @selectPreferredSlot.
  String get selectPreferredSlot;

  /// No description provided for @selectDate.
  String get selectDate;

  /// No description provided for @selectTime.
  String get selectTime;

  /// No description provided for @chooseAddress.
  String get chooseAddress;

  /// No description provided for @enterAddress.
  String get enterAddress;

  /// No description provided for @addressRequired.
  String get addressRequired;

  /// No description provided for @serviceDescription.
  String get serviceDescription;

  /// No description provided for @sendBookingRequest.
  String get sendBookingRequest;

  /// No description provided for @selectServiceToContinue.
  String get selectServiceToContinue;

  /// No description provided for @selectServiceTitle.
  String get selectServiceTitle;

  /// No description provided for @selectServiceSubtitle.
  String get selectServiceSubtitle;

  /// No description provided for @describeServiceNeeded.
  String get describeServiceNeeded;

  /// No description provided for @writeDescription.
  String get writeDescription;

  /// No description provided for @descriptionRequired.
  String get descriptionRequired;

  /// No description provided for @uploadPicture.
  String get uploadPicture;

  /// No description provided for @pictureRequired.
  String get pictureRequired;

  /// No description provided for @monthJan.
  String get monthJan;

  /// No description provided for @monthFeb.
  String get monthFeb;

  /// No description provided for @monthMar.
  String get monthMar;

  /// No description provided for @monthApr.
  String get monthApr;

  /// No description provided for @monthJun.
  String get monthJun;

  /// No description provided for @monthJul.
  String get monthJul;

  /// No description provided for @monthAugShort.
  String get monthAugShort;

  /// No description provided for @monthSep.
  String get monthSep;

  /// No description provided for @monthOct.
  String get monthOct;

  /// No description provided for @monthNov.
  String get monthNov;

  /// No description provided for @monthDec.
  String get monthDec;

  /// No description provided for @dayMonShort.
  String get dayMonShort;

  /// No description provided for @dayTueShort.
  String get dayTueShort;

  /// No description provided for @dayWedShort.
  String get dayWedShort;

  /// No description provided for @dayThuShort.
  String get dayThuShort;

  /// No description provided for @dayFriShort.
  String get dayFriShort;

  /// No description provided for @daySatShort.
  String get daySatShort;

  /// No description provided for @daySunShort.
  String get daySunShort;

  // ── Professionals / Search ───────────────────────────────────────────────────

  /// No description provided for @noProfessionalsFound.
  String get noProfessionalsFound;

  /// No description provided for @allCategories.
  String get allCategories;

  /// No description provided for @noProfessionalsInArea.
  String noProfessionalsInArea(String areaName);

  // ── Favorites ────────────────────────────────────────────────────────────────

  /// No description provided for @favorites.
  String get favorites;

  /// No description provided for @noFavoritesYet.
  String get noFavoritesYet;

  /// No description provided for @yearsExperience.
  String yearsExperience(int years);

  // ── Set new password ─────────────────────────────────────────────────────────

  /// No description provided for @chooseStrongPassword.
  String get chooseStrongPassword;

  /// No description provided for @currentPasswordLabel.
  String get currentPasswordLabel;

  /// No description provided for @pleaseEnterNewPassword.
  String get pleaseEnterNewPassword;

  /// No description provided for @mustBe8Chars.
  String get mustBe8Chars;

  /// No description provided for @addUppercase.
  String get addUppercase;

  /// No description provided for @addLowercase.
  String get addLowercase;

  /// No description provided for @addDigit.
  String get addDigit;

  /// No description provided for @addSpecial.
  String get addSpecial;

  /// No description provided for @savePassword.
  String get savePassword;

  /// No description provided for @passwordChangedSuccess.
  String get passwordChangedSuccess;

  /// No description provided for @strengthWeak.
  String get strengthWeak;

  /// No description provided for @strengthFair.
  String get strengthFair;

  /// No description provided for @strengthGood.
  String get strengthGood;

  /// No description provided for @strengthStrong.
  String get strengthStrong;

  /// No description provided for @strengthVeryStrong.
  String get strengthVeryStrong;

  // ── Verify current password ──────────────────────────────────────────────────

  /// No description provided for @verifyIdentity.
  String get verifyIdentity;

  /// No description provided for @enterCurrentPassword.
  String get enterCurrentPassword;

  /// No description provided for @currentPasswordRequired.
  String get currentPasswordRequired;

  // ── Sign in ──────────────────────────────────────────────────────────────────

  /// No description provided for @emailExampleHint.
  String get emailExampleHint;

  /// No description provided for @enterEmailAndPassword.
  String get enterEmailAndPassword;

  // ── Reset password (resetpass2) ──────────────────────────────────────────────

  /// No description provided for @resetCode.
  String get resetCode;

  /// No description provided for @enterResetCode.
  String get enterResetCode;

  /// No description provided for @resetCodeRequired.
  String get resetCodeRequired;

  // ── Document upload title ────────────────────────────────────────────────────

  /// No description provided for @uploadDoc.
  String uploadDoc(String title);

  // ── Welcome snackbar ─────────────────────────────────────────────────────────

  /// No description provided for @welcomeUser.
  String welcomeUser(String name);

  /// No description provided for @ok.
  String get ok;

  // ── Feedback / Review / Report ───────────────────────────────────────────────
  String get leaveFeedback;
  String get whatWouldYouDo;
  String get writeFeedbackHint;

  // ── Job Request ───────────────────────────────────────────────────────────────
  String get jobInformation;
  String get acceptRequest;
  String get declineRequest;
  String get reasonOptional;
  String get tellCustomerWhy;
  String get requestRejected;
  String get customerNotified;
  String get requestAccepted;
  String get jobAddedToSchedule;
  String get viewMyJobs;

  // ── Dashboard ─────────────────────────────────────────────────────────────────
  String get scheduledJobsTitle;
  String get noScheduledJobsYet;
  String get seeAll;
  String get updateStatus;
  String get incomingRequestsTitle;
  String get noIncomingRequests;
  String get declineLabel;
  String get acceptLabel;
  String get updateJobStatus;
  String get goodMorning;
  String get goodAfternoon;
  String get goodEvening;

  // ── Job Info ──────────────────────────────────────────────────────────────────
  String get jobStatus;
  String get confirmUpdate;
  String picturesAttached(int count);

  // ── Chat ──────────────────────────────────────────────────────────────────────
  String get photo;
  String get camera;
  String get fileLabel;

  // ── Nav bar ───────────────────────────────────────────────────────────────────
  String get navHome;
  String get navBookings;
  String get navProfile;
  String get navDashboard;

  // ── Full day names (for working hours) ───────────────────────────────────────
  String get dayFullSunday;
  String get dayFullMonday;
  String get dayFullTuesday;
  String get dayFullWednesday;
  String get dayFullThursday;
  String get dayFullFriday;
  String get dayFullSaturday;

  // ── Professional detail ───────────────────────────────────────────────────────
  String get tabAbout;
  String get tabServices;
  String get tabReviews;
  String get tabCertifications;
  String get professionalPrefix;
  String get yearsExp;
  String get kmAwayLabel;
  String get ratingLabel;
  String get aboutMe;
  String get serviceAreas;
  String get servicesOffered;
  String get customerReviews;
  String get reviewsLabel;
  String get professionalCertifications;
  String get noBioAdded;
  String get noCertificationsYet;
  String get backgroundSafety;
  String get backgroundCheck;
  String get identityVerifiedLabel;
  String get verifiedLabel;
  String get notVerifiedLabel;
  String get bookNow;
  String get noServicesListedYet;
  String get expYear;
  String get expYears;
  String get kmAwayUnit;
  String get mAwayUnit;

  // ── Booking flow ──────────────────────────────────────────────────────────────
  String get selectAddress;
  String get noSavedAddresses;
  String get loadingAddresses;
  String get tapToSelectAddress;
  String get pleaseSelectYourAddress;
  String get cancelBookingTitle;
  String get cancelBookingWarning;
  String get yesCancelBooking;
  String get keepMyBooking;
  String get bookingUpdatedTitle;
  String get bookingUpdatedMessage;
  String get appreciateTrust;
  String get weveGotItTitle;
  String get bookingRequestPending;
  String get paymentConfirmedMoved;
  String get pictureAttachedSingular;
  String get picturesAttachedPlural;
  String get amLabel;
  String get pmLabel;

  // ── Categories ────────────────────────────────────────────────────────────────
  String get categoryPlumbing;
  String get categoryElectricalWork;
  String get categoryAcRepair;
  String get categoryCarpentry;
  String get categoryPainting;
  String get categoryCleaning;
  String get categoryMovingServices;
  String get categoryApplianceRepair;

  // ── Category descriptions ─────────────────────────────────────────────────────
  String get categoryDescPlumbing;
  String get categoryDescElectricalWork;
  String get categoryDescAcRepair;
  String get categoryDescCarpentry;
  String get categoryDescPainting;
  String get categoryDescCleaning;
  String get categoryDescMovingServices;
  String get categoryDescApplianceRepair;

  // ── Booking status ────────────────────────────────────────────────────────────
  String get statusConfirmed;

  // ── Service names ─────────────────────────────────────────────────────────────
  String get servicePipeInstallation;
  String get serviceLeakRepairs;
  String get serviceWaterHeaterService;
  String get serviceDrainCleaning;
  String get serviceBathroomFixtures;
  String get serviceWiringRepair;
  String get serviceLightFixtureInstallation;
  String get serviceFurnitureAssembly;
  String get serviceDoorRepair;

  // ── Misc ──────────────────────────────────────────────────────────────────────
  String get describeIssuePlaceholder;
  String get myAvailability;
  String get myProfile;
  String get categories;
  String get location;
  String get chooseService;
  String get chooseDateTime;
  String get pleaseSelectService;
  String get pleaseEnterAddress;
  String get availabilitySaved;
  String get pictureAttached;
  String get pleaseEnterEmail;
  String get atLeastOneService;
  String get noServiceAreasAdded;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}

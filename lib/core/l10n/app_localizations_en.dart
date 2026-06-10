// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'AmanGhar';

  @override
  String get appTagline => 'Your home, taken care of';

  @override
  String get splashLoading => 'Loading...';

  @override
  String get loginTitle => 'Welcome to AmanGhar';

  @override
  String get loginSubtitle => 'Find trusted cooks and maids near you';

  @override
  String get loginButton => 'Sign in with Google';

  @override
  String get loginTerms =>
      'By signing in you agree to our Terms & Privacy Policy';

  @override
  String get loginError => 'Sign-in failed. Please try again.';

  @override
  String get loginBannedError =>
      'Your account has been suspended. Contact support.';

  @override
  String get roleSelectionTitle => 'How will you use AmanGhar?';

  @override
  String get roleSelectionSubtitle =>
      'Choose your role. This cannot be changed later.';

  @override
  String get roleHirerTitle => 'I want to hire';

  @override
  String get roleHirerSubtitle => 'Find cooks & maids near you';

  @override
  String get roleProviderTitle => 'I want to work';

  @override
  String get roleProviderSubtitle => 'Offer your services as a cook or maid';

  @override
  String get continueButton => 'Continue';

  @override
  String get profileSetupTitle => 'Set Up Your Profile';

  @override
  String get profileSetupPhotoHint => 'Add a profile photo (optional)';

  @override
  String get profileSetupNameLabel => 'Full Name';

  @override
  String get profileSetupNameHint => 'Enter your full name';

  @override
  String get profileSetupPhoneLabel => 'Phone Number';

  @override
  String get profileSetupPhoneHint => '03XXXXXXXXX';

  @override
  String get profileSetupCityLabel => 'City';

  @override
  String get profileSetupCityHint => 'Select your city';

  @override
  String get profileSetupCompleteButton => 'Complete Profile';

  @override
  String get providerSetupTitle => 'Your Services';

  @override
  String get providerSetupCategoryLabel => 'What services do you offer?';

  @override
  String get providerSetupCookTitle => 'Cook';

  @override
  String get providerSetupMaidTitle => 'Maid / House Help';

  @override
  String get providerSetupSkillsLabel => 'Your Skills';

  @override
  String get providerSetupSkillsHint => 'Select at least one skill';

  @override
  String get providerSetupFullTimeRateLabel => 'Full-Time Rate (PKR/day)';

  @override
  String get providerSetupPartTimeRateLabel => 'Part-Time Rate (PKR/hr)';

  @override
  String get providerSetupExperienceLabel => 'Years of Experience';

  @override
  String get providerSetupLanguagesLabel => 'Languages Spoken';

  @override
  String get providerSetupBioLabel => 'Bio (optional)';

  @override
  String get providerSetupBioHint => 'Tell hirers about yourself...';

  @override
  String get providerSetupGetStartedButton => 'Get Started';

  @override
  String get validationRequired => 'This field is required';

  @override
  String get validationNameMin => 'Name must be at least 2 characters';

  @override
  String get validationNameMax => 'Name must be less than 50 characters';

  @override
  String get validationPhoneFormat =>
      'Enter a valid Pakistani number (03XXXXXXXXX)';

  @override
  String get validationRateMin => 'Rate is too low';

  @override
  String get validationRateMax => 'Rate is too high';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get errorPermissionDenied => 'You don\'t have permission to do this.';

  @override
  String get errorNotFound => 'The requested data was not found.';

  @override
  String get errorNoConnection =>
      'No internet connection. Please check your network.';

  @override
  String get retryButton => 'Retry';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get saveButton => 'Save';

  @override
  String get confirmButton => 'Confirm';

  @override
  String get logoutButton => 'Logout';

  @override
  String get logoutConfirmTitle => 'Logout';

  @override
  String get logoutConfirmMessage => 'Are you sure you want to logout?';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusConfirmed => 'Confirmed';

  @override
  String get statusInProgress => 'In Progress';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get statusRejected => 'Rejected';

  @override
  String get chatsTitle => 'Chats';

  @override
  String get noConversationsYet => 'No conversations yet';

  @override
  String get typeMessageHint => 'Type a message';

  @override
  String sayHiTo(String name) {
    return 'Say hi to $name!';
  }

  @override
  String get notifications => 'Notifications';

  @override
  String get markAllRead => 'Mark all read';

  @override
  String get allCaughtUp => 'You\'re all caught up!';

  @override
  String get justNow => 'Just now';
}

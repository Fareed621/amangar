import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ur.dart';

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
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ur')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'AmanGhar'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Your home, taken care of'**
  String get appTagline;

  /// No description provided for @splashLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get splashLoading;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to AmanGhar'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Find trusted cooks and maids near you'**
  String get loginSubtitle;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get loginButton;

  /// No description provided for @loginTerms.
  ///
  /// In en, this message translates to:
  /// **'By signing in you agree to our Terms & Privacy Policy'**
  String get loginTerms;

  /// No description provided for @loginError.
  ///
  /// In en, this message translates to:
  /// **'Sign-in failed. Please try again.'**
  String get loginError;

  /// No description provided for @loginBannedError.
  ///
  /// In en, this message translates to:
  /// **'Your account has been suspended. Contact support.'**
  String get loginBannedError;

  /// No description provided for @roleSelectionTitle.
  ///
  /// In en, this message translates to:
  /// **'How will you use AmanGhar?'**
  String get roleSelectionTitle;

  /// No description provided for @roleSelectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your role. This cannot be changed later.'**
  String get roleSelectionSubtitle;

  /// No description provided for @roleHirerTitle.
  ///
  /// In en, this message translates to:
  /// **'I want to hire'**
  String get roleHirerTitle;

  /// No description provided for @roleHirerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Find cooks & maids near you'**
  String get roleHirerSubtitle;

  /// No description provided for @roleProviderTitle.
  ///
  /// In en, this message translates to:
  /// **'I want to work'**
  String get roleProviderTitle;

  /// No description provided for @roleProviderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Offer your services as a cook or maid'**
  String get roleProviderSubtitle;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @profileSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Set Up Your Profile'**
  String get profileSetupTitle;

  /// No description provided for @profileSetupPhotoHint.
  ///
  /// In en, this message translates to:
  /// **'Add a profile photo (optional)'**
  String get profileSetupPhotoHint;

  /// No description provided for @profileSetupNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get profileSetupNameLabel;

  /// No description provided for @profileSetupNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get profileSetupNameHint;

  /// No description provided for @profileSetupPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get profileSetupPhoneLabel;

  /// No description provided for @profileSetupPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'03XXXXXXXXX'**
  String get profileSetupPhoneHint;

  /// No description provided for @profileSetupCityLabel.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get profileSetupCityLabel;

  /// No description provided for @profileSetupCityHint.
  ///
  /// In en, this message translates to:
  /// **'Select your city'**
  String get profileSetupCityHint;

  /// No description provided for @profileSetupCompleteButton.
  ///
  /// In en, this message translates to:
  /// **'Complete Profile'**
  String get profileSetupCompleteButton;

  /// No description provided for @providerSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Services'**
  String get providerSetupTitle;

  /// No description provided for @providerSetupCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'What services do you offer?'**
  String get providerSetupCategoryLabel;

  /// No description provided for @providerSetupCookTitle.
  ///
  /// In en, this message translates to:
  /// **'Cook'**
  String get providerSetupCookTitle;

  /// No description provided for @providerSetupMaidTitle.
  ///
  /// In en, this message translates to:
  /// **'Maid / House Help'**
  String get providerSetupMaidTitle;

  /// No description provided for @providerSetupSkillsLabel.
  ///
  /// In en, this message translates to:
  /// **'Your Skills'**
  String get providerSetupSkillsLabel;

  /// No description provided for @providerSetupSkillsHint.
  ///
  /// In en, this message translates to:
  /// **'Select at least one skill'**
  String get providerSetupSkillsHint;

  /// No description provided for @providerSetupFullTimeRateLabel.
  ///
  /// In en, this message translates to:
  /// **'Full-Time Rate (PKR/day)'**
  String get providerSetupFullTimeRateLabel;

  /// No description provided for @providerSetupPartTimeRateLabel.
  ///
  /// In en, this message translates to:
  /// **'Part-Time Rate (PKR/hr)'**
  String get providerSetupPartTimeRateLabel;

  /// No description provided for @providerSetupExperienceLabel.
  ///
  /// In en, this message translates to:
  /// **'Years of Experience'**
  String get providerSetupExperienceLabel;

  /// No description provided for @providerSetupLanguagesLabel.
  ///
  /// In en, this message translates to:
  /// **'Languages Spoken'**
  String get providerSetupLanguagesLabel;

  /// No description provided for @providerSetupBioLabel.
  ///
  /// In en, this message translates to:
  /// **'Bio (optional)'**
  String get providerSetupBioLabel;

  /// No description provided for @providerSetupBioHint.
  ///
  /// In en, this message translates to:
  /// **'Tell hirers about yourself...'**
  String get providerSetupBioHint;

  /// No description provided for @providerSetupGetStartedButton.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get providerSetupGetStartedButton;

  /// No description provided for @validationRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get validationRequired;

  /// No description provided for @validationNameMin.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 2 characters'**
  String get validationNameMin;

  /// No description provided for @validationNameMax.
  ///
  /// In en, this message translates to:
  /// **'Name must be less than 50 characters'**
  String get validationNameMax;

  /// No description provided for @validationPhoneFormat.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid Pakistani number (03XXXXXXXXX)'**
  String get validationPhoneFormat;

  /// No description provided for @validationRateMin.
  ///
  /// In en, this message translates to:
  /// **'Rate is too low'**
  String get validationRateMin;

  /// No description provided for @validationRateMax.
  ///
  /// In en, this message translates to:
  /// **'Rate is too high'**
  String get validationRateMax;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No description provided for @errorPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have permission to do this.'**
  String get errorPermissionDenied;

  /// No description provided for @errorNotFound.
  ///
  /// In en, this message translates to:
  /// **'The requested data was not found.'**
  String get errorNotFound;

  /// No description provided for @errorNoConnection.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Please check your network.'**
  String get errorNoConnection;

  /// No description provided for @retryButton.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryButton;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @saveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveButton;

  /// No description provided for @confirmButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirmButton;

  /// No description provided for @logoutButton.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutButton;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirmMessage;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get statusConfirmed;

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

  /// No description provided for @statusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get statusRejected;

  /// No description provided for @chatsTitle.
  ///
  /// In en, this message translates to:
  /// **'Chats'**
  String get chatsTitle;

  /// No description provided for @noConversationsYet.
  ///
  /// In en, this message translates to:
  /// **'No conversations yet'**
  String get noConversationsYet;

  /// No description provided for @typeMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Type a message'**
  String get typeMessageHint;

  /// No description provided for @sayHiTo.
  ///
  /// In en, this message translates to:
  /// **'Say hi to {name}!'**
  String sayHiTo(String name);

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get markAllRead;

  /// No description provided for @allCaughtUp.
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up!'**
  String get allCaughtUp;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ur'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ur':
      return AppLocalizationsUr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}

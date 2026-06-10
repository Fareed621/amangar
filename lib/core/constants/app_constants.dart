// lib/core/constants/app_constants.dart
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/animation.dart';

/// Spacing constants using ScreenUtil — must be called after ScreenUtil.init()
class AppSpacing {
  AppSpacing._();
  static double get xs  => 4.w;
  static double get sm  => 8.w;
  static double get md  => 16.w;
  static double get lg  => 24.w;
  static double get xl  => 32.w;
  static double get xxl => 48.w;
}

/// Border radius constants using ScreenUtil
class AppRadius {
  AppRadius._();
  static double get sm   => 6.r;
  static double get md   => 10.r;
  static double get lg   => 12.r;
  static double get xl   => 16.r;
  static double get xxl  => 24.r;
  static double get full => 100.r;
}

/// Animation duration constants
class AppDurations {
  AppDurations._();
  static const instant       = Duration(milliseconds: 100);
  static const fast          = Duration(milliseconds: 200);
  static const normal        = Duration(milliseconds: 300);
  static const slow          = Duration(milliseconds: 500);
  static const pageTransition= Duration(milliseconds: 250);
  static const skeleton      = Duration(milliseconds: 1500);
}

/// Animation curve constants
class AppCurves {
  AppCurves._();
  static const standard   = Curves.easeInOut;
  static const enter      = Curves.easeOut;
  static const exit       = Curves.easeIn;
  static const spring     = Curves.elasticOut;
  static const decelerate = Curves.decelerate;
}

/// Business rule limits — mirrors Firestore schema and backend limits
class AppLimits {
  AppLimits._();
  static const int    maxFavorites              = 10;
  static const int    maxPortfolioPhotos         = 10;
  static const double maxPhotoSizeMB             = 2.0;
  static const int    maxBookingDates            = 31;
  static const int    maxNameLength              = 50;
  static const int    minNameLength              = 2;
  static const int    maxBioLength               = 500;
  static const int    maxBookingNotesLength      = 200;
  static const int    maxChatMessageLength       = 1000;
  static const int    maxRatingCommentLength     = 300;
  static const int    maxReportDetailsLength     = 500;
  static const int    maxSupportDescriptionLength= 2000;
  static const int    minFullTimeRate            = 5000;
  static const int    maxFullTimeRate            = 100000;
  static const int    minPartTimeRate            = 100;
  static const int    maxPartTimeRate            = 2000;
  static const int    minWithdrawalAmount        = 500;
  static const int    maxWithdrawalAmount        = 100000;
  static const int    searchDebounceMs           = 300;
  static const int    searchMinChars             = 2;
  static const int    chatPaginationLimit        = 50;
  static const int    listPaginationLimit        = 10;
}
